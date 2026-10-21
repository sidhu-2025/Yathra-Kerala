import urllib.request, urllib.parse, json

def test_query(source, dest):
    url = f"http://127.0.0.1:8000/api/plan-journey?source={urllib.parse.quote(source)}&destination={urllib.parse.quote(dest)}&preference=best"
    try:
        req = urllib.request.urlopen(url)
        data = json.loads(req.read().decode('utf-8'))
        has_train = data.get("has_train_available")
        modes = [r["mode_type"] for r in data.get("routes", [])]
        bus_routes = [r for r in data.get("routes", []) if r["mode_type"] == "BUS"]
        train_routes = [r for r in data.get("routes", []) if r["mode_type"] == "TRAIN"]
        
        print(f"\n=======================================================")
        print(f"QUERY: {source} -> {dest}")
        print(f"Distance: {data.get('distance_km')} km | Train Available: {has_train}")
        print(f"Available Modes: {list(set(modes))}")
        print(f"Bus suggestions count: {len(bus_routes)}")
        for b in bus_routes[:2]:
            fare_clean = b['total_fare'].replace('\u20b9', 'Rs. ')
            title_clean = b['title'].replace('\u20b9', 'Rs. ').replace('\u2022', '-')
            print(f"  * BUS: {title_clean}")
            print(f"    Fare: {fare_clean} | Dep: {b.get('expected_departure')} | Arr: {b.get('expected_arrival')}")
        if train_routes:
            print(f"Train suggestions count: {len(train_routes)}")
            for t in train_routes[:2]:
                fare_clean = t['total_fare'].replace('\u20b9', 'Rs. ')
                title_clean = t['title'].replace('\u20b9', 'Rs. ').replace('\u2022', '-')
                print(f"  * TRAIN: {title_clean} | Fare: {fare_clean} | Dep: {t.get('expected_departure')} | Arr: {t.get('expected_arrival')}")
        else:
            print("  * TRAIN: None (Correct - non-railway destination/origin)")
    except Exception as e:
        print(f"Error querying {source} -> {dest}: {e}")

if __name__ == '__main__':
    test_query("Kannur", "Cherukunnu")
    test_query("Kannur", "Parassinikadavu")
    test_query("Kannur", "Iritty")
    test_query("Kannur", "Thalassery")
