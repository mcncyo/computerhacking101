---
title: "Remotes & Sync"
description: "Connect to GitHub/GitLab, push/pull, track branches, and collaborate effectively."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 130
categories: ["tutorials", "git"]
tags: ["remotes", "push", "pull", "origin"]
---

## Introduction
Learn to collaborate via remote repositories.

## Prerequisites
- Branching & merging basics

## Topics Covered
- `git remote add`, `git remote -v`
- Tracking branches
- `git fetch`, `git pull`, `git push`
- Handling diverged branches

### Add and Inspect Remotes
```bash
git remote add origin https://github.com/USER/REPO.git
git remote -v        # list remotes and URLs
git remote set-url origin git@github.com:USER/REPO.git
```

### First Push and Upstream Tracking
```bash
# create main and set upstream to origin/main
git branch -M main
git push -u origin main

# create a feature branch and push with tracking
git switch -c feature/login
git push -u origin feature/login
```

### Tracking Branches Explained
- Local branch remembers its upstream (e.g., `origin/feature/login`).
- After upstream is set, `git push` and `git pull` don’t need explicit refs.
- See tracking info with `git branch -vv`.

### Fetch vs Pull
```bash
git fetch origin        # download remote refs, don't modify working tree
git pull --ff-only      # fetch + fast-forward merge
git pull --rebase       # fetch + rebase local commits on top of upstream
```
- Prefer `--ff-only` or `--rebase` to avoid accidental merge commits on local work.

### Handle Divergence Safely
```bash
# if your local branch has diverged from upstream
git fetch origin
git rebase origin/main      # or: git merge origin/main
# resolve conflicts if any, then push
git push                    # might need --force-with-lease after rebase
```
- When rewriting history (rebase), use `--force-with-lease`, not `--force`.

### Multiple Remotes (fork flows)
```bash
git remote add upstream https://github.com/ORIGINAL/REPO.git
git fetch upstream
git switch main && git rebase upstream/main
```

### Credential Tips
- Prefer SSH keys; add to your provider and use `git@` URLs.
- Use a credential manager to avoid re-typing tokens.

### Best Practices
- Protect default branches and require reviews/CI.
- Keep branches short-lived; clean up merged branches on remote.
- Name remotes clearly (`origin`, `upstream`).

## Conclusion
You can now sync your work with others safely and predictably.
