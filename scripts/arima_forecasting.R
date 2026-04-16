# OVERALL ARIMA FORECAST SCRIPT

library(readr)
library(dplyr)
library(forecast)
library(ggplot2)
library(tseries)

cat("Starting Overall ARIMA Forecasting...\n")

setwd("C:/Users/OMEN/Desktop/AQI-Analysis-Project")

# STEP 1: Load Dataset

data <- read_csv("data/clean/weather_aqi_clean.csv")

data$date <- as.POSIXct(data$timestamp, origin="1970-01-01")

cat("Dataset loaded successfully\n")

# STEP 2: Create Daily PM2.5 Trend

daily_data <- data %>%
  group_by(date = as.Date(date)) %>%
  summarise(pm25_daily = mean(pm2_5, na.rm=TRUE)) %>%
  arrange(date)

# STEP 3: Trend Plot

trend_plot <- ggplot(daily_data, aes(x=date, y=pm25_daily)) +
  geom_line(color="blue", linewidth=1) +
  labs(
    title="Overall PM2.5 Pollution Trend",
    x="Date",
    y="Average PM2.5",
    caption="Daily average PM2.5 across all cities"
  ) +
  theme_minimal()

ggsave(
  "results/forecast_plots/overall_trend.png",
  trend_plot,
  width=10,
  height=6
)

# STEP 4: Time Series Creation

ts_data <- ts(daily_data$pm25_daily, frequency=7)

train_size <- floor(0.8 * length(ts_data))

train_ts <- ts_data[1:train_size]
test_ts  <- ts_data[(train_size+1):length(ts_data)]

# STEP 5: Stationarity Test

print(adf.test(train_ts))

# STEP 6: Train ARIMA Model

model <- auto.arima(train_ts, seasonal=TRUE)

cat("Selected Model:\n")
print(model)

# STEP 7: Forecast

forecast_values <- forecast(model, h=length(test_ts))

# STEP 8: Model Evaluation

rmse <- sqrt(mean((test_ts - forecast_values$mean)^2))
mae  <- mean(abs(test_ts - forecast_values$mean))
mape <- mean(abs((test_ts - forecast_values$mean)/test_ts))*100

cat("\nModel Performance Metrics\n")
cat("RMSE:", rmse, "\n")
cat("MAE :", mae, "\n")
cat("MAPE:", mape, "%\n")

# STEP 9: Combined Comparison + Error Plot

actual_values <- as.numeric(test_ts)
predicted_values <- as.numeric(forecast_values$mean)

errors <- actual_values - predicted_values

time_index <- 1:length(actual_values)

png("results/forecast_plots/overall_comparison_error.png",
    width=900,
    height=700)

par(mfrow=c(2,1))

# Panel 1
plot(time_index,
     actual_values,
     type="l",
     col="red",
     lwd=2,
     main="Actual vs Predicted PM2.5 (Overall)",
     xlab="Time Index (Days)",
     ylab="PM2.5")

lines(time_index,
      predicted_values,
      col="blue",
      lwd=2)

legend("topleft",
       legend=c("Actual PM2.5","Predicted PM2.5"),
       col=c("red","blue"),
       lty=1,
       lwd=2)

# Panel 2
plot(time_index,
     errors,
     type="l",
     col="purple",
     lwd=2,
     main="Prediction Error (Actual - Predicted)",
     xlab="Time Index (Days)",
     ylab="Error")

abline(h=0, col="black", lty=2)

dev.off()
# STEP 10: Save Forecast Data

forecast_df <- data.frame(
  time_index = time_index,
  actual_pm25 = actual_values,
  predicted_pm25 = predicted_values,
  error = abs(actual_values - predicted_values)
)

write.csv(
  forecast_df,
  "results/forecast_results_overall.csv",
  row.names=FALSE
)

cat("Overall forecasting completed successfully\n")