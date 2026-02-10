library(dplyr)
library(readxl)
library(writexl)

raw_path <- "E:/AQI_Forecasting_Project/data/raw/weather_aqi_raw.csv"
clean_path <- "E:/AQI_Forecasting_Project/data/clean/weather_aqi_clean.xlsx"

df <- read.csv(raw_path)

df_clean <- df %>%
  distinct() %>%
  na.omit()

write_xlsx(df_clean, clean_path)

print("Cleaned data saved successfully.")
