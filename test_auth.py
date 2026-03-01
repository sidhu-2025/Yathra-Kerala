import urllib.request
import urllib.parse
import urllib.error
import json
import random
import string

BASE_URL = "http://127.0.0.1:8000/api"

def generate_random_string(length=8):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))

def post_json(url, data):
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'))
    req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req) as response:
            return response.getcode(), response.read().decode('utf-8')
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode('utf-8')
    except Exception as e:
        return 0, str(e)

def test_registration_and_login():
    username = f"testuser_{generate_random_string()}"
    email = f"{username}@example.com"
    password = "testpassword123"
    role = "STUDENT"

    print(f"--- Testing Registration for {username} ---")
    reg_data = {
        "username": username,
        "email": email,
        "password": password,
        "role": role,
        "phone_number": "1234567890"
    }
    
    code, body = post_json(f"{BASE_URL}/register/", reg_data)
    print(f"Registration Status: {code}")
    print(f"Registration Body: {body}")
    
    if code != 201:
        print("Registration failed!")
        return

    print(f"\n--- Testing Login for {username} ---")
    login_data = {
        "username": username,
        "password": password
    }
    code, body = post_json(f"{BASE_URL}/login/", login_data)
    print(f"Login Status: {code}")
    print(f"Login Body: {body}")

    if code == 200:
        print("\n[SUCCESS] Registration and Login flow verified on backend!")
    else:
        print("\n[FAILURE] Login failed!")

if __name__ == "__main__":
    test_registration_and_login()
