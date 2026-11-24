#!/usr/bin/env bash
# Lists every shortcode used in content/ with its use count and whether a template exists
# (site layouts/shortcodes, the Hextra module, or a Hugo built-in). Exit 1 if a used shortcode has no template.
set -uo pipefail
cd "$(dirname "$0")/.."
HXM="$(find "$HOME/.cache/hugo_cache" -type d -path '*imfing/hextra@v0.13.0' 2>/dev/null | head -1)"
BUILTIN=" figure ref relref youtube vimeo highlight details param qr x instagram gist "
missing=0
{
  grep -rhoE '\{\{[<%]\s*/?\s*[A-Za-z][A-Za-z0-9_/-]*' content | sed -E 's/\{\{[<%]\s*\/?\s*//' | sort | uniq -c | awk '{print $2" "$1}'
  for f in layouts/shortcodes/*.html; do b="$(basename "$f" .html)"; echo "$b 0"; done
} | awk '{u[$1]+=$2} END{for(k in u) print k, u[k]}' | sort | while read -r name uses; do
  if [ -f "layouts/shortcodes/$name.html" ]; then where=site
  elif [ -n "$HXM" ] && [ -f "$HXM/layouts/_shortcodes/$name.html" ]; then where=hextra
  elif [[ "$BUILTIN" == *" $name "* ]]; then where=builtin
  else where=MISSING; fi
  printf '%-18s uses=%-4s %s\n' "$name" "$uses" "$where"
done | tee /dev/stderr | grep -q MISSING && exit 1 || exit 0
