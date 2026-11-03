
# ============================================================
# Blog Post 8: Simulation, Bootstrap Confidence Intervals,
# and Hypothesis Testing
#
# 02 - Bootstrap Confidence Intervals
#
# Purpose:
# 1. Load the original simulated sample.
# 2. Resample with replacement.
# 3. Construct the bootstrap distribution.
# 4. Calculate percentile confidence intervals.
# 5. Visualize and save the results.
# ============================================================

# ------------------------------------------------------------
# Step 1: Load packages
# ------------------------------------------------------------

required_packages <- c("ggplot2", "dplyr", "readr")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(ggplot2)
library(dplyr)
library(readr)

# ------------------------------------------------------------
# Step 2: Load the original sample
# ------------------------------------------------------------

sample_data <- read_csv(
  "data/analysis_sample.csv",
  show_col_types = FALSE
)

sample_values <- sample_data$value

stopifnot(
  length(sample_values) > 1,
  all(is.finite(sample_values))
)

sample_size <- length(sample_values)
original_mean <- mean(sample_values)

true_population_mean <- 50

cat("============================================\n")
cat("BLOG POST 8 - BOOTSTRAP ANALYSIS\n")
cat("============================================\n")
cat("Sample size:", sample_size, "\n")
cat("Original sample mean:", original_mean, "\n")

# ------------------------------------------------------------
# Step 3: Set bootstrap parameters
# ------------------------------------------------------------

set.seed(6408)

n_bootstrap <- 2000
confidence_level <- 0.95
alpha <- 1 - confidence_level

# ------------------------------------------------------------
# Step 4: Bootstrap resampling
# ------------------------------------------------------------

bootstrap_means <- replicate(
  n_bootstrap,
  {
    bootstrap_sample <- sample(
      sample_values,
      size = sample_size,
      replace = TRUE
    )
    
    mean(bootstrap_sample)
  }
)

bootstrap_results <- tibble(
  iteration = seq_len(n_bootstrap),
  bootstrap_mean = bootstrap_means
)

write_csv(
  bootstrap_results,
  "data/bootstrap_means.csv"
)

# ------------------------------------------------------------
# Step 5: Calculate bootstrap confidence interval
# ------------------------------------------------------------

ci_bounds <- quantile(
  bootstrap_means,
  probs = c(alpha / 2, 1 - alpha / 2),
  names = FALSE
)

ci_lower <- ci_bounds[1]
ci_upper <- ci_bounds[2]

bootstrap_se <- sd(bootstrap_means)

bootstrap_summary <- tibble(
  sample_size = sample_size,
  n_bootstrap = n_bootstrap,
  confidence_level = confidence_level,
  original_mean = original_mean,
  bootstrap_mean = mean(bootstrap_means),
  bootstrap_se = bootstrap_se,
  ci_lower = ci_lower,
  ci_upper = ci_upper,
  ci_width = ci_upper - ci_lower,
  true_population_mean = true_population_mean,
  contains_true_mean = (
    ci_lower <= true_population_mean &
      ci_upper >= true_population_mean
  )
)

print(bootstrap_summary, width = Inf)

write_csv(
  bootstrap_summary,
  "results/tables/bootstrap_summary.csv"
)

# ------------------------------------------------------------
# Step 6: Plot bootstrap distribution
# ------------------------------------------------------------

figure2 <- ggplot(
  bootstrap_results,
  aes(x = bootstrap_mean)
) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 35,
    fill = "#5B8DB8",
    color = "white",
    alpha = 0.85
  ) +
  geom_density(
    color = "#264653",
    linewidth = 1
  ) +
  geom_vline(
    xintercept = original_mean,
    color = "#264653",
    linewidth = 1,
    linetype = "solid"
  ) +
  geom_vline(
    xintercept = c(ci_lower, ci_upper),
    color = "#E07A5F",
    linewidth = 1,
    linetype = "dashed"
  ) +
  annotate(
    "rect",
    xmin = ci_lower,
    xmax = ci_upper,
    ymin = -Inf,
    ymax = Inf,
    fill = "#5B8DB8",
    alpha = 0.08
  ) +
  labs(
    title = "Bootstrap Distribution of the Sample Mean",
    subtitle = paste0(
      n_bootstrap,
      " bootstrap resamples | n = ",
      sample_size,
      " | 95% percentile CI: [",
      round(ci_lower, 2),
      ", ",
      round(ci_upper, 2),
      "]"
    ),
    x = "Bootstrap Sample Mean",
    y = "Density",
    caption = paste(
      "Solid line: original sample mean.",
      "Dashed lines: 95% bootstrap confidence interval."
    )
  ) +
  theme_minimal(base_size = 13)

print(figure2)

ggsave(
  "results/figures/figure2_bootstrap_distribution.png",
  figure2,
  width = 9,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# Step 7: Visualize original estimate and confidence interval
# ------------------------------------------------------------

ci_plot_data <- tibble(
  parameter = "Population Mean",
  estimate = original_mean,
  lower = ci_lower,
  upper = ci_upper
)

figure3 <- ggplot(
  ci_plot_data,
  aes(x = parameter, y = estimate)
) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 0.15,
    linewidth = 1.2,
    color = "#5B8DB8"
  ) +
  geom_point(
    size = 3.5,
    color = "#264653"
  ) +
  geom_hline(
    yintercept = true_population_mean,
    color = "#E07A5F",
    linetype = "dashed",
    linewidth = 1
  ) +
  coord_flip() +
  labs(
    title = "Bootstrap Confidence Interval for the Mean",
    subtitle = "Point estimate and 95% percentile confidence interval",
    x = NULL,
    y = "Estimated Population Mean",
    caption = "Dashed line: true population mean (50)."
  ) +
  theme_minimal(base_size = 13)

print(figure3)

ggsave(
  "results/figures/figure3_bootstrap_ci.png",
  figure3,
  width = 9,
  height = 5,
  dpi = 300
)

# ------------------------------------------------------------
# Step 8: Validate outputs
# ------------------------------------------------------------

stopifnot(
  nrow(bootstrap_results) == n_bootstrap,
  all(is.finite(bootstrap_means)),
  ci_lower < ci_upper,
  ci_lower <= original_mean,
  ci_upper >= original_mean
)

output_files <- c(
  "data/bootstrap_means.csv",
  "results/tables/bootstrap_summary.csv",
  "results/figures/figure2_bootstrap_distribution.png",
  "results/figures/figure3_bootstrap_ci.png"
)

cat("\n============================================\n")
cat("BOOTSTRAP ANALYSIS COMPLETE\n")
cat("============================================\n")

print(
  data.frame(
    file = output_files,
    exists = file.exists(output_files)
  ),
  row.names = FALSE
)

stopifnot(all(file.exists(output_files)))

cat("\nAll bootstrap outputs generated successfully.\n")
