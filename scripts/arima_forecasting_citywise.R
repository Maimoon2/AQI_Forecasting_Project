
# CITY-WISE ARIMA FORECASTING SCRIPT

library(readr)
library(dplyr)
library(forecast)
library(ggplot2)
library(tseries)

cat("Starting City-wise ARIMA Forecasting\n")

setwd("C:/Users/OMEN/Desktop/AQI-Analysis-Project")

data <- read_csv("data/clean/weather_aqi_clean.csv")

data$date <- as.POSIXct(data$timestamp, origin="1970-01-01")

cities <- unique(data$city)

all_forecasts <- data.frame()

for(city_name in cities){
  
  cat("\nProcessing:", city_name,"\n")
  
  city_data <- data %>%
    filter(city == city_name)
  
  daily_data <- city_data %>%
    group_by(date = as.Date(date)) %>%
    summarise(pm25_daily = mean(pm2_5, na.rm=TRUE)) %>%
    arrange(date)
  
  if(nrow(daily_data) < 30){
    cat("Skipping city (not enough data)\n")
    next
  }
  
  # Trend Plot
  
  trend_plot <- ggplot(daily_data, aes(x=date, y=pm25_daily)) +
    geom_line(color="darkgreen", linewidth=1) +
    labs(
      title=paste("PM2.5 Trend -", city_name),
      x="Date",
      y="Average PM2.5"
    ) +
    theme_minimal()
  
  ggsave(
    paste0("results/forecast_plots/trend_",city_name,".png"),
    trend_plot,
    width=10,
    height=6
  )
  
  ts_data <- ts(daily_data$pm25_daily, frequency=7)
  
  train_size <- floor(0.8 * length(ts_data))
  
  train_ts <- ts_data[1:train_size]
  test_ts  <- ts_data[(train_size+1):length(ts_data)]
  
  model <- auto.arima(train_ts, seasonal=TRUE)
  
  forecast_values <- forecast(model, h=length(test_ts))
  
  actual_values <- as.numeric(test_ts)
  predicted_values <- as.numeric(forecast_values$mean)
  
  errors <- actual_values - predicted_values
  
  time_index <- 1:length(actual_values)
  
  png(
    paste0("results/forecast_plots/comparison_error_",city_name,".png"),
    width=900,
    height=700
  )
  
  par(mfrow=c(2,1))
  
  plot(time_index,
       actual_values,
       type="l",
       col="red",
       lwd=2,
       main=paste("Actual vs Predicted PM2.5 -", city_name),
       xlab="Time Index",
       ylab="PM2.5")
  
  lines(time_index,
        predicted_values,
        col="blue",
        lwd=2)
  
  legend("topleft",
         legend=c("Actual","Predicted"),
         col=c("red","blue"),
         lty=1,
         lwd=2)
  
  plot(time_index,
       errors,
       type="l",
       col="purple",
       lwd=2,
       main=paste("Prediction Error -", city_name),
       xlab="Time Index",
       ylab="Error")
  
  abline(h=0, col="black", lty=2)
  
  dev.off()
  
  forecast_df <- data.frame(
    city = city_name,
    time_index = time_index,
    actual_pm25 = actual_values,
    predicted_pm25 = predicted_values,
    error = abs(errors)
  )
  
  all_forecasts <- rbind(all_forecasts, forecast_df)
  
}

write.csv(
  all_forecasts,
  "results/forecast_results_citywise.csv",
  row.names=FALSE
)

cat("City-wise forecasting completed\n")