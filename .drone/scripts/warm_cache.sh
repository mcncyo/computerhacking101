#!/bin/sh
set -euo pipefail

SITEMAP_ROOT="${1:-https://computerhacking101.com/sitemap.xml}"  # Allow override via CLI arg
CONCURRENCY=10
EXTRA_URLS="${2:-https://computerhacking101.com/ https://www.computerhacking101.com/}"  # Allow override
TEMP_DIR="/tmp/warm_cache_$(date +%s)"
mkdir -p "$TEMP_DIR"

fetch_and_extract() {
    local url="$1"
    local output_file="$2"
    printf 'Fetching %s\n' "$url" >&2
    
    # Download the sitemap
    if ! curl -fsS "$url" -o "$TEMP_DIR/current_sitemap.xml"; then
        echo "Failed to fetch sitemap: $url" >&2
        return 1
    fi
    
    # Extract URLs using xmlstarlet if available, otherwise use grep
    if command -v xmlstarlet >/dev/null 2>&1; then
        xmlstarlet sel -t -v '//*[local-name()="loc"]' "$TEMP_DIR/current_sitemap.xml" > "$output_file"
    else
        # Use grep -o with a simpler pattern for BusyBox compatibility
        grep -o '<loc>[^<]*</loc>' "$TEMP_DIR/current_sitemap.xml" | sed 's/<loc>\(.*\)<\/loc>/\1/' > "$output_file"
    fi
    
    # Clean up empty lines and trim whitespace
    sed -i '/^[[:space:]]*$/d' "$output_file"
    sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "$output_file"
    
    return 0
}

echo "Fetching sitemap from $SITEMAP_ROOT"

# First, fetch the root sitemap
fetch_and_extract "$SITEMAP_ROOT" "$TEMP_DIR/root_urls.txt"

# Check if this is a sitemap index
if grep -qi "<sitemapindex" "$TEMP_DIR/current_sitemap.xml"; then
    echo "Sitemap index detected. Processing child sitemaps..."
    > "$TEMP_DIR/all_urls.txt"
    
    # Process each sitemap URL
    while IFS= read -r sm_url; do
        [ -z "$sm_url" ] && continue
        echo "Processing sitemap: $sm_url"
        fetch_and_extract "$sm_url" "$TEMP_DIR/child_urls.txt"
        cat "$TEMP_DIR/child_urls.txt" >> "$TEMP_DIR/all_urls.txt"
    done < "$TEMP_DIR/root_urls.txt"
else
    echo "Standard sitemap detected."
    cp "$TEMP_DIR/root_urls.txt" "$TEMP_DIR/all_urls.txt"
fi

# Add must-warm pages
for u in $EXTRA_URLS; do 
    echo "$u"
done >> "$TEMP_DIR/all_urls.txt"

# Clean and deduplicate URLs
awk '
# Function to clean URLs
function clean_url(url) {
    # Remove query strings and fragments
    gsub(/\?.*$/, "", url);
    gsub(/#.*$/, "", url);
    # Remove trailing slashes
    sub(/\/+$/, "", url);
    return url;
}

BEGIN {
    IGNORECASE = 1;
    FS = "\n";
    OFS = "\n";
}

/^https?:\/\// {
    url = clean_url($0);
    if (url && !seen[url]++) {
        print url;
    }
}
' "$TEMP_DIR/all_urls.txt" > "$TEMP_DIR/urls.txt"

URL_COUNT=$(wc -l < "$TEMP_DIR/urls.txt")
echo "Warming $URL_COUNT URLs with concurrency=$CONCURRENCY..."

# Process URLs in parallel
xargs -n1 -P "$CONCURRENCY" -I URL sh -c '
    echo "Warming: URL"
    if ! curl -s -L -o /dev/null --max-time 30 --retry 2 --retry-delay 1 "URL"; then
        echo "Failed: URL"
    fi
' < "$TEMP_DIR/urls.txt"

# Clean up
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "Cache warming complete. Processed $URL_COUNT URLs."
