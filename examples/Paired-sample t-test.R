source("../R/power_analysis.R")  # adjust path as needed

data_alt_paired <- function(
    sample_size,
    # Option A: Direct difference
    mean_diff   = NULL,
    sd_diff     = NULL,
    
    # Option B: separate means, sds, correlation
    mean_x      = 0,
    mean_y      = NULL,
    sd_x        = 1,
    sd_y        = 1,
    correlation = 0,
    
    seed        = NULL
) {
  if (!is.null(seed)) set.seed(seed)
  
  # A) Direct difference
  if (!is.null(mean_diff) && !is.null(sd_diff)) {
    X <- rep(0, sample_size)
    Y <- X + rnorm(sample_size, mean = mean_diff, sd = sd_diff)
    return(data.frame(X = X, Y = Y))
  }
  
  # B) Bivariate normal
  if (is.null(mean_y) && !is.null(mean_diff)) {
    mean_y <- mean_x + mean_diff
  } else if (is.null(mean_y)) {
    mean_y <- mean_x
  }
  
  cov_xy <- correlation * sd_x * sd_y
  cov_mat <- matrix(c(sd_x^2, cov_xy,
                      cov_xy,  sd_y^2),
                    nrow = 2, byrow = TRUE)
  mean_vec <- c(mean_x, mean_y)
  
  X_Y <- MASS::mvrnorm(n = sample_size, mu = mean_vec, Sigma = cov_mat)
  data.frame(X = X_Y[,1], Y = X_Y[,2])
}

p_val_paired <- function(dataset) {
  test_out <- t.test(dataset$X, dataset$Y, paired = TRUE)
  test_out$p.value
}

# Example call
res1 <- binary_search(
  data_alt_fun = function(sample_size, seed = NULL) {
    data_alt_paired(
      sample_size = sample_size,
      mean_diff   = 1,
      sd_diff     = 2,
      seed        = seed
    )
  },
  power_analysis_fun = power_analysis,
  sample_size_min    = 4,
  sample_size_max    = 300,
  power_threshold    = 0.80,
  n_samples          = 100000,
  alpha_level        = 0.05,
  p_val_fun          = p_val_paired
)

print(res1)
