import sqlite3, json
conn = sqlite3.connect('backend_yathra/yathrakerala.db')
conn.row_factory = sqlite3.Row
cur = conn.cursor()

cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = [r[0] for r in cur.fetchall()]
print('TABLES:', tables)

for t in tables:
    cur.execute(f'PRAGMA table_info({t})')
    cols = [(r[1], r[2]) for r in cur.fetchall()]
    cur.execute(f'SELECT COUNT(*) FROM {t}')
    count = cur.fetchone()[0]
    print(f'\n=== {t} ({count} rows) ===')
    print('  Columns:', cols)
    if count > 0:
        cur.execute(f'SELECT * FROM {t} LIMIT 3')
        rows = cur.fetchall()
        for row in rows:
            print(' ', dict(row))

conn.close()
