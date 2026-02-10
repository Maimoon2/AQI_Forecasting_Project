library(dplyr)
library(readxl)
library(writexl)
library(lubridate)

raw_path <- "E:/AQI_Forecasting_Project/data/raw/weather_aqi_raw.csv"
clean_path <- "E:/AQI_Forecasting_Project/data/clean/weather_aqi_clean.xlsx"

df <- read.csv(raw_path)

colnames(df) <- tolower(colnames(df))
colnames(df) <- gsub(" ", "_", colnames(df))

df <- distinct(df)

if("timestamp" %in% colnames(df)){
  df$timestamp <- as.POSIXct(df$timestamp,
                             origin="1970-01-01",
                             tz="UTC")
}

if("city" %in% colnames(df)){
  df$city <- trimws(df$city)
}

pollutants <- c("co","no","no2","o3","so2","pm2_5","pm10","nh3","aqi")
pollutants <- pollutants[pollutants %in% colnames(df)]

df[pollutants] <- lapply(df[pollutants], as.numeric)

for(col in pollutants){
  df <- df %>% filter(.data[[col]] >= 0 | is.na(.data[[col]]))
}

for(col in pollutants){
  med <- median(df[[col]], na.rm = TRUE)
  df[[col]][is.na(df[[col]])] <- med
}

for(col in pollutants){
  q1 <- quantile(df[[col]], 0.01, na.rm = TRUE)
  q99 <- quantile(df[[col]], 0.99, na.rm = TRUE)
  
  df <- df %>%
    filter(.data[[col]] >= q1,
           .data[[col]] <= q99)
}

write_xlsx(df, clean_path)

print("AQI dataset cleaned successfully.")
