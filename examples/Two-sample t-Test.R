#############################################################################
# two_sample_t_test_example.R
#
# Demonstration of a *generalized* two-sample t-test power analysis
# using your previously defined power_analysis() and binary_search().
#############################################################################

# 1) Load existing code for power analysis
source("../R/power_analysis.R")  # Adjust path if needed

#############################################################################
# data_alt_2sample()
#
# A generalized data generator for a two-sample t-test scenario. Allows:
#   (A) Direct specification of mean difference + single SD (equal SDs),
#   (B) Separate means and separate SDs for each group,
#   (C) Control of group allocation ratio (if you want unequal n1 / n2).
#
# Note: The function receives a single `sample_size` from power_analysis(),
#       which we interpret as the *total* sample size. We then split into
#       two groups, possibly by an allocation ratio.
#############################################################################

data_alt_2sample <- function(
    sample_size,
    # Option A: Direct difference (group1 mean=0, group2 mean=mean_diff, same sd)
    mean_diff       = NULL,  # e.g. 1
    sd_common       = NULL,  # e.g. 2
    
    # Option B: Explicit means and sds for each group
    mean1           = 0,
    mean2           = NULL,  # if mean_diff is provided, we can auto-set mean2 = mean1 + mean_diff
    sd1             = 1,
    sd2             = 1,
    
    # Allocation ratio
    ratio_n1n2      = 1,     # e.g. 1 => equal n; 2 => n1 is 2x n2, etc.
    
    # Misc
    seed            = NULL
) {
  # If a seed is provided, use it for reproducibility
  if (!is.null(seed)) set.seed(seed)
  
  # Decide group sizes from total sample_size and ratio
  # If ratio_n1n2=1, we get equal group sizes. If ratio=2, group1 is twice group2, etc.
  n1 <- floor(sample_size * ratio_n1n2 / (ratio_n1n2 + 1))
  n2 <- sample_size - n1
  
  #---------------------------------------------
  # A) If mean_diff and sd_common are specified, generate data with:
  #    group1 ~ N(0, sd_common^2)
  #    group2 ~ N(mean_diff, sd_common^2)
  #---------------------------------------------
  if (!is.null(mean_diff) && !is.null(sd_common)) {
    group1 <- rnorm(n1, mean = 0,         sd = sd_common)
    group2 <- rnorm(n2, mean = mean_diff, sd = sd_common)
    return(
      data.frame(
        value = c(group1, group2),
        group = rep(c("g1","g2"), times = c(n1, n2))
      )
    )
  }
  
  #---------------------------------------------
  # B) Otherwise, use separate means, separate SDs
  #    If mean2 is not explicitly given but mean_diff is, define it
  #---------------------------------------------
  if (!is.null(mean_diff) && is.null(mean2)) {
    mean2 <- mean1 + mean_diff
  } else if (is.null(mean2)) {
    # default if absolutely nothing was given
    mean2 <- mean1
  }
  
  group1 <- rnorm(n1, mean = mean1, sd = sd1)
  group2 <- rnorm(n2, mean = mean2, sd = sd2)
  
  data.frame(
    value = c(group1, group2),
    group = rep(c("g1","g2"), times = c(n1, n2))
  )
}

#############################################################################
# p_val_2sample()
#
# A function that runs a two-sample t-test on (value ~ group), returning the
# p-value. We allow toggling equal vs. unequal variances (var.equal=TRUE/FALSE).
#############################################################################
p_val_2sample <- function(dataset, var_equal = FALSE) {
  # 'dataset' has columns 'value' and 'group'
  t_result <- t.test(value ~ group, data = dataset, var.equal = var_equal)
  t_result$p.value
}

#############################################################################
# EXAMPLES:
#
# Below we show two ways to call binary_search() with different parameter sets.
#############################################################################


#############################################################################
# Example 1: 
#   - Direct difference approach => group1 mean=0, group2 mean=1, both sd=2
#   - Balanced allocation ratio = 1 ( => n1=n2)
#   - Equal variances => var_equal=TRUE in p_val_2sample
#############################################################################
res1 <- binary_search(
  data_alt_fun = function(sample_size, seed = NULL) {
    data_alt_2sample(
      sample_size   = sample_size,
      mean_diff     = 1,      # group2 minus group1
      sd_common     = 2,
      ratio_n1n2    = 1,
      seed          = seed
    )
  },
  power_analysis_fun = power_analysis,
  sample_size_min    = 4,
  sample_size_max    = 300,
  power_threshold    = 0.80,
  n_samples          = 10000,            # Monte Carlo reps
  alpha_level        = 0.05,
  p_val_fun          = function(df) p_val_2sample(df, var_equal = TRUE)
)

cat("Example 1 result:\n")
print(res1)


#############################################################################
# Example 2:
#   - Separate means & separate SDs => group1 ~ N(0, 2^2), group2 ~ N(2, 3^2)
#   - Unequal allocation ratio: ratio_n1n2=2  ( => n1 ~ 2/3 of total, n2 ~ 1/3 )
#   - Welch test => var.equal=FALSE
#############################################################################
res2 <- binary_search(
  data_alt_fun = function(sample_size, seed = NULL) {
    data_alt_2sample(
      sample_size   = sample_size,
      mean1         = 0,       # group1
      mean2         = 2,       # group2
      sd1           = 2,
      sd2           = 3,
      ratio_n1n2    = 2,       # group1 is double group2
      seed          = seed
    )
  },
  power_analysis_fun = power_analysis,
  sample_size_min    = 10,
  sample_size_max    = 500,
  power_threshold    = 0.80,
  n_samples          = 10000,
  alpha_level        = 0.05,
  p_val_fun          = function(df) p_val_2sample(df, var_equal = FALSE)
)

cat("Example 2 result:\n")
print(res2)

#############################################################################
# End of script
#############################################################################
