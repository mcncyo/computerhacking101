#!/usr/bin/env bash
# Deploy computerhacking101.com to Cloudflare Pages from this machine (replaces the Drone pipeline).
# Needs these in the environment (put them in a gitignored .envrc, loaded by direnv):
#   CLOUDFLARE_API_TOKEN   Pages:Edit for this account
#   CLOUDFLARE_ACCOUNT_ID  account id
#   CF_ZONE_ID             zone id for SITE_HOST (cache purge)
#   CLOUDFLARE_API_TOKEN_PURGE  optional, Zone Cache Purge token; falls back to CLOUDFLARE_API_TOKEN
# Run from the repo root:  direnv exec . bash scripts/deploy.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SITE_HOST="computerhacking101.com"
PAGES_PROJECT="computerhacking101"
HUGO_WANT="0.170"   # major.minor this site was tested on; the script warns when the installed Hugo differs

: "${CLOUDFLARE_API_TOKEN:?not set}"
: "${CLOUDFLARE_ACCOUNT_ID:?not set}"
: "${CF_ZONE_ID:?not set}"

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "Uncommitted changes: commit first so the deployed site matches git." >&2
  exit 1
fi

HAVE="$(hugo version | sed -E 's/^hugo v([0-9]+\.[0-9]+).*/\1/')"
if [[ "${HAVE}" != "${HUGO_WANT}" ]]; then
  echo "Warning: Hugo ${HAVE} installed, this site was tested on ${HUGO_WANT}." >&2
fi

echo "Building ${SITE_HOST}..."
hugo --minify --gc  --baseURL "https://${SITE_HOST}/" --cleanDestinationDir

test -f public/sitemap.xml || { echo "No public/sitemap.xml: build looks wrong, not deploying." >&2; exit 1; }

echo "Deploying to Cloudflare Pages..."
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${BRANCH}" == "main" ]]; then
  npx --yes wrangler@3 pages deploy public --project-name="${PAGES_PROJECT}" --branch=main
else
  npx --yes wrangler@3 pages deploy public --project-name="${PAGES_PROJECT}" --branch="${BRANCH}"
  echo "Branch preview only (not main): skipping cache purge."
  exit 0
fi

echo "Purging Cloudflare cache..."
RESP="$(curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN_PURGE:-$CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" -d '{"purge_everything":true}')"
if echo "${RESP}" | grep -q '"success":true'; then echo "Cache purged."; else echo "Warning: purge failed: ${RESP}" >&2; fi

echo "Done. Check one changed page on https://${SITE_HOST}/"
