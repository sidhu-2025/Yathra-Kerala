import urllib.request, json

# Test 1: Kannur to Cherukunnu (should show Cherukunnu Express bus, NO train since Cherukunnu is not main railway)
url = 'http://127.0.0.1:8000/api/plan-journey?source=Kannur&destination=Cherukunnu&preference=best'
resp = json.loads(urllib.request.urlopen(url).read())
print("=== Kannur -> Cherukunnu ===")
print("has_train_available:", resp.get("has_train_available"))
print("distance_km:", resp.get("distance_km"))
for r in resp.get("routes", []):
    print("  [" + r["mode_type"] + "]", r["title"][:65], "| Fare:", r["total_fare"], "| Dep:", r.get("expected_departure"), "| Arr:", r.get("expected_arrival"))

print()

# Test 2: Kannur to Thalassery (should show Malabar Coast Fast bus AND train - both have rail)
url2 = 'http://127.0.0.1:8000/api/plan-journey?source=Kannur&destination=Thalassery&preference=best'
resp2 = json.loads(urllib.request.urlopen(url2).read())
print("=== Kannur -> Thalassery ===")
print("has_train_available:", resp2.get("has_train_available"))
for r in resp2.get("routes", []):
    print("  [" + r["mode_type"] + "]", r["title"][:65], "| Fare:", r["total_fare"], "| Dep:", r.get("expected_departure"), "| Arr:", r.get("expected_arrival"))

print()

# Test 3: Kannur to Iritty (bus only, NO train - Iritty is inland)
url3 = 'http://127.0.0.1:8000/api/plan-journey?source=Kannur&destination=Iritty&preference=best'
resp3 = json.loads(urllib.request.urlopen(url3).read())
print("=== Kannur -> Iritty ===")
print("has_train_available:", resp3.get("has_train_available"))
for r in resp3.get("routes", []):
    print("  [" + r["mode_type"] + "]", r["title"][:65], "| Fare:", r["total_fare"], "| Dep:", r.get("expected_departure"))

print()

# Test 4: Kannur to Parassinikadavu
url4 = 'http://127.0.0.1:8000/api/plan-journey?source=Kannur&destination=Parassinikadavu&preference=best'
resp4 = json.loads(urllib.request.urlopen(url4).read())
print("=== Kannur -> Parassinikadavu ===")
print("has_train_available:", resp4.get("has_train_available"))
for r in resp4.get("routes", []):
    print("  [" + r["mode_type"] + "]", r["title"][:65], "| Fare:", r["total_fare"], "| Dep:", r.get("expected_departure"))
