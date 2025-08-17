---
title: "Worktrees"
description: "Use multiple working directories from a single repo to work on parallel tasks efficiently."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 260
categories: ["tutorials", "git"]
tags: ["worktree", "productivity"]
---

## Introduction
Worktrees let you check out multiple branches simultaneously.

{{< alert "lightbulb" >}}
Worktrees give you separate working directories tied to the same `.git` data. Great for parallel reviews, quick hotfixes, or large refactors.
{{< /alert >}}

{{< checklist >}}
{{< check-item id="wt-clean" >}}Start from a clean state on the source branch (no uncommitted changes).{{< /check-item >}}
{{< check-item id="wt-location" >}}Choose a sibling directory (outside repo) to avoid nesting confusion.{{< /check-item >}}
{{< check-item id="wt-prune" >}}Prune stale worktrees occasionally: `git worktree prune`.{{< /check-item >}}
{{< /checklist >}}

## Topics Covered
- `git worktree add`, `list`, `remove`
- Common use cases and gotchas

## Core Commands
{{< clipboard lang="bash" >}}
# Add a new worktree for a branch (creates branch if not exists)
git worktree add ../repo-feature feature/login

# List all worktrees
git worktree list

# Remove a worktree (from Git's perspective)
git worktree remove ../repo-feature

# Clean up stale entries (after manual deletes)
git worktree prune
{{< /clipboard >}}

{{< alert "warning" >}}
`git worktree remove` only detaches the worktree; deleting the folder manually can leave stale references until you run `git worktree prune`.
{{< /alert >}}

## Conclusion
Boost productivity by avoiding constant stash/switch cycles.

{{< cards >}}
{{< card title="Stash Like a Pro" link="/tutorials/git/stash-like-a-pro/" icon="archive" text="Short-term parking for changes when switching tasks." >}}
{{< card title="Branching & Merging" link="/tutorials/git/branching-and-merging/" icon="git" text="Structure your work to collaborate smoothly." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
