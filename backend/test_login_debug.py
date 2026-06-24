import urllib.request
import urllib.parse
import urllib.error
import json

BASE_URL = "http://127.0.0.1:8000/api"

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

def test_login(username, password, role):
    print(f"--- Testing Login for {username} as {role} ---")
    login_data = {
        "username": username,
        "password": password,
        "role": role
    }
    code, body = post_json(f"{BASE_URL}/login/", login_data)
    print(f"Status: {code}")
    print(f"Body: {body}")
    return code == 200

if __name__ == "__main__":
    # Test with newly created valid users
    test_login("valid_student", "testpass123", "STUDENT")
    test_login("valid_warden", "testpass123", "WARDEN")
    test_login("valid_parent", "testpass123", "PARENT")
