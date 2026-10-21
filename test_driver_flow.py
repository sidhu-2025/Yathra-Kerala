import sys
import os
import time

# Ensure backend_yathra is on python path
sys.path.insert(0, os.path.abspath("."))

from backend_yathra.main import (
    register_user,
    update_driver_location,
    get_live_tracking,
    UserAuthRequest,
    DriverLocationUpdate,
)

print("="*60)
print("TEST 1: Check unregistered bus tracking")
print("="*60)
data = get_live_tracking("KL-99-XX-9999")
print(f"Response: {data}")
assert data.get("driver_registered") == False, "Expected driver_registered to be False"
assert data.get("status") == "not_registered", "Expected status to be not_registered"
print("[PASS] TEST 1: Unregistered bus correctly denied tracking.")

print("\n" + "="*60)
print("TEST 2: Register a brand new driver with arbitrary bus plate")
print("="*60)
driver_username = f"test_driver_{int(time.time())}"
test_plate = "KL-59-Z-7777"
reg_req = UserAuthRequest(
    username=driver_username,
    password="password123",
    name="Test Driver Suresh",
    email=f"{driver_username}@test.com",
    phone="9876543210",
    role="driver",
    vehicle_no=test_plate
)
reg_data = register_user(reg_req)
print(f"Register response: {reg_data}")
assert reg_data.get("status") == "success", "Registration did not return success"
print("[PASS] TEST 2: New driver registered successfully.")

print("\n" + "="*60)
print("TEST 3: Check tracking BEFORE driver transmits live location (should be offline)")
print("="*60)
data = get_live_tracking(test_plate)
print(f"Tracking response: {data}")
assert data.get("driver_registered") == True, "Expected driver_registered to be True"
assert data.get("status") == "offline", f"Expected offline status, got {data.get('status')}"
assert data.get("has_live_gps") == False, "Expected has_live_gps to be False before broadcast"
assert data.get("driver_name") == "Test Driver Suresh", f"Unexpected driver_name: {data.get('driver_name')}"
print("[PASS] TEST 3: Driver is recognized as registered and offline before transmitting GPS.")

print("\n" + "="*60)
print("TEST 4: Driver transmits LIVE physical GPS coordinates")
print("="*60)
broadcast_req = DriverLocationUpdate(
    vehicle_id=test_plate,
    lat=12.0456,
    lng=75.3621,
    current_stop="Taliparamba Bus Terminal",
    next_stop="Live Device GPS Track",
    speed_kmh=32.5,
    delay_mins=0,
    is_active=True,
    driver_name="Test Driver Suresh"
)
up_data = update_driver_location(broadcast_req)
print(f"Update response: {up_data}")
assert up_data.get("status") == "success", "Update location did not return success"
print("[PASS] TEST 4: Location broadcast accepted and persisted.")

print("\n" + "="*60)
print("TEST 5: Passenger tracks the new bus via exact plate")
print("="*60)
data = get_live_tracking(test_plate)
print(f"Tracking response: {data}")
assert data.get("driver_registered") == True, "Expected driver_registered: True"
assert data.get("is_active") == True, "Expected is_active: True"
assert data.get("has_live_gps") == True, "Expected has_live_gps: True"
assert data.get("status") == "LIVE GPS TRANSMITTING", f"Expected LIVE GPS TRANSMITTING, got {data.get('status')}"
assert round(data.get("lat"), 4) == 12.0456, f"Lat mismatch: {data.get('lat')}"
assert round(data.get("lng"), 4) == 75.3621, f"Lng mismatch: {data.get('lng')}"
assert data.get("current_stop") == "Taliparamba Bus Terminal", f"Stop mismatch: {data.get('current_stop')}"
assert data.get("driver_name") == "Test Driver Suresh", f"Driver name mismatch: {data.get('driver_name')}"
print("[PASS] TEST 5: Passenger receives exact live GPS coordinates, status, and driver details.")

print("\n" + "="*60)
print("TEST 6: Passenger tracks with stripped/unhyphenated plate (e.g. KL59Z7777)")
print("="*60)
data = get_live_tracking(test_plate.replace("-", ""))
print(f"Tracking response: {data}")
assert data.get("has_live_gps") == True, "Expected has_live_gps: True on stripped plate query"
assert round(data.get("lat"), 4) == 12.0456, f"Lat mismatch: {data.get('lat')}"
print("[PASS] TEST 6: Hyphen-agnostic matching works perfectly.")

print("\n" + "="*60)
print("TEST 7: Driver logs out (isActive: False), Passenger checks last known position")
print("="*60)
logout_req = DriverLocationUpdate(
    vehicle_id=test_plate,
    lat=12.0456,
    lng=75.3621,
    current_stop="Taliparamba Bus Terminal",
    next_stop="Live Device GPS Track",
    speed_kmh=0.0,
    delay_mins=0,
    is_active=False,
    driver_name="Test Driver Suresh"
)
update_driver_location(logout_req)

# Passenger tracks again after driver logout
data = get_live_tracking(test_plate)
print(f"Tracking response after logout: {data}")
assert data.get("has_live_gps") == True, "Expected has_live_gps: True even after logout"
assert data.get("is_active") == True, "Expected is_active: True for trackability"
assert round(data.get("lat"), 4) == 12.0456, "Exact coordinates preserved after logout"
print("[PASS] TEST 7: Last known location correctly preserved and trackable after driver logout.")

print("\n" + "="*60)
print("ALL 7 END-TO-END TESTS PASSED SUCCESSFULLY!")
print("="*60)
