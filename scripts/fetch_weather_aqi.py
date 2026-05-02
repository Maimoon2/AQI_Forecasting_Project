import requests
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("OPENWEATHER_API_KEY")

cities = {
    "Delhi": (28.61, 77.23),
    "Mumbai": (19.07, 72.87),
    "Kolkata": (22.57, 88.36),
    "Chennai": (13.08, 80.27),
    "Bengaluru": (12.97, 77.59),
    "Hyderabad": (17.38, 78.48),
    "Pune": (18.52, 73.85),
    "Jaipur": (26.91, 75.79),
    "Udaipur": (24.58, 73.68),
    "Champaran": (26.65, 84.90),
    "Lucknow": (26.85, 80.95),
    "Patna": (25.61, 85.14)
}

url = "http://api.openweathermap.org/data/2.5/air_pollution/history"

all_rows = []

for city, (lat, lon) in cities.items():
    params = {
        "lat": lat,
        "lon": lon,
        "start": 1680000000,
        "end": 1705000000,
        "appid": API_KEY
    }

    response = requests.get(url, params=params).json()

    if "list" in response:
        for item in response["list"]:
            row = item["components"]
            row["timestamp"] = item["dt"]
            row["city"] = city
            all_rows.append(row)

df = pd.DataFrame(all_rows)

print("Total rows collected:", len(df))
print(df.head())

df.to_csv("data/raw/weather_aqi_raw.csv", index=False)
print("\nDataset saved to data/raw/weather_aqi_raw.csv")