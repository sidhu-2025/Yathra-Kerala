import os
from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 16)
        self.cell(0, 10, 'YathraKerala - Extended Bus Dataset (Kannur Region)', 0, 1, 'C')
        self.set_font('Arial', 'I', 10)
        self.cell(0, 10, 'Includes Private & KSRTC Services | Min Private Fare: 10 INR', 0, 1, 'C')
        self.ln(5)

        # Table Header
        self.set_font('Arial', 'B', 9)
        headers = ['Type / Bus Name', 'Bus No', 'Route (Start -> End)', 'Time', 'Fare', 'Exchanges']
        # Adjusted widths for slightly more data
        self.col_widths = [45, 25, 65, 20, 20, 60]
        for i in range(len(headers)):
            self.cell(self.col_widths[i], 8, headers[i], border=1, align='C')
        self.ln()

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

pdf = PDF(orientation='L')
pdf.add_page()

# Extended Data Array
data = [
    # Private City Buses (Min Fare: 10 INR)
    ['Private - City Ride', 'KL-13-CD-5566', 'Railway Stn -> New Bus Stand', '09:00 AM', '10', '0 (Direct)'],
    ['Private - Blue Star', 'KL-13-M-2233', 'Kannur -> Puthiyatheru', '11:30 AM', '10', '0 (Direct)'],
    ['Private - Sagara', 'KL-13-Z-5500', 'Kannur -> Payyambalam Beach', '16:00 PM', '10', '0 (Direct)'],
    ['Private - Town Express', 'KL-13-AR-1111', 'Old Bus Stand -> Meenkunnu', '10:15 AM', '15', '0 (Direct)'],
    
    # Private Regional Buses
    ['Private - VJEC Express', 'KL-13-AB-1234', 'Kannur -> Chemperi', '07:30 AM', '45', '0 (Direct)'],
    ['Private - Kannur King', 'KL-13-X-9090', 'Kannur -> Thalassery', '08:30 AM', '30', '0 (Direct)'],
    ['Private - Malabar Coach', 'KL-13-J-7788', 'Kannur -> Mattannur', '14:00 PM', '40', '0 (Direct)'],
    ['Private - Kalyan Travels', 'KL-58-K-9876', 'Kannur -> Payyavoor', '08:15 AM', '50', '1 (at Sreekandapuram)'],
    ['Private - Ocean Line', 'KL-13-MM-1001', 'Kannur -> Payyanur', '10:00 AM', '55', '0 (Direct)'],
    ['Private - Sree Muthappan', 'KL-13-EF-4433', 'Kannur -> Alakode', '06:45 AM', '65', '2 (Dharmasala, Taliparamba)'],
    ['Private - Royal Travels', 'KL-59-Q-2233', 'Chemperi -> Thalassery', '16:30 PM', '70', '1 (at Kannur Bus Stand)'],
    ['Private - Green Line', 'KL-58-L-1234', 'Taliparamba -> Sreekandapuram', '12:30 PM', '25', '0 (Direct)'],
    ['Private - Kairali', 'KL-13-F-1122', 'Kannur -> Iritty', '11:00 AM', '50', '0 (Direct)'],

    # KSRTC Services
    ['KSRTC - City Circular', 'KL-15-A-100', 'Kannur -> Thavakkara', '07:00 AM', '10', '0 (Direct)'],
    ['KSRTC - Ordinary', 'KL-15-B-4321', 'Kannur -> Iritty', '11:15 AM', '50', '0 (Direct)'],
    ['KSRTC - Town-to-Town', 'KL-15-X-333', 'Kannur -> Payyanur', '13:45 PM', '45', '0 (Direct)'],
    ['KSRTC - Ordinary', 'KL-15-Y-777', 'Payyanur -> Cherupuzha', '15:30 PM', '35', '0 (Direct)'],
    ['KSRTC - Fast Passenger', 'KL-15-A-1122', 'Kannur -> Taliparamba', '08:00 AM', '30', '0 (Direct)'],
    ['KSRTC - Fast Passenger', 'KL-15-C-7654', 'Kannur -> Kasaragod', '09:30 AM', '110', '0 (Direct)'],
    ['KSRTC - Super Fast', 'KL-15-A-9999', 'Kannur -> Kozhikode', '06:00 AM', '140', '0 (Direct)'],
    ['KSRTC - Swift Deluxe', 'KL-SWIFT-123', 'Kannur Airport -> Kozhikode', '21:00 PM', '220', '0 (Direct)'],
    ['KSRTC - Minnal', 'KL-15-M-001', 'Kannur -> Trivandrum', '18:00 PM', '750', '0 (Direct)'],
    ['KSRTC - AC Low Floor', 'KL-15-AC-10', 'Kannur -> Thalassery', '10:30 AM', '40', '0 (Direct)']
]

pdf.set_font('Arial', '', 9)

for row in data:
    for i in range(len(row)):
        pdf.cell(pdf.col_widths[i], 8, str(row[i]), border=1, align='C')
    pdf.ln()

pdf_path = os.path.join(os.getcwd(), 'Kannur_Extended_Bus_Dataset.pdf')
pdf.output(pdf_path)
print(f"Extended PDF successfully generated at: {pdf_path}")
