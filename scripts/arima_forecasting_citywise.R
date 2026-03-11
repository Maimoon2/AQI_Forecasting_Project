library(readr)
library(dplyr)
library(forecast)
library(ggplot2)
library(tseries)

cat("Starting City-wise ARIMA Forecasting\n")

# Load dataset
data <- read_csv("data/clean/weather_aqi_clean.csv")

# Convert timestamp
data$date <- as.POSIXct(data$timestamp, origin="1970-01-01")

# Get list of cities
cities <- unique(data$city)

print(cities)

# Loop through each city
for(city_name in cities){
  
  cat("\nProcessing city:", city_name,"\n")
  
  # Filter data for that city
  city_data <- data %>%
    filter(city == city_name)
  
  # Daily PM2.5
  daily_data <- city_data %>%
    group_by(date = as.Date(date)) %>%
    summarise(pm25_daily = mean(pm2_5, na.rm=TRUE)) %>%
    arrange(date)
  
  # Convert to time series
  ts_data <- ts(daily_data$pm25_daily, frequency=7)
  
  # Train/Test split
  train_size <- floor(0.8 * length(ts_data))
  
  train_ts <- ts_data[1:train_size]
  test_ts  <- ts_data[(train_size+1):length(ts_data)]
  
  # ADF Test
  adf_result <- adf.test(train_ts)
  print(adf_result)
  
  # Train ARIMA
  model <- auto.arima(train_ts)
  
  print(model)
  
  # Forecast
  forecast_values <- forecast(model, h=length(test_ts))
  
  # RMSE
  rmse <- sqrt(mean((test_ts - forecast_values$mean)^2))
  cat("RMSE:", rmse,"\n")
  
  # Save forecast plot
  file_name <- paste0("results/forecast_plots/arima_forecast_",city_name,".png")
  
  png(file_name, width=900, height=600)
  
  plot(forecast_values,
       main=paste("ARIMA Forecast for", city_name),
       xlab="Time",
       ylab="PM2.5")
  
  dev.off()
  
}

cat("\nCity-wise forecasting completed\n")