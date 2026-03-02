# AQI Project — Exploratory Data Analysis

library(readr)
library(dplyr)
library(ggplot2)
library(corrplot)
# STEP 1: Load cleaned dataset
data <- read_csv("data/clean/weather_aqi_clean.csv")

# STEP 2: Basic overview
cat("Dataset dimensions:\n")
print(dim(data))

cat("\nStructure:\n")
str(data)

cat("\nSummary statistics:\n")
summary(data)

# STEP 3: Check missing values
cat("\nMissing values per column:\n")
print(colSums(is.na(data)))

# VISUALIZATION 1 — PM2.5 Trend

p1 <- ggplot(data, aes(x = date, y = pm2_5)) +
  geom_line(color = "blue") +
  labs(
    title = "PM2.5 Trend Over Time",
    x = "Date",
    y = "PM2.5"
  )

ggsave("results/eda_plots/pm25_trend.png", plot = p1, width = 8, height = 5)

# VISUALIZATION 2 — City Comparison

city_avg <- data %>%
  group_by(city) %>%
  summarise(avg_pm25 = mean(pm2_5, na.rm = TRUE))

p2 <- ggplot(city_avg, aes(x = reorder(city, avg_pm25), y = avg_pm25)) +
  geom_bar(stat = "identity", fill = "orange") +
  coord_flip() +
  labs(
    title = "Average PM2.5 by City",
    x = "City",
    y = "Average PM2.5"
  )

ggsave("results/eda_plots/city_comparison.png", plot = p2, width = 8, height = 5)

# VISUALIZATION 3 — Correlation

num_data <- data %>%
  select(pm2_5, pm10, no2, co, o3)

corr_matrix <- cor(num_data, use = "complete.obs")

png("results/eda_plots/correlation_matrix.png", width = 800, height = 600)
corrplot(corr_matrix, method = "color")
dev.off()

cat("\nEDA completed successfully!\n")