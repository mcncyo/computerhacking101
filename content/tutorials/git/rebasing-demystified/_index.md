---
title: "Rebasing Demystified"
description: "Master interactive rebase, fixup, autosquash, and when to prefer rebase vs merge."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 210
categories: ["tutorials", "git"]
tags: ["rebase", "i-rebase", "history"]
---

## Introduction
Rebase keeps history linear and readable when used appropriately.

## Topics Covered
- `git rebase` vs `git merge`
- Interactive rebase (`-i`): reorder, squash, fixup
- Autosquash with `--autosquash`
- Safety guidelines for shared branches

### Rebase vs Merge — When to Use Which
- Rebase: keep a linear history for local feature branches before opening a PR.
- Merge: preserve true branch topology on shared branches and release branches.
- Never rebase public/shared branches that others track.

### Interactive Rebase Walkthrough
```bash
# combine and reorder the last N commits on current branch
git rebase -i HEAD~5
```
- Edit the todo list: replace `pick` with `reword`, `edit`, `squash (s)`, or `fixup (f)`.
- Continue after resolving conflicts:
```bash
git add <files>
git rebase --continue
```
- Abort if needed: `git rebase --abort`.

### Fixup and Autosquash
```bash
# create a fixup commit targeting an earlier commit
git commit --fixup <commit>

# automatically reorder/squash fixups during rebase
git rebase -i --autosquash HEAD~10
```
- Tip: enable autosquash globally:
```bash
git config --global rebase.autosquash true
```

### Rebase with Merge Structure
- Preserve branch merge structure when rebasing:
```bash
git rebase --rebase-merges origin/main
```

### Keep Your Feature Up to Date
```bash
git fetch origin
git rebase origin/main
# or set pull.rebase so `git pull` rebases by default
git config --global pull.rebase true
```

### Safety and Best Practices
- Don’t rebase branches others have pulled; prefer merge or revert.
- Use `--force-with-lease` after rebasing remote-tracked branches to protect others’ work:
```bash
git push --force-with-lease
```
- Resolve conflicts commit-by-commit; smaller rebases are easier.

## Conclusion
Use rebase to craft clean, comprehensible history.
