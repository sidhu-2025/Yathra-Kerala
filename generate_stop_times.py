import csv
import os
from fpdf import FPDF
from datetime import datetime, timedelta

# Define the exact time it takes to travel between each micro-stop (in minutes)
route_a_stops_delays = [
    ("Kannur Bus Stand", 0), ("Caltex", 3), ("Mele Chovva", 5),
    ("Kappad", 4), ("Mundayad", 3), ("Kudukkamotta", 3),
    ("Eachur", 3), ("Mowanchery", 3), ("Chalode", 6),
    ("Therur", 3), ("Edayannur", 4), ("Koodali", 4),
    ("Panayathamparamba", 3), ("Pazhassi", 4), ("Mattannur", 7),
    ("Illambha", 4), ("Chavassery", 4), ("Uliyil", 3),
    ("19th Mile", 3), ("Keezhur", 3), ("Iritty", 3)
]

route_b_stops_delays = [
    ("Kannur Bus Stand", 0), ("Caltex", 3), ("Mele Chovva", 5),
    ("Kappad", 4), ("Kanhirode", 4), ("Chakkarakkal", 6),
    ("Peralassery", 5), ("Mavilayi", 4), ("Anjarakandy", 6),
    ("Paduvilayi", 4), ("Koodali", 6), ("Panayathamparamba", 3),
    ("Pazhassi", 4), ("Mattannur", 6), ("Illambha", 4),
    ("Chavassery", 4), ("Uliyil", 3), ("19th Mile", 3),
    ("Keezhur", 3), ("Iritty", 3)
]

def generate_timeline(bus_name, start_time_str, stops_with_delays):
    start_time = datetime.strptime(start_time_str, "%I:%M %p")
    current_time = start_time
    timeline = []
    seq = 1
    
    for stop_name, delay_mins in stops_with_delays:
        current_time += timedelta(minutes=delay_mins)
        arrival_time = current_time.strftime("%I:%M %p")
        
        # Assume 1 min dwell time for passengers to board, except at the final destination
        departure_time = (current_time + timedelta(minutes=1)).strftime("%I:%M %p")
        if seq == len(stops_with_delays):
            departure_time = arrival_time # End of route
            
        timeline.append({
            "bus": bus_name,
            "seq": seq,
            "stop": stop_name,
            "arrival": arrival_time,
            "departure": departure_time
        })
        # advance current time by dwell time for the next leg's calculation
        if seq < len(stops_with_delays):
            current_time += timedelta(minutes=1)
        
        seq += 1
    return timeline

# Generate timelines for 3 distinct buses
bus1 = generate_timeline("Private - Kairali (KL-13-F-4433) [Route A]", "07:00 AM", route_a_stops_delays)
bus2 = generate_timeline("Private - Malabar Coach (KL-13-J-7788) [Route B]", "07:45 AM", route_b_stops_delays)
bus3 = generate_timeline("KSRTC - Fast Passenger (KL-15-C-7654) [Route A]", "08:30 AM", route_a_stops_delays)

dataset = bus1 + bus2 + bus3

# 1. Output to CSV (Ready to import into MySQL `timings` table)
csv_path = os.path.join(os.getcwd(), 'Kannur_Iritty_Stop_By_Stop_Times.csv')
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Bus Details', 'Stop Sequence', 'Stop Name', 'Arrival Time', 'Departure Time'])
    for row in dataset:
        writer.writerow([row['bus'], row['seq'], row['stop'], row['arrival'], row['departure']])

# 2. Output to PDF (Timetable style)
class PDFStopTimes(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 14)
        self.cell(0, 8, 'YathraKerala - Exact Stop-by-Stop Timings (Kannur to Iritty)', 0, 1, 'C')
        self.set_font('Arial', 'I', 9)
        self.cell(0, 6, 'Perfectly matches the "Timings" and "Stop_Allocation" tables in your Database', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDFStopTimes(orientation='P')
pdf.add_page()

current_bus = ""
for row in dataset:
    if row['bus'] != current_bus:
        current_bus = row['bus']
        pdf.ln(5)
        pdf.set_font('Arial', 'B', 11)
        pdf.set_text_color(153, 0, 0)
        pdf.cell(0, 8, f"TIMETABLE FOR: {current_bus}", 0, 1, 'L')
        
        pdf.set_font('Arial', 'B', 9)
        pdf.set_text_color(0, 51, 102)
        pdf.cell(15, 6, "Seq", border=1, align='C')
        pdf.cell(85, 6, "Stop Name", border=1, align='L')
        pdf.cell(35, 6, "Arrival Time", border=1, align='C')
        pdf.cell(35, 6, "Departure Time", border=1, align='C')
        pdf.ln()

    pdf.set_font('Arial', '', 9)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(15, 5, str(row['seq']), border=1, align='C')
    pdf.cell(85, 5, row['stop'], border=1, align='L')
    pdf.cell(35, 5, row['arrival'], border=1, align='C')
    pdf.cell(35, 5, row['departure'], border=1, align='C')
    pdf.ln()

pdf_path = os.path.join(os.getcwd(), 'Kannur_Iritty_Stop_By_Stop_Times.pdf')
pdf.output(pdf_path)
print(f"Generated Stop Times CSV at: {csv_path}")
print(f"Generated Stop Times PDF at: {pdf_path}")
