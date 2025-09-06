#!/bin/sh
set -euo pipefail

SITEMAP_ROOT="${1:-https://computerhacking101.com/sitemap.xml}"  # Allow override via CLI arg
CONCURRENCY=10
EXTRA_URLS="${2:-https://computerhacking101.com/ https://www.computerhacking101.com/}"  # Allow override

fetch_and_extract() {
    printf 'Fetching %s\n' "$1" >&2  # Log to stderr
    curl -fsS "$1" -o /tmp/sm.xml
    sed -n 's:.*<loc>\(.*\)</loc>.*:\1:p' /tmp/sm.xml
}

echo "Fetching sitemap from $SITEMAP_ROOT"
ROOT_CONTENT="$(fetch_and_extract "$SITEMAP_ROOT")"

# Process sitemap
if echo "$ROOT_CONTENT" | grep -qi "<sitemapindex"; then
    echo "Sitemap index detected. Expanding..."
    : > /tmp/all_urls.txt
    echo "$ROOT_CONTENT" | while read -r sm; do
        [ -n "$sm" ] || continue
        echo "$sm" | grep -E '^https?://' >/dev/null 2>&1 || continue
        fetch_and_extract "$sm" >> /tmp/all_urls.txt
    done
else
    echo "Standard sitemap detected."
    echo "$ROOT_CONTENT" > /tmp/all_urls.txt
fi

# Add must-warm pages
for u in $EXTRA_URLS; do 
    echo "$u"
done >> /tmp/all_urls.txt

# Keep only real http(s) URLs, de-dup
awk 'BEGIN{IGNORECASE=1} /^https?:\/\// {print}' /tmp/all_urls.txt | sort -u > /tmp/urls.txt

URL_COUNT=$(wc -l < /tmp/urls.txt)
echo "Warming $URL_COUNT URLs with concurrency=$CONCURRENCY..."

xargs -n1 -P "$CONCURRENCY" -I URL sh -c '
    echo "Warming: URL"
    if ! curl -s -L -o /dev/null --max-time 30 "URL"; then
        echo "Failed: URL"
    fi
' < /tmp/urls.txt

echo "Cache warming complete. Processed $URL_COUNT URLs."
