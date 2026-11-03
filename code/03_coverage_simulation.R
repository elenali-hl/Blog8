
# ============================================================
# Blog Post 8
# 03 - Confidence Interval Coverage Simulation
#
# Purpose:
# 1. Generate repeated independent samples.
# 2. Construct a bootstrap CI for each sample.
# 3. Estimate empirical coverage probability.
# 4. Visualize covered and missed intervals.
# 5. Save reproducible results.
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
# Step 2: Define simulation parameters
# ------------------------------------------------------------

set.seed(6408)

true_mean <- 50
true_sd <- 10

sample_size <- 100
n_simulations <- 1000
n_bootstrap <- 500

confidence_level <- 0.95
alpha <- 1 - confidence_level

cat("============================================\n")
cat("BLOG POST 8 - COVERAGE SIMULATION\n")
cat("============================================\n")

cat("True mean:", true_mean, "\n")
cat("Sample size:", sample_size, "\n")
cat("Number of simulations:", n_simulations, "\n")
cat("Bootstrap repetitions per sample:", n_bootstrap, "\n")
cat("Confidence level:", confidence_level, "\n")

# ------------------------------------------------------------
# Step 3: Define bootstrap CI function
# ------------------------------------------------------------

bootstrap_ci <- function(x, B, conf_level) {
  
  n <- length(x)
  
  boot_means <- replicate(
    B,
    mean(sample(x, size = n, replace = TRUE))
  )
  
  alpha <- 1 - conf_level
  
  bounds <- quantile(
    boot_means,
    probs = c(alpha / 2, 1 - alpha / 2),
    names = FALSE
  )
  
  c(
    lower = bounds[1],
    upper = bounds[2]
  )
}

# ------------------------------------------------------------
# Step 4: Run repeated simulations
# ------------------------------------------------------------

simulation_results <- vector(
  "list",
  length = n_simulations
)

for (i in seq_len(n_simulations)) {
  
  # Generate a new independent sample
  x <- rnorm(
    n = sample_size,
    mean = true_mean,
    sd = true_sd
  )
  
  # Calculate bootstrap confidence interval
  ci <- bootstrap_ci(
    x,
    B = n_bootstrap,
    conf_level = confidence_level
  )
  
  # Check whether interval contains true mean
  covered <- (
    ci["lower"] <= true_mean &&
      ci["upper"] >= true_mean
  )
  
  simulation_results[[i]] <- tibble(
    simulation = i,
    sample_mean = mean(x),
    ci_lower = unname(ci["lower"]),
    ci_upper = unname(ci["upper"]),
    ci_width = unname(ci["upper"] - ci["lower"]),
    covered = covered
  )
  
  if (i %% 100 == 0) {
    cat("Completed", i, "of", n_simulations, "\n")
  }
}

coverage_results <- bind_rows(simulation_results)

# ------------------------------------------------------------
# Step 5: Calculate empirical coverage
# ------------------------------------------------------------

coverage_summary <- coverage_results %>%
  summarise(
    sample_size = sample_size,
    n_simulations = n(),
    n_bootstrap = n_bootstrap,
    confidence_level = confidence_level,
    true_mean = true_mean,
    intervals_covered = sum(covered),
    intervals_missed = sum(!covered),
    empirical_coverage = mean(covered),
    average_ci_width = mean(ci_width)
  ) %>%
  mutate(
    coverage_difference = empirical_coverage -
      confidence_level
  )

cat("\n============================================\n")
cat("COVERAGE SIMULATION RESULTS\n")
cat("============================================\n")

print(coverage_summary, width = Inf)

# ------------------------------------------------------------
# Step 6: Save simulation results
# ------------------------------------------------------------

write_csv(
  coverage_results,
  "data/coverage_simulation.csv"
)

write_csv(
  coverage_summary,
  "results/tables/coverage_summary.csv"
)

# ------------------------------------------------------------
# Step 7: Figure 4 - Confidence interval coverage
# ------------------------------------------------------------

# Display first 100 simulated intervals
plot_data <- coverage_results %>%
  slice_head(n = 100) %>%
  mutate(
    coverage_status = if_else(
      covered,
      "Contains true mean",
      "Misses true mean"
    )
  )

figure4 <- ggplot(
  plot_data,
  aes(
    x = simulation,
    y = sample_mean,
    color = coverage_status
  )
) +
  geom_linerange(
    aes(
      ymin = ci_lower,
      ymax = ci_upper
    ),
    linewidth = 0.7,
    alpha = 0.85
  ) +
  geom_point(size = 1.2) +
  geom_hline(
    yintercept = true_mean,
    color = "#264653",
    linetype = "dashed",
    linewidth = 1
  ) +
  scale_color_manual(
    values = c(
      "Contains true mean" = "#2A9D8F",
      "Misses true mean" = "#E76F51"
    )
  ) +
  labs(
    title = "Which Confidence Intervals Capture the True Mean?",
    subtitle = paste(
      "First 100 simulations |",
      "95% bootstrap confidence intervals"
    ),
    x = "Simulation Number",
    y = "Estimated Mean and Confidence Interval",
    color = "Coverage Status",
    caption = "Dashed horizontal line: true population mean = 50."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom"
  )

print(figure4)

ggsave(
  "results/figures/figure4_ci_coverage.png",
  figure4,
  width = 11,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# Step 8: Figure 5 - Cumulative coverage probability
# ------------------------------------------------------------

cumulative_coverage <- coverage_results %>%
  mutate(
    cumulative_coverage = cumsum(covered) /
      seq_len(n())
  )

figure5 <- ggplot(
  cumulative_coverage,
  aes(
    x = simulation,
    y = cumulative_coverage
  )
) +
  geom_line(
    color = "#5B8DB8",
    linewidth = 1
  ) +
  geom_hline(
    yintercept = confidence_level,
    color = "#E07A5F",
    linetype = "dashed",
    linewidth = 1
  ) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1)
  ) +
  labs(
    title = "Does Empirical Coverage Approach 95%?",
    subtitle = paste(
      n_simulations,
      "independent samples with bootstrap confidence intervals"
    ),
    x = "Number of Simulations",
    y = "Cumulative Coverage Rate",
    caption = "Dashed line: nominal 95% confidence level."
  ) +
  theme_minimal(base_size = 13)

print(figure5)

ggsave(
  "results/figures/figure5_cumulative_coverage.png",
  figure5,
  width = 9,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# Step 9: Validate outputs
# ------------------------------------------------------------

stopifnot(
  nrow(coverage_results) == n_simulations,
  all(is.finite(coverage_results$ci_lower)),
  all(is.finite(coverage_results$ci_upper)),
  all(coverage_results$ci_lower <
        coverage_results$ci_upper),
  coverage_summary$intervals_covered +
    coverage_summary$intervals_missed == n_simulations,
  coverage_summary$empirical_coverage >= 0,
  coverage_summary$empirical_coverage <= 1
)

output_files <- c(
  "data/coverage_simulation.csv",
  "results/tables/coverage_summary.csv",
  "results/figures/figure4_ci_coverage.png",
  "results/figures/figure5_cumulative_coverage.png"
)

cat("\n============================================\n")
cat("COVERAGE SIMULATION COMPLETE\n")
cat("============================================\n")

print(
  data.frame(
    file = output_files,
    exists = file.exists(output_files)
  ),
  row.names = FALSE
)

stopifnot(all(file.exists(output_files)))

cat("\nAll coverage outputs generated successfully.\n")
