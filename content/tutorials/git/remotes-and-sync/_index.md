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

{{< alert "lightbulb" >}}
Prefer SSH for convenience and security. Set up an SSH key once and skip tokens on every push.
{{< /alert >}}

{{< checklist >}}
{{< check-item id="ssh-key" >}}Have an SSH key added to your provider (GitHub/GitLab){{< /check-item >}}
{{< check-item id="remote-added" >}}Remote `origin` added (SSH or HTTPS){{< /check-item >}}
{{< check-item id="upstream-set" >}}Local branch has an upstream set (tracking){{< /check-item >}}
{{< /checklist >}}

## Prerequisites
- Branching & merging basics

## Topics Covered
- `git remote add`, `git remote -v`
- Tracking branches
- `git fetch`, `git pull`, `git push`
- Handling diverged branches

### Add and Inspect Remotes
{{< tabs >}}
{{< tab name="SSH (recommended)" >}}
{{< clipboard lang="bash" >}}
git remote add origin git@github.com:USER/REPO.git
git remote -v        # list remotes and URLs
{{< /clipboard >}}
{{< /tab >}}
{{< tab name="HTTPS" >}}
{{< clipboard lang="bash" >}}
git remote add origin https://github.com/USER/REPO.git
git remote -v        # list remotes and URLs
{{< /clipboard >}}
{{< /tab >}}
{{< /tabs >}}

Update a remote later:
{{< clipboard lang="bash" >}}
git remote set-url origin git@github.com:USER/REPO.git
{{< /clipboard >}}

### First Push and Upstream Tracking
{{< clipboard lang="bash" >}}
# create main and set upstream to origin/main
git branch -M main
git push -u origin main

# create a feature branch and push with tracking
git switch -c feature/login
git push -u origin feature/login
{{< /clipboard >}}

### Tracking Branches Explained
- Local branch remembers its upstream (e.g., `origin/feature/login`).
- After upstream is set, `git push` and `git pull` don’t need explicit refs.
- See tracking info with `git branch -vv`.

{{< alert "check" >}}
Newer Git supports `git push --set-upstream origin <branch>` as a one‑liner when pushing first time.
{{< /alert >}}

### Fetch vs Pull
{{< tabs >}}
{{< tab name="Commands" >}}
{{< clipboard lang="bash" >}}
git fetch origin        # download remote refs, don't modify working tree
git pull --ff-only      # fetch + fast-forward merge
git pull --rebase       # fetch + rebase local commits on top of upstream
{{< /clipboard >}}
{{< /tab >}}
{{< tab name="Guidance" >}}
- Prefer `--ff-only` or `--rebase` to avoid accidental merge commits on local work.
- Use `git config --global pull.rebase true` to make rebase the default.
{{< /tab >}}
{{< /tabs >}}

### Handle Divergence Safely
{{< clipboard lang="bash" >}}
# if your local branch has diverged from upstream
git fetch origin
git rebase origin/main      # or: git merge origin/main
# resolve conflicts if any, then push
git push                    # might need --force-with-lease after rebase
{{< /clipboard >}}

{{< alert "warning" >}}
After a rebase, use `git push --force-with-lease` (never plain `--force`) to avoid clobbering others' work.
{{< /alert >}}

### Multiple Remotes (fork flows)
{{< clipboard lang="bash" >}}
git remote add upstream https://github.com/ORIGINAL/REPO.git
git fetch upstream
git switch main && git rebase upstream/main
{{< /clipboard >}}

### Credential Tips
- Prefer SSH keys; add to your provider and use `git@` URLs.
- Use a credential manager to avoid re-typing tokens.

{{< cards >}}
{{< card title="SSH Key Management" link="/tutorials/ssh/ssh-key-management/" icon="key" text="Generate, add, and rotate SSH keys securely." >}}
{{< card title="Signed Commits" link="/tutorials/git/signed-commits/" icon="certificate" text="Verify authorship with GPG or SSH signing." >}}
{{< /cards >}}

### Best Practices
- Protect default branches and require reviews/CI.
- Keep branches short-lived; clean up merged branches on remote.
- Name remotes clearly (`origin`, `upstream`).

## Conclusion
You can now sync your work with others safely and predictably.

{{< social-share >}}
{{< feedback >}}
