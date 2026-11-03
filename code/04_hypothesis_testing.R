
# ============================================================
# Blog Post 8
# 04 - Hypothesis Testing Through Simulation
#
# Purpose:
# 1. Simulate a null distribution of t-statistics.
# 2. Identify two-sided rejection regions.
# 3. Calculate simulation-based p-values.
# 4. Compare null and alternative scenarios.
# 5. Save tables and figures.
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

dir.create(
  "results/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "results/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# Step 2: Set simulation parameters
# ------------------------------------------------------------

set.seed(6408)

null_mean <- 50
population_sd <- 10
sample_size <- 100

n_simulations <- 10000
alpha <- 0.05

df <- sample_size - 1

critical_value <- qt(
  1 - alpha / 2,
  df = df
)

cat("============================================\n")
cat("HYPOTHESIS TESTING SIMULATION\n")
cat("============================================\n")

cat("Null hypothesis: mu =", null_mean, "\n")
cat("Sample size:", sample_size, "\n")
cat("Simulations:", n_simulations, "\n")
cat("Significance level:", alpha, "\n")
cat("Critical t-value:", critical_value, "\n")

# ------------------------------------------------------------
# Step 3: Define t-statistic function
# ------------------------------------------------------------

calculate_t <- function(x, mu0) {
  
  (mean(x) - mu0) /
    (sd(x) / sqrt(length(x)))
  
}

# ------------------------------------------------------------
# Step 4: Simulate null distribution
# ------------------------------------------------------------

null_statistics <- replicate(
  n_simulations,
  {
    x <- rnorm(
      sample_size,
      mean = null_mean,
      sd = population_sd
    )
    
    calculate_t(x, null_mean)
  }
)

null_results <- tibble(
  simulation = seq_len(n_simulations),
  t_statistic = null_statistics,
  rejected = abs(null_statistics) > critical_value
)

write_csv(
  null_results,
  "data/null_distribution.csv"
)

# ------------------------------------------------------------
# Step 5: Calculate Type I error rate
# ------------------------------------------------------------

type1_error <- mean(null_results$rejected)

cat("\nEmpirical Type I error rate:",
    type1_error, "\n")

# ------------------------------------------------------------
# Step 6: Generate observed samples
# ------------------------------------------------------------

# Scenario A: Null hypothesis is true
observed_null <- rnorm(
  sample_size,
  mean = 50,
  sd = population_sd
)

# Scenario B: Alternative hypothesis is true
observed_alternative <- rnorm(
  sample_size,
  mean = 53,
  sd = population_sd
)

observed_samples <- list(
  "Null scenario (mu = 50)" = observed_null,
  "Alternative scenario (mu = 53)" =
    observed_alternative
)

# ------------------------------------------------------------
# Step 7: Calculate observed test statistics
# ------------------------------------------------------------

test_results <- bind_rows(
  lapply(names(observed_samples), function(name) {
    
    x <- observed_samples[[name]]
    
    t_obs <- calculate_t(x, null_mean)
    
    # Two-sided simulation-based p-value
    extreme_count <- sum(
      abs(null_statistics) >= abs(t_obs)
    )
    
    p_sim <- (
      extreme_count + 1
    ) / (
      n_simulations + 1
    )
    
    p_theoretical <- 2 * pt(
      -abs(t_obs),
      df = df
    )
    
    tibble(
      scenario = name,
      sample_mean = mean(x),
      sample_sd = sd(x),
      t_statistic = t_obs,
      simulated_p_value = p_sim,
      theoretical_p_value = p_theoretical,
      reject_null = p_sim < alpha
    )
  })
)

print(test_results, width = Inf)

write_csv(
  test_results,
  "results/tables/hypothesis_test_results.csv"
)

# ------------------------------------------------------------
# Step 8: Figure 6 - Null distribution
# ------------------------------------------------------------

figure6 <- ggplot(
  null_results,
  aes(x = t_statistic)
) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 65,
    fill = "#5B8DB8",
    color = "white",
    alpha = 0.8
  ) +
  stat_function(
    fun = dt,
    args = list(df = df),
    color = "#264653",
    linewidth = 1
  ) +
  geom_vline(
    xintercept = c(
      -critical_value,
      critical_value
    ),
    color = "#E76F51",
    linetype = "dashed",
    linewidth = 1
  ) +
  labs(
    title = "Simulated Null Distribution of the t-Statistic",
    subtitle = paste0(
      n_simulations,
      " simulations | H0: mu = 50 | alpha = 0.05"
    ),
    x = "t-Statistic",
    y = "Density",
    caption = paste(
      "Dashed lines mark the two-sided 5%",
      "rejection boundaries."
    )
  ) +
  theme_minimal(base_size = 13)

print(figure6)

ggsave(
  "results/figures/figure6_null_distribution.png",
  figure6,
  width = 9,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# Step 9: Figure 7 - Rejection regions
# ------------------------------------------------------------

plot_density <- tibble(
  t = seq(-4.5, 4.5, length.out = 1000)
) %>%
  mutate(
    density = dt(t, df = df),
    region = if_else(
      abs(t) > critical_value,
      "Rejection region",
      "Non-rejection region"
    )
  )

figure7 <- ggplot(
  plot_density,
  aes(x = t, y = density)
) +
  geom_area(
    aes(fill = region),
    alpha = 0.75
  ) +
  geom_line(
    color = "#264653",
    linewidth = 0.9
  ) +
  geom_vline(
    xintercept = c(
      -critical_value,
      critical_value
    ),
    linetype = "dashed",
    color = "#E76F51"
  ) +
  scale_fill_manual(
    values = c(
      "Rejection region" = "#E76F51",
      "Non-rejection region" = "#A8DADC"
    )
  ) +
  labs(
    title = "Understanding Rejection Regions",
    subtitle = "Two-sided t-test at the 5% significance level",
    x = "t-Statistic",
    y = "Density",
    fill = "Decision Region",
    caption = "Each tail contains 2.5% under the null."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom"
  )

print(figure7)

ggsave(
  "results/figures/figure7_rejection_regions.png",
  figure7,
  width = 9,
  height = 6,
  dpi = 300
)


# ------------------------------------------------------------
# Step 10: Figure 8 - Understanding p-values
# ------------------------------------------------------------

# Create a smooth theoretical null distribution
t_grid <- seq(-5.5, 5.5, length.out = 2000)

pvalue_plot_data <- bind_rows(
  lapply(seq_len(nrow(test_results)), function(i) {
    
    result <- test_results[i, ]
    
    tibble(
      scenario = result$scenario,
      t_statistic = t_grid,
      density = dt(t_grid, df = df),
      extreme = abs(t_grid) >= abs(result$t_statistic)
    )
  })
)

# Add observed test statistic boundaries
observed_lines <- bind_rows(
  test_results %>%
    transmute(
      scenario,
      boundary = t_statistic
    ),
  test_results %>%
    transmute(
      scenario,
      boundary = -t_statistic
    )
)

# Labels for simulated p-values
pvalue_labels <- test_results %>%
  mutate(
    label = paste0(
      "Simulated p-value = ",
      format(
        simulated_p_value,
        digits = 3,
        scientific = FALSE
      )
    ),
    x = 0,
    y = 0.35
  )

figure8 <- ggplot(
  pvalue_plot_data,
  aes(x = t_statistic, y = density)
) +
  geom_area(
    aes(fill = extreme),
    alpha = 0.8
  ) +
  geom_line(
    color = "#264653",
    linewidth = 0.9
  ) +
  geom_vline(
    data = observed_lines,
    aes(xintercept = boundary),
    color = "#264653",
    linetype = "dashed",
    linewidth = 0.8
  ) +
  geom_text(
    data = pvalue_labels,
    aes(x = x, y = y, label = label),
    inherit.aes = FALSE,
    size = 4
  ) +
  facet_wrap(
    ~scenario,
    ncol = 1
  ) +
  scale_fill_manual(
    values = c(
      "FALSE" = "#A8DADC",
      "TRUE" = "#E76F51"
    ),
    labels = c(
      "FALSE" = "Less extreme",
      "TRUE" = "At least as extreme"
    )
  ) +
  coord_cartesian(
    xlim = c(-5.5, 5.5)
  ) +
  labs(
    title = "Understanding Simulation-Based p-Values",
    subtitle = paste(
      "Theoretical null density with observed",
      "test-statistic boundaries"
    ),
    x = "t-Statistic Under H0",
    y = "Density",
    fill = "Region",
    caption = paste(
      "Shaded tails represent theoretical p-value areas.",
      "Labels report simulation-based p-values."
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom"
  )

print(figure8)

ggsave(
  "results/figures/figure8_pvalues.png",
  figure8,
  width = 10,
  height = 8,
  dpi = 300
)


# ------------------------------------------------------------
# Step 11: Save summary
# ------------------------------------------------------------

hypothesis_summary <- tibble(
  sample_size = sample_size,
  n_simulations = n_simulations,
  null_mean = null_mean,
  significance_level = alpha,
  critical_t = critical_value,
  empirical_type1_error = type1_error,
  theoretical_type1_error = alpha
)

write_csv(
  hypothesis_summary,
  "results/tables/hypothesis_summary.csv"
)

print(hypothesis_summary, width = Inf)

# ------------------------------------------------------------
# Step 12: Validate outputs
# ------------------------------------------------------------

stopifnot(
  nrow(null_results) == n_simulations,
  all(is.finite(null_statistics)),
  all(is.finite(test_results$t_statistic)),
  all(test_results$simulated_p_value >= 0),
  all(test_results$simulated_p_value <= 1),
  type1_error >= 0,
  type1_error <= 1
)

output_files <- c(
  "data/null_distribution.csv",
  "results/tables/hypothesis_test_results.csv",
  "results/tables/hypothesis_summary.csv",
  "results/figures/figure6_null_distribution.png",
  "results/figures/figure7_rejection_regions.png",
  "results/figures/figure8_pvalues.png"
)

cat("\n============================================\n")
cat("HYPOTHESIS TESTING COMPLETE\n")
cat("============================================\n")

print(
  data.frame(
    file = output_files,
    exists = file.exists(output_files)
  ),
  row.names = FALSE
)

stopifnot(all(file.exists(output_files)))

cat("\nAll hypothesis testing outputs generated.\n")
