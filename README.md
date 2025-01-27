# Power Analysis in R for Custom Hypotheses

This repository contains a framework for performing power analysis in R, including:

- **`power_analysis.R`**: A file with two functions:
  1. `power_analysis()`: Estimates power via Monte Carlo simulation.
  2. `binary_search()`: Finds the minimum sample size to achieve a desired power.
- **Example Scripts** for specific scenarios:
  - Paired t-test
  - Two-sample t-test
  - Wilcoxon Mann–Whitney test
  - …and more

---

## Overview

The goal of this project is to provide a **flexible and extensible** way to compute the statistical power of a given test or model. You can plug in your own:

1. **Data Generating Function** (`data_alt_fun`), which should simulate data under the alternative hypothesis.
2. **P-Value Function** (`p_val_fun`), which should take the simulated data and compute the p-value that the data corresponds to the null hypothesis.

These functions will then be used within `power_analysis()` to estimate the power for your model/test, and can be combined with `binary_search()` to find the sample size needed to attain a specific power.

---

## Repository Contents

- **`R/power_analysis.R`**:
  Contains the `power_analysis()` and `binary_search()` functions.
- **Example Scripts**:
  - **`example_paired_ttest.R`**: Demonstrates how to do a power analysis for a paired t-test scenario.
  - **`example_two_sample_ttest.R`**: Demonstrates power analysis for a two-sample t-test.
  - **`example_wilcoxon.R`**: Shows how to handle the Wilcoxon–Mann–Whitney test with a desired Pr(X>Y).

---

## Usage

1. **Clone or download** this repository.
2. **Open R or RStudio** in the project directory.
3. **Source** the file `power_analysis.R`:
   ```r
   source("R/power_analysis.R")
   ```
4. **Define** your own `data_alt_fun` and `p_val_fun` or use the ones in the examples.
5. **Call** either `power_analysis()` directly or use `binary_search()` to find the smallest sample size for the desired power.

---

## Example: Two-sample t-test.R 
```r
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
```

The output from `binary_search()` is a data frame with:

- **`power`**: the estimated power at the found sample size
- **`sample_size`**: the smallest sample size per group needed to achieve that power

---

## Contributing

Contributions and suggestions are welcome! If you have a new example or a general improvement, feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

