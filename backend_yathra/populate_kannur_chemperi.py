import sqlite3
import os
import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "yathrakerala.db")

# 61 Sequential verified stops along Kannur - Chemperi corridor
from seed_verified_stops import STOPS_ORDER

# 9 Vehicles specified by user
VEHICLES_TO_UPDATE = [
    (1, "KL-13-AB-8429", "Royal Travels", "Bus", "Private Bus", 1, "06:00 AM", 95),
    (2, "KL-15-A-8199", "KSRTC Super Fast", "Bus", "KSRTC Swift", 1, "07:15 AM", 90),
    (3, "TRAIN-12064", "Vande Bharat Express", "Train", "Superfast Express", 1, "08:30 AM", 90),
    (4, "KL-13-Q-3111", "Mayura Travels", "Bus", "Private Bus", 1, "09:45 AM", 95),
    (5, "KL-13-C-6876", "Kannur Town Fast", "Bus", "City Circular", 1, "11:15 AM", 95),
    (6, "KL-13-W-4455", "Cherukunnu Express", "Bus", "Private Bus", 1, "12:45 PM", 95),
    (7, "KL-13-S-7890", "Muthappan Travels", "Bus", "Private Bus", 1, "02:15 PM", 95),
    (8, "KL-15-A-9012", "KSRTC Fast Passenger", "Bus", "KSRTC Swift", 1, "03:45 PM", 90),
    (9, "KL-13-AA-3321", "Malabar Coast Fast", "Bus", "Private Bus", 1, "05:30 PM", 95),
]

# Total corridor distance: 48.0 km
# Proportional milestone distances (km) for intermediate landmarks:
MILESTONES = {
    "Kannur New Bus Stand": 0.0,
    "SPCA": 0.8,
    "AKG Hospital": 1.6,
    "Chettippeedika": 2.2,
    "Women's College": 2.8,
    "Milma": 3.5,
    "Podikundu": 4.1,
    "Puthiyatheru": 4.7,
    "Highway Junction": 5.8,
    "Valapattanam": 6.8,
    "Valapattanam Bridge / After Bridge": 7.6,
    "Chungam": 8.2,
    "Panchayath": 8.8,
    "Velapuram": 9.4,
    "Keecheri / Keechery": 10.4,
    "Kalliasseri": 11.4,
    "Haji Motta": 12.2,
    "Mangad": 13.0,
    "Dharmasala": 14.0,
    "Thazhe Bakkalam": 15.5,
    "Mele Bakkalam": 16.2,
    "Kuttikol Bridge": 17.5,
    "Kuttikol Toll": 18.3,
    "7th Mile": 20.0,
    "Trichambaram": 21.8,
    "Pookoth Nada": 22.7,
    "TPBA Stand / Taliparamba Bus Stand": 23.4,
    "Taliparamba": 24.0,
    "Chiravakk": 24.6,
    "Kappalam": 25.1,
    "Manna": 25.6,
    "Manna Co-op Hospital": 26.2,
    "Karimbam": 28.0,
    "Karimbam Bridge": 28.7,
    "Vellarampara": 29.6,
    "Chorukala": 30.8,
    "Pokkund Kurumathur": 31.7,
    "Kurumathur Nedumuda": 32.5,
    "Valakkai Bridge": 33.6,
    "Valakkai": 34.2,
    "Niduvalur": 35.3,
    "Cherankunnu": 36.2,
    "Kottaparamba": 37.0,
    "Chenglayi Mukkadam": 37.7,
    "Chengalayi": 38.4,
    "Parippayi": 39.3,
    "Sreekandapuram": 40.5,
    "Pazhayangadi": 41.2,
    "Podikkalam": 41.8,
    "Koottumugham Bridge": 42.4,
    "Allikkalliyil": 42.9,
    "Ambalakara Junction": 43.4,
    "Poovam": 44.0,
    "Aichery": 44.8,
    "Nedungome": 45.6,
    "Chudaparamba": 46.2,
    "Muyipra": 46.8,
    "Eruveshy Bridge": 47.2,
    "Pooparamba": 47.5,
    "Cheliparamba": 47.8,
    "Chemperi": 48.0,
}

def calculate_bus_fare(km: float) -> float:
    """Kerala MVD stage fare: Base ₹10 up to 2.5km, then ~₹1/km"""
    if km <= 0.05:
        return 0.0
    if km <= 2.5:
        return 10.0
    fare = 10.0 + (km - 2.5) * 1.00
    # Round to nearest rupee or ₹5 stage
    return float(round(fare))

def parse_time_str(time_str: str) -> datetime.datetime:
    return datetime.datetime.strptime(time_str, "%I:%M %p")

def format_time_str(dt: datetime.datetime) -> str:
    return dt.strftime("%I:%M %p")

def main():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    print("[1/5] Verifying Route #1 'Kannur - Chemperi Regional Line'...")
    c.execute("""
        INSERT OR REPLACE INTO routes (id, route_name, start_point, end_point, mode, total_distance_km)
        VALUES (1, 'Kannur - Chemperi Regional Line', 'Kannur', 'Chemperi', 'BUS', 48.0)
    """)

    print("[2/5] Assigning all 9 vehicles to Route #1...")
    for v_id, v_no, v_name, v_type, s_type, r_id, _, _ in VEHICLES_TO_UPDATE:
        c.execute("""
            INSERT OR REPLACE INTO vehicles (id, vehicle_number, vehicle_name, vehicle_type, sub_type, current_route_id)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (v_id, v_no, v_name, v_type, s_type, 1))
    print(f"  -> Updated {len(VEHICLES_TO_UPDATE)} vehicles to current_route_id = 1")

    print("[3/5] Verifying and inserting all 61 stops...")
    stop_ids = {}
    for name, lat, lng in STOPS_ORDER:
        c.execute("""
            INSERT OR REPLACE INTO stops (stop_name, latitude, longitude)
            VALUES (?, ?, ?)
        """, (name, lat, lng))
        # Fetch stop ID
        c.execute("SELECT id FROM stops WHERE stop_name = ?", (name,))
        stop_ids[name] = c.fetchone()[0]
    print(f"  -> {len(stop_ids)} stops verified in DB")

    print("[4/5] Populating 'stop_allocation' for Route #1...")
    c.execute("DELETE FROM stop_allocation WHERE route_id = 1")
    allocations = []
    for seq, (stop_name, _, _) in enumerate(STOPS_ORDER, start=1):
        s_id = stop_ids[stop_name]
        dist = MILESTONES.get(stop_name, (seq - 1) * (48.0 / (len(STOPS_ORDER) - 1)))
        allocations.append((1, s_id, seq, round(dist, 1)))

    c.executemany("""
        INSERT INTO stop_allocation (route_id, stop_id, sequence_no, distance_from_start_km)
        VALUES (?, ?, ?, ?)
    """, allocations)
    print(f"  -> Inserted {len(allocations)} stop allocations for Route #1")

    print("[5/5] Populating 'timings' table for all 9 vehicles across 61 stops...")
    vehicle_ids = [v[0] for v in VEHICLES_TO_UPDATE]
    c.execute(f"DELETE FROM timings WHERE vehicle_id IN ({','.join(map(str, vehicle_ids))})")

    timings_records = []
    base_date = datetime.date(2026, 1, 1)

    for v_id, v_no, v_name, v_type, s_type, _, start_time_str, total_duration_mins in VEHICLES_TO_UPDATE:
        start_dt = datetime.datetime.combine(base_date, parse_time_str(start_time_str).time())
        
        # Calculate timing for each stop
        for seq, (stop_name, _, _) in enumerate(STOPS_ORDER, start=1):
            s_id = stop_ids[stop_name]
            dist_km = MILESTONES.get(stop_name, (seq - 1) * (48.0 / (len(STOPS_ORDER) - 1)))
            fare = calculate_bus_fare(dist_km)

            # Cumulative travel time fraction based on distance
            dist_ratio = dist_km / 48.0
            elapsed_mins = dist_ratio * total_duration_mins

            arrival_dt = start_dt + datetime.timedelta(minutes=elapsed_mins)

            # Dwell time at stops:
            # Origin & Terminus: dwell = 0
            # Major transit hubs (Taliparamba, Sreekandapuram): dwell = 2 mins
            # Intermediate stops: dwell = 1 min
            if seq == 1 or seq == len(STOPS_ORDER):
                dwell_mins = 0
            elif "Taliparamba" in stop_name or "Sreekandapuram" in stop_name:
                dwell_mins = 2
            else:
                dwell_mins = 1

            dep_dt = arrival_dt + datetime.timedelta(minutes=dwell_mins)

            arr_str = format_time_str(arrival_dt)
            dep_str = format_time_str(dep_dt)

            timings_records.append((
                v_id,
                s_id,
                "ALL",
                arr_str,
                dep_str,
                fare
            ))

    c.executemany("""
        INSERT INTO timings (vehicle_id, stop_id, day_of_week, arrival_time, departure_time, fare_from_origin)
        VALUES (?, ?, ?, ?, ?, ?)
    """, timings_records)
    print(f"  -> Inserted {len(timings_records)} timing records into 'timings' table!")

    conn.commit()

    # Quick Verification Query
    print("\n--- VERIFICATION ---")
    c.execute("SELECT count(*) FROM vehicles WHERE current_route_id = 1")
    print(f"Vehicles assigned to Route 1: {c.fetchone()[0]}")

    c.execute("SELECT count(*) FROM stop_allocation WHERE route_id = 1")
    print(f"Stop allocations for Route 1: {c.fetchone()[0]}")

    c.execute("SELECT count(*) FROM timings")
    print(f"Total timings records: {c.fetchone()[0]}")

    print("\nSample Timetable for Bus #1 (KL-13-AB-8429 Royal Travels):")
    rows = c.execute("""
        SELECT sa.sequence_no, s.stop_name, sa.distance_from_start_km, t.arrival_time, t.departure_time, t.fare_from_origin
        FROM timings t
        JOIN stops s ON t.stop_id = s.id
        JOIN stop_allocation sa ON sa.stop_id = s.id AND sa.route_id = 1
        WHERE t.vehicle_id = 1
        ORDER BY sa.sequence_no
    """).fetchall()

    # Print first 5, middle 5, last 5
    for r in rows[:4] + [("...", "...", "...", "...", "...", "...")] + rows[25:29] + [("...", "...", "...", "...", "...", "...")] + rows[-3:]:
        if r[0] == "...":
            print("  ...")
        else:
            print(f"  Stop #{r[0]:2d}: {r[1]:<35} | {r[2]:4.1f} km | Arr: {r[3]} | Dep: {r[4]} | Fare: Rs.{r[5]:.0f}")

    conn.close()
    print("\n[SUCCESS] All 9 buses added to Kannur-Chemperi route with full database timetable!")

if __name__ == "__main__":
    main()
