#!/usr/bin/env python3
"""Remove a leading '# H1' from the body when it equals the front-matter title.
Usage: dedupe-h1.py [--write] [--demote] content/   (check mode exits 1 if any is found)
--demote also turns a leading body "# X" that differs from the title into "## X" (one H1 per page)."""
import re, sys, pathlib

def split(text):
    m = re.match(r'^(---\s*\n)(.*?\n)(---\s*\n)(.*)$', text, re.S)
    return m.groups() if m else None

def title_of(fm):
    m = re.search(r'^title:\s*(.+?)\s*$', fm, re.M)
    if not m: return None
    return m.group(1).strip().strip('"\'').strip().lower()

def main():
    write = '--write' in sys.argv
    demote = '--demote' in sys.argv
    roots = [a for a in sys.argv[1:] if not a.startswith('--')] or ['content']
    found = []
    for root in roots:
        for p in sorted(pathlib.Path(root).rglob('*.md')):
            text = p.read_text(encoding='utf-8')
            parts = split(text)
            if not parts: continue
            a, fm, b, body = parts
            t = title_of(fm)
            if not t: continue
            lines = body.split('\n')
            i = 0
            while i < len(lines) and lines[i].strip() == '': i += 1
            if i < len(lines):
                m = re.match(r'^#\s+(.+?)\s*#*\s*$', lines[i])
                if m and re.sub(r'\s+', ' ', m.group(1).strip().strip('*_`').lower()) == re.sub(r'\s+', ' ', t):
                    found.append(str(p))
                    if write:
                        del lines[i]
                        if i < len(lines) and lines[i].strip() == '': del lines[i]
                        p.write_text(a + fm + b + '\n'.join(lines), encoding='utf-8')
                elif m and demote:
                    found.append(str(p) + '  (demote)')
                    if write:
                        lines[i] = '#' + lines[i]
                        p.write_text(a + fm + b + '\n'.join(lines), encoding='utf-8')
    for f in found: print(f)
    print(f'{len(found)} file(s) with a duplicate H1')
    sys.exit(0 if (write or not found) else 1)

main()
