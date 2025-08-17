---
title: "Bisect for Debugging"
description: "Use git bisect to find regressions quickly with binary search—manual and automated."
date: 2025-08-17T08:51:14-05:00
draft: true
weight: 320
categories: ["tutorials", "git"]
tags: ["bisect", "debugging"]
---

## Introduction
Hunt down the exact commit that introduced a bug.

{{< alert "lightbulb" >}}
Binary search cuts your search space in half each step—`git bisect` often finds the culprit in minutes.
{{< /alert >}}

{{< checklist >}}
{{< check-item id="pre-build" >}}Repo builds cleanly: `git clean -fdx && <your build>`{{< /check-item >}}
{{< check-item id="repro" >}}You have a fast, reliable reproduction or test that distinguishes GOOD vs BAD{{< /check-item >}}
{{< check-item id="range" >}}You know a known-good commit or tag close to when the bug appeared{{< /check-item >}}
{{< /checklist >}}

## Topics Covered
- `git bisect start`, `good`, `bad`
- Automating with `git bisect run`
- Strategies for flaky tests

### Manual Bisect Workflow
{{< clipboard lang="bash" >}}
# start a bisect session
git bisect start

# mark current commit as bad (contains the bug)
git bisect bad

# mark a known good commit (no bug)
git bisect good <good-commit-or-tag>

# Git checks out a midpoint commit automatically.
# Reproduce or run your test here and decide good/bad:
# - If bug is present:   git bisect bad
# - If bug is absent:    git bisect good
# Repeat until Git prints the first bad commit.
{{< /clipboard >}}

When finished:
{{< clipboard lang="bash" >}}
git bisect reset   # return to your original branch/commit
{{< /clipboard >}}

### Automate with `git bisect run`
Write a script that returns exit code 0 when GOOD and non‑zero when BAD.
{{< clipboard lang="bash" >}}
#!/usr/bin/env bash
# test_bug.sh — return 0 if good (no bug), 1 if bad (bug present)

set -euo pipefail

# example: run tests or a specific failing scenario
if npm test; then
  exit 0   # good
else
  exit 1   # bad
fi
{{< /clipboard >}}
Run automated bisect:
{{< clipboard lang="bash" >}}
git bisect start
git bisect bad              # current is bad
git bisect good v1.4.0      # last known good tag
git bisect run ./test_bug.sh
git bisect reset
{{< /clipboard >}}

### Handling Flaky or Non‑Deterministic Failures
- Use `git bisect skip` when the result is inconclusive (e.g., build fails unrelated to the bug):
  {{< clipboard lang="bash" >}}
git bisect skip
  {{< /clipboard >}}
- Add retries in your script to stabilize detection:
  {{< clipboard lang="bash" >}}
# inside test_bug.sh
for i in {1..3}; do
  if npm test; then exit 0; fi
done
exit 1
  {{< /clipboard >}}
- Limit scope (monorepos): run only the affected package tests.

{{< alert "warning" >}}
Flaky signals can mislead bisect. Prefer deterministic checks or add retries/backoffs. Use `git bisect skip` liberally on unrelated build failures.
{{< /alert >}}

### Speed Tips
- Build caching: cache dependencies between runs to accelerate testing.
- Narrow the search range: pick the earliest known good tag/commit close to the failure.
- Use `git clean -fdx` in scripts if leftover artifacts affect results.

### Best Practices
- Ensure your “good vs bad” test is reliable and fast.
- Record the first bad commit and its context in your issue tracker.
- After identifying the offending commit, add a regression test to prevent recurrence.

## Conclusion
Bisect turns painful hunts into fast, deterministic searches.

{{< cards >}}
{{< card title="Undoing Changes" link="/tutorials/git/undoing-changes/" icon="history" text="Reset, revert, and recover safely." >}}
{{< card title="Git Workflow Best Practices" link="/tutorials/git/git-workflow-best-practices/" icon="checklist" text="Keep changes small and easy to review." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
