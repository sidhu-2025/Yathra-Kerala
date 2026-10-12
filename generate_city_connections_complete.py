import csv
import os
from fpdf import FPDF

# Defining Complete Multi-Leg Journey Test Cases for KANNUR CITY LIMITS (Covering every suburb)
city_connections = [
    # Original Core Routes
    {
        "origin": "Mele Chovva", "dest": "Payyambalam Beach",
        "leg1": "Private - City Ride | Mele Chovva -> Caltex -> Old Bus Stand", "leg1_time": "09:00 AM -> 09:15 AM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 5 mins)",
        "leg2": "Private - Town Fast | Old Bus Stand -> Ayikkara -> Payyambalam Beach", "leg2_time": "09:20 AM -> 09:30 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "30 mins", "exchanges": 1
    },
    {
        "origin": "Puthiyatheru", "dest": "Thottada (SN College)",
        "leg1": "Private - Blue Star | Puthiyatheru -> Pallikunnu -> Caltex", "leg1_time": "10:00 AM -> 10:15 AM", "leg1_fare": 10,
        "exchange": "Caltex Junction (Wait: 10 mins)",
        "leg2": "KSRTC - City Circular | Caltex -> Thavakkara -> SN College -> Thottada", "leg2_time": "10:25 AM -> 10:45 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "45 mins", "exchanges": 1
    },
    {
        "origin": "Kannur Railway Station", "dest": "Pallikunnu",
        "leg1": "Private - Local City | Railway Station -> Caltex", "leg1_time": "11:15 AM -> 11:25 AM", "leg1_fare": 10,
        "exchange": "Caltex Junction (Wait: 5 mins)",
        "leg2": "Private - VJEC Local | Caltex -> Pallikunnu", "leg2_time": "11:30 AM -> 11:40 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "25 mins", "exchanges": 1
    },
    {
        "origin": "Ayikkara", "dest": "AKG Hospital (Talap)",
        "leg1": "Private - Town Fast | Ayikkara -> City Center -> Old Bus Stand", "leg1_time": "12:00 PM -> 12:10 PM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 15 mins)",
        "leg2": "Private - City Ride | Old Bus Stand -> New Bus Stand -> Thavakkara -> AKG Hospital -> Talap", "leg2_time": "12:25 PM -> 12:40 PM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "40 mins", "exchanges": 1
    },
    
    # NEW ROUTES: Covering all other missing Kannur City suburbs/nodes
    {
        "origin": "St. Angelo Fort (Burnacherry)", "dest": "Thottada",
        "leg1": "Private - City Ride | Burnacherry -> Cantonment -> Old Bus Stand", "leg1_time": "08:00 AM -> 08:15 AM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 10 mins)",
        "leg2": "Private - Thottada Route | Old Bus Stand -> New Bus Stand -> SN College -> Thottada", "leg2_time": "08:25 AM -> 08:45 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "45 mins", "exchanges": 1
    },
    {
        "origin": "Varam", "dest": "Payyambalam Beach",
        "leg1": "Private - Kairali | Varam -> Kappad -> Mele Chovva -> Old Bus Stand", "leg1_time": "13:30 PM -> 13:55 PM", "leg1_fare": 15,
        "exchange": "Kannur Old Bus Stand (Wait: 5 mins)",
        "leg2": "Private - Sagara | Old Bus Stand -> Payyambalam Beach", "leg2_time": "14:00 PM -> 14:15 PM", "leg2_fare": 10,
        "total_fare": "25 INR", "total_time": "45 mins", "exchanges": 1
    },
    {
        "origin": "Thayyil", "dest": "Pallikunnu",
        "leg1": "Private - Town Fast | Thayyil -> Ayikkara -> Old Bus Stand", "leg1_time": "10:30 AM -> 10:45 AM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 10 mins)",
        "leg2": "Private - Blue Star | Old Bus Stand -> Caltex -> Pallikunnu", "leg2_time": "10:55 AM -> 11:10 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "40 mins", "exchanges": 1
    },
    {
        "origin": "Thazhe Chovva", "dest": "Kattampally",
        "leg1": "KSRTC - City Circular | Thazhe Chovva -> Mele Chovva -> Caltex", "leg1_time": "09:15 AM -> 09:30 AM", "leg1_fare": 10,
        "exchange": "Caltex Junction (Wait: 15 mins)",
        "leg2": "Private - VJEC Local | Caltex -> Pallikunnu -> Puthiyatheru -> Kattampally", "leg2_time": "09:45 AM -> 10:05 AM", "leg2_fare": 15,
        "total_fare": "25 INR", "total_time": "50 mins", "exchanges": 1
    },
    {
        "origin": "Eachur", "dest": "Burnacherry (Fort)",
        "leg1": "Private - Malabar | Eachur -> Mundayad -> Mele Chovva -> Old Bus Stand", "leg1_time": "11:00 AM -> 11:25 AM", "leg1_fare": 15,
        "exchange": "Kannur Old Bus Stand (Wait: 5 mins)",
        "leg2": "Private - City Ride | Old Bus Stand -> Cantonment -> Burnacherry", "leg2_time": "11:30 AM -> 11:45 AM", "leg2_fare": 10,
        "total_fare": "25 INR", "total_time": "45 mins", "exchanges": 1
    },
    {
        "origin": "Kizhunna Beach", "dest": "Kannur Railway Station",
        "leg1": "Private - Royal | Kizhunna -> Thottada -> SN College -> Thavakkara (New Bus Stand)", "leg1_time": "15:00 PM -> 15:30 PM", "leg1_fare": 15,
        "exchange": "New Bus Stand (Wait: 10 mins)",
        "leg2": "KSRTC - Circular | New Bus Stand -> Railway Station", "leg2_time": "15:40 PM -> 15:45 PM", "leg2_fare": 10,
        "total_fare": "25 INR", "total_time": "45 mins", "exchanges": 1
    },
    {
        "origin": "Chala", "dest": "Talap",
        "leg1": "Private - Kannur King | Chala -> Thazhe Chovva -> Mele Chovva -> Caltex", "leg1_time": "17:00 PM -> 17:25 PM", "leg1_fare": 15,
        "exchange": "Caltex Junction (Wait: 5 mins)",
        "leg2": "Private - Local | Caltex -> AKG Hospital -> Talap", "leg2_time": "17:30 PM -> 17:40 PM", "leg2_fare": 10,
        "total_fare": "25 INR", "total_time": "40 mins", "exchanges": 1
    },
    {
        "origin": "Meenkunnu Beach", "dest": "Kizhuthalli",
        "leg1": "Private - Sagara | Meenkunnu -> Azhikode -> Pallikunnu -> Caltex -> Old Bus Stand", "leg1_time": "16:00 PM -> 16:40 PM", "leg1_fare": 20,
        "exchange": "Kannur Old Bus Stand (Wait: 10 mins)",
        "leg2": "Private - Kairali | Old Bus Stand -> Mele Chovva -> Kizhuthalli", "leg2_time": "16:50 PM -> 17:10 PM", "leg2_fare": 10,
        "total_fare": "30 INR", "total_time": "1 hr 10 mins", "exchanges": 1
    }
]

# 1. Output to CSV
csv_path = os.path.join(os.getcwd(), 'Kannur_City_Connections_Complete.csv')
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Origin', 'Destination', 'Leg 1', 'Leg 1 Time', 'Exchange Point', 'Leg 2', 'Leg 2 Time', 'Total Fare', 'Total Time', 'Exchanges'])
    for row in city_connections:
        writer.writerow([row['origin'], row['dest'], row['leg1'], row['leg1_time'], row['exchange'], row['leg2'], row['leg2_time'], row['total_fare'], row['total_time'], row['exchanges']])

# 2. Output to PDF
class PDFCity(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 15)
        self.cell(0, 8, 'YathraKerala - Complete Kannur City Connections', 0, 1, 'C')
        self.set_font('Arial', 'I', 9)
        self.cell(0, 6, 'Includes ALL suburbs: Burnacherry, Azhikode, Varam, Chala, Kattampally, Kizhunna', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDFCity(orientation='P')
pdf.add_page()

for row in city_connections:
    pdf.set_font('Arial', 'B', 11)
    pdf.set_text_color(153, 0, 0)
    title = f"{row['origin']}   ->   {row['dest']}"
    pdf.cell(140, 6, title, 0, 0, 'L')
    
    pdf.set_text_color(0, 100, 0)
    pdf.cell(50, 6, f"Total: {row['total_fare']}", 0, 1, 'R')
    
    pdf.set_font('Arial', 'I', 9)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(190, 5, f"Total Time: {row['total_time']} | Exchanges: {row['exchanges']}", 0, 1, 'L')
    pdf.ln(1)
    
    # Leg 1
    pdf.set_font('Arial', 'B', 8)
    pdf.set_text_color(0, 51, 102)
    pdf.cell(15, 5, "LEG 1:", 0, 0)
    pdf.set_font('Arial', '', 8)
    pdf.multi_cell(0, 5, f"{row['leg1']}  [{row['leg1_time']}] (Rs. {row['leg1_fare']})")
    
    # Exchange
    pdf.set_font('Arial', 'B', 8)
    pdf.set_text_color(204, 102, 0)
    pdf.cell(15, 5, "SWITCH:", 0, 0)
    pdf.set_font('Arial', 'I', 8)
    pdf.multi_cell(0, 5, f"At {row['exchange']}")
    
    # Leg 2
    pdf.set_font('Arial', 'B', 8)
    pdf.set_text_color(0, 51, 102)
    pdf.cell(15, 5, "LEG 2:", 0, 0)
    pdf.set_font('Arial', '', 8)
    pdf.multi_cell(0, 5, f"{row['leg2']}  [{row['leg2_time']}] (Rs. {row['leg2_fare']})")
    
    pdf.ln(2)
    pdf.set_draw_color(220, 220, 220)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(3)

pdf_path = os.path.join(os.getcwd(), 'Kannur_City_Connections_Complete.pdf')
pdf.output(pdf_path)
print(f"Generated Complete Local Connections CSV at: {csv_path}")
print(f"Generated Complete Local Connections PDF at: {pdf_path}")
