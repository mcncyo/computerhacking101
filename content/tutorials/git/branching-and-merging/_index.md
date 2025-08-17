---
title: "Branching & Merging"
description: "Create, switch, and merge branches. Understand fast-forward vs. merge commits and resolve conflicts."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 120
categories: ["tutorials", "git"]
tags: ["branches", "merge", "beginner"]
---

## Introduction
Learn how branches enable parallel work and safe experimentation.

{{< alert "lightbulb" >}}
Branches let you experiment freely without risking `main`. Open PRs to review and merge when ready.
{{< /alert >}}

{{< checklist >}}
{{< check-item id="bm-clean-main" >}}Keep `main` always releasable; protect with CI.{{< /check-item >}}
{{< check-item id="bm-feature" >}}Create a feature branch per task/issue.{{< /check-item >}}
{{< check-item id="bm-sync" >}}Regularly sync your feature with `origin/main` (rebase/merge).{{< /check-item >}}
{{< /checklist >}}

## Prerequisites
- Comfortable with Git basics: add/commit/status

## Topics Covered
- Creating branches: `git branch`, `git switch -c`
- Switching branches: `git switch`, `git checkout`
- Merging branches: fast-forward vs merge commit
- Resolving conflicts

{{< figure src="/images/git/branching-flow.svg" alt="Branching and merging flow" caption="Create a feature branch, stay up to date with main, then merge back via PR." >}}

## Walkthrough
- Feature branch workflow
- Keeping `main` clean

### Create and Switch Branches
{{< clipboard lang="bash" >}}
# create a branch from current HEAD and switch
git switch -c feature/login

# list branches
git branch

# switch back
git switch main
{{< /clipboard >}}

### Keep Your Branch Up To Date
{{< clipboard lang="bash" >}}
# fetch latest from origin
git fetch origin

# rebase your feature on top of updated main (linear history)
git switch feature/login
git rebase origin/main

# or merge main into your feature (preserve merge commits)
git merge origin/main
{{< /clipboard >}}

### Merge Fast-Forward vs No-FF
{{< clipboard lang="bash" >}}
# fast-forward (default when possible)
git switch main
git merge feature/login

# create a merge commit even if FF is possible
git merge --no-ff feature/login -m "merge: feature/login"
{{< /clipboard >}}

### Resolve Merge Conflicts
1. Run the merge and see conflicts in `git status`.
2. Open files with conflict markers `<<<<<<<`, `=======`, `>>>>>>>` and resolve.
3. Mark resolved files and complete the merge:
{{< clipboard lang="bash" >}}
git add path/to/file
git commit   # if merging
# or during rebase
git rebase --continue
{{< /clipboard >}}
- Abort if needed: `git merge --abort` or `git rebase --abort`.

{{< alert "warning" >}}
Avoid rebasing shared branches that others track. Prefer merging or coordinate with your team.
{{< /alert >}}

### Best Practices
- Protect `main` with CI and reviews; work on short-lived feature branches.
- Prefer rebase for local branches before opening a PR; avoid rebasing shared branches.
- Name branches consistently: `feature/*`, `fix/*`, `chore/*`.

## Conclusion
Branches are your superpower. Next: working with remotes.

{{< cards >}}
{{< card title="Remotes & Sync" link="/tutorials/git/remotes-and-sync/" icon="cloud" text="Push/pull, tracking branches, and collaborating." >}}
{{< card title="Rebasing Demystified" link="/tutorials/git/rebasing-demystified/" icon="stream" text="When and how to rebase safely." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
