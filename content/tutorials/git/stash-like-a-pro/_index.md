---
title: "Stash Like a Pro"
description: "Park in-progress work, stash selectively, keep-index, and manage multiple stashes."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 220
categories: ["tutorials", "git"]
tags: ["stash", "work-in-progress"]
---

## Introduction
Stashing lets you quickly switch tasks without losing changes.

## Topics Covered
- `git stash push`, `git stash list`, `apply`, `pop`
- Partial stash with pathspecs
- `--keep-index` and `--include-untracked`

{{< alert "lightbulb" >}}
Use stashes to park work temporarily, but consider `git worktree` for full parallel work without context switching. Stashes are local-only and not pushed to remotes.
{{< /alert >}}

## Quick Checklist
{{< checklist >}}
  {{< check-item id="stash-clean-working-tree" >}}Working tree clean? Commit or stash only what's needed.{{< /check-item >}}
  {{< check-item id="stash-describe" >}}Add a clear message with `-m` (e.g., "wip: refactor settings form").{{< /check-item >}}
  {{< check-item id="stash-keep-index" >}}Want to keep staged changes? Use `--keep-index`.{{< /check-item >}}
  {{< check-item id="stash-untracked" >}}Need untracked files too? Use `-u/--include-untracked` (or `-a/--all` to include ignored).{{< /check-item >}}
  {{< check-item id="stash-verify" >}}After applying, run tests before dropping the stash.{{< /check-item >}}
{{< /checklist >}}

## Core Commands
```bash
# Stash everything tracked with a message
git stash push -m "wip: refactor settings form"

# List your stashes
git stash list

# See what's inside a stash (diff)
git stash show -p stash@{0}

# Apply (keep stash) vs pop (apply and remove)
git stash apply stash@{0}
git stash pop stash@{0}

# Re-apply index (staged) state as well
git stash apply --index stash@{0}

# Drop a single stash or clear all (dangerous)
git stash drop stash@{0}
git stash clear
```

## Selective and Advanced Stashing
```bash
# Interactively choose hunks to stash
git stash -p

# Stash only files under a path or matching pattern
git stash push -m "wip: api" -- api/
git stash push -m "wip: css" -- "**/*.css"

# Stash leaving staged changes intact
git stash push --keep-index -m "wip: half-done, keep staged"

# Include untracked (and ignored) files
git stash push -u -m "wip: include untracked"
git stash push -a -m "wip: include ignored too"
```

## Naming and Managing Multiple Stashes
```bash
# Always name your stash for clarity
git stash push -m "wip: oauth callback fix"

# Reference any stash by index
git stash show -p stash@{2}

# Create a new branch from a stash (applies and drops)
git stash branch oauth-fix stash@{0}
```

{{< alert "warning" >}}
Stashes are repository-local and not pushed. Treat them as temporary scratchpads, not durable backups. Don't rely on `git stash clear` being reversible.
{{< /alert >}}

## Common Recipes
{{< accordion >}}
  {{< accordion-item title="Quickly park only unstaged work, keep staged for commit" >}}
  ```bash
  git add -A                    # stage what is ready
  git stash push --keep-index -m "wip: keep staged"
  git commit -m "feat: finish staged part"
  # Later...
  git stash pop                 # bring back the rest
  ```
  {{< /accordion-item >}}

  {{< accordion-item title="Move WIP to a dedicated branch" >}}
  ```bash
  git stash push -m "wip: spike auth UI"
  git switch -c spike/auth-ui
  git stash pop
  ```
  {{< /accordion-item >}}

  {{< accordion-item title="Recover after a conflicted apply" >}}
  ```bash
  # If apply conflicts, resolve as usual, then continue working.
  # If you popped and regret it, the stash may be in reflog:
  git reflog | grep stash
  ```
  {{< /accordion-item >}}
{{< /accordion >}}

## Conclusion
Efficient context switching with minimal disruption.
