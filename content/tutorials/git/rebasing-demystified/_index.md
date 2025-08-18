---
title: "Rebasing Demystified"
description: "Master interactive rebase, fixup, autosquash, and when to prefer rebase vs merge."
date: 2025-08-17T08:51:14-05:00
weight: 210
categories: ["tutorials", "git"]
tags: ["rebase", "i-rebase", "history"]
---

## Introduction
Rebase keeps history linear and readable when used appropriately.

{{< alert "lightbulb" >}}
Prefer rebase for local feature branches to craft a clean history. Use merge on shared/release branches to preserve true topology.
{{< /alert >}}

## Topics Covered
- `git rebase` vs `git merge`
- Interactive rebase (`-i`): reorder, squash, fixup
- Autosquash with `--autosquash`
- Safety guidelines for shared branches

### Rebase vs Merge — When to Use Which
- Rebase: keep a linear history for local feature branches before opening a PR.
- Merge: preserve true branch topology on shared branches and release branches.
- Never rebase public/shared branches that others track.

{{< figure src="/images/git/rebase-vs-merge.svg" alt="Rebase vs merge diagram" caption="Merge preserves branch structure; rebase replays commits for a linear history." >}}

### Interactive Rebase Walkthrough
{{< clipboard lang="bash" >}}
# combine and reorder the last N commits on current branch
git rebase -i HEAD~5
{{< /clipboard >}}
- Edit the todo list: replace `pick` with `reword`, `edit`, `squash (s)`, or `fixup (f)`.
- Continue after resolving conflicts:
{{< clipboard lang="bash" >}}
git add <files>
git rebase --continue
{{< /clipboard >}}
- Abort if needed: `git rebase --abort`.

### Fixup and Autosquash
{{< clipboard lang="bash" >}}
# create a fixup commit targeting an earlier commit
git commit --fixup <commit>

# automatically reorder/squash fixups during rebase
git rebase -i --autosquash HEAD~10
{{< /clipboard >}}
- Tip: enable autosquash globally:
{{< clipboard lang="bash" >}}
git config --global rebase.autosquash true
{{< /clipboard >}}

### Rebase with Merge Structure
- Preserve branch merge structure when rebasing:
{{< clipboard lang="bash" >}}
git rebase --rebase-merges origin/main
{{< /clipboard >}}

### Keep Your Feature Up to Date
{{< clipboard lang="bash" >}}
git fetch origin
git rebase origin/main
# or set pull.rebase so `git pull` rebases by default
git config --global pull.rebase true
{{< /clipboard >}}

### Safety and Best Practices
- Don’t rebase branches others have pulled; prefer merge or revert.
- Use `--force-with-lease` after rebasing remote-tracked branches to protect others’ work:
{{< clipboard lang="bash" >}}
git push --force-with-lease
{{< /clipboard >}}
- Resolve conflicts commit-by-commit; smaller rebases are easier.

{{< alert "warning" >}}
Never rewrite history on shared branches without coordination. Rebasing public history can disrupt collaborators.
{{< /alert >}}

## Conclusion
Use rebase to craft clean, comprehensible history.

{{< cards >}}
{{< card title="Branching & Merging" link="/tutorials/git/branching-and-merging/" icon="git" text="Branch strategies and merge types." >}}
{{< card title="Remotes & Sync" link="/tutorials/git/remotes-and-sync/" icon="cloud" text="Collaborate safely after rebases." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
