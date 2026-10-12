import csv
import os
from fpdf import FPDF

# Defining Multi-Leg Journey Test Cases (Where NO direct bus exists)
connections = [
    {
        "origin": "Chemperi", "dest": "Payyanur",
        "leg1": "Private - VJEC Express | Chemperi -> Pooparamba -> Sreekandapuram -> Kurumathur -> Karimbam -> Manna -> Taliparamba",
        "leg1_time": "08:00 AM -> 08:45 AM", "leg1_fare": 35,
        "exchange": "Taliparamba Bus Stand (Wait: 15 mins)",
        "leg2": "KSRTC - Fast Passenger | Taliparamba -> Manna -> Pariyaram -> Pilathara -> Perumba -> Payyanur",
        "leg2_time": "09:00 AM -> 09:40 AM", "leg2_fare": 25,
        "total_fare": "60 INR", "total_time": "1 hr 40 mins", "exchanges": 1
    },
    {
        "origin": "Mattannur", "dest": "Payyambalam Beach",
        "leg1": "Private - Kairali | Mattannur -> Koodali -> Anjarakandy -> Chakkarakkal -> Kappad -> Mele Chovva -> Old Bus Stand",
        "leg1_time": "10:15 AM -> 11:10 AM", "leg1_fare": 40,
        "exchange": "Kannur Old Bus Stand (Wait: 10 mins)",
        "leg2": "Private - Town Fast | Old Bus Stand -> Ayikkara -> City Center -> Payyambalam Beach",
        "leg2_time": "11:20 AM -> 11:35 AM", "leg2_fare": 10,
        "total_fare": "50 INR", "total_time": "1 hr 20 mins", "exchanges": 1
    },
    {
        "origin": "Alakode", "dest": "Thalassery",
        "leg1": "Private - Sree Muthappan | Alakode -> Karuvanchal -> Naduvil -> Oduvalithattu -> Karimbam -> Manna -> Taliparamba -> Dharmasala -> Puthiyatheru -> Kannur",
        "leg1_time": "07:00 AM -> 08:35 AM", "leg1_fare": 65,
        "exchange": "Kannur Thavakkara Stand (Wait: 25 mins)",
        "leg2": "Private - Royal Travels | Kannur -> Thavakkara -> SN College -> Thottada -> Edakkad -> Muzhappilangad -> Dharmadam -> Thalassery",
        "leg2_time": "09:00 AM -> 09:50 AM", "leg2_fare": 30,
        "total_fare": "95 INR", "total_time": "2 hr 50 mins", "exchanges": 1
    },
    {
        "origin": "Iritty", "dest": "Chemperi",
        "leg1": "KSRTC - Ordinary | Iritty -> Keezhur -> Chavassery -> Mattannur -> Chalode -> Eachur -> Mundayad -> Mele Chovva -> Caltex",
        "leg1_time": "13:00 PM -> 14:30 PM", "leg1_fare": 55,
        "exchange": "Kannur Caltex Junction (Wait: 20 mins)",
        "leg2": "Private - VJEC Express | Caltex -> Pallikunnu -> Puthiyatheru -> Kalliasseri -> Dharmasala -> Taliparamba -> Manna -> Karimbam -> Kurumathur -> Sreekandapuram -> Madampam -> Pooparamba -> Chemperi",
        "leg2_time": "14:50 PM -> 16:15 PM", "leg2_fare": 45,
        "total_fare": "100 INR", "total_time": "3 hr 15 mins", "exchanges": 1
    },
    {
        "origin": "Kuthuparamba", "dest": "Taliparamba",
        "leg1": "Private - Kannur King | Kuthuparamba -> Mambaram -> Kadachira -> Nada -> Chala -> Mele Chovva -> Kannur",
        "leg1_time": "09:30 AM -> 10:15 AM", "leg1_fare": 35,
        "exchange": "Kannur Bus Stand (Wait: 15 mins)",
        "leg2": "KSRTC - Fast Passenger | Kannur -> Caltex -> Pallikunnu -> Puthiyatheru -> Kalliasseri -> Dharmasala -> Taliparamba",
        "leg2_time": "10:30 AM -> 11:15 AM", "leg2_fare": 30,
        "total_fare": "65 INR", "total_time": "1 hr 45 mins", "exchanges": 1
    },
    {
        "origin": "Ezhimala", "dest": "Iritty",
        "leg1": "Private - Ocean Line | Ezhimala -> Pazhayangadi -> Cherukunnu -> Pappinisseri -> Kattampally -> Puthiyatheru -> Pallikunnu -> Kannur",
        "leg1_time": "15:00 PM -> 16:10 PM", "leg1_fare": 45,
        "exchange": "Kannur Bus Stand (Wait: 20 mins)",
        "leg2": "KSRTC - Ordinary | Kannur -> Mele Chovva -> Mundayad -> Eachur -> Chalode -> Mattannur -> Chavassery -> Keezhur -> Iritty",
        "leg2_time": "16:30 PM -> 18:00 PM", "leg2_fare": 55,
        "total_fare": "100 INR", "total_time": "3 hr", "exchanges": 1
    },
    {
        "origin": "Dharmasala", "dest": "Pinarayi",
        "leg1": "Private - VJEC Return | Dharmasala -> Kalliasseri -> Puthiyatheru -> Pallikunnu -> Caltex -> Kannur",
        "leg1_time": "11:00 AM -> 11:25 AM", "leg1_fare": 20,
        "exchange": "Kannur Thavakkara Stand (Wait: 15 mins)",
        "leg2": "Private - Thalassery Route | Kannur -> Thavakkara -> SN College -> Thottada -> Edakkad -> Muzhappilangad -> Dharmadam -> Thalassery",
        "leg2_time": "11:40 AM -> 12:20 PM", "leg2_fare": 30,
        "exchange_2": "Thalassery Bus Stand (Wait: 10 mins)",
        "leg3": "Private - Local | Thalassery -> Eranholi -> Kadirur -> Pinarayi",
        "leg3_time": "12:30 PM -> 12:50 PM", "leg3_fare": 15,
        "total_fare": "65 INR", "total_time": "1 hr 50 mins", "exchanges": 2
    }
]

# 1. Output to CSV
csv_path = os.path.join(os.getcwd(), 'Kannur_Connections_TestCases.csv')
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Origin', 'Destination', 'Leg 1', 'Leg 1 Time', 'Exchange Point 1', 'Leg 2', 'Leg 2 Time', 'Exchange Point 2', 'Leg 3', 'Total Fare', 'Total Time', 'Exchanges'])
    for row in connections:
        leg3 = row.get('leg3', 'N/A')
        exc2 = row.get('exchange_2', 'N/A')
        writer.writerow([row['origin'], row['dest'], row['leg1'], row['leg1_time'], row['exchange'], row['leg2'], row['leg2_time'], exc2, leg3, row['total_fare'], row['total_time'], row['exchanges']])

# 2. Output to PDF
class PDFConnections(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 15)
        self.cell(0, 8, 'YathraKerala - Multi-Leg Connection Test Cases', 0, 1, 'C')
        self.set_font('Arial', 'I', 9)
        self.cell(0, 6, 'Optimal Pathing for Destinations with No Direct Bus (Exchanges Included)', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDFConnections(orientation='P')
pdf.add_page()

for row in connections:
    pdf.set_font('Arial', 'B', 12)
    pdf.set_text_color(153, 0, 0) # Dark Red for endpoints
    title = f"{row['origin']}   ->   {row['dest']}  (Exchanges: {row['exchanges']})"
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
    pdf.set_text_color(204, 102, 0) # Orange
    pdf.cell(20, 5, "SWITCH:", 0, 0)
    pdf.set_font('Arial', 'I', 9)
    pdf.multi_cell(0, 5, f"At {row['exchange']}")
    
    # Leg 2
    pdf.set_font('Arial', 'B', 9)
    pdf.set_text_color(0, 51, 102)
    pdf.cell(20, 5, "LEG 2:", 0, 0)
    pdf.set_font('Arial', '', 9)
    pdf.multi_cell(0, 5, f"{row['leg2']}  [{row['leg2_time']}] (Rs. {row['leg2_fare']})")
    
    # Leg 3 (if exists)
    if 'leg3' in row:
        # Exchange 2
        pdf.set_font('Arial', 'B', 9)
        pdf.set_text_color(204, 102, 0)
        pdf.cell(20, 5, "SWITCH:", 0, 0)
        pdf.set_font('Arial', 'I', 9)
        pdf.multi_cell(0, 5, f"At {row['exchange_2']}")
        
        # Leg 3
        pdf.set_font('Arial', 'B', 9)
        pdf.set_text_color(0, 51, 102)
        pdf.cell(20, 5, "LEG 3:", 0, 0)
        pdf.set_font('Arial', '', 9)
        pdf.multi_cell(0, 5, f"{row['leg3']}  [{row['leg3_time']}] (Rs. {row['leg3_fare']})")
    
    pdf.ln(2)
    pdf.set_draw_color(220, 220, 220)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(4)

pdf_path = os.path.join(os.getcwd(), 'Kannur_Connections_TestCases.pdf')
pdf.output(pdf_path)
print(f"Generated Connections CSV at: {csv_path}")
print(f"Generated Connections PDF at: {pdf_path}")
