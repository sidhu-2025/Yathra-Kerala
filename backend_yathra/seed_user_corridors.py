import sqlite3
import os

db_path = os.path.join(r"c:\Users\Asus\OneDrive\Desktop\program\PROJECT\backend_yathra", "yathrakerala.db")

# Accurate GPS coordinates for the corridors
CORRIDOR_DATA = {
    "kannur_cherukunnu": {
        "route_name": "Kannur - Cherukunnu Passenger Line",
        "start": "Kannur New Bus Stand",
        "end": "Cherukunnu",
        "distance": 16.5,
        "stops": [
            ("Kannur New Bus Stand", 11.8745, 75.3704),
            ("SPCA", 11.8770, 75.3685),
            ("AKG Hospital", 11.8810, 75.3660),
            ("Chettippeedika", 11.8850, 75.3640),
            ("Women's College", 11.8890, 75.3620),
            ("Milma", 11.8940, 75.3610),
            ("Podikundu", 11.8990, 75.3600),
            ("Puthiyatheru", 11.9050, 75.3580),
            ("Highway Junction", 11.9120, 75.3560),
            ("Valapattanam", 11.9170, 75.3550),
            ("Valapattanam Bridge / After Bridge", 11.9230, 75.3540),
            ("Kaattile Palli", 11.9310, 75.3510),
            ("Haji Road", 11.9370, 75.3470),
            ("High School", 11.9440, 75.3430),
            ("Puthiya Kavu", 11.9510, 75.3390),
            ("Karikkankulam", 11.9580, 75.3350),
            ("Kottappalam", 11.9640, 75.3310),
            ("Irinav Road", 11.9700, 75.3280),
            ("Kallushop", 11.9750, 75.3250),
            ("Kannapuram Bridge", 11.9800, 75.3220),
            ("Kannapuram Railway Station", 11.9830, 75.3200),
            ("Cherukunnu", 11.9860, 75.3210),
        ],
        "bus": ("KL-13-W-4455", "Cherukunnu Express", "Private Bus")
    },
    "kannur_parassinikadavu": {
        "route_name": "Kannur - Parassinikadavu Pilgrim Line",
        "start": "Kannur",
        "end": "Parassinikadavu Bus Stand",
        "distance": 20.0,
        "stops": [
            ("Kannur", 11.8745, 75.3704),
            ("Dharmasala", 11.9690, 75.3570),
            ("Government College of Engineering Kannur", 11.9730, 75.3600),
            ("All India Radio", 11.9770, 75.3640),
            ("Parassinikkadavu Snake Park", 11.9820, 75.3700),
            ("Kolmotta", 11.9860, 75.3740),
            ("Vismaya", 11.9900, 75.3790),
            ("Parassinikadavu Bus Stand", 11.9940, 75.3850),
        ],
        "bus": ("KL-13-S-7890", "Muthappan Travels", "Private Bus")
    },
    "kannur_iritty": {
        "route_name": "Kannur - Mattannur - Iritty Express Line",
        "start": "Kannur",
        "end": "Iritty Bus Stand",
        "distance": 41.5,
        "stops": [
            ("Kannur", 11.8745, 75.3704),
            ("Thana", 11.8680, 75.3810),
            ("Kannothumchal", 11.8660, 75.3880),
            ("Mele Chovva", 11.8650, 75.3950),
            ("Vaidya Peedika", 11.8690, 75.4050),
            ("Panchayath Office", 11.8730, 75.4130),
            ("Chettirakkunnu", 11.8760, 75.4200),
            ("Varam", 11.8790, 75.4280),
            ("Variyannur", 11.8820, 75.4350),
            ("Madhukoth", 11.8840, 75.4410),
            ("Eachur", 11.8870, 75.4480),
            ("Kudukimotta", 11.8900, 75.4560),
            ("Kanjir Road", 11.8920, 75.4660),
            ("Kumbam", 11.8940, 75.4760),
            ("Chalode", 11.8950, 75.4980),
            ("Veliyannur", 11.9010, 75.5120),
            ("Perool", 11.9070, 75.5250),
            ("Nagavalavu", 11.9140, 75.5390),
            ("Kodheri", 11.9210, 75.5530),
            ("Vayanthode", 11.9270, 75.5650),
            ("Mattannur", 11.9330, 75.5780),
            ("Mattannur Polytechnic", 11.9410, 75.5900),
            ("19th Mile", 11.9510, 75.6100),
            ("Uliyil", 11.9560, 75.6210),
            ("Keezhur", 11.9610, 75.6320),
            ("Peravoor Road", 11.9720, 75.6490),
            ("Iritty Bus Stand", 11.9830, 75.6660),
        ],
        "bus": ("KL-15-A-9012", "KSRTC Fast Passenger", "KSRTC Swift")
    },
    "kannur_thalassery": {
        "route_name": "Kannur - Thalassery Coastal Highway Line",
        "start": "Kannur",
        "end": "Thalassery New Bus Stand",
        "distance": 21.5,
        "stops": [
            ("Kannur", 11.8745, 75.3704),
            ("Thana", 11.8680, 75.3810),
            ("Kannothumchal", 11.8660, 75.3880),
            ("Mele Chovva", 11.8650, 75.3950),
            ("Thazhe Chovva", 11.8590, 75.4020),
            ("Thottada", 11.8280, 75.4320),
            ("Nadaal", 11.8150, 75.4410),
            ("Edakkad", 11.8020, 75.4490),
            ("Muzhappilangad", 11.7920, 75.4520),
            ("Moydu Paalam", 11.7820, 75.4610),
            ("Dharmadam Railway Station", 11.7740, 75.4740),
            ("Meethale Peedika", 11.7660, 75.4790),
            ("Koduvally", 11.7580, 75.4830),
            ("Kodiyeri", 11.7530, 75.4860),
            ("Thalassery Old Bus Stand", 11.7491, 75.4890),
            ("Thalassery New Bus Stand", 11.7470, 75.4920),
        ],
        "bus": ("KL-13-AA-3321", "Malabar Coast Fast", "Private Bus")
    }
}

conn = sqlite3.connect(db_path)
c = conn.cursor()

# 1. Insert/update stops
all_stops_dict = {}
for c_key, data in CORRIDOR_DATA.items():
    for stop_name, lat, lng in data["stops"]:
        all_stops_dict[stop_name] = (lat, lng)

print(f"Total unique stops to register: {len(all_stops_dict)}")
for stop_name, (lat, lng) in all_stops_dict.items():
    # Check if stop already exists
    row = c.execute("SELECT id FROM stops WHERE stop_name = ?", (stop_name,)).fetchone()
    if row:
        c.execute("UPDATE stops SET latitude = ?, longitude = ? WHERE id = ?", (lat, lng, row[0]))
    else:
        c.execute("INSERT INTO stops (stop_name, latitude, longitude) VALUES (?, ?, ?)", (stop_name, lat, lng))

# 2. Insert/update routes and vehicles
for c_key, data in CORRIDOR_DATA.items():
    r_name = data["route_name"]
    start_p = data["start"]
    end_p = data["end"]
    dist = data["distance"]

    # Check if route exists
    r_row = c.execute("SELECT id FROM routes WHERE route_name = ? OR (start_point = ? AND end_point = ?)", 
                      (r_name, start_p, end_p)).fetchone()
    if r_row:
        route_id = r_row[0]
        c.execute("""
            UPDATE routes 
            SET route_name = ?, start_point = ?, end_point = ?, mode = 'BUS', total_distance_km = ?
            WHERE id = ?
        """, (r_name, start_p, end_p, dist, route_id))
    else:
        c.execute("""
            INSERT INTO routes (route_name, start_point, end_point, mode, total_distance_km)
            VALUES (?, ?, ?, 'BUS', ?)
        """, (r_name, start_p, end_p, dist))
        route_id = c.lastrowid

    # Check if vehicle exists
    v_no, v_name, v_type = data["bus"]
    v_row = c.execute("SELECT id FROM vehicles WHERE vehicle_number = ?", (v_no,)).fetchone()
    if v_row:
        c.execute("""
            UPDATE vehicles
            SET vehicle_name = ?, vehicle_type = 'Bus', sub_type = ?, current_route_id = ?
            WHERE id = ?
        """, (v_name, v_type, route_id, v_row[0]))
    else:
        c.execute("""
            INSERT INTO vehicles (vehicle_number, vehicle_name, vehicle_type, sub_type, current_route_id)
            VALUES (?, ?, 'Bus', ?, ?)
        """, (v_no, v_name, v_type, route_id))

conn.commit()

# Print summary
routes_cnt = c.execute("SELECT COUNT(*) FROM routes").fetchone()[0]
stops_cnt = c.execute("SELECT COUNT(*) FROM stops").fetchone()[0]
veh_cnt = c.execute("SELECT COUNT(*) FROM vehicles").fetchone()[0]
print(f"[SUCCESS] Database updated successfully!")
print(f"Total Routes in DB: {routes_cnt}")
print(f"Total Stops in DB: {stops_cnt}")
print(f"Total Vehicles in DB: {veh_cnt}")
conn.close()
