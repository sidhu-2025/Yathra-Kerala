"""
Official Southern Railway / NTES Timetable Database for Yathra Kerala
Comprehensive station-to-station coverage for all stations across Kerala corridors.
"""

INDIAN_RAILWAYS_TRAINS = [
    {
        "train_no": "16308",
        "name": "Executive Express",
        "origin": "Kannur (CAN)",
        "destination": "Alappuzha (ALLP)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "CAN",
                "arr": "05:00 AM",
                "dep": "05:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "05:29 AM",
                "dep": "05:30 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "05:38 AM",
                "dep": "05:39 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "05:49 AM",
                "dep": "05:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "06:09 AM",
                "dep": "06:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "06:37 AM",
                "dep": "06:40 AM",
                "pf": "PF 3"
            },
            {
                "code": "FK",
                "arr": "06:54 AM",
                "dep": "06:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "07:14 AM",
                "dep": "07:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "07:24 AM",
                "dep": "07:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "07:33 AM",
                "dep": "07:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "07:54 AM",
                "dep": "07:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "08:14 AM",
                "dep": "08:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "08:40 AM",
                "dep": "08:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "WKI",
                "arr": "09:04 AM",
                "dep": "09:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "09:23 AM",
                "dep": "09:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "IJK",
                "arr": "09:52 AM",
                "dep": "09:53 AM",
                "pf": "PF 1"
            },
            {
                "code": "CKI",
                "arr": "10:02 AM",
                "dep": "10:03 AM",
                "pf": "PF 1"
            },
            {
                "code": "AFK",
                "arr": "10:19 AM",
                "dep": "10:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "10:33 AM",
                "dep": "10:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "10:58 AM",
                "dep": "11:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "11:20 AM",
                "dep": "11:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "12:04 PM",
                "dep": "12:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "ALLP",
                "arr": "12:45 PM",
                "dep": "12:45 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16307",
        "name": "Executive Express",
        "origin": "Alappuzha (ALLP)",
        "destination": "Kannur (CAN)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "ALLP",
                "arr": "03:45 PM",
                "dep": "03:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "04:09 PM",
                "dep": "04:10 PM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "04:55 PM",
                "dep": "05:00 PM",
                "pf": "PF 2"
            },
            {
                "code": "ERN",
                "arr": "05:10 PM",
                "dep": "05:12 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "05:33 PM",
                "dep": "05:35 PM",
                "pf": "PF 3"
            },
            {
                "code": "AFK",
                "arr": "05:46 PM",
                "dep": "05:47 PM",
                "pf": "PF 2"
            },
            {
                "code": "CKI",
                "arr": "06:02 PM",
                "dep": "06:03 PM",
                "pf": "PF 2"
            },
            {
                "code": "IJK",
                "arr": "06:12 PM",
                "dep": "06:13 PM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "06:33 PM",
                "dep": "06:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "WKI",
                "arr": "06:54 PM",
                "dep": "06:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "07:25 PM",
                "dep": "07:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "07:44 PM",
                "dep": "07:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "08:04 PM",
                "dep": "08:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "08:23 PM",
                "dep": "08:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "08:34 PM",
                "dep": "08:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "08:44 PM",
                "dep": "08:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "09:04 PM",
                "dep": "09:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "09:27 PM",
                "dep": "09:30 PM",
                "pf": "PF 4"
            },
            {
                "code": "QLD",
                "arr": "09:54 PM",
                "dep": "09:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "10:14 PM",
                "dep": "10:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "10:29 PM",
                "dep": "10:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "10:44 PM",
                "dep": "10:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "DMD",
                "arr": "10:54 PM",
                "dep": "10:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "11:30 PM",
                "dep": "11:30 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "12081",
        "name": "Jan Shatabdi Express",
        "origin": "Kannur (CAN)",
        "destination": "Thiruvananthapuram Central (TVC)",
        "type": "Jan Shatabdi Superfast",
        "days": "Mon, Tue, Thu, Fri, Sat",
        "stops": [
            {
                "code": "CAN",
                "arr": "04:50 AM",
                "dep": "04:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "05:09 AM",
                "dep": "05:10 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "05:27 AM",
                "dep": "05:28 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "06:07 AM",
                "dep": "06:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "06:44 AM",
                "dep": "06:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "07:12 AM",
                "dep": "07:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "07:53 AM",
                "dep": "07:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "08:58 AM",
                "dep": "09:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "09:40 AM",
                "dep": "09:43 AM",
                "pf": "PF 1"
            },
            {
                "code": "KTYM",
                "arr": "10:32 AM",
                "dep": "10:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "CGY",
                "arr": "10:54 AM",
                "dep": "10:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "TRVL",
                "arr": "11:04 AM",
                "dep": "11:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "CNGR",
                "arr": "11:15 AM",
                "dep": "11:17 AM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "11:29 AM",
                "dep": "11:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "11:43 AM",
                "dep": "11:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "QLN",
                "arr": "12:28 PM",
                "dep": "12:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "02:25 PM",
                "dep": "02:25 PM",
                "pf": "PF 3"
            }
        ]
    },
    {
        "train_no": "12082",
        "name": "Jan Shatabdi Express",
        "origin": "Thiruvananthapuram Central (TVC)",
        "destination": "Kannur (CAN)",
        "type": "Jan Shatabdi Superfast",
        "days": "Sun, Mon, Wed, Thu, Fri",
        "stops": [
            {
                "code": "TVC",
                "arr": "02:50 PM",
                "dep": "02:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "QLN",
                "arr": "03:45 PM",
                "dep": "03:47 PM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "04:26 PM",
                "dep": "04:28 PM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "04:39 PM",
                "dep": "04:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "CNGR",
                "arr": "04:52 PM",
                "dep": "04:54 PM",
                "pf": "PF 3"
            },
            {
                "code": "TRVL",
                "arr": "05:04 PM",
                "dep": "05:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "CGY",
                "arr": "05:14 PM",
                "dep": "05:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "05:35 PM",
                "dep": "05:38 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "06:48 PM",
                "dep": "06:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "07:48 PM",
                "dep": "07:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "08:32 PM",
                "dep": "08:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "09:14 PM",
                "dep": "09:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "10:02 PM",
                "dep": "10:05 PM",
                "pf": "PF 3"
            },
            {
                "code": "BDJ",
                "arr": "10:44 PM",
                "dep": "10:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "11:04 PM",
                "dep": "11:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "11:55 PM",
                "dep": "11:55 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "20631",
        "name": "Vande Bharat Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Thiruvananthapuram (TVC)",
        "type": "Superfast / Vande Bharat",
        "days": "Daily except Wed",
        "stops": [
            {
                "code": "MAQ",
                "arr": "06:25 AM",
                "dep": "06:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "06:58 AM",
                "dep": "07:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:33 AM",
                "dep": "07:34 AM",
                "pf": "PF 2"
            },
            {
                "code": "CAN",
                "arr": "07:55 AM",
                "dep": "07:57 AM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "08:14 AM",
                "dep": "08:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "08:57 AM",
                "dep": "08:59 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "09:23 AM",
                "dep": "09:24 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "09:58 AM",
                "dep": "10:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "10:38 AM",
                "dep": "10:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERS",
                "arr": "11:45 AM",
                "dep": "11:48 AM",
                "pf": "PF 1"
            },
            {
                "code": "ALLP",
                "arr": "12:38 PM",
                "dep": "12:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "01:40 PM",
                "dep": "01:42 PM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "03:05 PM",
                "dep": "03:05 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "20632",
        "name": "Vande Bharat Express",
        "origin": "Thiruvananthapuram (TVC)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Superfast / Vande Bharat",
        "days": "Daily except Wed",
        "stops": [
            {
                "code": "TVC",
                "arr": "04:05 PM",
                "dep": "04:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "04:53 PM",
                "dep": "04:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "ALLP",
                "arr": "05:55 PM",
                "dep": "05:57 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERS",
                "arr": "06:35 PM",
                "dep": "06:38 PM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "07:40 PM",
                "dep": "07:42 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "08:15 PM",
                "dep": "08:17 PM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "08:52 PM",
                "dep": "08:53 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "09:32 PM",
                "dep": "09:34 PM",
                "pf": "PF 3"
            },
            {
                "code": "TLY",
                "arr": "10:14 PM",
                "dep": "10:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "10:33 PM",
                "dep": "10:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "11:00 PM",
                "dep": "11:01 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "11:48 PM",
                "dep": "11:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "12:40 AM",
                "dep": "12:40 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16649",
        "name": "Parasuram Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Nagercoil Jn (NCJ)",
        "type": "Ordinary Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "05:05 AM",
                "dep": "05:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "05:59 AM",
                "dep": "06:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "06:19 AM",
                "dep": "06:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "06:29 AM",
                "dep": "06:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "06:39 AM",
                "dep": "06:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "06:49 AM",
                "dep": "06:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "06:54 AM",
                "dep": "06:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "07:10 AM",
                "dep": "07:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "DMD",
                "arr": "07:29 AM",
                "dep": "07:30 AM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "07:34 AM",
                "dep": "07:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "07:44 AM",
                "dep": "07:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "07:54 AM",
                "dep": "07:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "PYOL",
                "arr": "08:04 AM",
                "dep": "08:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "QLD",
                "arr": "08:14 AM",
                "dep": "08:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "08:37 AM",
                "dep": "08:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "08:54 AM",
                "dep": "08:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "09:14 AM",
                "dep": "09:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "09:24 AM",
                "dep": "09:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "09:34 AM",
                "dep": "09:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "09:54 AM",
                "dep": "09:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "10:14 AM",
                "dep": "10:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "11:10 AM",
                "dep": "11:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "WKI",
                "arr": "11:34 AM",
                "dep": "11:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "11:58 AM",
                "dep": "12:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "IJK",
                "arr": "12:22 PM",
                "dep": "12:23 PM",
                "pf": "PF 1"
            },
            {
                "code": "CKI",
                "arr": "12:32 PM",
                "dep": "12:33 PM",
                "pf": "PF 1"
            },
            {
                "code": "AFK",
                "arr": "12:49 PM",
                "dep": "12:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "01:03 PM",
                "dep": "01:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "01:30 PM",
                "dep": "01:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "TRTR",
                "arr": "01:54 PM",
                "dep": "01:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "PVRD",
                "arr": "02:14 PM",
                "dep": "02:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "02:55 PM",
                "dep": "03:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "CGY",
                "arr": "03:19 PM",
                "dep": "03:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "TRVL",
                "arr": "03:29 PM",
                "dep": "03:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "CNGR",
                "arr": "03:41 PM",
                "dep": "03:43 PM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "03:54 PM",
                "dep": "03:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "04:13 PM",
                "dep": "04:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "04:29 PM",
                "dep": "04:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "05:02 PM",
                "dep": "05:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "05:19 PM",
                "dep": "05:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "05:31 PM",
                "dep": "05:32 PM",
                "pf": "PF 1"
            },
            {
                "code": "CRY",
                "arr": "05:49 PM",
                "dep": "05:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZK",
                "arr": "06:14 PM",
                "dep": "06:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "TVP",
                "arr": "06:29 PM",
                "dep": "06:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "06:50 PM",
                "dep": "06:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "NYY",
                "arr": "07:19 PM",
                "dep": "07:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "PASA",
                "arr": "07:34 PM",
                "dep": "07:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "NCJ",
                "arr": "08:45 PM",
                "dep": "08:45 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16650",
        "name": "Parasuram Express",
        "origin": "Nagercoil Jn (NCJ)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Ordinary Express",
        "days": "Daily",
        "stops": [
            {
                "code": "NCJ",
                "arr": "04:00 AM",
                "dep": "04:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "PASA",
                "arr": "04:44 AM",
                "dep": "04:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "NYY",
                "arr": "04:59 AM",
                "dep": "05:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "05:35 AM",
                "dep": "05:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVP",
                "arr": "05:46 AM",
                "dep": "05:47 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZK",
                "arr": "06:01 AM",
                "dep": "06:02 AM",
                "pf": "PF 1"
            },
            {
                "code": "CRY",
                "arr": "06:20 AM",
                "dep": "06:21 AM",
                "pf": "PF 2"
            },
            {
                "code": "VAK",
                "arr": "06:35 AM",
                "dep": "06:36 AM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "06:48 AM",
                "dep": "06:49 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "07:12 AM",
                "dep": "07:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "07:39 AM",
                "dep": "07:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "07:58 AM",
                "dep": "08:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "08:11 AM",
                "dep": "08:12 AM",
                "pf": "PF 2"
            },
            {
                "code": "CNGR",
                "arr": "08:24 AM",
                "dep": "08:26 AM",
                "pf": "PF 3"
            },
            {
                "code": "TRVL",
                "arr": "08:36 AM",
                "dep": "08:37 AM",
                "pf": "PF 2"
            },
            {
                "code": "CGY",
                "arr": "08:46 AM",
                "dep": "08:47 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "09:12 AM",
                "dep": "09:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "PVRD",
                "arr": "09:44 AM",
                "dep": "09:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "TRTR",
                "arr": "10:09 AM",
                "dep": "10:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "10:55 AM",
                "dep": "11:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "11:20 AM",
                "dep": "11:22 AM",
                "pf": "PF 3"
            },
            {
                "code": "AFK",
                "arr": "11:34 AM",
                "dep": "11:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "CKI",
                "arr": "11:49 AM",
                "dep": "11:50 AM",
                "pf": "PF 2"
            },
            {
                "code": "IJK",
                "arr": "11:59 AM",
                "dep": "12:00 PM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "12:23 PM",
                "dep": "12:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "WKI",
                "arr": "12:44 PM",
                "dep": "12:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "01:25 PM",
                "dep": "01:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "PTB",
                "arr": "01:44 PM",
                "dep": "01:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "02:04 PM",
                "dep": "02:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "02:23 PM",
                "dep": "02:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "02:34 PM",
                "dep": "02:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "02:44 PM",
                "dep": "02:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "03:04 PM",
                "dep": "03:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "03:32 PM",
                "dep": "03:35 PM",
                "pf": "PF 4"
            },
            {
                "code": "QLD",
                "arr": "04:04 PM",
                "dep": "04:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "PYOL",
                "arr": "04:14 PM",
                "dep": "04:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "BDJ",
                "arr": "04:24 PM",
                "dep": "04:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "04:39 PM",
                "dep": "04:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "04:54 PM",
                "dep": "04:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "DMD",
                "arr": "05:04 PM",
                "dep": "05:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "05:25 PM",
                "dep": "05:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPQ",
                "arr": "05:44 PM",
                "dep": "05:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "05:54 PM",
                "dep": "05:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "06:09 PM",
                "dep": "06:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "06:24 PM",
                "dep": "06:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "06:39 PM",
                "dep": "06:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "07:14 PM",
                "dep": "07:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "08:50 PM",
                "dep": "08:50 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16605",
        "name": "Ernad Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Nagercoil Jn (NCJ)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "07:20 AM",
                "dep": "07:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "08:04 AM",
                "dep": "08:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "08:24 AM",
                "dep": "08:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "08:34 AM",
                "dep": "08:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "CHV",
                "arr": "08:44 AM",
                "dep": "08:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "08:54 AM",
                "dep": "08:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "09:04 AM",
                "dep": "09:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "09:09 AM",
                "dep": "09:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAPM",
                "arr": "09:19 AM",
                "dep": "09:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "09:32 AM",
                "dep": "09:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "09:54 AM",
                "dep": "09:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "10:04 AM",
                "dep": "10:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "10:14 AM",
                "dep": "10:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "PYOL",
                "arr": "10:24 AM",
                "dep": "10:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "10:39 AM",
                "dep": "10:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "11:07 AM",
                "dep": "11:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "11:24 AM",
                "dep": "11:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "11:44 AM",
                "dep": "11:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "11:54 AM",
                "dep": "11:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "12:08 PM",
                "dep": "12:10 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "12:29 PM",
                "dep": "12:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "12:49 PM",
                "dep": "12:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "01:25 PM",
                "dep": "01:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "02:12 PM",
                "dep": "02:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "CKI",
                "arr": "02:44 PM",
                "dep": "02:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "AFK",
                "arr": "03:00 PM",
                "dep": "03:01 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "03:13 PM",
                "dep": "03:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERS",
                "arr": "04:10 PM",
                "dep": "04:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "04:54 PM",
                "dep": "04:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "ALLP",
                "arr": "05:22 PM",
                "dep": "05:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "AMPA",
                "arr": "05:39 PM",
                "dep": "05:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "HAD",
                "arr": "05:59 PM",
                "dep": "06:00 PM",
                "pf": "PF 2"
            },
            {
                "code": "KYJ",
                "arr": "06:18 PM",
                "dep": "06:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "06:34 PM",
                "dep": "06:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "07:12 PM",
                "dep": "07:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "07:39 PM",
                "dep": "07:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "08:45 PM",
                "dep": "08:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "NCJ",
                "arr": "10:35 PM",
                "dep": "10:35 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16606",
        "name": "Ernad Express",
        "origin": "Nagercoil Jn (NCJ)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "NCJ",
                "arr": "02:00 AM",
                "dep": "02:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "03:30 AM",
                "dep": "03:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "04:14 AM",
                "dep": "04:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "04:42 AM",
                "dep": "04:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "05:04 AM",
                "dep": "05:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "05:20 AM",
                "dep": "05:22 AM",
                "pf": "PF 1"
            },
            {
                "code": "HAD",
                "arr": "05:39 AM",
                "dep": "05:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "AMPA",
                "arr": "05:59 AM",
                "dep": "06:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "ALLP",
                "arr": "06:17 AM",
                "dep": "06:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "06:44 AM",
                "dep": "06:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "07:45 AM",
                "dep": "07:50 AM",
                "pf": "PF 2"
            },
            {
                "code": "AWY",
                "arr": "08:13 AM",
                "dep": "08:15 AM",
                "pf": "PF 3"
            },
            {
                "code": "AFK",
                "arr": "08:24 AM",
                "dep": "08:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "CKI",
                "arr": "08:39 AM",
                "dep": "08:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "09:03 AM",
                "dep": "09:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "10:00 AM",
                "dep": "10:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "10:24 AM",
                "dep": "10:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "10:44 AM",
                "dep": "10:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "11:03 AM",
                "dep": "11:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "11:14 AM",
                "dep": "11:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "11:24 AM",
                "dep": "11:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "11:44 AM",
                "dep": "11:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "12:12 PM",
                "dep": "12:15 PM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "12:44 PM",
                "dep": "12:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "PYOL",
                "arr": "12:54 PM",
                "dep": "12:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "BDJ",
                "arr": "01:04 PM",
                "dep": "01:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "01:19 PM",
                "dep": "01:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "01:34 PM",
                "dep": "01:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "02:05 PM",
                "dep": "02:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAPM",
                "arr": "02:22 PM",
                "dep": "02:23 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "02:31 PM",
                "dep": "02:32 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "02:39 PM",
                "dep": "02:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "02:54 PM",
                "dep": "02:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "CHV",
                "arr": "03:09 PM",
                "dep": "03:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "03:19 PM",
                "dep": "03:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "03:34 PM",
                "dep": "03:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "04:09 PM",
                "dep": "04:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "05:55 PM",
                "dep": "05:55 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16629",
        "name": "Malabar Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Thiruvananthapuram Central (TVC)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "06:15 PM",
                "dep": "06:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "06:58 PM",
                "dep": "07:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "07:19 PM",
                "dep": "07:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "07:29 PM",
                "dep": "07:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:49 PM",
                "dep": "07:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "07:59 PM",
                "dep": "08:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "08:09 PM",
                "dep": "08:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "08:35 PM",
                "dep": "08:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "09:03 PM",
                "dep": "09:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "09:14 PM",
                "dep": "09:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "09:29 PM",
                "dep": "09:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "09:49 PM",
                "dep": "09:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "10:17 PM",
                "dep": "10:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "10:44 PM",
                "dep": "10:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "10:54 PM",
                "dep": "10:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "11:08 PM",
                "dep": "11:10 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "11:29 PM",
                "dep": "11:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "11:49 PM",
                "dep": "11:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "12:15 AM",
                "dep": "12:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "01:02 AM",
                "dep": "01:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "01:58 AM",
                "dep": "02:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "02:30 AM",
                "dep": "02:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "03:47 AM",
                "dep": "03:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "CGY",
                "arr": "04:14 AM",
                "dep": "04:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "TRVL",
                "arr": "04:24 AM",
                "dep": "04:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "CNGR",
                "arr": "04:36 AM",
                "dep": "04:38 AM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "04:49 AM",
                "dep": "04:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "05:08 AM",
                "dep": "05:10 AM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "05:24 AM",
                "dep": "05:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "06:12 AM",
                "dep": "06:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "06:31 AM",
                "dep": "06:32 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "06:44 AM",
                "dep": "06:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZK",
                "arr": "07:24 AM",
                "dep": "07:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVP",
                "arr": "07:44 AM",
                "dep": "07:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "08:15 AM",
                "dep": "08:15 AM",
                "pf": "PF 3"
            }
        ]
    },
    {
        "train_no": "16630",
        "name": "Malabar Express",
        "origin": "Thiruvananthapuram Central (TVC)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "TVC",
                "arr": "06:30 PM",
                "dep": "06:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "TVP",
                "arr": "06:37 PM",
                "dep": "06:38 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZK",
                "arr": "06:54 PM",
                "dep": "06:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "07:24 PM",
                "dep": "07:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "07:39 PM",
                "dep": "07:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "08:07 PM",
                "dep": "08:10 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "08:34 PM",
                "dep": "08:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "08:53 PM",
                "dep": "08:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "09:07 PM",
                "dep": "09:08 PM",
                "pf": "PF 2"
            },
            {
                "code": "CNGR",
                "arr": "09:19 PM",
                "dep": "09:21 PM",
                "pf": "PF 3"
            },
            {
                "code": "TRVL",
                "arr": "09:31 PM",
                "dep": "09:32 PM",
                "pf": "PF 2"
            },
            {
                "code": "CGY",
                "arr": "09:41 PM",
                "dep": "09:42 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "10:10 PM",
                "dep": "10:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "11:35 PM",
                "dep": "11:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "12:08 AM",
                "dep": "12:10 AM",
                "pf": "PF 3"
            },
            {
                "code": "TCR",
                "arr": "01:02 AM",
                "dep": "01:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "02:10 AM",
                "dep": "02:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "02:34 AM",
                "dep": "02:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "02:54 AM",
                "dep": "02:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "03:13 AM",
                "dep": "03:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "03:24 AM",
                "dep": "03:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "03:34 AM",
                "dep": "03:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "04:17 AM",
                "dep": "04:20 AM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "04:49 AM",
                "dep": "04:50 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "05:09 AM",
                "dep": "05:10 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "05:24 AM",
                "dep": "05:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "05:38 AM",
                "dep": "05:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "06:10 AM",
                "dep": "06:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "06:34 AM",
                "dep": "06:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "06:44 AM",
                "dep": "06:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "06:59 AM",
                "dep": "07:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "07:19 AM",
                "dep": "07:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "07:34 AM",
                "dep": "07:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "08:14 AM",
                "dep": "08:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "09:35 AM",
                "dep": "09:35 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16603",
        "name": "Maveli Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Thiruvananthapuram Central (TVC)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "05:30 PM",
                "dep": "05:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "06:13 PM",
                "dep": "06:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "06:33 PM",
                "dep": "06:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "06:44 PM",
                "dep": "06:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:03 PM",
                "dep": "07:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "07:14 PM",
                "dep": "07:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "07:24 PM",
                "dep": "07:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "07:50 PM",
                "dep": "07:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "08:18 PM",
                "dep": "08:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "08:29 PM",
                "dep": "08:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "08:43 PM",
                "dep": "08:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "09:04 PM",
                "dep": "09:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "09:32 PM",
                "dep": "09:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "10:18 PM",
                "dep": "10:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "11:20 PM",
                "dep": "11:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "12:15 AM",
                "dep": "12:18 AM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "01:13 AM",
                "dep": "01:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "01:45 AM",
                "dep": "01:50 AM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "02:10 AM",
                "dep": "02:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "02:54 AM",
                "dep": "02:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "ALLP",
                "arr": "03:22 AM",
                "dep": "03:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "AMPA",
                "arr": "03:39 AM",
                "dep": "03:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "HAD",
                "arr": "03:59 AM",
                "dep": "04:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "KYJ",
                "arr": "04:18 AM",
                "dep": "04:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "04:34 AM",
                "dep": "04:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "05:12 AM",
                "dep": "05:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "05:31 AM",
                "dep": "05:32 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "05:44 AM",
                "dep": "05:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "06:45 AM",
                "dep": "06:45 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16604",
        "name": "Maveli Express",
        "origin": "Thiruvananthapuram Central (TVC)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "TVC",
                "arr": "07:25 PM",
                "dep": "07:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "08:04 PM",
                "dep": "08:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "08:19 PM",
                "dep": "08:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "08:47 PM",
                "dep": "08:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "09:14 PM",
                "dep": "09:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "09:33 PM",
                "dep": "09:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "HAD",
                "arr": "09:49 PM",
                "dep": "09:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "AMPA",
                "arr": "10:09 PM",
                "dep": "10:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "ALLP",
                "arr": "10:27 PM",
                "dep": "10:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "10:54 PM",
                "dep": "10:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "11:55 PM",
                "dep": "12:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "AWY",
                "arr": "12:28 AM",
                "dep": "12:30 AM",
                "pf": "PF 3"
            },
            {
                "code": "TCR",
                "arr": "01:22 AM",
                "dep": "01:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "02:30 AM",
                "dep": "02:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "03:18 AM",
                "dep": "03:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "04:07 AM",
                "dep": "04:10 AM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "04:34 AM",
                "dep": "04:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "04:54 AM",
                "dep": "04:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "05:09 AM",
                "dep": "05:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "05:23 AM",
                "dep": "05:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "05:55 AM",
                "dep": "06:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "06:19 AM",
                "dep": "06:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "06:29 AM",
                "dep": "06:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "06:44 AM",
                "dep": "06:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "07:04 AM",
                "dep": "07:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "07:19 AM",
                "dep": "07:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "07:54 AM",
                "dep": "07:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "09:00 AM",
                "dep": "09:00 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16348",
        "name": "Mangaluru - Trivandrum Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Thiruvananthapuram Central (TVC)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "02:25 PM",
                "dep": "02:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "03:18 PM",
                "dep": "03:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "03:43 PM",
                "dep": "03:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "03:54 PM",
                "dep": "03:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "04:14 PM",
                "dep": "04:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "04:24 PM",
                "dep": "04:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "04:34 PM",
                "dep": "04:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "04:55 PM",
                "dep": "05:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "05:24 PM",
                "dep": "05:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "05:34 PM",
                "dep": "05:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "05:49 PM",
                "dep": "05:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "06:09 PM",
                "dep": "06:10 PM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "06:37 PM",
                "dep": "06:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "06:54 PM",
                "dep": "06:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "07:14 PM",
                "dep": "07:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "07:24 PM",
                "dep": "07:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "07:38 PM",
                "dep": "07:40 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "07:59 PM",
                "dep": "08:00 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "08:19 PM",
                "dep": "08:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "08:45 PM",
                "dep": "08:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "WKI",
                "arr": "09:14 PM",
                "dep": "09:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "09:35 PM",
                "dep": "09:38 PM",
                "pf": "PF 1"
            },
            {
                "code": "IJK",
                "arr": "10:04 PM",
                "dep": "10:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "CKI",
                "arr": "10:14 PM",
                "dep": "10:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "AFK",
                "arr": "10:31 PM",
                "dep": "10:32 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "10:45 PM",
                "dep": "10:47 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "11:15 PM",
                "dep": "11:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "TRTR",
                "arr": "11:39 PM",
                "dep": "11:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "PVRD",
                "arr": "11:59 PM",
                "dep": "12:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "12:35 AM",
                "dep": "12:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "CGY",
                "arr": "01:04 AM",
                "dep": "01:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "TRVL",
                "arr": "01:14 AM",
                "dep": "01:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "CNGR",
                "arr": "01:26 AM",
                "dep": "01:28 AM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "01:39 AM",
                "dep": "01:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "01:58 AM",
                "dep": "02:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "02:14 AM",
                "dep": "02:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "02:57 AM",
                "dep": "03:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "03:19 AM",
                "dep": "03:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "03:32 AM",
                "dep": "03:33 AM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "04:45 AM",
                "dep": "04:45 AM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "16347",
        "name": "Trivandrum - Mangaluru Express",
        "origin": "Thiruvananthapuram Central (TVC)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "TVC",
                "arr": "08:50 PM",
                "dep": "08:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "VAK",
                "arr": "09:34 PM",
                "dep": "09:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "PVU",
                "arr": "09:49 PM",
                "dep": "09:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "10:17 PM",
                "dep": "10:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "10:44 PM",
                "dep": "10:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "11:03 PM",
                "dep": "11:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "MVLK",
                "arr": "11:17 PM",
                "dep": "11:18 PM",
                "pf": "PF 2"
            },
            {
                "code": "CNGR",
                "arr": "11:29 PM",
                "dep": "11:31 PM",
                "pf": "PF 3"
            },
            {
                "code": "TRVL",
                "arr": "11:41 PM",
                "dep": "11:42 PM",
                "pf": "PF 2"
            },
            {
                "code": "CGY",
                "arr": "11:51 PM",
                "dep": "11:52 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTYM",
                "arr": "12:20 AM",
                "dep": "12:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "PVRD",
                "arr": "12:54 AM",
                "dep": "12:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "TRTR",
                "arr": "01:19 AM",
                "dep": "01:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "ERN",
                "arr": "01:45 AM",
                "dep": "01:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "02:18 AM",
                "dep": "02:20 AM",
                "pf": "PF 3"
            },
            {
                "code": "AFK",
                "arr": "02:31 AM",
                "dep": "02:32 AM",
                "pf": "PF 2"
            },
            {
                "code": "CKI",
                "arr": "02:46 AM",
                "dep": "02:47 AM",
                "pf": "PF 2"
            },
            {
                "code": "IJK",
                "arr": "02:56 AM",
                "dep": "02:57 AM",
                "pf": "PF 2"
            },
            {
                "code": "TCR",
                "arr": "03:17 AM",
                "dep": "03:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "WKI",
                "arr": "03:39 AM",
                "dep": "03:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "04:30 AM",
                "dep": "04:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "04:54 AM",
                "dep": "04:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "05:14 AM",
                "dep": "05:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "05:33 AM",
                "dep": "05:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "05:44 AM",
                "dep": "05:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "05:54 AM",
                "dep": "05:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "06:14 AM",
                "dep": "06:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "06:47 AM",
                "dep": "06:50 AM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "07:19 AM",
                "dep": "07:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "07:39 AM",
                "dep": "07:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "07:54 AM",
                "dep": "07:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "08:08 AM",
                "dep": "08:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "08:35 AM",
                "dep": "08:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "08:59 AM",
                "dep": "09:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "09:09 AM",
                "dep": "09:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "09:24 AM",
                "dep": "09:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "09:44 AM",
                "dep": "09:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "09:59 AM",
                "dep": "10:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "10:39 AM",
                "dep": "10:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "11:55 AM",
                "dep": "11:55 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "22609",
        "name": "Intercity Superfast Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Coimbatore Jn (CBE)",
        "type": "Superfast",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "11:05 AM",
                "dep": "11:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "11:44 AM",
                "dep": "11:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "12:04 PM",
                "dep": "12:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "12:14 PM",
                "dep": "12:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "12:34 PM",
                "dep": "12:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "12:44 PM",
                "dep": "12:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "12:54 PM",
                "dep": "12:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "01:12 PM",
                "dep": "01:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "01:34 PM",
                "dep": "01:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "01:44 PM",
                "dep": "01:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "01:54 PM",
                "dep": "01:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "02:14 PM",
                "dep": "02:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "02:37 PM",
                "dep": "02:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "03:04 PM",
                "dep": "03:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "03:19 PM",
                "dep": "03:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "04:10 PM",
                "dep": "04:15 PM",
                "pf": "PF 3"
            },
            {
                "code": "OTP",
                "arr": "04:34 PM",
                "dep": "04:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "05:12 PM",
                "dep": "05:15 PM",
                "pf": "PF 3"
            },
            {
                "code": "CBE",
                "arr": "06:30 PM",
                "dep": "06:30 PM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "22610",
        "name": "Intercity Superfast Express",
        "origin": "Coimbatore Jn (CBE)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Superfast",
        "days": "Daily",
        "stops": [
            {
                "code": "CBE",
                "arr": "06:00 AM",
                "dep": "06:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "PGT",
                "arr": "06:57 AM",
                "dep": "07:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "OTP",
                "arr": "07:24 AM",
                "dep": "07:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "07:55 AM",
                "dep": "08:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "08:38 AM",
                "dep": "08:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "08:54 AM",
                "dep": "08:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "09:47 AM",
                "dep": "09:50 AM",
                "pf": "PF 4"
            },
            {
                "code": "QLD",
                "arr": "10:14 AM",
                "dep": "10:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "10:34 AM",
                "dep": "10:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "10:49 AM",
                "dep": "10:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "11:04 AM",
                "dep": "11:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "11:27 AM",
                "dep": "11:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "11:49 AM",
                "dep": "11:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "11:59 AM",
                "dep": "12:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "12:14 PM",
                "dep": "12:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "12:34 PM",
                "dep": "12:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "12:49 PM",
                "dep": "12:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "01:29 PM",
                "dep": "01:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "02:35 PM",
                "dep": "02:35 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "12617",
        "name": "Mangala Lakshadweep Express",
        "origin": "Ernakulam Jn (ERS)",
        "destination": "Hazrat Nizamuddin (NZM)",
        "type": "Superfast",
        "days": "Daily",
        "stops": [
            {
                "code": "ERS",
                "arr": "01:25 PM",
                "dep": "01:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "01:48 PM",
                "dep": "01:50 PM",
                "pf": "PF 3"
            },
            {
                "code": "TCR",
                "arr": "02:42 PM",
                "dep": "02:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "03:40 PM",
                "dep": "03:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "04:04 PM",
                "dep": "04:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "04:28 PM",
                "dep": "04:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "04:44 PM",
                "dep": "04:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "05:37 PM",
                "dep": "05:40 PM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "06:04 PM",
                "dep": "06:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "06:24 PM",
                "dep": "06:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "06:44 PM",
                "dep": "06:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "07:12 PM",
                "dep": "07:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:44 PM",
                "dep": "07:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "08:04 PM",
                "dep": "08:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "08:19 PM",
                "dep": "08:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "08:58 PM",
                "dep": "09:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAJN",
                "arr": "10:00 PM",
                "dep": "10:10 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "12618",
        "name": "Mangala Lakshadweep Express",
        "origin": "Hazrat Nizamuddin (NZM)",
        "destination": "Ernakulam Jn (ERS)",
        "type": "Superfast",
        "days": "Daily",
        "stops": [
            {
                "code": "MAJN",
                "arr": "04:10 AM",
                "dep": "04:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "05:04 AM",
                "dep": "05:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "05:24 AM",
                "dep": "05:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "05:39 AM",
                "dep": "05:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "05:59 AM",
                "dep": "06:00 AM",
                "pf": "PF 2"
            },
            {
                "code": "CAN",
                "arr": "06:35 AM",
                "dep": "06:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "07:04 AM",
                "dep": "07:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "07:24 AM",
                "dep": "07:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "08:07 AM",
                "dep": "08:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "08:34 AM",
                "dep": "08:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "08:54 AM",
                "dep": "08:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "09:24 AM",
                "dep": "09:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "10:05 AM",
                "dep": "10:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "11:00 AM",
                "dep": "11:03 AM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "11:58 AM",
                "dep": "12:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERS",
                "arr": "01:05 PM",
                "dep": "01:05 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16345",
        "name": "Netravati Express",
        "origin": "Lokmanya Tilak Terminus (LTT)",
        "destination": "Thiruvananthapuram (TVC)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "05:40 AM",
                "dep": "05:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "06:34 AM",
                "dep": "06:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "06:54 AM",
                "dep": "06:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:24 AM",
                "dep": "07:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "CAN",
                "arr": "07:55 AM",
                "dep": "08:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "08:24 AM",
                "dep": "08:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "08:44 AM",
                "dep": "08:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "09:32 AM",
                "dep": "09:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "10:04 AM",
                "dep": "10:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "10:24 AM",
                "dep": "10:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "10:44 AM",
                "dep": "10:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "11:45 AM",
                "dep": "11:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "TCR",
                "arr": "12:42 PM",
                "dep": "12:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "AWY",
                "arr": "01:38 PM",
                "dep": "01:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "ERS",
                "arr": "02:35 PM",
                "dep": "02:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "03:19 PM",
                "dep": "03:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "ALLP",
                "arr": "03:47 PM",
                "dep": "03:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "HAD",
                "arr": "04:19 PM",
                "dep": "04:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "KYJ",
                "arr": "04:38 PM",
                "dep": "04:40 PM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "04:54 PM",
                "dep": "04:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "05:42 PM",
                "dep": "05:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "06:14 PM",
                "dep": "06:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "TVC",
                "arr": "07:35 PM",
                "dep": "07:35 PM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "16346",
        "name": "Netravati Express",
        "origin": "Thiruvananthapuram (TVC)",
        "destination": "Lokmanya Tilak Terminus (LTT)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "TVC",
                "arr": "09:15 AM",
                "dep": "09:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAK",
                "arr": "09:54 AM",
                "dep": "09:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLN",
                "arr": "10:22 AM",
                "dep": "10:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "KPY",
                "arr": "10:44 AM",
                "dep": "10:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "KYJ",
                "arr": "11:03 AM",
                "dep": "11:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "HAD",
                "arr": "11:24 AM",
                "dep": "11:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "ALLP",
                "arr": "11:52 AM",
                "dep": "11:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "SRTL",
                "arr": "12:24 PM",
                "dep": "12:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "ERS",
                "arr": "01:20 PM",
                "dep": "01:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "AWY",
                "arr": "01:48 PM",
                "dep": "01:50 PM",
                "pf": "PF 3"
            },
            {
                "code": "TCR",
                "arr": "02:42 PM",
                "dep": "02:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "03:50 PM",
                "dep": "03:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "04:24 PM",
                "dep": "04:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "04:43 PM",
                "dep": "04:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "04:59 PM",
                "dep": "05:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "05:47 PM",
                "dep": "05:50 PM",
                "pf": "PF 3"
            },
            {
                "code": "BDJ",
                "arr": "06:34 PM",
                "dep": "06:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "06:54 PM",
                "dep": "06:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "07:22 PM",
                "dep": "07:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:54 PM",
                "dep": "07:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "08:24 PM",
                "dep": "08:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "08:58 PM",
                "dep": "09:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "10:15 PM",
                "dep": "10:25 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "12601",
        "name": "Chennai Mail",
        "origin": "Chennai Central (MAS)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Superfast / Mail",
        "days": "Daily",
        "stops": [
            {
                "code": "CBE",
                "arr": "03:30 AM",
                "dep": "03:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "04:35 AM",
                "dep": "04:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "OTP",
                "arr": "05:04 AM",
                "dep": "05:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "05:35 AM",
                "dep": "05:40 AM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "05:59 AM",
                "dep": "06:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "06:19 AM",
                "dep": "06:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "06:38 AM",
                "dep": "06:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "06:49 AM",
                "dep": "06:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "06:59 AM",
                "dep": "07:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "07:19 AM",
                "dep": "07:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "07:52 AM",
                "dep": "07:55 AM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "08:24 AM",
                "dep": "08:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "08:44 AM",
                "dep": "08:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "08:59 AM",
                "dep": "09:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "09:14 AM",
                "dep": "09:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "09:42 AM",
                "dep": "09:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "10:09 AM",
                "dep": "10:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "10:24 AM",
                "dep": "10:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "10:44 AM",
                "dep": "10:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "10:59 AM",
                "dep": "11:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "11:34 AM",
                "dep": "11:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "01:05 PM",
                "dep": "01:05 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "12602",
        "name": "Chennai Mail",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Chennai Central (MAS)",
        "type": "Superfast / Mail",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "01:55 PM",
                "dep": "01:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "02:38 PM",
                "dep": "02:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "02:58 PM",
                "dep": "03:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "03:09 PM",
                "dep": "03:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "03:29 PM",
                "dep": "03:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "03:39 PM",
                "dep": "03:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "04:12 PM",
                "dep": "04:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "04:34 PM",
                "dep": "04:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "04:44 PM",
                "dep": "04:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "04:58 PM",
                "dep": "05:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "05:19 PM",
                "dep": "05:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "05:47 PM",
                "dep": "05:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "06:09 PM",
                "dep": "06:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "06:29 PM",
                "dep": "06:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "06:39 PM",
                "dep": "06:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "06:53 PM",
                "dep": "06:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "07:14 PM",
                "dep": "07:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "07:34 PM",
                "dep": "07:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "08:15 PM",
                "dep": "08:20 PM",
                "pf": "PF 3"
            },
            {
                "code": "OTP",
                "arr": "08:44 PM",
                "dep": "08:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "09:32 PM",
                "dep": "09:35 PM",
                "pf": "PF 3"
            },
            {
                "code": "CBE",
                "arr": "10:55 PM",
                "dep": "11:00 PM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "22637",
        "name": "West Coast Superfast Express",
        "origin": "Chennai Central (MAS)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Superfast",
        "days": "Daily",
        "stops": [
            {
                "code": "CBE",
                "arr": "08:45 PM",
                "dep": "08:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "09:47 PM",
                "dep": "09:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "OTP",
                "arr": "10:19 PM",
                "dep": "10:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "10:55 PM",
                "dep": "11:00 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "11:34 PM",
                "dep": "11:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "11:53 PM",
                "dep": "11:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "12:14 AM",
                "dep": "12:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "01:02 AM",
                "dep": "01:05 AM",
                "pf": "PF 3"
            },
            {
                "code": "BDJ",
                "arr": "01:49 AM",
                "dep": "01:50 AM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "02:08 AM",
                "dep": "02:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "02:40 AM",
                "dep": "02:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "03:14 AM",
                "dep": "03:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "03:34 AM",
                "dep": "03:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "03:49 AM",
                "dep": "03:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "04:24 AM",
                "dep": "04:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "05:40 AM",
                "dep": "05:40 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "22638",
        "name": "West Coast Superfast Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Chennai Central (MAS)",
        "type": "Superfast",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "11:45 PM",
                "dep": "11:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "12:23 AM",
                "dep": "12:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "12:43 AM",
                "dep": "12:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "12:54 AM",
                "dep": "12:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "01:14 AM",
                "dep": "01:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "CAN",
                "arr": "01:50 AM",
                "dep": "01:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "02:14 AM",
                "dep": "02:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "02:34 AM",
                "dep": "02:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "03:22 AM",
                "dep": "03:25 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "03:49 AM",
                "dep": "03:50 AM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "04:03 AM",
                "dep": "04:05 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "04:24 AM",
                "dep": "04:25 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "05:10 AM",
                "dep": "05:15 AM",
                "pf": "PF 3"
            },
            {
                "code": "OTP",
                "arr": "05:39 AM",
                "dep": "05:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "06:17 AM",
                "dep": "06:20 AM",
                "pf": "PF 3"
            },
            {
                "code": "CBE",
                "arr": "07:35 AM",
                "dep": "07:40 AM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "06477",
        "name": "Kannur - Mangaluru Passenger Special",
        "origin": "Kannur (CAN)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Passenger",
        "days": "Daily",
        "stops": [
            {
                "code": "CAN",
                "arr": "07:40 AM",
                "dep": "07:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "VAPM",
                "arr": "07:49 AM",
                "dep": "07:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "07:58 AM",
                "dep": "07:59 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "08:06 AM",
                "dep": "08:07 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "08:19 AM",
                "dep": "08:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "CHV",
                "arr": "08:31 AM",
                "dep": "08:32 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "08:41 AM",
                "dep": "08:42 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "08:54 AM",
                "dep": "08:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "BFR",
                "arr": "09:04 AM",
                "dep": "09:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "KQK",
                "arr": "09:14 AM",
                "dep": "09:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "09:34 AM",
                "dep": "09:35 AM",
                "pf": "PF 1"
            },
            {
                "code": "KMBL",
                "arr": "09:49 AM",
                "dep": "09:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "UAA",
                "arr": "10:04 AM",
                "dep": "10:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "MJS",
                "arr": "10:19 AM",
                "dep": "10:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "11:00 AM",
                "dep": "11:00 AM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "06478",
        "name": "Mangaluru - Kannur Passenger Special",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Kannur (CAN)",
        "type": "Passenger",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "05:05 PM",
                "dep": "05:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "MJS",
                "arr": "05:29 PM",
                "dep": "05:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "UAA",
                "arr": "05:44 PM",
                "dep": "05:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KMBL",
                "arr": "05:59 PM",
                "dep": "06:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "06:19 PM",
                "dep": "06:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "KQK",
                "arr": "06:34 PM",
                "dep": "06:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "BFR",
                "arr": "06:44 PM",
                "dep": "06:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "06:59 PM",
                "dep": "07:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "07:14 PM",
                "dep": "07:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "CHV",
                "arr": "07:24 PM",
                "dep": "07:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "07:44 PM",
                "dep": "07:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "07:59 PM",
                "dep": "08:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "08:09 PM",
                "dep": "08:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "VAPM",
                "arr": "08:19 PM",
                "dep": "08:20 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "08:45 PM",
                "dep": "08:45 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "06481",
        "name": "Kannur - Kozhikode Daily Passenger",
        "origin": "Kannur (CAN)",
        "destination": "Kozhikode (CLT)",
        "type": "Passenger",
        "days": "Daily",
        "stops": [
            {
                "code": "CAN",
                "arr": "05:45 AM",
                "dep": "05:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "CS",
                "arr": "05:52 AM",
                "dep": "05:53 AM",
                "pf": "PF 1"
            },
            {
                "code": "DMD",
                "arr": "06:04 AM",
                "dep": "06:05 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "06:14 AM",
                "dep": "06:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "MAHE",
                "arr": "06:26 AM",
                "dep": "06:27 AM",
                "pf": "PF 1"
            },
            {
                "code": "BDJ",
                "arr": "06:44 AM",
                "dep": "06:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "PYOL",
                "arr": "06:56 AM",
                "dep": "06:57 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "07:14 AM",
                "dep": "07:15 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "07:55 AM",
                "dep": "07:55 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "06482",
        "name": "Kozhikode - Kannur Daily Passenger",
        "origin": "Kozhikode (CLT)",
        "destination": "Kannur (CAN)",
        "type": "Passenger",
        "days": "Daily",
        "stops": [
            {
                "code": "CLT",
                "arr": "06:30 PM",
                "dep": "06:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "07:04 PM",
                "dep": "07:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "PYOL",
                "arr": "07:17 PM",
                "dep": "07:18 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "07:31 PM",
                "dep": "07:32 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "07:44 PM",
                "dep": "07:45 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "08:04 PM",
                "dep": "08:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "DMD",
                "arr": "08:14 PM",
                "dep": "08:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "CS",
                "arr": "08:29 PM",
                "dep": "08:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "CAN",
                "arr": "08:45 PM",
                "dep": "08:45 PM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "06479",
        "name": "Kozhikode - Shoranur Daily Passenger",
        "origin": "Kozhikode (CLT)",
        "destination": "Shoranur Jn (SRR)",
        "type": "Passenger",
        "days": "Daily",
        "stops": [
            {
                "code": "CLT",
                "arr": "05:20 PM",
                "dep": "05:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "FK",
                "arr": "05:39 PM",
                "dep": "05:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "05:59 PM",
                "dep": "06:00 PM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "06:14 PM",
                "dep": "06:15 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "06:28 PM",
                "dep": "06:30 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "06:49 PM",
                "dep": "06:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "07:09 PM",
                "dep": "07:10 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "07:45 PM",
                "dep": "07:45 PM",
                "pf": "PF 3"
            }
        ]
    },
    {
        "train_no": "06480",
        "name": "Shoranur - Kozhikode Daily Passenger",
        "origin": "Shoranur Jn (SRR)",
        "destination": "Kozhikode (CLT)",
        "type": "Passenger",
        "days": "Daily",
        "stops": [
            {
                "code": "SRR",
                "arr": "08:20 AM",
                "dep": "08:20 AM",
                "pf": "PF 3"
            },
            {
                "code": "PTB",
                "arr": "08:39 AM",
                "dep": "08:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "08:59 AM",
                "dep": "09:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "09:18 AM",
                "dep": "09:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "09:31 AM",
                "dep": "09:32 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "09:44 AM",
                "dep": "09:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "10:09 AM",
                "dep": "10:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "10:45 AM",
                "dep": "10:45 AM",
                "pf": "PF 2"
            }
        ]
    },
    {
        "train_no": "16527",
        "name": "Yesvantpur Express",
        "origin": "Kannur (CAN)",
        "destination": "Yesvantpur (YPR)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "CAN",
                "arr": "06:05 PM",
                "dep": "06:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "06:24 PM",
                "dep": "06:25 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "06:44 PM",
                "dep": "06:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "07:04 PM",
                "dep": "07:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "07:37 PM",
                "dep": "07:40 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "08:04 PM",
                "dep": "08:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "TIR",
                "arr": "08:18 PM",
                "dep": "08:20 PM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "08:39 PM",
                "dep": "08:40 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "09:25 PM",
                "dep": "09:30 PM",
                "pf": "PF 3"
            },
            {
                "code": "OTP",
                "arr": "09:54 PM",
                "dep": "09:55 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "10:32 PM",
                "dep": "10:35 PM",
                "pf": "PF 3"
            },
            {
                "code": "CBE",
                "arr": "11:57 PM",
                "dep": "12:00 AM",
                "pf": "PF 3"
            }
        ]
    },
    {
        "train_no": "16528",
        "name": "Yesvantpur - Kannur Express",
        "origin": "Yesvantpur (YPR)",
        "destination": "Kannur (CAN)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "CBE",
                "arr": "03:47 AM",
                "dep": "03:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "04:52 AM",
                "dep": "04:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "OTP",
                "arr": "05:19 AM",
                "dep": "05:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "05:50 AM",
                "dep": "05:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "06:29 AM",
                "dep": "06:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "06:48 AM",
                "dep": "06:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "07:09 AM",
                "dep": "07:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "07:47 AM",
                "dep": "07:50 AM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "08:14 AM",
                "dep": "08:15 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "08:34 AM",
                "dep": "08:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "TLY",
                "arr": "08:54 AM",
                "dep": "08:55 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "09:45 AM",
                "dep": "09:45 AM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16159",
        "name": "Chennai Egmore - Mangaluru Express",
        "origin": "Chennai Egmore (MS)",
        "destination": "Mangaluru Central (MAQ)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "CBE",
                "arr": "10:15 AM",
                "dep": "10:20 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "11:32 AM",
                "dep": "11:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "OTP",
                "arr": "12:04 PM",
                "dep": "12:05 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "12:45 PM",
                "dep": "12:50 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "01:09 PM",
                "dep": "01:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "KTU",
                "arr": "01:29 PM",
                "dep": "01:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "01:48 PM",
                "dep": "01:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "TA",
                "arr": "01:59 PM",
                "dep": "02:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "02:09 PM",
                "dep": "02:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "02:29 PM",
                "dep": "02:30 PM",
                "pf": "PF 1"
            },
            {
                "code": "CLT",
                "arr": "03:02 PM",
                "dep": "03:05 PM",
                "pf": "PF 3"
            },
            {
                "code": "QLD",
                "arr": "03:34 PM",
                "dep": "03:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "03:54 PM",
                "dep": "03:55 PM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "04:09 PM",
                "dep": "04:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "04:24 PM",
                "dep": "04:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "04:55 PM",
                "dep": "05:00 PM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "05:24 PM",
                "dep": "05:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAZ",
                "arr": "05:34 PM",
                "dep": "05:35 PM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "05:49 PM",
                "dep": "05:50 PM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "06:09 PM",
                "dep": "06:10 PM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "06:24 PM",
                "dep": "06:25 PM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "07:04 PM",
                "dep": "07:05 PM",
                "pf": "PF 1"
            },
            {
                "code": "MAQ",
                "arr": "08:35 PM",
                "dep": "08:35 PM",
                "pf": "PF 1"
            }
        ]
    },
    {
        "train_no": "16160",
        "name": "Mangaluru - Chennai Egmore Express",
        "origin": "Mangaluru Central (MAQ)",
        "destination": "Chennai Egmore (MS)",
        "type": "Express",
        "days": "Daily",
        "stops": [
            {
                "code": "MAQ",
                "arr": "06:45 AM",
                "dep": "06:45 AM",
                "pf": "PF 1"
            },
            {
                "code": "KGQ",
                "arr": "07:28 AM",
                "dep": "07:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "KZE",
                "arr": "07:49 AM",
                "dep": "07:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "NLE",
                "arr": "07:59 AM",
                "dep": "08:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "PAY",
                "arr": "08:19 AM",
                "dep": "08:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "PAZ",
                "arr": "08:29 AM",
                "dep": "08:30 AM",
                "pf": "PF 1"
            },
            {
                "code": "KPQ",
                "arr": "08:39 AM",
                "dep": "08:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "CAN",
                "arr": "09:05 AM",
                "dep": "09:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "TLY",
                "arr": "09:34 AM",
                "dep": "09:35 AM",
                "pf": "PF 2"
            },
            {
                "code": "MAHE",
                "arr": "09:44 AM",
                "dep": "09:45 AM",
                "pf": "PF 2"
            },
            {
                "code": "BDJ",
                "arr": "09:59 AM",
                "dep": "10:00 AM",
                "pf": "PF 1"
            },
            {
                "code": "QLD",
                "arr": "10:19 AM",
                "dep": "10:20 AM",
                "pf": "PF 2"
            },
            {
                "code": "CLT",
                "arr": "10:47 AM",
                "dep": "10:50 AM",
                "pf": "PF 1"
            },
            {
                "code": "FK",
                "arr": "11:09 AM",
                "dep": "11:10 AM",
                "pf": "PF 1"
            },
            {
                "code": "PGI",
                "arr": "11:29 AM",
                "dep": "11:30 AM",
                "pf": "PF 2"
            },
            {
                "code": "TA",
                "arr": "11:39 AM",
                "dep": "11:40 AM",
                "pf": "PF 1"
            },
            {
                "code": "TIR",
                "arr": "11:53 AM",
                "dep": "11:55 AM",
                "pf": "PF 2"
            },
            {
                "code": "KTU",
                "arr": "12:14 PM",
                "dep": "12:15 PM",
                "pf": "PF 2"
            },
            {
                "code": "PTB",
                "arr": "12:34 PM",
                "dep": "12:35 PM",
                "pf": "PF 2"
            },
            {
                "code": "SRR",
                "arr": "01:15 PM",
                "dep": "01:20 PM",
                "pf": "PF 3"
            },
            {
                "code": "OTP",
                "arr": "01:44 PM",
                "dep": "01:45 PM",
                "pf": "PF 1"
            },
            {
                "code": "PGT",
                "arr": "02:32 PM",
                "dep": "02:35 PM",
                "pf": "PF 3"
            },
            {
                "code": "CBE",
                "arr": "03:55 PM",
                "dep": "04:00 PM",
                "pf": "PF 2"
            }
        ]
    }
]
