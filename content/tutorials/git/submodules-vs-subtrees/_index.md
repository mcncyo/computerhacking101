---
title: "Submodules vs Subtrees"
description: "Compare submodules and subtrees: trade-offs, setup, and maintenance tips for managing dependencies."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 310
categories: ["tutorials", "git"]
tags: ["submodule", "subtree", "monorepo"]
---

## Introduction
When should you embed another repo? Understand your options.

{{< alert "lightbulb" >}}
Choose submodules if you need to keep the dependency as its own Git repo with independent history and access controls. Choose subtrees for a simpler, vendor-like copy managed within your main repo.
{{< /alert >}}

## Topics Covered
- Submodules: init/update, pros/cons
- Subtrees: add/pull, pros/cons
- Migration strategies

## Submodules Basics
{{< clipboard lang="bash" >}}
# Add a submodule
git submodule add https://github.com/ORG/LIB.git vendor/LIB

# Clone repo with submodules
git clone https://github.com/ORG/APP.git
git submodule update --init --recursive

# Update submodule to latest on its default branch
cd vendor/LIB && git fetch && git checkout main && git pull --ff-only && cd -
git add vendor/LIB
git commit -m "chore: bump submodule LIB"
{{< /clipboard >}}

## Subtrees Basics
{{< clipboard lang="bash" >}}
# Add a subtree (imports history at a prefix)
git remote add LIB https://github.com/ORG/LIB.git
git subtree add --prefix=vendor/LIB LIB main --squash

# Pull upstream changes later
git fetch LIB
git subtree pull --prefix=vendor/LIB LIB main --squash
{{< /clipboard >}}

## Migration Tips
{{< clipboard lang="bash" >}}
# Submodule → Subtree (one approach)
git rm -f vendor/LIB
git commit -m "chore: remove submodule LIB"
git remote add LIB https://github.com/ORG/LIB.git
git subtree add --prefix=vendor/LIB LIB main --squash
{{< /clipboard >}}

{{< alert "warning" >}}
Submodules require extra developer steps (`--recurse-submodules`, `git submodule update`). Subtrees copy code into your repo—ensure licensing compliance and be ready to pull upstream periodically.
{{< /alert >}}

## Conclusion
Pick the right approach for your team and tooling.

{{< cards >}}
{{< card title="Remotes & Sync" link="/tutorials/git/remotes-and-sync/" icon="cloud" text="Keep forks/remotes tidy when pulling upstream." >}}
{{< card title="Large Repos & Performance" link="/tutorials/git/large-repos-and-performance/" icon="gauge" text="Speed up massive repos and vendor trees." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
