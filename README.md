# Blog Post 8: Simulation, Bootstrap Confidence Intervals, and Hypothesis Testing

## 1. Project Overview

This project uses Monte Carlo simulation and bootstrap resampling to illustrate how statistical inference works. Rather than relying on an external dataset, the analysis generates synthetic observations from a known normal population, allowing us to compare statistical estimates with the true population parameter.

The project addresses three main research questions:

1. How can bootstrap resampling be used to construct a confidence interval for an unknown population mean?
2. Does a nominal 95% bootstrap confidence interval contain the true population mean approximately 95% of the time across repeated independent samples?
3. How can simulated null distributions help explain hypothesis testing, rejection regions, p-values, and Type I errors?

The analysis combines reproducible R simulations, static visualizations created with `ggplot2`, and an interactive browser-based bootstrap demonstration using JavaScript and Plotly.

## 2. Data Source and Generation

All observations are synthetically generated using R's built-in `rnorm()` function. No external dataset, API, or manual data collection is required.

The population is defined as:

\[
X_i \sim N(\mu = 50,\sigma^2 = 100)
\]

where:

- Population mean: \(\mu = 50\)
- Population standard deviation: \(\sigma = 10\)
- Initial sample size: \(n = 100\)
- Random seed: `6408`

Because the true population parameters are known, the simulations allow us to evaluate whether confidence intervals successfully cover the true mean and whether hypothesis tests maintain their intended significance level.

The original sample is saved in `data-raw/initial_sample.csv`, while the analysis-ready copy is stored in `data/analysis_sample.csv`.

All additional datasets are generated programmatically by the analysis scripts.

## 3. Repository Structure

```text
Blog8/
├── code/
│   ├── 01_generate_data.R
│   ├── 02_bootstrap_ci.R
│   ├── 03_coverage_simulation.R
│   ├── 04_hypothesis_testing.R
│   └── 05_interactive_simulation.js
│
├── data-raw/
│   └── initial_sample.csv
│
├── data/
│   ├── analysis_sample.csv
│   ├── bootstrap_means.csv
│   ├── coverage_simulation.csv
│   └── null_distribution.csv
│
├── results/
│   ├── figures/
│   │   ├── figure1_sample_distribution.png
│   │   ├── figure2_bootstrap_distribution.png
│   │   ├── figure3_bootstrap_ci.png
│   │   ├── figure4_ci_coverage.png
│   │   ├── figure5_cumulative_coverage.png
│   │   ├── figure6_null_distribution.png
│   │   ├── figure7_rejection_regions.png
│   │   └── figure8_pvalues.png
│   │
│   └── tables/
│       ├── sample_statistics.csv
│       ├── bootstrap_summary.csv
│       ├── coverage_summary.csv
│       ├── hypothesis_test_results.csv
│       └── hypothesis_summary.csv
│
├── interactive_demo.html
├── README.md
└── Blog8.Rproj
```

### File Descriptions

| File | Purpose |
|---|---|
| `01_generate_data.R` | Generates the initial sample and visualizes its distribution. |
| `02_bootstrap_ci.R` | Constructs a bootstrap distribution and percentile confidence interval. |
| `03_coverage_simulation.R` | Estimates the empirical coverage probability across independent samples. |
| `04_hypothesis_testing.R` | Simulates a null distribution and illustrates rejection regions and p-values. |
| `05_interactive_simulation.js` | Implements the browser-based interactive bootstrap simulation. |
| `interactive_demo.html` | Provides the interface for changing simulation parameters. |

The `data-raw/` directory contains the original simulated sample. The `data/` directory contains analysis-ready observations and generated simulation results. Final visualizations and summary tables are stored separately under `results/`.

## 4. Methodology

### 4.1 Sampling from a Known Population

The analysis begins by generating 100 independent observations from a normal population with mean 50 and standard deviation 10.

The sample mean is calculated as:

\[
\bar X=\frac{1}{n}\sum_{i=1}^{n}X_i
\]

The sample mean generally differs from the true population mean because of sampling variability.

### 4.2 Bootstrap Confidence Intervals

Bootstrap resampling estimates the sampling uncertainty of a statistic using the observed sample.

The procedure is:

1. Draw an initial sample of 100 observations.
2. Resample 100 observations with replacement from the original sample.
3. Calculate the mean of each bootstrap resample.
4. Repeat the process 2,000 times.
5. Use the 2.5th and 97.5th percentiles of the bootstrap means to construct a 95% confidence interval.

The percentile bootstrap interval is:

\[
CI_{95\%}=
\left[
Q_{0.025}(\bar X^*),
Q_{0.975}(\bar X^*)
\right]
\]

where \(\bar X^*\) represents the bootstrap sample mean.

### 4.3 Confidence Interval Coverage

To evaluate the long-run performance of confidence intervals, the project generates 1,000 independent samples from the known population.

For each sample:

1. Generate 100 observations.
2. Construct a 95% percentile bootstrap confidence interval using 500 bootstrap resamples.
3. Check whether the interval contains the true population mean of 50.

Empirical coverage is calculated as:

\[
\widehat{\text{Coverage}}
=
\frac{\text{Number of intervals containing }\mu}
{\text{Total number of simulated intervals}}
\]

A nominal 95% confidence interval is designed to cover the true population parameter approximately 95% of the time under repeated sampling, subject to the assumptions and accuracy of the interval construction method.

### 4.4 Hypothesis Testing

The hypothesis-testing demonstration considers:

\[
H_0:\mu=50
\]

\[
H_1:\mu\neq50
\]

The one-sample t-statistic is:

\[
t=\frac{\bar X-\mu_0}{s/\sqrt n}
\]

The project generates 10,000 independent samples under the null hypothesis and calculates the t-statistic for each sample.

At the 5% significance level, the two-sided rejection region is defined by:

\[
|t|>t_{0.975,99}\approx1.984
\]

The simulation-based two-sided p-value is estimated by the proportion of null statistics at least as extreme as the observed statistic, with an add-one correction:

\[
\hat p=
\frac{
1+\sum_{b=1}^{B}I(|T_b|\geq|t_{\mathrm{obs}}|)
}{
B+1
}
\]

The analysis also estimates the Type I error rate, defined as the probability of rejecting the null hypothesis when it is true.

## 5. Main Results

### 5.1 Initial Sample

The original sample contained 100 observations with a sample mean of approximately 50.39, compared with the true population mean of 50.

This difference illustrates sampling variability.

### 5.2 Bootstrap Confidence Interval

Using 2,000 bootstrap resamples, the estimated 95% percentile confidence interval was approximately:

\[
[48.2,\ 52.5]
\]

The interval contained the true population mean of 50.

However, coverage of a single interval does not establish the long-run reliability of the procedure.

### 5.3 Confidence Interval Coverage

Across 1,000 independent simulations:

| Measure | Result |
|---|---:|
| Total simulations | 1,000 |
| Intervals covering the true mean | 940 |
| Intervals missing the true mean | 60 |
| Empirical coverage | 94.0% |
| Nominal confidence level | 95.0% |
| Average confidence interval width | 3.85 |

The empirical coverage rate of 94.0% was close to the nominal 95% confidence level.

The small difference may reflect Monte Carlo variability and finite-sample properties of the percentile bootstrap method.

### 5.4 Hypothesis Testing

The simulated null distribution closely matched the theoretical t-distribution.

The empirical Type I error rate was approximately 5.12%, close to the nominal significance level of 5%.

Two observed scenarios were examined:

| Measure | Null scenario | Alternative scenario |
|---|---:|---:|
| Data-generating mean | 50 | 53 |
| Observed sample mean | Approximately 51.4 | Approximately 54.2 |
| Observed t-statistic | Approximately 1.27 | Approximately 4.61 |
| Simulated p-value | 0.2087 | 0.0001 |
| Decision at 5% | Fail to reject | Reject |

These results demonstrate how the extremeness of an observed test statistic relative to its null distribution determines the p-value and statistical decision.

The alternative scenario illustrates rejection of a false null hypothesis, but one observed rejection should not be interpreted as an estimate of statistical power.

## 6. Interactive Visualization

The project includes an interactive bootstrap demonstration implemented in JavaScript and Plotly.

Readers can modify:

- Sample size: 20, 50, 100, 200, or 300
- Number of bootstrap resamples: 100, 500, 1,000, or 2,000
- Confidence level: 90%, 95%, or 99%
- True population mean: 40, 45, 50, 55, or 60

The simulator generates a new synthetic sample for the selected parameters, constructs a bootstrap percentile confidence interval, and displays the bootstrap distribution.

The interactive demonstration uses a fixed pseudo-random seed for reproducibility. Its numerical results may differ from those generated by R because the random number generators differ.

The interactive demonstration illustrates a single-sample bootstrap procedure, while the repeated-sampling coverage experiment is presented separately in the R analysis.

To open the interactive demonstration locally, run:

```r
browseURL(normalizePath("interactive_demo.html"))
```

An internet connection is required to load Plotly from the external CDN.

## 7. Reproducibility Instructions

### Software Requirements

The analysis was developed using:

- R 4.6.1
- RStudio
- `ggplot2`
- `dplyr`
- `readr`
- `scales` (used for percentage-axis formatting)
- JavaScript and Plotly.js for interactive visualization

### Step 1: Clone the Repository

```bash
git clone <YOUR-REPOSITORY-URL>
cd Blog8
```

Replace `<YOUR-REPOSITORY-URL>` with the actual GitHub repository URL.

Alternatively, download the repository as a ZIP file and open `Blog8.Rproj` in RStudio.

### Step 2: Install Required R Packages

```r
install.packages(c(
  "ggplot2",
  "dplyr",
  "readr",
  "scales"
))
```

### Step 3: Run the Analysis

Open the project root directory in RStudio and execute the scripts in order:

```r
source("code/01_generate_data.R")
source("code/02_bootstrap_ci.R")
source("code/03_coverage_simulation.R")
source("code/04_hypothesis_testing.R")
```

Each script generates the required data, tables, and figures.

The scripts use fixed random seeds to ensure reproducible results within a consistent R environment.

### Step 4: Verify Outputs

After running the scripts, confirm that the following directories contain the generated files:

```text
data-raw/
data/
results/figures/
results/tables/
```

Eight static figures and five summary tables should be available in `results/`.

### Step 5: Open the Interactive Demonstration

Run:

```r
browseURL(normalizePath("interactive_demo.html"))
```

Select different parameters and click **Run Simulation** to update the bootstrap visualization.

## 8. Interpretation and Limitations

The simulations illustrate three important principles of statistical inference.

First, bootstrap resampling approximates sampling uncertainty using the empirical distribution of the observed sample. Its performance depends on how well the sample represents the underlying population.

Second, confidence levels describe the long-run performance of an interval construction procedure. A 95% confidence interval does not imply a 95% probability that a fixed population parameter lies inside a particular realized interval.

Third, hypothesis tests evaluate the compatibility of observed data with a null hypothesis. A p-value is not the probability that the null hypothesis is true.

Several limitations should be considered:

- The simulations assume independent, normally distributed observations.
- The main experiments use a fixed sample size of 100.
- Percentile bootstrap intervals may have imperfect coverage in small samples or under skewed distributions.
- The number of Monte Carlo replications introduces simulation uncertainty.
- The hypothesis-testing examples use a two-sided one-sample t-test and do not represent every possible testing framework.
- The interactive simulator illustrates one bootstrap interval at a time rather than estimating coverage through repeated independent samples.

## 9. Conclusion

This project demonstrates how simulation can make statistical inference more intuitive.

Bootstrap resampling reveals the uncertainty surrounding a sample estimate. Repeated sampling shows why confidence intervals should be understood in terms of long-run coverage. Simulated null distributions clarify the relationship between test statistics, rejection regions, p-values, and Type I errors.

Together, these experiments show that statistical inference is not about eliminating uncertainty. It is about quantifying uncertainty and making decisions using procedures whose behavior can be studied through repeated sampling.