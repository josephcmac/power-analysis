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

## Overview

The goal of this project is to provide a **flexible and extensible** way to compute the statistical power of a given test or model. You can plug in your own:

1. **Data Generating Function** (`data_alt_fun`), which should simulate data under the alternative hypothesis.
2. **P-Value Function** (`p_val_fun`), which should take the simulated data and compute the relevant p-value.

These functions will then be used within `power_analysis()` to estimate the power for your model/test, and can be combined with `binary_search()` to find the sample size needed to attain a specific power threshold.

## Repository Contents

- **`R/power_analysis.R`**: Contains the `power_analysis()` and `binary_search()` functions.  
- **Example Scripts**:
  - **`example_paired_ttest.R`**: Demonstrates how to do a power analysis for a paired t-test scenario.
  - **`example_two_sample_ttest.R`**: Demonstrates power analysis for a two-sample t-test.
  - **`example_wilcoxon.R`**: Shows how to handle the Wilcoxon–Mann–Whitney test with a desired \(\text{Pr}(X>Y)\).

## Usage

1. **Clone or download** this repository.
2. **Open R or RStudio** in the project directory.
3. **Source** the file `power_analysis.R`:
   ```r
   source("R/power_analysis.R")
   ```
4. **Define** your own `data_alt_fun` and `p_val_fun` or use the ones in the examples.
5. **Call** either `power_analysis()` directly or use `binary_search()` to find the smallest sample size for the desired power.

## Example: Wilcoxon Mann–Whitney

```r
# Example usage for Wilcoxon with P(X>Y) = 0.76
source("R/power_analysis.R")  # loads power_analysis() and binary_search()

# Suppose we define data_alt_wilcoxon() and p_val_wilcoxon() in example_wilcoxon.R
source("examples/example_wilcoxon.R")

res_wmw <- binary_search(
  data_alt_fun      = function(sample_size, seed = NULL) {
    data_alt_wilcoxon(
      sample_size = sample_size,
      p_gt        = 0.76,
      seed        = seed
    )
  },
  power_analysis_fun = power_analysis,
  sample_size_min    = 4,
  sample_size_max    = 500,
  power_threshold    = 0.80,
  n_samples          = 10000,
  alpha_level        = 0.05,
  p_val_fun          = p_val_wilcoxon
)

print(res_wmw)
```

## Prompt for Generating Your Own Data and P-Value Functions

If you need a **custom** statistical model, you can use ChatGPT (or a similar Large Language Model) to generate tailored R functions. Below is a generic prompt you can copy, paste, and adapt for ChatGPT:

---

> **Prompt**  
>  
> I have a statistical model described as follows:  
>  
> **\<MODEL SPECIFICATION HERE\>**  
>  
> I want you to write two R functions in code blocks:  
>  
> 1. A function named `data_alt_fun` that takes:  
>    - `sample_size` (integer, the number of observations to generate),  
>    - `seed` (integer or NULL for reproducibility),  
>    - **any other relevant parameters** for this model, e.g. `<PARAMETERS>`.  
>  
>    This function should set the seed if provided (e.g., `if (!is.null(seed)) set.seed(seed)`) and then generate random data **under the alternative hypothesis** of the specified model. It should return a data frame (or list) containing all relevant columns for subsequent analysis.  
>  
> 2. A function named `p_val_fun` that accepts a dataset (the output from `data_alt_fun`) and returns the **p-value** from an appropriate statistical test. For example, if it is a two-sample scenario, you might use `t.test()`, `wilcox.test()`, or a custom likelihood ratio test—whatever is appropriate for **\<MODEL SPECIFICATION\>**.  
>  
> Please provide the R code for both functions, clearly labeled, and include brief explanations where needed. Make sure both functions line up with the **\<MODEL SPECIFICATION\>** and **\<PARAMETERS\>** I’ve described and that they’ll be compatible with a typical power-analysis routine expecting `data_alt_fun(sample_size, seed, ...)` and `p_val_fun(dataset)`.

---

**Note**: Replace **\<MODEL SPECIFICATION\>** and **\<PARAMETERS\>** with the actual details of your analysis (e.g., distributions, means, variances, correlation structures, etc.). ChatGPT will then produce custom R code for your scenario, which you can incorporate into your power analysis pipeline.

## Contributing

Contributions and suggestions are welcome! If you have a new example or general improvement, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
