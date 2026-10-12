"""
Train and export Random Forest Arrival Time Prediction Model
Based on Slide 10 & 14: Random Forest model for bus arrival time prediction
using segment distance, weather condition, hour of day, and traffic level.
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
import joblib
import os

def generate_and_train():
    np.random.seed(42)
    n_samples = 3000

    # Features:
    # 1. distance_km: 1.0 to 35.0 km
    distance_km = np.random.uniform(1.0, 35.0, n_samples)
    
    # 2. hour_of_day: 6 to 22 (6 AM to 10 PM)
    hour_of_day = np.random.randint(6, 23, n_samples)
    
    # 3. traffic_level: 0 (Low), 1 (Medium), 2 (High / Rush hour)
    # Peak hours around 8-10 AM and 4-7 PM have higher probability of traffic
    traffic_level = []
    for h in hour_of_day:
        if h in [8, 9, 10, 16, 17, 18, 19]:
            traffic_level.append(np.random.choice([1, 2], p=[0.3, 0.7]))
        else:
            traffic_level.append(np.random.choice([0, 1], p=[0.7, 0.3]))
    traffic_level = np.array(traffic_level)

    # 4. weather_impact: 0 (Clear), 1 (Rain/Monsoon - typical in Kerala)
    weather_impact = np.random.choice([0, 1], size=n_samples, p=[0.75, 0.25])

    # 5. num_stops: roughly 1 to 2 stops per 2 km
    num_stops = np.clip((distance_km * np.random.uniform(0.8, 1.5)).astype(int), 1, 30)

    # Calculate actual arrival/travel time in minutes with realistic variations
    # Base speed ~ 30 km/h -> 2 mins/km
    base_time = distance_km * 2.0
    dwell_time = num_stops * 1.2  # 1.2 mins per stop dwell
    traffic_penalty = traffic_level * 6.5
    weather_penalty = weather_impact * 5.0
    noise = np.random.normal(0, 2.0, n_samples)

    travel_time_minutes = base_time + dwell_time + traffic_penalty + weather_penalty + noise
    travel_time_minutes = np.maximum(travel_time_minutes, 3.0) # minimum 3 mins

    df = pd.DataFrame({
        'distance_km': distance_km,
        'hour_of_day': hour_of_day,
        'traffic_level': traffic_level,
        'weather_impact': weather_impact,
        'num_stops': num_stops,
        'travel_time_minutes': travel_time_minutes
    })

    X = df[['distance_km', 'hour_of_day', 'traffic_level', 'weather_impact', 'num_stops']]
    y = df['travel_time_minutes']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    rf_model = RandomForestRegressor(n_estimators=100, max_depth=12, random_state=42)
    rf_model.fit(X_train, y_train)

    train_score = rf_model.score(X_train, y_train)
    test_score = rf_model.score(X_test, y_test)
    print(f"Random Forest Model Trained! Train R2: {train_score:.3f}, Test R2: {test_score:.3f}")

    os.makedirs('backend_yathra/models', exist_ok=True)
    model_path = 'backend_yathra/models/eta_rf_model.pkl'
    joblib.dump(rf_model, model_path)
    print(f"Model saved to {model_path}")

if __name__ == '__main__':
    generate_and_train()
