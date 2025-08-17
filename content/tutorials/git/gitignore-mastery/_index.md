---
title: "Gitignore Mastery"
description: "Write powerful ignore rules, use global ignores, and avoid common pitfalls."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 250
categories: ["tutorials", "git"]
tags: ["gitignore", "patterns"]
---

## Introduction
Proper ignore rules keep repos clean and secure.

## Topics Covered
- Pattern syntax: `*`, `**`, `!`, exceptions
- Global and per-repo `.gitignore`
- Fixing tracked files accidentally committed

{{< alert "lightbulb" >}}
Patterns in `.gitignore` are matched relative to the directory of the file that contains them. Use leading `/` to anchor to repo root, and `!` to unignore.
{{< /alert >}}

## Quick Checklist
{{< checklist >}}
  {{< check-item id="gi-create-early" >}}Create `.gitignore` before first commit (or as early as possible).{{< /check-item >}}
  {{< check-item id="gi-global" >}}Set a global ignore for editor/OS junk (e.g., `.DS_Store`, swap files).{{< /check-item >}}
  {{< check-item id="gi-test-patterns" >}}Test rules with `git check-ignore -v <path>`.{{< /check-item >}}
  {{< check-item id="gi-remove-cached" >}}If files are already tracked, run `git rm -r --cached` to retroactively apply ignores.{{< /check-item >}}
  {{< check-item id="gi-secrets" >}}Never rely on `.gitignore` to remove secrets from history; rotate keys and rewrite history if leaked.{{< /check-item >}}
{{< /checklist >}}

## Core Patterns
```gitignore
# Build outputs
dist/
build/

# Dependencies
node_modules/
vendor/

# Environments and local config
.env
.env.*.local

# OS/editor noise
.DS_Store
Thumbs.db
*.swp
*.swo

# Logs and caches
*.log
.cache/
coverage/

# Keep a file inside an ignored dir
data/*
!data/.gitkeep

# Anchor to repo root
/.vscode/

# Ignore all but specific file type
*.secret
!README.secret
```

## Global Ignore (User-level)
```bash
# Create a global ignore file
mkdir -p ~/.config/git
touch ~/.config/git/ignore

# Tell Git to use it
git config --global core.excludesFile ~/.config/git/ignore

# Add common entries
printf ".DS_Store\nThumbs.db\n*.swp\n" >> ~/.config/git/ignore
```

## Troubleshooting and Retroactive Fixes
```bash
# Why is this file ignored/not ignored?
git check-ignore -v path/to/file

# File is already tracked, but should be ignored now
git rm -r --cached path/to/file-or-dir
git commit -m "chore: stop tracking generated files"
git push

# Remove everything tracked that matches updated .gitignore (keep in working tree)
git rm -r --cached .
git add .
git commit -m "chore: apply .gitignore"
```

{{< alert "warning" >}}
`.gitignore` does not scrub history. If secrets were committed, rotate credentials and rewrite history (e.g., `git filter-repo` or BFG). Then force-push and coordinate with collaborators.
{{< /alert >}}

## Common Recipes
{{< accordion >}}
  {{< accordion-item title="Language and framework templates" >}}
  Start with a template tailored to your stack (e.g., Node, Python, Go). Review and trim; don't blindly ignore too much.
  {{< /accordion-item >}}

  {{< accordion-item title="Per-directory .gitignore" >}}
  A `.gitignore` inside a subdirectory applies relative to that directory and can narrow rules for specific components.
  {{< /accordion-item >}}

  {{< accordion-item title="Monorepo tip: centralize and override" >}}
  Keep a root `.gitignore` for common rules and allow package-level `.gitignore` to override with `!` patterns when needed.
  {{< /accordion-item >}}
{{< /accordion >}}

## Conclusion
A clean working tree simplifies collaboration and CI.
