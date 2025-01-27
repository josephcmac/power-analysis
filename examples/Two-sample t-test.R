source("../R/power_analysis.R")

data_alt_two_sample <- function(
    sample_size,
    mean_diff = 0,   # Difference in means (Group2 - Group1)
    sd        = 1,   # Standard deviation in both groups
    seed      = NULL
) {
  # Optionally set the seed for reproducibility
  if (!is.null(seed)) set.seed(seed)
  
  # Group 1: Mean = 0,   SD = sd
  # Group 2: Mean = mean_diff, SD = sd
  x <- rnorm(sample_size, mean = 0,         sd = sd)
  y <- rnorm(sample_size, mean = mean_diff, sd = sd)
  
  data.frame(group1 = x, group2 = y)
}

p_val_two_sample <- function(dataset) {
  test_out <- t.test(dataset$group1, dataset$group2, var.equal = TRUE)
  test_out$p.value
}

# Example usage: find sample size to achieve 80% power
# for a two-sample t-test (mean_diff = 1, sd = 2).

res_two_sample <- binary_search(
  data_alt_fun = function(sample_size, seed = NULL) {
    data_alt_two_sample(
      sample_size = sample_size,
      mean_diff   = 1,
      sd          = 2,
      seed        = seed
    )
  },
  power_analysis_fun = power_analysis,
  sample_size_min    = 4,       # lower bound to start searching
  sample_size_max    = 300,     # upper bound
  power_threshold    = 0.80,    # desired power
  n_samples          = 100000,   # number of Monte Carlo simulations per power calc
  alpha_level        = 0.05,    # significance level (two-sided)
  p_val_fun          = p_val_two_sample
)

print(res_two_sample)

