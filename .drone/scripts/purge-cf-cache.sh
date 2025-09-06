#!/bin/sh
set -eux

echo "🚀 Starting Cloudflare cache purge..."

# Verify required environment variables
if [ -z "$CF_ZONE_ID" ]; then 
    echo "❌ Error: CF_ZONE_ID is not set"
    exit 1
fi

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ Error: CLOUDFLARE_API_TOKEN is not set"
    exit 1
fi

# Show debug info (masking sensitive data)
echo "🔑 Using Zone ID: ${CF_ZONE_ID:0:4}...${CF_ZONE_ID: -4}"
echo "🔑 Using API Token: ${CLOUDFLARE_API_TOKEN:0:5}..."

# Make the API request using the external JSON payload
echo "📡 Sending cache purge request to Cloudflare..."

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

response=$(
    curl -sS -X POST \
    "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/purge_cache" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data @"$SCRIPT_DIR/cf-purge-payload.json"
)

# Save and display the response
echo "📨 Response from Cloudflare:"
echo "$response" | jq . 2>/dev/null || echo "$response"

# Verify the response
if ! echo "$response" | grep -q '"success":true'; then
    echo "❌ Cache purge failed"
    exit 1
fi

echo "✅ Cache purge successful"
