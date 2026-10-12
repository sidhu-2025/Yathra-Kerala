import os
from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 16)
        self.cell(0, 10, 'YathraKerala - Comprehensive Regional Dataset', 0, 1, 'C')
        self.set_font('Arial', 'I', 10)
        self.cell(0, 10, 'Full Kannur District Network (Intermediate Stops Included)', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDF(orientation='P')
pdf.add_page()

# Comprehensive Data Array covering Local, North, East, South and Inter-district
routes = [
    # --- CITY LOCAL ---
    {"bus": "Private - City Ride (KL-13-CD-5566)", "path": "Railway Station -> Caltex -> Thavakkara -> New Bus Stand", "time": "08:00 AM -> 08:15 AM", "fare": "10 INR"},
    {"bus": "Private - City Ride Return (KL-13-CD-5567)", "path": "New Bus Stand -> Thavakkara -> Caltex -> Railway Station", "time": "08:30 AM -> 08:45 AM", "fare": "10 INR"},
    {"bus": "KSRTC - City Circular (KL-15-A-100)", "path": "Kannur -> Thavakkara -> SN College -> Thottada", "time": "07:00 AM -> 07:45 AM", "fare": "10 INR"},
    {"bus": "Private - Blue Star (KL-13-M-2233)", "path": "Kannur -> Pallikunnu -> Puthiyatheru", "time": "10:00 AM -> 10:15 AM", "fare": "10 INR"},
    {"bus": "Private - Town Fast (KL-13-AR-1111)", "path": "Old Bus Stand -> Ayikkara -> Payyambalam Beach", "time": "11:15 AM -> 11:30 AM", "fare": "10 INR"},

    # --- NORTH REGION (Taliparamba, Payyanur) ---
    {"bus": "KSRTC - Fast Passenger (KL-15-C-1020)", "path": "Kannur -> Puthiyatheru -> Dharmasala -> Taliparamba", "time": "07:30 AM -> 08:15 AM", "fare": "30 INR"},
    {"bus": "Private - Ocean Line (KL-13-MM-1001)", "path": "Kannur -> Puthiyatheru -> Pappinisseri -> Pazhayangadi -> Payyanur", "time": "08:45 AM -> 10:00 AM", "fare": "55 INR"},
    {"bus": "KSRTC - Ordinary (KL-15-B-1122)", "path": "Payyanur -> Pilathara -> Pariyaram -> Taliparamba", "time": "09:15 AM -> 10:10 AM", "fare": "30 INR"},
    {"bus": "Private - Sree Muthappan (KL-13-EF-4433)", "path": "Kannur -> Puthiyatheru -> Dharmasala -> Taliparamba -> Karuvanchal -> Alakode", "time": "06:45 AM -> 08:20 AM", "fare": "65 INR"},
    {"bus": "KSRTC - Super Fast (KL-15-A-9999)", "path": "Kannur -> Taliparamba -> Payyanur -> Kanhangad -> Kasaragod", "time": "10:30 AM -> 13:00 PM", "fare": "110 INR"},
    {"bus": "Private - Payyanur Express (KL-59-C-4455)", "path": "Kannur -> Dharmasala -> Taliparamba -> Pilathara -> Payyanur", "time": "14:15 PM -> 15:30 PM", "fare": "55 INR"},

    # --- EAST REGION (Chemperi, Sreekandapuram, Iritty, Mattannur, Airport) ---
    {"bus": "Private - VJEC Express (KL-13-AB-1234)", "path": "Kannur Bus Stand -> Puthiyatheru -> Dharmasala -> Sreekandapuram -> Chemperi", "time": "07:30 AM -> 08:50 AM", "fare": "45 INR"},
    {"bus": "Private - VJEC Return (KL-13-AB-1234)", "path": "Chemperi -> Sreekandapuram -> Dharmasala -> Puthiyatheru -> Kannur", "time": "16:30 PM -> 17:50 PM", "fare": "45 INR"},
    {"bus": "Private - Kalyan Travels (KL-58-K-9876)", "path": "Kannur -> Puthiyatheru -> Dharmasala -> Sreekandapuram -> Payyavoor", "time": "08:15 AM -> 09:40 AM", "fare": "50 INR"},
    {"bus": "KSRTC - Ordinary (KL-15-B-4321)", "path": "Kannur -> Mele Chovva -> Chalode -> Mattannur -> Iritty", "time": "11:15 AM -> 12:45 PM", "fare": "50 INR"},
    {"bus": "Private - Kairali (KL-13-F-1122)", "path": "Kannur -> Mele Chovva -> Chakkarakkal -> Anjarakandy -> Mattannur", "time": "12:45 PM -> 13:55 PM", "fare": "45 INR"},
    {"bus": "Private - Malabar Coach (KL-13-J-7788)", "path": "Kannur -> Chalode -> Mattannur -> Ulikkal -> Iritty", "time": "14:00 PM -> 15:30 PM", "fare": "55 INR"},
    {"bus": "Private - Green Line (KL-58-L-1234)", "path": "Taliparamba -> Kurumathur -> Chuzhali -> Sreekandapuram", "time": "12:30 PM -> 13:10 PM", "fare": "25 INR"},
    {"bus": "KSRTC - Swift Deluxe (KL-SWIFT-123)", "path": "Kannur Airport -> Mattannur -> Thalassery -> Vadakara -> Kozhikode", "time": "21:00 PM -> 23:45 PM", "fare": "220 INR"},

    # --- SOUTH REGION (Thalassery, Kuthuparamba) ---
    {"bus": "Private - Royal Travels (KL-59-Q-2233)", "path": "Kannur -> Edakkad -> Muzhappilangad -> Thalassery", "time": "09:00 AM -> 09:50 AM", "fare": "35 INR"},
    {"bus": "KSRTC - AC Low Floor (KL-15-AC-10)", "path": "Kannur -> Thalassery -> Mahe -> Vadakara", "time": "10:30 AM -> 11:45 AM", "fare": "60 INR"},
    {"bus": "Private - Kannur King (KL-13-X-9090)", "path": "Kannur -> Mele Chovva -> Chala -> Kuthuparamba", "time": "13:20 PM -> 14:05 PM", "fare": "40 INR"},
    {"bus": "KSRTC - Ordinary (KL-15-Y-777)", "path": "Thalassery -> Pinarayi -> Mambaram -> Kuthuparamba", "time": "15:00 PM -> 15:45 PM", "fare": "25 INR"},
    {"bus": "Private - Navya (KL-58-N-1122)", "path": "Kuthuparamba -> Mattannur -> Iritty -> Koottupuzha", "time": "16:45 PM -> 18:00 PM", "fare": "45 INR"},

    # --- LONG DISTANCE / INTER-DISTRICT ---
    {"bus": "KSRTC - Minnal (KL-15-M-001)", "path": "Kannur -> Kozhikode -> Ernakulam -> Trivandrum", "time": "18:00 PM -> 05:00 AM (Next Day)", "fare": "750 INR"},
    {"bus": "KSRTC - Fast Passenger (KL-15-C-7777)", "path": "Kannur -> Iritty -> Peravoor -> Boys Town -> Mananthavady", "time": "07:15 AM -> 10:30 AM", "fare": "130 INR"},
    {"bus": "KSRTC - Super Fast (KL-15-A-8888)", "path": "Kannur -> Thalassery -> Kozhikode -> Thrissur", "time": "22:30 PM -> 04:00 AM", "fare": "280 INR"}
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

pdf_path = os.path.join(os.getcwd(), 'Kannur_Full_Regional_Network.pdf')
pdf.output(pdf_path)
print(f"Comprehensive PDF successfully generated at: {pdf_path}")
