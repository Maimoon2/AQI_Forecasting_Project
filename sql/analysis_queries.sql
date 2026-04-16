CREATE DATABASE aqi_project;

USE aqi_project;

CREATE TABLE pollution_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(50),
    timestamp DATETIME,
    pm2_5 FLOAT,
    pm10 FLOAT,
    no2 FLOAT,
    co FLOAT,
    o3 FLOAT
);

CREATE TABLE forecast_overall (
    id INT AUTO_INCREMENT PRIMARY KEY,
    time_index INT,
    actual_pm25 FLOAT,
    predicted_pm25 FLOAT
);

select * from forecast_overall limit 10;

CREATE TABLE forecast_citywise (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(50),
    time_index INT,
    actual_pm25 FLOAT,
    predicted_pm25 FLOAT
);

select * from forecast_citywise limit 10;



# Identified most polluted Days
SELECT DATE(timestamp) AS date,
       ROUND(MAX(pm2_5),2) AS max_pm25
FROM pollution_data
GROUP BY DATE(timestamp)
ORDER BY max_pm25 DESC
LIMIT 10;

# Monthly Polluted Trend
SELECT MONTH(timestamp) AS month,
       ROUND(AVG(pm2_5),2) AS avg_pm25
FROM pollution_data
GROUP BY MONTH(timestamp)
ORDER BY month;

# Pollution Ranking of Cities
SELECT city,
       ROUND(AVG(pm2_5),2) AS avg_pm25,
       RANK() OVER (ORDER BY AVG(pm2_5) DESC) AS pollution_rank
FROM pollution_data
GROUP BY city;

# Worst Pollution Spike Per City
SELECT city,
       ROUND(MAX(pm2_5),2) AS worst_pollution_level
FROM pollution_data
GROUP BY city
ORDER BY worst_pollution_level DESC;

# Actual vs Predicted
SELECT time_index,
       actual_pm25,
       predicted_pm25,
       ROUND(ABS(actual_pm25 - predicted_pm25),2) AS prediction_error
FROM forecast_overall;

# Forecast Accuracy Per City
SELECT city,
       ROUND(AVG(ABS(actual_pm25 - predicted_pm25)),2) AS mean_prediction_error
FROM forecast_citywise
GROUP BY city
ORDER BY mean_prediction_error;

# Highest Predicted Pollution Cities 
SELECT city,
       ROUND(AVG(ABS(actual_pm25 - predicted_pm25)),2) AS mean_prediction_error
FROM forecast_citywise
GROUP BY city
ORDER BY mean_prediction_error;

# Predicted Accuracy Percentage 
SELECT city,
       ROUND(
         (1 - AVG(ABS(actual_pm25 - predicted_pm25)/actual_pm25))*100,2) AS prediction_accuracy_percent
FROM forecast_citywise
GROUP BY city
ORDER BY prediction_accuracy_percent DESC;

# Pollution Variability Per City 
SELECT city,
       ROUND(
         (1 - AVG(ABS(actual_pm25 - predicted_pm25)/actual_pm25))*100,
         2
       ) AS prediction_accuracy_percent
FROM forecast_citywise
GROUP BY city
ORDER BY prediction_accuracy_percent DESC;

# Cities With Consistently High Pollution 
SELECT city,
       COUNT(*) AS high_pollution_days
FROM pollution_data
WHERE pm2_5 > 150
GROUP BY city
ORDER BY high_pollution_days DESC;