import os
from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 16)
        self.cell(0, 10, 'YathraKerala - Detailed Route Dataset', 0, 1, 'C')
        self.set_font('Arial', 'I', 10)
        self.cell(0, 10, 'Includes Intermediate Stops & Exact Routing', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDF(orientation='P') # Portrait mode for better list reading
pdf.add_page()

routes = [
    {
        "bus": "Private - VJEC Express (KL-13-AB-1234)",
        "path": "Kannur Bus Stand -> Puthiyatheru -> Dharmasala -> Sreekandapuram -> Chemperi",
        "time": "07:30 AM (Start) -> 08:50 AM (End)",
        "fare": "45 INR"
    },
    {
        "bus": "KSRTC - Fast Passenger (KL-15-C-7654)",
        "path": "Kannur -> Puthiyatheru -> Dharmasala -> Taliparamba -> Payyanur -> Cheruvathur -> Kanhangad -> Kasaragod",
        "time": "09:30 AM -> 12:15 PM",
        "fare": "110 INR"
    },
    {
        "bus": "Private - City Ride (KL-13-CD-5566)",
        "path": "Railway Station -> Caltex Junction -> Thavakkara -> New Bus Stand",
        "time": "09:00 AM -> 09:15 AM",
        "fare": "10 INR (Min Fare)"
    },
    {
        "bus": "Private - Sree Muthappan (KL-13-EF-4433)",
        "path": "Kannur -> Puthiyatheru -> Dharmasala -> Taliparamba -> Karuvanchal -> Alakode",
        "time": "06:45 AM -> 08:20 AM",
        "fare": "65 INR"
    },
    {
        "bus": "KSRTC - Ordinary (KL-15-B-4321)",
        "path": "Kannur -> Mele Chovva -> Chalode -> Mattannur -> Iritty",
        "time": "11:15 AM -> 12:45 PM",
        "fare": "50 INR"
    },
    {
        "bus": "Private - Ocean Line (KL-13-MM-1001)",
        "path": "Kannur -> Puthiyatheru -> Pappinisseri -> Pazhayangadi -> Payyanur",
        "time": "10:00 AM -> 11:15 AM",
        "fare": "55 INR"
    },
    {
        "bus": "KSRTC - Swift Deluxe (KL-SWIFT-123)",
        "path": "Kannur Airport -> Mattannur -> Thalassery -> Vadakara -> Kozhikode",
        "time": "21:00 PM -> 23:45 PM",
        "fare": "220 INR"
    },
    {
        "bus": "Private - Green Line (KL-58-L-1234)",
        "path": "Taliparamba -> Kurumathur -> Chuzhali -> Sreekandapuram",
        "time": "12:30 PM -> 13:10 PM",
        "fare": "25 INR"
    },
    {
        "bus": "KSRTC - City Circular (KL-15-A-100)",
        "path": "Kannur -> Thavakkara -> SN College -> Thottada",
        "time": "07:00 AM -> 07:45 AM",
        "fare": "10 INR (Min Fare)"
    },
    {
        "bus": "Private - Kalyan Travels (KL-58-K-9876)",
        "path": "Kannur -> Puthiyatheru -> Dharmasala -> Sreekandapuram -> Payyavoor",
        "time": "08:15 AM -> 09:40 AM",
        "fare": "50 INR"
    }
]

for route in routes:
    # Bus Name & Fare
    pdf.set_font('Arial', 'B', 12)
    pdf.set_text_color(0, 51, 102) # Dark Blue
    pdf.cell(140, 8, route["bus"], 0, 0, 'L')
    pdf.set_text_color(0, 102, 0) # Green for fare
    pdf.cell(50, 8, f'Fare: {route["fare"]}', 0, 1, 'R')
    
    # Timing
    pdf.set_font('Arial', 'B', 10)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(190, 6, f'Time: {route["time"]}', 0, 1, 'L')
    
    # Path (Intermediate Stops)
    pdf.set_font('Arial', 'I', 10)
    pdf.set_text_color(80, 80, 80)
    pdf.multi_cell(0, 6, f'Intermediate Stops: {route["path"]}')
    
    # Divider line
    pdf.ln(2)
    pdf.set_draw_color(200, 200, 200)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(5)

pdf_path = os.path.join(os.getcwd(), 'Kannur_Detailed_Routes_Dataset.pdf')
pdf.output(pdf_path)
print(f"Detailed PDF successfully generated at: {pdf_path}")
