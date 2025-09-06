#!/usr/bin/env python3
import sys, json, pathlib, os, requests

if len(sys.argv) < 3:
    print("usage: indexnow_submit.py <host> <key>")
    sys.exit(0)

host = sys.argv[1].strip()
key  = (sys.argv[2] or "").strip() or "51ccd95176a34334891dc90cab8d3dc7"

p = pathlib.Path("changed_urls.txt")
urls = []
if p.exists() and p.stat().st_size > 0:
    urls = [u.strip() for u in p.read_text().splitlines() if u.strip()]

if not urls:
    print("IndexNow: no URLs, skipping.")
    sys.exit(0)

payload = {
    "host": host,
    "key": key,
    "keyLocation": f"https://{host}/{key}.txt",
    "urlList": urls
}
print("IndexNow payload URLs:", len(urls))

try:
    r = requests.post("https://api.indexnow.org/indexnow", json=payload, timeout=30)
    print("IndexNow response:", r.status_code, (r.text or "")[:500])
except Exception as e:
    print("IndexNow error (ignored):", e)
