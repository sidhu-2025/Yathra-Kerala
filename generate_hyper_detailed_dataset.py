import csv
import random
import os
from fpdf import FPDF

# 1. Base realistic routes mapped out through the Kannur network WITH ALL MICRO STOPS
base_routes = [
    # Route: Kannur to Chemperi (including Manna, Pooparamba, Madampam, etc.)
    {"path": "Kannur -> Caltex -> Pallikunnu -> Puthiyatheru -> Kalliasseri -> Dharmasala -> Taliparamba -> Manna -> Karimbam -> Kurumathur -> Sreekandapuram -> Madampam -> Pooparamba -> Chemperi", "fare": 45, "exchanges": "0 (Direct)"},
    {"path": "Chemperi -> Pooparamba -> Madampam -> Sreekandapuram -> Kurumathur -> Karimbam -> Manna -> Taliparamba -> Dharmasala -> Kalliasseri -> Puthiyatheru -> Pallikunnu -> Caltex -> Kannur", "fare": 45, "exchanges": "0 (Direct)"},
    
    # Route: NH66 North (Kannur to Payyanur)
    {"path": "Kannur -> Caltex -> Pallikunnu -> Puthiyatheru -> Kalliasseri -> Dharmasala -> Taliparamba -> Manna -> Pariyaram Medical College -> Pilathara -> Perumba -> Payyanur", "fare": 55, "exchanges": "0 (Direct)"},
    {"path": "Payyanur -> Perumba -> Pilathara -> Pariyaram Medical College -> Manna -> Taliparamba -> Dharmasala -> Kalliasseri -> Puthiyatheru -> Pallikunnu -> Kannur", "fare": 55, "exchanges": "0 (Direct)"},
    
    # Route: Coastal North
    {"path": "Kannur -> Pallikunnu -> Puthiyatheru -> Kattampally -> Pappinisseri -> Cherukunnu -> Pazhayangadi -> Ezhimala -> Ramanthali -> Payyanur", "fare": 50, "exchanges": "0 (Direct)"},
    
    # Route: East to Iritty (SH30)
    {"path": "Kannur -> Caltex -> Mele Chovva -> Mundayad -> Eachur -> Chalode -> Mattannur -> Chavassery -> Keezhur -> Iritty", "fare": 55, "exchanges": "0 (Direct)"},
    {"path": "Iritty -> Keezhur -> Chavassery -> Mattannur -> Chalode -> Eachur -> Mundayad -> Mele Chovva -> Caltex -> Kannur", "fare": 55, "exchanges": "0 (Direct)"},
    
    # Route: Chakkarakkal Route to Mattannur
    {"path": "Kannur -> Mele Chovva -> Kappad -> Chakkarakkal -> Peralassery -> Anjarakandy -> Koodali -> Mattannur", "fare": 40, "exchanges": "0 (Direct)"},
    
    # Route: South to Thalassery
    {"path": "Kannur -> Thavakkara -> SN College -> Thottada -> Edakkad -> Muzhappilangad -> Dharmadam -> Thalassery", "fare": 30, "exchanges": "0 (Direct)"},
    
    # Route: Kannur to Kuthuparamba
    {"path": "Kannur -> Mele Chovva -> Chala -> Nada -> Kadachira -> Mambaram -> Kuthuparamba", "fare": 35, "exchanges": "0 (Direct)"},
    
    # Route: Inter-town Thalassery to Kuthuparamba
    {"path": "Thalassery -> Eranholi -> Kadirur -> Pinarayi -> Mambaram -> Kuthuparamba", "fare": 20, "exchanges": "0 (Direct)"},
    
    # Route: Alakode Hilly Route
    {"path": "Kannur -> Puthiyatheru -> Dharmasala -> Taliparamba -> Manna -> Karimbam -> Oduvalithattu -> Naduvil -> Karuvanchal -> Alakode", "fare": 65, "exchanges": "0 (Direct)"},
    
    # Route: Taliparamba to Sreekandapuram
    {"path": "Taliparamba -> Manna -> Karimbam -> Kurumathur -> Chuzhali -> Sreekandapuram", "fare": 25, "exchanges": "0 (Direct)"},
    
    # Route: Local City
    {"path": "Railway Station -> Caltex -> Talap -> AKG Hospital -> Thavakkara -> New Bus Stand -> Old Bus Stand", "fare": 10, "exchanges": "0 (Direct)"},
    {"path": "Old Bus Stand -> Ayikkara -> City Center -> Payyambalam Beach", "fare": 10, "exchanges": "0 (Direct)"},
    
    # Route: Long Distance Inter-District
    {"path": "Kannur -> Thalassery -> Mahe -> Vadakara -> Payyoli -> Koyilandy -> Kozhikode", "fare": 130, "exchanges": "0 (Direct)"},
    {"path": "Kannur -> Mele Chovva -> Chalode -> Mattannur -> Iritty -> Peravoor -> Boys Town -> Mananthavady", "fare": 140, "exchanges": "0 (Direct)"},
    {"path": "Kannur Airport -> Mattannur -> Koothuparamba -> Thalassery -> Mahe -> Vadakara -> Kozhikode", "fare": 160, "exchanges": "0 (Direct)"}
]

private_names = ["VJEC Express", "Kalyan Travels", "Sree Muthappan", "Royal Travels", "Ocean Line", "Green Line", "Malabar Coach", "P.K. Travels", "Golden Travels", "Mayura", "Brothers", "Sagara", "Navya"]

dataset = []
bus_count = 1
random.seed(999) # Seed for consistent generation

def generate_time(hour_start, minute_start, duration_mins):
    start = f"{hour_start:02d}:{minute_start:02d}"
    end_h = hour_start + (minute_start + duration_mins) // 60
    end_m = (minute_start + duration_mins) % 60
    
    start_ampm = "AM" if hour_start < 12 else "PM"
    end_ampm = "AM" if end_h % 24 < 12 else "PM"
    
    start_fmt = f"{(hour_start % 12) or 12:02d}:{minute_start:02d} {start_ampm}"
    end_fmt = f"{(end_h % 12) or 12:02d}:{end_m:02d} {end_ampm}"
    return f"{start_fmt} -> {end_fmt}"

for i in range(100):
    route = random.choice(base_routes)
    is_ksrtc = random.random() < 0.35 
    
    if route["fare"] == 10: 
        bus_name = f"Private - {random.choice(['City Ride', 'Blue Star', 'Town Fast'])}"
        bus_no = f"KL-13-C-{random.randint(1000, 9999)}"
        duration = random.randint(25, 40)
    elif route["fare"] > 100:
        bus_name = f"KSRTC - {random.choice(['Super Fast', 'Swift Deluxe', 'Fast Passenger'])}"
        bus_no = f"KL-15-A-{random.randint(1000, 9999)}"
        duration = random.randint(140, 200)
    else:
        if is_ksrtc:
            bus_name = f"KSRTC - {random.choice(['Ordinary', 'Fast Passenger', 'Town-to-Town'])}"
            bus_no = f"KL-15-{random.choice(['B', 'C', 'X'])}-{random.randint(1000, 9999)}"
        else:
            bus_name = f"Private - {random.choice(private_names)}"
            bus_no = f"KL-13-{random.choice(['AB', 'EF', 'MM', 'Q', 'K'])}-{random.randint(1000, 9999)}"
        duration = random.randint(60, 110)

    hour = random.randint(5, 20)
    minute = random.choice([0, 10, 15, 20, 30, 40, 45, 50])
    time_str = generate_time(hour, minute, duration)
    
    dataset.append({
        "id": bus_count,
        "bus_name": bus_name,
        "bus_no": bus_no,
        "path": route["path"],
        "time": time_str,
        "fare": route["fare"],
        "exchanges": route["exchanges"]
    })
    bus_count += 1

dataset = sorted(dataset, key=lambda x: (x["time"][-2:], x["time"][:5]))

# 1. Output to CSV
csv_path = os.path.join(os.getcwd(), 'Kannur_100_Buses_MicroStops.csv')
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['ID', 'Bus Name', 'Bus No', 'Route (Intermediate Stops)', 'Time', 'Fare (INR)', 'Exchanges'])
    for row in dataset:
        writer.writerow([row['id'], row['bus_name'], row['bus_no'], row['path'], row['time'], row['fare'], row['exchanges']])

# 2. Output to PDF (Card layout since paths are too long for a single row table)
class PDFMicroStops(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 15)
        self.cell(0, 8, 'YathraKerala - Hyper Detailed App Database (100 Routes)', 0, 1, 'C')
        self.set_font('Arial', 'I', 9)
        self.cell(0, 6, 'Includes all micro-stops (Manna, Pooparamba, Caltex, etc.)', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDFMicroStops(orientation='P')
pdf.add_page()

for row in dataset:
    pdf.set_font('Arial', 'B', 11)
    pdf.set_text_color(0, 51, 102)
    title = f"{row['id']}. {row['bus_name']} ({row['bus_no']})"
    pdf.cell(140, 6, title, 0, 0, 'L')
    
    pdf.set_text_color(0, 100, 0)
    pdf.cell(50, 6, f"Fare: Rs. {row['fare']}", 0, 1, 'R')
    
    pdf.set_font('Arial', 'B', 9)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(190, 5, f"Time: {row['time']}", 0, 1, 'L')
    
    pdf.set_font('Arial', '', 9)
    pdf.set_text_color(50, 50, 50)
    pdf.multi_cell(0, 5, f"Stops: {row['path']}")
    
    pdf.ln(2)
    pdf.set_draw_color(220, 220, 220)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(3)

pdf_path = os.path.join(os.getcwd(), 'Kannur_100_Buses_MicroStops.pdf')
pdf.output(pdf_path)
print(f"Generated Detailed CSV at: {csv_path}")
print(f"Generated Detailed PDF at: {pdf_path}")
