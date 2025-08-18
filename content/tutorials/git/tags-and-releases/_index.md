---
title: "Tags & Releases"
description: "Create lightweight and annotated tags, sign releases, and integrate tagging into your release flow."
date: 2025-08-17T08:51:14-05:00
weight: 230
categories: ["tutorials", "git"]
tags: ["tags", "release", "signing"]
---

## Introduction
Tagging marks important history points like releases.

## Topics Covered
- Lightweight vs annotated tags
- Signing and verifying tags
- Release checklist and automation hooks

{{< alert "lightbulb" >}}
Prefer annotated tags (`-a`) for releases. They store metadata (author, date, message) and can be signed. Lightweight tags are just named pointers.
{{< /alert >}}

## Quick Release Checklist
{{< checklist >}}
  {{< check-item id="rel-clean-wd" >}}Working tree clean, version bumped, changelog updated.{{< /check-item >}}
  {{< check-item id="rel-tests-green" >}}CI is green for the commit to be tagged.{{< /check-item >}}
  {{< check-item id="rel-annotated-signed" >}}Create an annotated (and optionally signed) tag with a meaningful message.{{< /check-item >}}
  {{< check-item id="rel-push-tag" >}}Push the tag to origin.{{< /check-item >}}
  {{< check-item id="rel-notes" >}}Generate/attach release notes and artifacts.{{< /check-item >}}
{{< /checklist >}}

## Core Tag Commands
{{< clipboard lang="bash" >}}
# Create tags
git tag v1.2.0                         # lightweight
git tag -a v1.2.0 -m "release: v1.2.0"  # annotated

# Signed tag (requires GPG set up)
git tag -s v1.2.0 -m "release: v1.2.0"

# Inspect
git show v1.2.0

# List all tags (optionally filter)
git tag --list
git tag --list "v1.*"

# Move/fix a tag to a different commit
git tag -f -a v1.2.0 <commit>
git push -f origin v1.2.0

# Delete a tag
git tag -d v1.2.0
git push origin :refs/tags/v1.2.0

# Push tags
git push origin v1.2.0
git push --tags    # push all local tags
{{< /clipboard >}}

## Signing and Verification
{{< clipboard lang="bash" >}}
# Configure (once)
git config --global user.signingkey <GPG_KEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# Verify a signed tag
git verify-tag v1.2.0
{{< /clipboard >}}

{{< alert "warning" >}}
Signed tags require your public key to be published where verifiers can fetch it (e.g., GitHub, key servers). Keep your private key safe and use YubiKey/agent where possible.
{{< /alert >}}

## Pre-release and Build Tags
{{< clipboard lang="bash" >}}
# Pre-releases (semantic pre-release identifiers)
git tag -a v1.3.0-rc.1 -m "release: v1.3.0-rc.1"

# Include build metadata (not ordered by Git, but useful for CI)
git tag -a v1.3.0+2025.08.17 -m "nightly build"
{{< /clipboard >}}

## Common Recipes
{{< accordion >}}
  {{< accordion-item title="Cut a release tag from main" >}}
  {{< clipboard lang="bash" >}}
  git switch main
  git pull --ff-only
  git tag -a v1.2.0 -m "release: v1.2.0"
  git push origin v1.2.0
  {{< /clipboard >}}
  {{< /accordion-item >}}

  {{< accordion-item title="Tag a hotfix from a commit SHA" >}}
  {{< clipboard lang="bash" >}}
  git tag -a v1.2.1 -m "hotfix: security patch" <sha>
  git push origin v1.2.1
  {{< /clipboard >}}
  {{< /accordion-item >}}

  {{< accordion-item title="Generate release notes between tags" >}}
  {{< clipboard lang="bash" >}}
  git log --no-merges --pretty=format:"* %s (%h)" v1.1.0..v1.2.0
  {{< /clipboard >}}
  {{< /accordion-item >}}
{{< /accordion >}}

## Conclusion
Consistent tags make release management clear and auditable.

{{< cards >}}
{{< card title="Signed Commits" link="/tutorials/git/signed-commits/" icon="shield" text="Set up GPG/SSH signing and verify provenance." >}}
{{< card title="Git Workflow Best Practices" link="/tutorials/git/git-workflow-best-practices/" icon="checklist" text="Keep releases smooth with healthy PR hygiene." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
