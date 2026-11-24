#!/usr/bin/env bash
# Usage: scripts/seo-check.sh <public-dir>   (build with --environment production)
# Exits 1 if any production page ships noindex, canonical/og:image/JSON-LD/sitemap expectations fail.
set -uo pipefail
P="${1:?usage: seo-check.sh <public-dir>}"
fail=0; bad(){ echo "FAIL: $*"; fail=1; }
n="$(grep -rli 'noindex' "$P" --include=*.html | wc -l)"; [ "$n" -eq 0 ] || bad "$n html file(s) contain noindex"
tut="$(find "$P/tutorials" -name index.html | sed -n '5p')"; post="$(find "$P/blog" -mindepth 2 -name index.html | head -1)"
for f in "$P/index.html" "$tut" "$post"; do
  [ -f "$f" ] || { bad "missing page $f"; continue; }
  c="$(grep -oE '<link rel=canonical href=[^ >]*' "$f" | wc -l)"; [ "$c" -eq 1 ] || bad "$f has $c canonical tags"
  grep -oE '<link rel=canonical href=[^ >]*' "$f" | grep -q 'https://computerhacking101.com/' || bad "$f canonical not on computerhacking101.com"
  img="$(grep -oE 'property="?og:image"? content="?[^" >]*' "$f" | head -1 | sed -E 's/.*content="?//')"
  [[ "$img" =~ \.(png|jpg|jpeg|webp)$ ]] || bad "$f og:image not an image file: ${img:-none}"
  [ -n "$img" ] && [ -f "$P/${img#https://computerhacking101.com/}" ] || bad "$f og:image file missing in public: $img"
  python3 - "$f" <<'PY' || bad "$f has invalid JSON-LD"
import re,sys,json
h=open(sys.argv[1],encoding='utf-8').read()
blocks=re.findall(r'<script type=application/ld\+json>(.*?)</script>',h,re.S)
if not blocks: sys.exit(1)
for b in blocks: json.loads(b)
PY
  t="$(grep -oE '<title>[^<]*' "$f" | sed 's/<title>//')"; [ "$(grep -o 'Computer Hacking 101' <<<"$t" | wc -l)" -le 1 ] || bad "$f title repeats site name: $t"
done
for s in sitemap.xml sitemap-pages.xml sitemap-posts.xml; do [ -f "$P/$s" ] || bad "missing $s"; done
exit $fail
