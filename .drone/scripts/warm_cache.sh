#!/usr/bin/env sh
set -eu

SITEMAP_ROOT="${1:-https://computerhacking101.com/sitemap.xml}"
CONCURRENCY="${2:-10}"

EXTRA_URLS="https://computerhacking101.com/ https://www.computerhacking101.com/"

fetch_and_extract() {
  # $1 = sitemap URL
  echo "Fetching $1"
  curl -fsS "$1" -o /tmp/sm.xml
  # extract all <loc>...</loc>
  sed -n 's:.*<loc>\(.*\)</loc>.*:\1:p' /tmp/sm.xml
}

ROOT_LOCS="$(fetch_and_extract "$SITEMAP_ROOT")"

# If root file is a sitemap index, expand child sitemaps
if grep -q "<sitemapindex" /tmp/sm.xml; then
  echo "Sitemap index detected. Expanding child sitemaps..."
  : > /tmp/all_urls.txt
  echo "$ROOT_LOCS" | while read -r sm; do
    [ -n "$sm" ] || continue
    fetch_and_extract "$sm" >> /tmp/all_urls.txt
  done
else
  echo "Standard sitemap detected."
  echo "$ROOT_LOCS" > /tmp/all_urls.txt
fi

# Add extra URLs
for u in $EXTRA_URLS; do echo "$u"; done >> /tmp/all_urls.txt

# Dedup
awk 'NF' /tmp/all_urls.txt | sort -u > /tmp/urls.txt

COUNT="$(wc -l < /tmp/urls.txt | tr -d ' ')"
echo "Warming $COUNT URLs with concurrency=$CONCURRENCY ..."

# Parallel warmup (no {} or %{..} tokens)
cat /tmp/urls.txt | xargs -n1 -P "$CONCURRENCY" -I URL sh -c '
  echo "Warming: URL"
  curl -s -L -o /dev/null "URL" || echo "Failed: URL"
'
