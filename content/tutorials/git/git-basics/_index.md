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
{{< tabs >}}
{{< tab name="Windows" >}}
{{< clipboard lang="powershell" >}}
# Winget (Windows 10/11)
winget install --id Git.Git -e

# Chocolatey
choco install git
{{< /clipboard >}}
{{< /tab >}}
{{< tab name="macOS" >}}
{{< clipboard lang="bash" >}}
# Homebrew
brew install git
{{< /clipboard >}}
{{< /tab >}}
{{< tab name="Linux" >}}
{{< clipboard lang="bash" >}}
# Debian/Ubuntu
sudo apt update && sudo apt install -y git

# Fedora
sudo dnf install -y git

# Arch
sudo pacman -S git
{{< /clipboard >}}
{{< /tab >}}
{{< /tabs >}}

{{< alert "check" >}}
Verify installation:
{{< clipboard lang="bash" >}}
git --version
{{< /clipboard >}}
{{< /alert >}}

## Step 2: Configure Git
- `git config --global user.name` and `user.email`
- Useful configs: `init.defaultBranch`, `core.editor`

{{< checklist >}}
{{< check-item id="git-name" >}}Set your name: `git config --global user.name "Your Name"`{{< /check-item >}}
{{< check-item id="git-email" >}}Set your email: `git config --global user.email you@example.com`{{< /check-item >}}
{{< check-item id="git-default-branch" >}}Set default branch: `git config --global init.defaultBranch main`{{< /check-item >}}
{{< check-item id="git-editor" >}}Optional editor: `git config --global core.editor "code --wait"`{{< /check-item >}}
{{< /checklist >}}

## Step 3: Create or Clone a Repository
- `git init`
- `git clone <url>`

## Step 4: The Core Cycle
- `git status`, `git add`, `git commit`
- Writing good commit messages

## Quickstart Workflow Example
{{< clipboard lang="bash" >}}
# initialize and commit
git init
echo "# My Project" > README.md
git add README.md
git commit -m "feat: add initial README"

# connect to remote and push
git branch -M main
git remote add origin https://github.com/USER/REPO.git
git push -u origin main
{{< /clipboard >}}

## Commit Message Tips
- Use the imperative mood: "add", "fix", "refactor".
- Include context: what and why (not just what).
- Conventional Commits help automate changelogs and releases.

## Files to Ignore
Create a `.gitignore` to avoid committing build artifacts and secrets:
{{< clipboard lang="gitignore" >}}
node_modules/
dist/
.env
*.log
.DS_Store
{{< /clipboard >}}

## Common Pitfalls
- Committing secrets: use `.gitignore` and secret scanners; rotate keys if leaked.
- Large binaries: consider Git LFS (`/tutorials/git/git-lfs/`).
- Working on `main`: prefer feature branches (`/tutorials/git/branching-and-merging/`).

## Next Steps

{{< cards >}}
{{< card title="Branching & Merging" link="/tutorials/git/branching-and-merging/" icon="code-branch" text="Learn how to create feature branches and merge safely." >}}
{{< card title="Remotes & Sync" link="/tutorials/git/remotes-and-sync/" icon="cloud-upload-alt" text="Connect to GitHub/GitLab and collaborate." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}

## Conclusion
You’ve set up Git and mastered the basics. Next: branching and merging.
