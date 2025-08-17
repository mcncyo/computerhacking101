---
title: "Undoing Changes"
description: "Restore files, reset to previous commits, revert bad merges, and recover with reflog."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 140
categories: ["tutorials", "git"]
tags: ["reset", "revert", "restore", "reflog"]
---

## Introduction
Mistakes happen. Learn safe ways to undo and recover.

## Topics Covered
- `git restore` (unstage/checkout file contents)
- `git reset` (soft, mixed, hard)
- `git revert` for public history fixes
- `git reflog` for recovery

### Restore Working Tree and Staging Area
```bash
# discard local changes in a file (working tree)
git restore path/to/file

# unstage a file (keep changes in working tree)
git restore --staged path/to/file

# checkout a file from a specific commit
git restore --source=<commit> path/to/file
```
- Safer than older `git checkout -- path` for everyday file restore tasks.

### Reset: Move HEAD (and optionally index/working tree)
```bash
# soft: move HEAD only (keep index and working tree)
git reset --soft HEAD~1

# mixed (default): move HEAD and reset index (keep working tree changes)
git reset HEAD~1

# hard: move HEAD, reset index and working tree (DESTRUCTIVE)
git reset --hard HEAD~1
```
- Use `--hard` with caution; you’ll lose uncommitted changes.

### Revert: Safe Undo in Public History
```bash
# create a new commit that undoes <commit>
git revert <commit>

# revert a merge commit (specify the mainline parent)
git revert -m 1 <merge-commit>
```
- Prefer `revert` over `reset` for branches that others may have pulled.

### Reflog: Your Safety Net
```bash
git reflog            # show where HEAD has been
git checkout <sha>    # or: git switch --detach <sha>
# recover a lost branch
git branch recovered <sha>
```
- The reflog lets you find commits even after resets and branch deletions.

### Practical Scenarios
- Unstaged the wrong file: `git restore --staged file`.
- Undo last commit but keep changes to edit message: `git reset --soft HEAD~1`.
- Public fix for a bad commit: `git revert <sha>` and push.

### Best Practices
- Don’t rewrite shared history; coordinate before force-pushing.
- Commit frequently with clear messages to make undo operations targeted.
- Use branches to isolate risky changes.

## Conclusion
You’re now equipped to fix mistakes without fear.
