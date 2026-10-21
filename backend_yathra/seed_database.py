"""
Database Setup and Seeder for YathraKerala
Creates all tables matching ER Diagram (Slide 29):
- auth_user / users
- routes
- stops
- stop_allocation
- timings
- vehicles
- gps_tracking
- travel_history
- eta_prediction
- taxi_rates

Seeds rich dummy data for Kannur / Chemperi / Malabar transit network.
"""

import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "yathrakerala.db")

def init_and_seed_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Enable foreign keys
    cursor.execute("PRAGMA foreign_keys = ON;")

    # 1. Users Table (Slide 29: auth_user, user, login, email, phone)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user' -- 'user', 'driver', 'admin'
    );
    """)

    # 2. Routes Table (Slide 29: route, start_point, end_point)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_name TEXT NOT NULL,
        start_point TEXT NOT NULL,
        end_point TEXT NOT NULL,
        mode TEXT NOT NULL DEFAULT 'BUS', -- 'BUS', 'TRAIN'
        total_distance_km REAL NOT NULL
    );
    """)

    # 3. Stops Table (Slide 29: stop, stop_name, stop_no, latitude, longitude)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS stops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stop_name TEXT UNIQUE NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
    );
    """)

    # 4. Stop Allocation (Slide 29: stop_allocation, stop_id, route_id, sequence_no)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS stop_allocation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER NOT NULL,
        stop_id INTEGER NOT NULL,
        sequence_no INTEGER NOT NULL,
        distance_from_start_km REAL NOT NULL,
        FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
        FOREIGN KEY (stop_id) REFERENCES stops(id) ON DELETE CASCADE
    );
    """)

    # 5. Vehicles Table (Slide 29: vehicle, vehicle_number, vehicle_type, sub_type)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_number TEXT UNIQUE NOT NULL,
        vehicle_name TEXT NOT NULL,
        vehicle_type TEXT NOT NULL, -- 'Bus', 'Train', 'Auto', 'Taxi'
        sub_type TEXT NOT NULL,     -- 'KSRTC Swift', 'Private Bus', 'Vande Bharat', 'Auto'
        current_route_id INTEGER,
        FOREIGN KEY (current_route_id) REFERENCES routes(id)
    );
    """)

    # 6. Timings Table (Slide 29: timings, day, arrival, departure)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS timings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        stop_id INTEGER NOT NULL,
        day_of_week TEXT NOT NULL DEFAULT 'ALL',
        arrival_time TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        fare_from_origin REAL NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
        FOREIGN KEY (stop_id) REFERENCES stops(id) ON DELETE CASCADE
    );
    """)

    # 7. GPS Tracking Table (Slide 29: tracking_id, vehicle_id, latitude, longitude, speed)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS gps_tracking (
        tracking_id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        speed REAL NOT NULL,
        current_stop TEXT,
        next_stop TEXT,
        delay_mins INTEGER DEFAULT 0,
        recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
    );
    """)

    # 8. Travel History & ML ETA Prediction (Slide 29: travel_history, eta_prediction)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS travel_history (
        history_id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        route_id INTEGER NOT NULL,
        stop_id INTEGER NOT NULL,
        arrival_time TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        travel_duration_mins REAL NOT NULL,
        weather_condition TEXT NOT NULL,
        traffic_level INTEGER NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
        FOREIGN KEY (route_id) REFERENCES routes(id),
        FOREIGN KEY (stop_id) REFERENCES stops(id)
    );
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS eta_prediction (
        prediction_id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        route_id INTEGER NOT NULL,
        prediction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        predicted_arrival_time TEXT NOT NULL,
        predicted_duration_mins REAL NOT NULL,
        model_name TEXT DEFAULT 'Random Forest',
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
        FOREIGN KEY (route_id) REFERENCES routes(id)
    );
    """)

    # 9. Taxi & Auto Fare Configuration (Slide 24: Taxi Database - Cost Per Kilometer)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS taxi_fares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transport_type TEXT UNIQUE NOT NULL, -- 'Auto', 'Taxi Hatchback', 'Taxi Sedan'
        base_fare REAL NOT NULL,
        base_distance_km REAL NOT NULL,
        per_km_rate REAL NOT NULL,
        waiting_charge_per_hour REAL NOT NULL
    );
    """)

    # ---------------- SEED DUMMY DATA ----------------

    # Clean previous records in dependent order
    cursor.execute("DELETE FROM travel_history;")
    cursor.execute("DELETE FROM eta_prediction;")
    cursor.execute("DELETE FROM gps_tracking;")
    cursor.execute("DELETE FROM timings;")
    cursor.execute("DELETE FROM stop_allocation;")
    cursor.execute("DELETE FROM vehicles;")
    cursor.execute("DELETE FROM routes;")
    cursor.execute("DELETE FROM stops;")
    cursor.execute("DELETE FROM users;")
    cursor.execute("DELETE FROM taxi_fares;")

    # Users
    cursor.executemany("""
    INSERT INTO users (username, password, name, email, phone, role) VALUES (?, ?, ?, ?, ?, ?);
    """, [
        ("user1", "pass123", "Abhijith K", "abhijith@vjec.ac.in", "9847123456", "user"),
        ("user2", "pass123", "Sidharth P", "sidharth@vjec.ac.in", "9847234567", "user"),
        ("driver1", "driver123", "Ramesh Driver", "ramesh@keralatransit.in", "9447112233", "driver"),
        ("driver2", "driver123", "Suresh Conductor", "suresh@keralatransit.in", "9447998877", "driver"),
        ("admin", "admin123", "Transport Admin", "admin@yathrakerala.gov.in", "9995001122", "admin"),
    ])
    stops_data = [
        ("Chemperi", 12.0469, 75.5451),
        ("Pooparamba", 12.0390, 75.5280),
        ("Madampam", 12.0310, 75.4980),
        ("Sreekandapuram", 12.0289, 75.4744),
        ("Kurumathur", 12.0230, 75.4120),
        ("Karimbam", 12.0350, 75.3780),
        ("Taliparamba", 12.0436, 75.3562),
        ("Dharmasala", 11.9680, 75.3710),
        ("Kalliasseri", 11.9540, 75.3620),
        ("Puthiyatheru", 11.9020, 75.3650),
        ("Pallikunnu", 11.8840, 75.3680),
        ("Caltex", 11.8745, 75.3704),
        ("Kannur Railway Station", 11.8705, 75.3644),
        ("Thalassery", 11.7491, 75.4890),
        ("Thalassery Railway Station", 11.7510, 75.4920),
        ("Vadakara", 11.6040, 75.5910),
        ("Kozhikode", 11.2588, 75.7804),
        ("Kozhikode Railway Station", 11.2480, 75.7830),
        ("Payyambalam Beach", 11.8685, 75.3480),
        ("Iritty", 11.9830, 75.6660),
        ("Mattannur", 11.9330, 75.5780),
        ("Payyanur", 12.1020, 75.2010),
    ]
    cursor.executemany("INSERT INTO stops (stop_name, latitude, longitude) VALUES (?, ?, ?);", stops_data)

    # Routes
    cursor.execute("DELETE FROM routes;")
    cursor.executemany("""
    INSERT INTO routes (id, route_name, start_point, end_point, mode, total_distance_km) VALUES (?, ?, ?, ?, ?, ?);
    """, [
        (1, "Kannur - Chemperi Regional Line", "Kannur", "Chemperi", "BUS", 48.0),
        (2, "Kannur - Kozhikode Highway Express", "Kannur", "Kozhikode", "BUS", 90.0),
        (3, "Malabar Vande Bharat Train Corridor", "Kannur Railway Station", "Kozhikode Railway Station", "TRAIN", 89.0),
        (4, "Chemperi - Taliparamba Feeder", "Chemperi", "Taliparamba", "BUS", 24.0),
        (5, "Kannur City Circular", "Kannur Railway Station", "Payyambalam Beach", "BUS", 5.0),
    ])

    # Vehicles
    cursor.execute("DELETE FROM vehicles;")
    cursor.executemany("""
    INSERT INTO vehicles (id, vehicle_number, vehicle_name, vehicle_type, sub_type, current_route_id) VALUES (?, ?, ?, ?, ?, ?);
    """, [
        (1, "KL-13-AB-8429", "Royal Travels", "Bus", "Private Bus", 1),
        (2, "KL-15-A-8199", "KSRTC Super Fast", "Bus", "KSRTC Swift", 2),
        (3, "TRAIN-12064", "Vande Bharat Express", "Train", "Superfast Express", 3),
        (4, "KL-13-Q-3111", "Mayura Travels", "Bus", "Private Bus", 4),
        (5, "KL-13-C-6876", "Kannur Town Fast", "Bus", "City Circular", 5),
    ])

    # GPS Tracking Live State
    cursor.execute("DELETE FROM gps_tracking;")
    cursor.executemany("""
    INSERT INTO gps_tracking (vehicle_id, latitude, longitude, speed, current_stop, next_stop, delay_mins) VALUES (?, ?, ?, ?, ?, ?, ?);
    """, [
        (1, 12.0289, 75.4744, 42.0, "Sreekandapuram", "Madampam", 2),
        (2, 11.7491, 75.4890, 58.0, "Thalassery", "Vadakara", 4),
        (3, 11.8100, 75.4600, 95.0, "Kannur Railway Station", "Thalassery Railway Station", 0),
    ])

    # Taxi Fares Table (Slide 24)
    cursor.execute("DELETE FROM taxi_fares;")
    cursor.executemany("""
    INSERT INTO taxi_fares (transport_type, base_fare, base_distance_km, per_km_rate, waiting_charge_per_hour) VALUES (?, ?, ?, ?, ?);
    """, [
        ("Auto", 30.0, 1.5, 15.0, 30.0),
        ("Taxi Hatchback", 120.0, 3.0, 20.0, 60.0),
        ("Taxi Sedan", 180.0, 3.0, 25.0, 80.0),
    ])

    # Fetch real stop IDs for insertion
    cursor.execute("SELECT id FROM stops LIMIT 5;")
    stop_ids = [row[0] for row in cursor.fetchall()]
    s1 = stop_ids[0] if len(stop_ids) > 0 else 1
    s2 = stop_ids[1] if len(stop_ids) > 1 else 1

    cursor.executemany("""
    INSERT INTO travel_history (vehicle_id, route_id, stop_id, arrival_time, departure_time, travel_duration_mins, weather_condition, traffic_level) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """, [
        (1, 1, s1, "08:00 AM", "08:02 AM", 24.5, "Clear", 1),
        (1, 1, s2, "08:26 AM", "08:28 AM", 18.0, "Light Rain", 2),
        (2, 2, s1, "09:15 AM", "09:20 AM", 45.0, "Heavy Rain", 2),
        (2, 2, s2, "10:05 AM", "10:08 AM", 38.0, "Clear", 0),
        (3, 3, s1, "07:45 AM", "07:47 AM", 22.0, "Clear", 0),
    ])

    conn.commit()
    conn.close()
    print("[SUCCESS] Successfully initialized SQLite database (yathrakerala.db) with rich dummy data matching all ER Diagram entities!")

if __name__ == "__main__":
    init_and_seed_db()
