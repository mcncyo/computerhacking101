---
title: "Git Workflow Best Practices"
description: "Adopt effective workflows: feature branches, trunk-based development, and PR hygiene."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 240
categories: ["tutorials", "git"]
tags: ["workflow", "pull-requests", "trunk-based"]
---

## Introduction
Good workflows reduce friction and prevent merge hell.

## Topics Covered
- Feature branches vs trunk-based development
- Branch protections and CI gates
- Small PRs, code review checklists

{{< alert "lightbulb" >}}
Choose one workflow and apply it consistently. Optimize for small, frequent merges into a protected default branch with automated checks.
{{< /alert >}}

## Branching Model Basics
```bash
# Create a feature branch off the default branch (main)
git switch main && git pull --ff-only
git switch -c feat/search-index

# Keep your branch up to date
git fetch origin
git rebase origin/main          # preferred for a linear history
# or: git merge origin/main     # if merges are allowed/desired

# Publish branch
git push -u origin feat/search-index
```

## Pull Request Hygiene
{{< checklist >}}
  {{< check-item id="pr-small" >}}PR is small and focused (ideally < 300 lines changed).{{< /check-item >}}
  {{< check-item id="pr-tests" >}}Tests added/updated; CI passes locally.{{< /check-item >}}
  {{< check-item id="pr-description" >}}Clear title and description: what/why, screenshots or logs if UI/behavioural.{{< /check-item >}}
  {{< check-item id="pr-self-review" >}}Self-reviewed: remove dead code, commented out code, debug prints.{{< /check-item >}}
  {{< check-item id="pr-docs" >}}Docs/changelogs updated if user-facing.{{< /check-item >}}
{{< /checklist >}}

## Reviewer Checklist
{{< checklist >}}
  {{< check-item id="rv-scope" >}}Scope fits the PR title/description; suggest splitting if not.{{< /check-item >}}
  {{< check-item id="rv-correctness" >}}Edge cases covered; tests meaningful and stable.{{< /check-item >}}
  {{< check-item id="rv-security" >}}Security/privacy implications considered (input validation, secrets).{{< /check-item >}}
  {{< check-item id="rv-maintainability" >}}Naming, complexity, duplication, logging, errors, comments.{{< /check-item >}}
  {{< check-item id="rv-release" >}}Rollout risk noted; feature flags/backout plan if needed.{{< /check-item >}}
{{< /checklist >}}

## Sync and Safety Commands
```bash
# Update your feature branch with the latest main (rebase) safely
git fetch origin
git rebase origin/main

# If you rebased a published branch, push safely
git push --force-with-lease

# Start a release or hotfix branch (release-flow teams)
git switch -c release/1.4.0 origin/main
git switch -c hotfix/login-null origin/main

# Cherry-pick a fix onto release branch
git cherry-pick <commit>
```

{{< alert "warning" >}}
Avoid plain `git push -f`. Use `--force-with-lease` to prevent overwriting collaborators' work.
{{< /alert >}}

## Common Recipes
{{< accordion >}}
  {{< accordion-item title="Feature branch flow (merge or rebase)" >}}
  ```bash
  git switch -c feat/payments
  # commits...
  git fetch origin && git rebase origin/main
  git push -u origin feat/payments
  # open PR → CI passes → review → squash-merge or rebase-merge
  ```
  {{< /accordion-item >}}

  {{< accordion-item title="Trunk-based: short-lived branches" >}}
  - Keep branches under a day or two.
  - Hide incomplete features behind flags.
  - Squash merge for a clean history.
  {{< /accordion-item >}}

  {{< accordion-item title="Split a large PR into smaller ones" >}}
  ```bash
  # Use interactive rebase to reorder/split commits
  git rebase -i origin/main
  # mark commits with 'edit' or 's' (squash) to curate logical changes
  ```
  {{< /accordion-item >}}

  {{< accordion-item title="Backport a fix to a release branch" >}}
  ```bash
  git switch release/1.4.0
  git cherry-pick <fix-sha>
  git push origin release/1.4.0
  ```
  {{< /accordion-item >}}
{{< /accordion >}}

## Conclusion
Pick a workflow that fits your team and enforce it consistently.
