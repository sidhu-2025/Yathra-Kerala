import csv
import os
from fpdf import FPDF

# Defining Multi-Leg Journey Test Cases Strictly for KANNUR CITY LIMITS
city_connections = [
    {
        "origin": "Mele Chovva", "dest": "Payyambalam Beach",
        "leg1": "Private - City Ride | Mele Chovva -> Caltex -> Old Bus Stand",
        "leg1_time": "09:00 AM -> 09:15 AM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 5 mins)",
        "leg2": "Private - Town Fast | Old Bus Stand -> Ayikkara -> Payyambalam Beach",
        "leg2_time": "09:20 AM -> 09:30 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "30 mins", "exchanges": 1
    },
    {
        "origin": "Puthiyatheru", "dest": "Thottada (SN College)",
        "leg1": "Private - Blue Star | Puthiyatheru -> Pallikunnu -> Caltex",
        "leg1_time": "10:00 AM -> 10:15 AM", "leg1_fare": 10,
        "exchange": "Caltex Junction (Wait: 10 mins)",
        "leg2": "KSRTC - City Circular | Caltex -> Thavakkara -> SN College -> Thottada",
        "leg2_time": "10:25 AM -> 10:45 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "45 mins", "exchanges": 1
    },
    {
        "origin": "Kannur Railway Station", "dest": "Pallikunnu",
        "leg1": "Private - Local City | Railway Station -> Caltex",
        "leg1_time": "11:15 AM -> 11:25 AM", "leg1_fare": 10,
        "exchange": "Caltex Junction (Wait: 5 mins)",
        "leg2": "Private - VJEC Local | Caltex -> Pallikunnu",
        "leg2_time": "11:30 AM -> 11:40 AM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "25 mins", "exchanges": 1
    },
    {
        "origin": "Ayikkara", "dest": "AKG Hospital (Talap)",
        "leg1": "Private - Town Fast | Ayikkara -> City Center -> Old Bus Stand",
        "leg1_time": "12:00 PM -> 12:10 PM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 15 mins)",
        "leg2": "Private - City Ride | Old Bus Stand -> New Bus Stand -> Thavakkara -> AKG Hospital -> Talap",
        "leg2_time": "12:25 PM -> 12:40 PM", "leg2_fare": 10,
        "total_fare": "20 INR", "total_time": "40 mins", "exchanges": 1
    },
    {
        "origin": "Mundayad (Indoor Stadium)", "dest": "Meenkunnu Beach",
        "leg1": "Private - Kairali | Mundayad -> Mele Chovva -> Caltex -> Old Bus Stand",
        "leg1_time": "14:00 PM -> 14:25 PM", "leg1_fare": 10,
        "exchange": "Kannur Old Bus Stand (Wait: 10 mins)",
        "leg2": "Private - Sagara | Old Bus Stand -> Meenkunnu Beach",
        "leg2_time": "14:35 PM -> 14:55 PM", "leg2_fare": 15,
        "total_fare": "25 INR", "total_time": "55 mins", "exchanges": 1
    },
    {
        "origin": "Thavakkara (Kannur University)", "dest": "Kalliasseri",
        "leg1": "Private - City Ride | Thavakkara -> Caltex",
        "leg1_time": "08:30 AM -> 08:40 AM", "leg1_fare": 10,
        "exchange": "Caltex Junction (Wait: 5 mins)",
        "leg2": "KSRTC - Fast Passenger | Caltex -> Pallikunnu -> Puthiyatheru -> Kalliasseri",
        "leg2_time": "08:45 AM -> 09:05 AM", "leg2_fare": 15,
        "total_fare": "25 INR", "total_time": "35 mins", "exchanges": 1
    },
    {
        "origin": "Edakkad", "dest": "Payyambalam Beach",
        "leg1": "Private - Royal Travels | Edakkad -> Thottada -> SN College -> Old Bus Stand",
        "leg1_time": "16:00 PM -> 16:25 PM", "leg1_fare": 15,
        "exchange": "Kannur Old Bus Stand (Wait: 10 mins)",
        "leg2": "Private - Town Fast | Old Bus Stand -> Ayikkara -> Payyambalam Beach",
        "leg2_time": "16:35 PM -> 16:50 PM", "leg2_fare": 10,
        "total_fare": "25 INR", "total_time": "50 mins", "exchanges": 1
    }
]

# 1. Output to CSV
csv_path = os.path.join(os.getcwd(), 'Kannur_City_Only_Connections.csv')
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Origin', 'Destination', 'Leg 1', 'Leg 1 Time', 'Exchange Point', 'Leg 2', 'Leg 2 Time', 'Total Fare', 'Total Time', 'Exchanges'])
    for row in city_connections:
        writer.writerow([row['origin'], row['dest'], row['leg1'], row['leg1_time'], row['exchange'], row['leg2'], row['leg2_time'], row['total_fare'], row['total_time'], row['exchanges']])

# 2. Output to PDF
class PDFCity(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 15)
        self.cell(0, 8, 'YathraKerala - Kannur City Local Connections', 0, 1, 'C')
        self.set_font('Arial', 'I', 9)
        self.cell(0, 6, 'Strictly Local Paths (No Direct Buses) | Micro-Mobility Test Cases', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDFCity(orientation='P')
pdf.add_page()

for row in city_connections:
    pdf.set_font('Arial', 'B', 12)
    pdf.set_text_color(153, 0, 0)
    title = f"{row['origin']}   ->   {row['dest']}  (Exchange: {row['exchanges']})"
    pdf.cell(140, 6, title, 0, 0, 'L')
    
    pdf.set_text_color(0, 100, 0)
    pdf.cell(50, 6, f"Total: {row['total_fare']}", 0, 1, 'R')
    
    pdf.set_font('Arial', 'I', 10)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(190, 5, f"Total Estimated Time: {row['total_time']}", 0, 1, 'L')
    pdf.ln(2)
    
    # Leg 1
    pdf.set_font('Arial', 'B', 9)
    pdf.set_text_color(0, 51, 102)
    pdf.cell(20, 5, "LEG 1:", 0, 0)
    pdf.set_font('Arial', '', 9)
    pdf.multi_cell(0, 5, f"{row['leg1']}  [{row['leg1_time']}] (Rs. {row['leg1_fare']})")
    
    # Exchange
    pdf.set_font('Arial', 'B', 9)
    pdf.set_text_color(204, 102, 0)
    pdf.cell(20, 5, "SWITCH:", 0, 0)
    pdf.set_font('Arial', 'I', 9)
    pdf.multi_cell(0, 5, f"At {row['exchange']}")
    
    # Leg 2
    pdf.set_font('Arial', 'B', 9)
    pdf.set_text_color(0, 51, 102)
    pdf.cell(20, 5, "LEG 2:", 0, 0)
    pdf.set_font('Arial', '', 9)
    pdf.multi_cell(0, 5, f"{row['leg2']}  [{row['leg2_time']}] (Rs. {row['leg2_fare']})")
    
    pdf.ln(2)
    pdf.set_draw_color(220, 220, 220)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(4)

pdf_path = os.path.join(os.getcwd(), 'Kannur_City_Only_Connections.pdf')
pdf.output(pdf_path)
print(f"Generated Local Connections CSV at: {csv_path}")
print(f"Generated Local Connections PDF at: {pdf_path}")
