import urllib.request, json

def test_login(username, password):
    url = 'http://127.0.0.1:8000/api/auth/login'
    payload = json.dumps({'username': username, 'password': password}).encode('utf-8')
    req = urllib.request.Request(url, data=payload, headers={'Content-Type': 'application/json'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read().decode('utf-8'))
        role = data['user']['role']
        name = data['user']['name']
        print(f"PASS login for '{username}': Role='{role}', Name='{name}'")
    except Exception as e:
        print(f"FAIL login for '{username}': {e}")

if __name__ == '__main__':
    print("Testing Passenger & Driver Logins:")
    test_login('user1', 'pass123')
    test_login('user2', 'pass123')
    test_login('driver1', 'driver123')
    test_login('driver2', 'driver123')
    test_login('invalid', 'wrongpassword')
