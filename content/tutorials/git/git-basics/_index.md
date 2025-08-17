---
title: "Git Basics"
description: "Install Git and learn core commands: init, clone, status, add, commit — the foundation for version control."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 110
categories: ["tutorials", "git"]
tags: ["git", "basics", "beginner"]
---

## Introduction
Learn what Git is and why it matters. We’ll set up Git and walk through the fundamental workflow.

## Prerequisites
- Terminal/Command Prompt basics
- A GitHub or GitLab account (optional)

## Step 1: Install Git
- Windows/macOS/Linux install options
- `git --version`

## Step 2: Configure Git
- `git config --global user.name` and `user.email`
- Useful configs: `init.defaultBranch`, `core.editor`

## Step 3: Create or Clone a Repository
- `git init`
- `git clone <url>`

## Step 4: The Core Cycle
- `git status`, `git add`, `git commit`
- Writing good commit messages

## Quickstart Workflow Example
```bash
# initialize and commit
git init
echo "# My Project" > README.md
git add README.md
git commit -m "feat: add initial README"

# connect to remote and push
git branch -M main
git remote add origin https://github.com/USER/REPO.git
git push -u origin main
```

## Commit Message Tips
- Use the imperative mood: "add", "fix", "refactor".
- Include context: what and why (not just what).
- Conventional Commits help automate changelogs and releases.

## Files to Ignore
Create a `.gitignore` to avoid committing build artifacts and secrets:
```gitignore
node_modules/
dist/
.env
*.log
.DS_Store
```

## Common Pitfalls
- Committing secrets: use `.gitignore` and secret scanners; rotate keys if leaked.
- Large binaries: consider Git LFS (`/tutorials/git/git-lfs/`).
- Working on `main`: prefer feature branches (`/tutorials/git/branching-and-merging/`).

## Next Steps
- Branches and merges → `/tutorials/git/branching-and-merging/`
- Remotes and sync → `/tutorials/git/remotes-and-sync/`

## Conclusion
You’ve set up Git and mastered the basics. Next: branching and merging.
