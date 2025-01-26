#' @title Estimate Statistical Power via Monte Carlo Simulation
#'
#' @description 
#' This function estimates the power of a statistical test by repeatedly
#' generating data under the alternative hypothesis and computing the p-value.
#'
#' @param sample_size Integer. Sample size for the simulated dataset.
#' @param data_alt_fun A function that generates synthetic data under the alternative.
#'   Must accept arguments \code{sample_size} and \code{seed}.
#' @param p_val_fun A function that computes the p-value from a dataset 
#'   (for example, from a fitted model).
#' @param n_samples Integer. Number of Monte Carlo replications.
#' @param alpha_level Numeric. Significance level for the test, default is 0.05.
#'
#' @return A numeric value representing the estimated power, i.e. the proportion 
#'   of times the null hypothesis was rejected (p-value < \code{alpha_level}).
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' res <- power_analysis(
#'   sample_size   = 30,
#'   data_alt_fun  = data_alt_fun,
#'   p_val_fun     = p_val_fun,
#'   n_samples     = 1000,
#'   alpha_level   = 0.05
#' )
#' }
#'
#' @export
power_analysis <- function(sample_size,
                           data_alt_fun,
                           p_val_fun,
                           n_samples   = 1000,
                           alpha_level = 0.05) {
  #--- Input Validation ---#
  stopifnot(
    is.numeric(sample_size), length(sample_size) == 1L, sample_size > 0,
    is.function(data_alt_fun),
    is.function(p_val_fun),
    is.numeric(n_samples), length(n_samples) == 1L, n_samples > 0,
    is.numeric(alpha_level), length(alpha_level) == 1L,
    alpha_level > 0, alpha_level < 1
  )
  
  #--- Monte Carlo simulation ---#
  p_values <- vapply(
    X = seq_len(n_samples),
    FUN = function(i) {
      set.seed(i)
      data_sim <- data_alt_fun(sample_size = sample_size)
      p_val_fun(data_sim)
    },
    FUN.VALUE = numeric(1L)
  )
  
  
  #--- Compute empirical power ---#
  mean(p_values < alpha_level)
}


#' @title Binary Search for Minimum Sample Size
#'
#' @description
#' Performs a binary search over sample sizes to find the smallest sample size
#' for which the statistical power meets or exceeds the specified threshold.
#'
#' @param data_alt_fun A function that generates synthetic data under the alternative.
#' @param power_analysis_fun The function that estimates the statistical power (default: \code{power_analysis}).
#' @param sample_size_min Integer. Lower bound of the search range for sample size.
#' @param sample_size_max Integer. Upper bound of the search range for sample size.
#' @param power_threshold Numeric. The power threshold to meet or exceed (e.g., 0.8).
#' @param n_samples Integer. Number of Monte Carlo simulations per power calculation (default: 5000).
#' @param alpha_level Numeric. Significance level for the test (default: 0.05).
#' @param p_val_fun A function that computes the p-value from a dataset (e.g., \code{p_val_fun}).
#'
#' @return A data.frame with two columns:
#'   \code{power} (the estimated power) and 
#'   \code{sample_size} (the smallest sample size achieving that power).
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' res <- binary_search(
#'   data_alt_fun     = data_alt_fun,
#'   sample_size_min  = 4,
#'   sample_size_max  = 500,
#'   power_threshold  = 0.8,
#'   n_samples        = 5000,
#'   alpha_level      = 0.05,
#'   p_val_fun        = p_val_fun
#' )
#' print(res)
#' }
#'
#' @export
binary_search <- function(data_alt_fun,
                          power_analysis_fun = power_analysis,
                          sample_size_min,
                          sample_size_max,
                          power_threshold = 0.8,
                          n_samples = 5000,
                          alpha_level = 0.05,
                          p_val_fun) {
  #--- Input Validation ---#
  stopifnot(
    is.function(data_alt_fun),
    is.function(power_analysis_fun),
    is.numeric(sample_size_min), length(sample_size_min) == 1L, sample_size_min > 0,
    is.numeric(sample_size_max), length(sample_size_max) == 1L, sample_size_max >= sample_size_min,
    is.numeric(power_threshold), length(power_threshold) == 1L, power_threshold > 0, power_threshold < 1,
    is.numeric(n_samples), length(n_samples) == 1L, n_samples > 0,
    is.numeric(alpha_level), length(alpha_level) == 1L, alpha_level > 0, alpha_level < 1,
    is.function(p_val_fun)
  )
  
  # A small environment-based cache for power values
  power_cache <- new.env(parent = emptyenv())
  
  # Helper function that returns cached power if available,
  # otherwise computes it, stores it, and returns it
  get_power <- function(ss) {
    ss_char <- as.character(ss)
    if (exists(ss_char, envir = power_cache)) {
      return(get(ss_char, envir = power_cache))
    }
    pwr <- power_analysis_fun(
      sample_size   = ss,
      data_alt_fun  = data_alt_fun,
      p_val_fun     = p_val_fun,
      n_samples     = n_samples,
      alpha_level   = alpha_level
    )
    assign(ss_char, pwr, envir = power_cache)
    pwr
  }
  
  #-- 1) Quick checks at boundaries --
  power_min <- get_power(sample_size_min)
  if (power_min >= power_threshold) {
    return(data.frame(power = power_min, sample_size = sample_size_min))
  }
  
  power_max <- get_power(sample_size_max)
  if (power_max < power_threshold) {
    warning("Threshold not reached, even at sample_size_max.")
    return(data.frame(power = power_max, sample_size = sample_size_max))
  }
  
  #-- 2) Binary search loop --
  low  <- sample_size_min
  high <- sample_size_max
  
  while (low < high) {
    mid       <- floor((low + high) / 2)
    power_mid <- get_power(mid)
    
    if (power_mid >= power_threshold) {
      high <- mid
    } else {
      low <- mid + 1
    }
  }
  
  final_power <- get_power(low)
  data.frame(power = final_power, sample_size = low)
}


