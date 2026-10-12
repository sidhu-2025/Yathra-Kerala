import sys
import subprocess
import os

# Auto-install fpdf if it's not present
try:
    from fpdf import FPDF
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "fpdf"])
    from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 16)
        self.cell(0, 10, 'YathraKerala - Sample Dataset (OSM Integrated)', 0, 1, 'C')
        self.set_font('Arial', 'I', 10)
        self.cell(0, 10, 'Generated for Multi-Modal AI Journey Planner Demo', 0, 1, 'C')
        self.ln(5)

pdf = PDF(orientation='L')
pdf.add_page()
pdf.set_font('Arial', 'B', 10)

# Define columns
headers = ['Bus Name', 'Bus No', 'Route (Start -> End)', 'Bus Time', 'Fare (INR)', 'Exchanges']
col_widths = [35, 30, 55, 25, 25, 60]

# Add Table Header
for i in range(len(headers)):
    pdf.cell(col_widths[i], 10, headers[i], border=1, align='C')
pdf.ln()

# Realistic Data for Kannur City & Surrounding
data = [
    ['VJEC Express', 'KL-13-AB-1234', 'Kannur -> Chemperi', '07:30 AM', '45', '0 (Direct)'],
    ['KSRTC Fast', 'KL-15-A-1122', 'Kannur -> Taliparamba', '08:00 AM', '35', '0 (Direct)'],
    ['Kalyan Travels', 'KL-58-K-9876', 'Kannur -> Payyavoor', '08:15 AM', '50', '1 (at Sreekandapuram)'],
    ['City Ride', 'KL-13-CD-5566', 'Railway Stn -> New Bus Stand', '09:00 AM', '10', '0 (Direct)'],
    ['Sree Muthappan', 'KL-13-EF-4433', 'Kannur -> Alakode', '06:45 AM', '65', '2 (Dharmasala, Taliparamba)'],
    ['Royal Travels', 'KL-59-Q-2233', 'Chemperi -> Thalassery', '16:30 PM', '70', '1 (at Kannur Bus Stand)'],
    ['Ocean Line', 'KL-13-MM-1001', 'Kannur -> Payyanur', '10:00 AM', '55', '0 (Direct)'],
    ['KSRTC Ordinary', 'KL-15-B-4321', 'Kannur -> Iritty', '11:15 AM', '50', '0 (Direct)']
]

pdf.set_font('Arial', '', 10)
for row in data:
    for i in range(len(row)):
        pdf.cell(col_widths[i], 10, str(row[i]), border=1, align='C')
    pdf.ln()

pdf_path = os.path.join(os.getcwd(), 'Kannur_Sample_Bus_Dataset.pdf')
pdf.output(pdf_path)
print(f"PDF successfully generated at: {pdf_path}")
