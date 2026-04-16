# 🌍 AQI Analysis & PM2.5 Forecasting Project

## 📌 Introduction

Air pollution has become one of the most serious environmental issues affecting human health and quality of life. This project focuses on analyzing air quality data and predicting PM2.5 levels using time series techniques.

The goal of this project is to build a complete pipeline — from data collection to visualization — and gain meaningful insights into pollution patterns.

---

## 🎯 Objectives

- Analyze air pollution data across different cities
- Understand trends and patterns in PM2.5 levels
- Forecast future pollution using time series modeling (ARIMA)
- Build an interactive dashboard for visualization
- Create a reproducible system using Docker and MySQL

---

## 📊 Data Collection

The data was collected using the **OpenWeather Air Pollution API**, which provides information about multiple pollutants such as:

- PM2.5  
- PM10  
- NO2  
- CO  
- O3  

Python was used to fetch this data dynamically using API requests.

---

## 🗄️ Data Storage

The collected data is stored in a **MySQL database**, which is containerized using **Docker**.

Why Docker?
- Ensures consistency across systems  
- Easy to set up and run  
- Avoids dependency issues  

---

## 🧹 Data Preprocessing

Before analysis, the data was cleaned and prepared:

- Handled missing/null values  
- Converted timestamps to proper datetime format  
- Sorted data chronologically  
- Structured data for time series modeling  

---

## 📈 Exploratory Data Analysis (EDA)

Initial analysis was performed to understand:

- Pollution trends over time  
- Differences across cities  
- Peak pollution periods  

This helped in selecting PM2.5 as the primary variable for forecasting.

---

## 🤖 Model Building

The **ARIMA (AutoRegressive Integrated Moving Average)** model was used for forecasting PM2.5 values.

### Why ARIMA?
- Suitable for time series data  
- Captures trends effectively  
- Easy to interpret  

---

## 🔮 Forecasting

The model was trained on historical data and used to predict future PM2.5 values.

These predictions were then compared with actual values to evaluate performance.

---

## 📉 Error Analysis

To understand model performance:

- Error = Actual - Predicted  
- Error trends were analyzed over time  

This helped identify limitations of the model, especially in handling sudden spikes.

---

## 📊 Power BI Dashboard

An interactive dashboard was created in Power BI to visualize insights:

### Key Visuals:
- PM2.5 Trend Over Time  
- City-wise Pollution Comparison  
- Actual vs Predicted Values  
- Error Over Time  
- Peak Pollution Days  

The dashboard allows filtering by city and provides a clear overview of pollution patterns.

---

## 🐳 Docker Setup

The MySQL database is containerized using Docker.

### To run the database:

```bash
docker-compose up -d