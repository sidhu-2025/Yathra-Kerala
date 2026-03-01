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

def test_role(role):
    username = f"test_{role.lower()}_{generate_random_string()}"
    email = f"{username}@example.com"
    password = "testpassword123"

    print(f"\n--- Testing Registration/Login for {role} ({username}) ---")
    reg_data = {
        "username": username,
        "email": email,
        "password": password,
        "role": role,
    }
    
    code, body = post_json(f"{BASE_URL}/register/", reg_data)
    if code != 201:
        print(f"Registration failed! Status: {code}, Body: {body}")
        return False

    login_data = {"username": username, "password": password}
    code, body = post_json(f"{BASE_URL}/login/", login_data)
    if code == 200:
        res = json.loads(body)
        print(f"Login success! Returned Role: {res.get('role')}")
        if res.get('role') == role:
            print(f"[SUCCESS] {role} verified.")
            return True
        else:
            print(f"[FAILURE] Role mismatch! Expected {role}, got {res.get('role')}")
    else:
        print(f"Login failed! Status: {code}, Body: {body}")
    return False

if __name__ == "__main__":
    roles = ["STUDENT", "PARENT", "WARDEN", "SECURITY"]
    results = {role: test_role(role) for role in roles}
    
    print("\n" + "="*30)
    print("FINAL RESULTS:")
    for role, success in results.items():
        print(f"{role}: {'PASSED' if success else 'FAILED'}")
    print("="*30)
