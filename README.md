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
2. **P-Value Function** (`p_val_fun`), which should take the simulated data and compute the relevant p-value.

These functions will then be used within `power_analysis()` to estimate the power for your model/test, and can be combined with `binary_search()` to find the sample size needed to attain a specific power.

---

## Repository Contents

- **`R/power_analysis.R`**:
  Contains the `power_analysis()` and `binary_search()` functions.
- **Example Scripts**:
  - **`example_paired_ttest.R`**: Demonstrates how to do a power analysis for a paired t-test scenario.
  - **`example_two_sample_ttest.R`**: Demonstrates power analysis for a two-sample t-test.
  - **`example_wilcoxon.R`**: Shows how to handle the Wilcoxon–Mann–Whitney test with a desired \(\text{Pr}(X>Y)\).

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

The output from `binary_search()` is a data frame with:

- **`power`**: the estimated power at the found sample size
- **`sample_size`**: the smallest sample size per group needed to achieve that power

---

## Advanced Prompt for Generating Your Own Data and P-Value Functions

If you need a **custom** statistical model, you can use the following **highly detailed** prompt to instruct ChatGPT (or another LLM) to generate your `data_alt_fun` and `p_val_fun`. 

### Prompt Title: "Generate R Functions for Power Analysis Pipeline"

**System / Role Instructions:**
- You are ChatGPT, a top-tier data scientist and statistician with expertise in R, statistical modeling, and power analysis.
- Your goal is to produce high-quality R code that precisely meets the user’s specifications.
- You will strictly follow the user instructions below.

---

**User Instructions:**

1. **Context**: I have a statistical model described as follows:

   - **Model Description**:  
     <PUT YOUR MODEL SPECIFICATION HERE — e.g., "Two independent normal distributions with different means and a common standard deviation" or "A logistic regression model with certain coefficients">

   - **Alternative Hypothesis**:  
     <DESCRIBE THE ALTERNATIVE — e.g., a specific difference in means, a certain effect size, or a parametric form you assume under H1.>

   - **Parameters**:  
     <LIST ALL RELEVANT PARAMETERS — e.g., mean_diff, sd, correlation, slope, intercept, etc. — that you want to pass into the function.>

2. **Required Functions**: I need two R functions that will be compatible with an existing power-analysis framework. The framework calls:
   - `data_alt_fun(sample_size, seed, <OTHER PARAMETERS>)`
   - `p_val_fun(dataset)`

   **Important**: 
   - The function **`data_alt_fun`** must:
     - Accept `sample_size` (integer).
     - Accept `seed` (integer or NULL).
     - Accept any other relevant model parameters needed for data generation under the alternative.
     - Internally set the random seed if `seed` is provided (e.g., `if (!is.null(seed)) set.seed(seed)`).
     - Generate a dataset representing one replicate under the alternative hypothesis.
     - Return that dataset in a format suitable for subsequent analysis (preferably a data frame with informative column names).

   - The function **`p_val_fun`** must:
     - Accept the dataset returned by `data_alt_fun`.
     - Perform the appropriate statistical test that corresponds to the model specification (e.g., `t.test`, `wilcox.test`, a likelihood ratio test, etc.).
     - Return only the p-value of that test as a numeric value (i.e., a single numeric).

3. **Formatting and Documentation**:
   - Provide each function in its own R code block.
   - At the top of each function’s code block, add a short comment describing what it does and how it relates to the statistical model.
   - Include inline comments or docstrings as needed so that the code is self-explanatory.

4. **Output Requirements**:
   - Do not wrap these functions inside any other function; they should be standalone.
   - Ensure the function signatures exactly match the required forms:
     ```r
     data_alt_fun <- function(sample_size, seed = NULL, ...)
     p_val_fun <- function(dataset)
     ```
   - Replace `...` with any specific parameter names you need.
   - The code must run on standard R installations without additional packages (unless absolutely required for your model, in which case you must specify those packages clearly).

5. **Example Usage** (just an illustration):  
   
   ```r
   # Example usage after your code is defined:
   set.seed(123)
   my_data <- data_alt_fun(sample_size = 30, seed = 1, mean_diff = 2, sd = 1)
   my_p    <- p_val_fun(my_data)
   my_p
   ```

6. **Final Instructions**:
   - Present only the two functions (`data_alt_fun` and `p_val_fun`) and brief explanatory text. 
   - Stop after showing these two code blocks; do not add extra commentary or call the functions.
   - If relevant, mention which R package(s) might be required (e.g., `MASS` for multivariate normal), but keep dependencies minimal.

**End of User Instructions.**

Using this **advanced prompt**, you can precisely instruct ChatGPT to produce the `data_alt_fun` and `p_val_fun` functions for your custom model. Once you have them, you can integrate them into your power analysis pipeline.

---

## Contributing

Contributions and suggestions are welcome! If you have a new example or a general improvement, feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

This improved version enhances readability with clear sectioning, concise instructions, and consistent formatting.
