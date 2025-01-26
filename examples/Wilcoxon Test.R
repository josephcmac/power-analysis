#----------------------------------------------------------
# 1) Source the existing power-analysis framework.
#    (Adjust the file path as necessary.)
#----------------------------------------------------------
source("../R/power_analysis.R")

#----------------------------------------------------------
# 2) Define the data-generating function for WMW scenarios.
#    We want P(X > Y) = 0.76 under the alternative.
#----------------------------------------------------------
data_alt_wilcoxon <- function(
    sample_size,
    p_gt = 0.76,   # Target probability P(X > Y)
    seed = NULL
) {
  if (!is.null(seed)) set.seed(seed)
  
  # X ~ Normal(0, 1), Y ~ Normal(d, 1),
  # with d chosen so that P(X > Y) = 0.76.
  # 
  # If X ~ N(0, 1), Y ~ N(d, 1) => X - Y ~ N(-d, 2).
  # P(X - Y > 0) = p_gt => 0 is the (1 - p_gt)-quantile => d = sqrt(2)*qnorm(p_gt).
  d <- sqrt(2) * qnorm(p_gt)
  
  X <- rnorm(sample_size, mean = 0, sd = 1)
  Y <- rnorm(sample_size, mean = d, sd = 1)
  
  data.frame(X = X, Y = Y)
}
#----------------------------------------------------------
# 3) Define the p-value function for the two-sample
#    Wilcoxon (Mann–Whitney) test, two-sided.
#----------------------------------------------------------
p_val_wilcoxon <- function(dataset) {
  w_out <- wilcox.test(x = dataset$X, y = dataset$Y, alternative = "two.sided", exact=TRUE)
  w_out$p.value
}

#----------------------------------------------------------
# 4) Run the binary search to find minimum sample size
#    that achieves 80% power at alpha = 0.05.
#    Note: This assumes 'power_analysis' and 'binary_search'
#    are provided by the sourced file above.
#----------------------------------------------------------
res_wmw <- binary_search(
  data_alt_fun      = function(sample_size, seed = NULL) {
    data_alt_wilcoxon(
      sample_size = sample_size,
      p_gt        = 0.76,       # We want P(X > Y) = 0.76
      seed        = seed
    )
  },
  power_analysis_fun = power_analysis,
  sample_size_min    = 4,
  sample_size_max    = 50,
  power_threshold    = 0.80,    # desired power
  n_samples          = 100000,   # Monte Carlo reps
  alpha_level        = 0.05,    # two-sided alpha
  p_val_fun          = p_val_wilcoxon
)

#----------------------------------------------------------
# 5) Print the results
#----------------------------------------------------------
print(res_wmw)
