---
title: "Large Repos & Performance"
description: "Speed up large repos with shallow/partial clones, sparse checkout, and tune performance."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 340
categories: ["tutorials", "git"]
tags: ["performance", "sparse-checkout", "partial-clone"]
---

## Introduction
Make Git fast again on massive repositories.

{{< alert "lightbulb" >}}
The biggest wins usually come from combining partial clone (skip blobs) with sparse checkout (focus your working set). Clone less, check out less.
{{< /alert >}}

## Topics Covered
- Shallow clones, partial clone
- Sparse checkout and cone mode
- FS tuning and repo hygiene

## Shallow and Partial Clone
{{< clipboard lang="bash" >}}
# Shallow clone (history-limited)
git clone --depth 1 https://github.com/ORG/BIGREPO.git

# Partial clone: skip blobs until needed (requires supported server)
git clone --filter=blob:none https://github.com/ORG/BIGREPO.git BIGREPO

# Combine with sparse mode from the start
git clone --filter=blob:none --sparse https://github.com/ORG/BIGREPO.git BIGREPO
cd BIGREPO
{{< /clipboard >}}

## Sparse Checkout (cone mode)
{{< clipboard lang="bash" >}}
# Initialize sparse checkout in cone mode (fast, directory-based)
git sparse-checkout init --cone

# Focus only on key directories
git sparse-checkout set client/ server/api/ tools/

# See what is included
git sparse-checkout list

# Later, expand the working set
git sparse-checkout add docs/
{{< /clipboard >}}

## Light Housekeeping
{{< clipboard lang="bash" >}}
# Regular maintenance to keep things snappy
git fetch --prune
git gc --prune=now
{{< /clipboard >}}

{{< alert "warning" >}}
Avoid running aggressive maintenance during active work (`git gc --aggressive` can take a long time). Prefer partial/sparse strategies to reduce IO.
{{< /alert >}}

## Conclusion
Practical techniques to keep developers productive.

{{< cards >}}
{{< card title="Git LFS" link="/tutorials/git/git-lfs/" icon="database" text="Store large binaries outside normal Git history." >}}
{{< card title="Worktrees" link="/tutorials/git/worktrees/" icon="layout" text="Parallel branches without extra clones." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
