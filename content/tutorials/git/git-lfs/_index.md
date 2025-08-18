---
title: "Git LFS"
description: "Manage large binary assets with Git LFS: setup, workflows, and migration caveats."
date: 2025-08-17T08:51:14-05:00
weight: 350
categories: ["tutorials", "git"]
tags: ["lfs", "binaries"]
---

## Introduction
Git LFS keeps binaries out of normal Git history.

{{< alert "lightbulb" >}}
Use Git LFS for large, frequently-changing binaries (media, models). It stores file contents outside your repo and keeps small pointers in Git.
{{< /alert >}}

## Topics Covered
- Installing and enabling LFS
- Tracking patterns and storage costs
- Migrating existing history

## Setup and Tracking
{{< clipboard lang="bash" >}}
# Install LFS (once per machine)
git lfs install

# Track specific patterns (creates/updates .gitattributes)
git lfs track "*.psd"
git lfs track "*.zip"

# Commit the attribute rules so collaborators inherit them
git add .gitattributes
git commit -m "chore: track binaries with Git LFS"

# Regular workflow
git add path/to/asset.psd
git commit -m "feat: add design asset"
git push
{{< /clipboard >}}

## Migrating Existing History (rewrite)
{{< clipboard lang="bash" >}}
# Rewrite repo history to move matching paths into LFS
# NOTE: This rewrites commits; coordinate with your team.
git lfs migrate import --include="*.zip,*.psd"

# After migration, force-push protectedly
git push --force-with-lease --all
git push --force-with-lease --tags
{{< /clipboard >}}

{{< alert "warning" >}}
Storage and bandwidth for LFS objects may incur costs with your Git host. Migrating history rewrites commits—communicate clearly and avoid disrupting shared branches.
{{< /alert >}}

## Conclusion
Use LFS deliberately to avoid painful surprises.

{{< cards >}}
{{< card title="Large Repos & Performance" link="/tutorials/git/large-repos-and-performance/" icon="gauge" text="Speed up massive repos with sparse/partial clones." >}}
{{< card title="Gitignore Mastery" link="/tutorials/git/gitignore-mastery/" icon="ban" text="Keep build artifacts and secrets out of your repo." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
