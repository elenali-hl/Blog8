
# Blog Post 8 - Create repository structure

folders <- c(
  "code",
  "data-raw",
  "data",
  "results",
  "results/figures",
  "results/tables"
)

for (folder in folders) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}

# Create README
if (!file.exists("README.md")) {
  file.create("README.md")
}

# Check structure
list.files(".", recursive = TRUE, all.files = FALSE)



# ============================================================
# Blog Post 8: Simulation, Bootstrap Confidence Intervals,
# and Hypothesis Testing
#
# 01 - Generate Simulation Data
#
# Purpose:
# 1. Define a known population distribution.
# 2. Generate one random sample.
# 3. Calculate descriptive statistics.
# 4. Visualize the sample distribution.
# 5. Save data, tables, and figures.
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
# Step 2: Check project directories
# ------------------------------------------------------------

folders <- c(
  "code",
  "data-raw",
  "data",
  "results/figures",
  "results/tables"
)

for (folder in folders) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}

# ------------------------------------------------------------
# Step 3: Define simulation parameters
# ------------------------------------------------------------

set.seed(6408)

population_mean <- 50
population_sd <- 10
sample_size <- 100

cat("============================================\n")
cat("BLOG POST 8 - DATA GENERATION\n")
cat("============================================\n")
cat("True population mean:", population_mean, "\n")
cat("True population SD:", population_sd, "\n")
cat("Sample size:", sample_size, "\n")

# ------------------------------------------------------------
# Step 4: Generate random sample
# ------------------------------------------------------------

sample_data <- tibble(
  observation_id = seq_len(sample_size),
  value = rnorm(
    n = sample_size,
    mean = population_mean,
    sd = population_sd
  )
)

# Save the original generated sample
write_csv(
  sample_data,
  "data-raw/initial_sample.csv"
)

# ------------------------------------------------------------
# Step 5: Calculate sample statistics
# ------------------------------------------------------------

sample_statistics <- sample_data %>%
  summarise(
    sample_size = n(),
    sample_mean = mean(value),
    sample_sd = sd(value),
    sample_median = median(value),
    sample_min = min(value),
    sample_max = max(value),
    standard_error = sd(value) / sqrt(n())
  ) %>%
  mutate(
    true_population_mean = population_mean,
    true_population_sd = population_sd
  )

print(sample_statistics, width = Inf)

write_csv(
  sample_statistics,
  "results/tables/sample_statistics.csv"
)

# ------------------------------------------------------------
# Step 6: Save analysis-ready sample
# ------------------------------------------------------------

write_csv(
  sample_data,
  "data/analysis_sample.csv"
)

# ------------------------------------------------------------
# Step 7: Visualize sample distribution
# ------------------------------------------------------------

figure1 <- ggplot(sample_data, aes(x = value)) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 20,
    fill = "#5B8DB8",
    color = "white",
    alpha = 0.8
  ) +
  stat_function(
    fun = dnorm,
    args = list(
      mean = population_mean,
      sd = population_sd
    ),
    color = "#E07A5F",
    linewidth = 1.1
  ) +
  geom_vline(
    xintercept = population_mean,
    color = "#E07A5F",
    linetype = "dashed",
    linewidth = 0.8
  ) +
  geom_vline(
    xintercept = mean(sample_data$value),
    color = "#264653",
    linetype = "dotted",
    linewidth = 0.9
  ) +
  labs(
    title = "A Random Sample from a Known Population",
    subtitle = paste0(
      "n = ", sample_size,
      " | True mean = ", population_mean,
      " | Sample mean = ",
      round(mean(sample_data$value), 2)
    ),
    x = "Observed Value",
    y = "Density",
    caption = paste(
      "Dashed line: true population mean;",
      "dotted line: sample mean.",
      "Red curve: theoretical normal density."
    )
  ) +
  theme_minimal(base_size = 13)

print(figure1)

ggsave(
  filename = "results/figures/figure1_sample_distribution.png",
  plot = figure1,
  width = 9,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# Step 8: Verify outputs
# ------------------------------------------------------------

cat("\n============================================\n")
cat("DATA GENERATION COMPLETE\n")
cat("============================================\n")

cat("\nGenerated files:\n")

output_files <- c(
  "data-raw/initial_sample.csv",
  "data/analysis_sample.csv",
  "results/tables/sample_statistics.csv",
  "results/figures/figure1_sample_distribution.png"
)

print(
  data.frame(
    file = output_files,
    exists = file.exists(output_files)
  ),
  row.names = FALSE
)

stopifnot(all(file.exists(output_files)))

cat("\nAll files generated successfully.\n")


