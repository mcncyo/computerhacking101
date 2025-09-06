#!/usr/bin/env python3

import os
import sys
import re
import time
import requests
from urllib.parse import urlparse

def main():
    HOST = os.environ.get('SITE_HOST', 'computerhacking101.com')
    KEY = os.environ.get('INDEXNOW_KEY', '')
    
    if not KEY:
        print("INDEXNOW_KEY environment variable not set")
        sys.exit(0)

    KEY_URL = f"https://{HOST}/{KEY}.txt"
    SITEMAP_URL = f"https://{HOST}/sitemap.xml"
    INDEXNOW_ENDPOINT = "https://api.indexnow.org/indexnow"
    MAX_BATCH = 10_000

    def fetch(url, timeout=30):
        try:
            r = requests.get(url, timeout=timeout)
            if r.status_code == 200:
                return r.text
            print(f"Fetch {url} -> {r.status_code}")
        except Exception as e:
            print(f"Fetch error {url}: {e}")
        return ""

    def extract_locs(xml_text):
        return re.findall(r"<loc>\s*([^<\s]+)\s*</loc>", xml_text, flags=re.IGNORECASE)

    def normalize(urls):
        out, seen = [], set()
        for u in urls:
            pu = urlparse(u.strip())
            if pu.scheme in ("http","https") and pu.netloc.endswith(HOST):
                v = f"https://{HOST}{pu.path or '/'}"
                if pu.query:
                    v += f"?{pu.query}"
                if v not in seen:
                    seen.add(v)
                    out.append(v)
        return out

    # Get sitemap (expand index if present)
    root = fetch(SITEMAP_URL)
    if not root:
        print("No sitemap retrieved; skipping.")
        return

    urls = []
    if "<sitemapindex" in root.lower():
        for sm in extract_locs(root):
            child = fetch(sm)
            if child:
                urls.extend(extract_locs(child))
    else:
        urls.extend(extract_locs(root))

    urls = normalize(urls)
    if not urls:
        print("No URLs found in sitemap; skipping.")
        return

    print(f"Submitting {len(urls)} URLs from sitemap.xml")

    def submit(batch):
        payload = {"host": HOST, "key": KEY, "keyLocation": KEY_URL, "urlList": batch}
        for attempt in range(5):
            try:
                r = requests.post(INDEXNOW_ENDPOINT, json=payload, timeout=30)
            except Exception as e:
                print(f"IndexNow POST error (attempt {attempt+1}): {e}")
                time.sleep(min(60, 2**attempt))
                continue
                
            if r.status_code in (200, 202):
                print(f"IndexNow OK {len(batch)} URLs")
                return True
                
            if r.status_code in (429, 500, 502, 503, 504):
                wait = min(60, 2**attempt)
                print(f"IndexNow {r.status_code}, retrying in {wait}s")
                time.sleep(wait)
                continue
                
            print(f"IndexNow failed {r.status_code}: {r.text[:300]}")
            return False
            
        return False

    sent = 0
    for i in range(0, len(urls), MAX_BATCH):
        chunk = urls[i:i+MAX_BATCH]
        if submit(chunk):
            sent += len(chunk)

    print(f"IndexNow done. Submitted {sent}/{len(urls)} URLs.")

if __name__ == "__main__":
    main()
