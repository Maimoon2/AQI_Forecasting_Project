# Load required libraries
library(readr)
library(dplyr)
library(forecast)
library(ggplot2)
library(tseries)

cat("Starting ARIMA Forecasting...\n")

# Step 1: Load cleaned dataset

data <- read_csv("data/clean/weather_aqi_clean.csv")
# Convert timestamp to proper date format
data$date <- as.POSIXct(data$timestamp, origin = "1970-01-01")

cat("Dataset loaded successfully\n")

# Step 2: Create Daily Average PM2.5

daily_data <- data %>%
  group_by(date = as.Date(date)) %>%
  summarise(pm25_daily = mean(pm2_5, na.rm = TRUE)) %>%
  arrange(date)

cat("Daily PM2.5 values prepared\n")

# Step 3: Convert to Time Series

ts_data <- ts(daily_data$pm25_daily, frequency = 7)

cat("Time series created\n")

# Step 4: Train/Test Split

train_size <- floor(0.8 * length(ts_data))

train_ts <- ts_data[1:train_size]
test_ts  <- ts_data[(train_size + 1):length(ts_data)]

cat("Train-test split completed\n")

# Step 5: Check Stationarity (ADF Test)

cat("Running ADF test...\n")

adf_result <- adf.test(train_ts)

print(adf_result)

# Step 6: Fit ARIMA Model

cat("Training ARIMA model...\n")

model <- auto.arima(train_ts)

summary(model)

cat("Selected Model:\n")
print(model)

# Step 7: Forecast Future Values

forecast_values <- forecast(model, h = length(test_ts))

cat("Forecast generated\n")

# Step 8: Model Evaluation (RMSE)

rmse <- sqrt(mean((test_ts - forecast_values$mean)^2))

cat("RMSE Value:", rmse, "\n")

# Step 9: Save ARIMA Forecast Plot

png("results/forecast_plots/arima_forecast.png",
    width = 900, height = 600)

plot(forecast_values,
     main = "ARIMA Forecast of PM2.5",
     xlab = "Time",
     ylab = "PM2.5 Concentration")

dev.off()

cat("ARIMA forecast plot saved\n")

# Step 10: Forecast vs Actual Plot


png("results/forecast_plots/forecast_vs_actual.png",
    width = 900, height = 600)

autoplot(forecast_values) +
  autolayer(ts(test_ts), series = "Actual PM2.5") +
  ggtitle("ARIMA Forecast vs Actual PM2.5") +
  xlab("Time") +
  ylab("PM2.5 Concentration") +
  guides(colour = guide_legend(title = "Legend"))

dev.off()

cat("Forecast vs Actual plot saved\n")

cat("ARIMA forecasting completed successfully!\n")

