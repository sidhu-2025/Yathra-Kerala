import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "yathrakerala.db")

STOPS_ORDER = [
    ("Kannur New Bus Stand", 11.8715, 75.3725),
    ("SPCA", 11.8740, 75.3710),
    ("AKG Hospital", 11.8810, 75.3660),
    ("Chettippeedika", 11.8845, 75.3670),
    ("Women's College", 11.8890, 75.3680),
    ("Milma", 11.8940, 75.3665),
    ("Podikundu", 11.8980, 75.3655),
    ("Puthiyatheru", 11.9020, 75.3650),
    ("Highway Junction", 11.9120, 75.3620),
    ("Valapattanam", 11.9210, 75.3600),
    ("Valapattanam Bridge / After Bridge", 11.9280, 75.3590),
    ("Chungam", 11.9320, 75.3600),
    ("Panchayath", 11.9360, 75.3610),
    ("Velapuram", 11.9400, 75.3620),
    ("Keecheri / Keechery", 11.9470, 75.3625),
    ("Kalliasseri", 11.9540, 75.3620),
    ("Haji Motta", 11.9590, 75.3650),
    ("Mangad", 11.9630, 75.3680),
    ("Dharmasala", 11.9680, 75.3710),
    ("Thazhe Bakkalam", 11.9790, 75.3730),
    ("Mele Bakkalam", 11.9840, 75.3720),
    ("Kuttikol Bridge", 11.9950, 75.3680),
    ("Kuttikol Toll", 12.0010, 75.3670),
    ("7th Mile", 12.0150, 75.3630),
    ("Trichambaram", 12.0310, 75.3600),
    ("Pookoth Nada", 12.0380, 75.3580),
    ("TPBA Stand / Taliparamba Bus Stand", 12.0425, 75.3565),
    ("Taliparamba", 12.0436, 75.3562),
    ("Chiravakk", 12.0450, 75.3550),
    ("Kappalam", 12.0460, 75.3540),
    ("Manna", 12.0400, 75.3500),
    ("Manna Co-op Hospital", 12.0380, 75.3520),
    ("Karimbam", 12.0350, 75.3780),
    ("Karimbam Bridge", 12.0340, 75.3830),
    ("Vellarampara", 12.0320, 75.3910),
    ("Chorukala", 12.0300, 75.4010),
    ("Pokkund Kurumathur", 12.0260, 75.4080),
    ("Kurumathur Nedumuda", 12.0230, 75.4120),
    ("Valakkai Bridge", 12.0220, 75.4210),
    ("Valakkai", 12.0210, 75.4260),
    ("Niduvalur", 12.0220, 75.4350),
    ("Cherankunnu", 12.0240, 75.4420),
    ("Kottaparamba", 12.0250, 75.4490),
    ("Chenglayi Mukkadam", 12.0260, 75.4540),
    ("Chengalayi", 12.0270, 75.4590),
    ("Parippayi", 12.0280, 75.4660),
    ("Sreekandapuram", 12.0289, 75.4744),
    ("Pazhayangadi", 12.0295, 75.4800),
    ("Podikkalam", 12.0300, 75.4850),
    ("Koottumugham Bridge", 12.0305, 75.4900),
    ("Allikkalliyil", 12.0310, 75.4940),
    ("Ambalakara Junction", 12.0315, 75.4980),
    ("Poovam", 12.0320, 75.5030),
    ("Aichery", 12.0330, 75.5090),
    ("Nedungome", 12.0340, 75.5150),
    ("Chudaparamba", 12.0350, 75.5200),
    ("Muyipra", 12.0370, 75.5250),
    ("Eruveshy Bridge", 12.0385, 75.5270),
    ("Pooparamba", 12.0390, 75.5280),
    ("Cheliparamba", 12.0420, 75.5350),
    ("Chemperi", 12.0469, 75.5451)
]

def update_stops_in_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    for name, lat, lng in STOPS_ORDER:
        c.execute("""
            INSERT OR REPLACE INTO stops (stop_name, latitude, longitude)
            VALUES (?, ?, ?);
        """, (name, lat, lng))
    conn.commit()
    conn.close()
    print(f"Successfully added/updated {len(STOPS_ORDER)} stops in yathrakerala.db")

if __name__ == "__main__":
    update_stops_in_db()
