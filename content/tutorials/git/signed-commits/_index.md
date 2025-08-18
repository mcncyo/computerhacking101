---
title: "Signed Commits"
description: "Sign commits and tags with GPG or SSH keys and verify provenance in code reviews."
date: 2025-08-17T08:51:14-05:00
weight: 330
categories: ["tutorials", "git"]
tags: ["security", "signing", "gpg", "ssh"]
---

## Introduction
Signed history builds trust and traceability.

{{< alert "lightbulb" >}}
Sign with either GPG (classic) or SSH keys (newer, simpler). Teams can require signed commits/tags to verify authorship and provenance.
{{< /alert >}}

## Topics Covered
- Configuring GPG/SSH signing
- Verifying signatures locally and in hosting platforms
- Policies for teams

## GPG Signing (classic)
{{< clipboard lang="bash" >}}
# Generate a GPG key (Ed25519 if supported)
gpg --quick-generate-key "Your Name <you@example.com>" default default never

# List keys and copy the key ID / armored public key
gpg --list-secret-keys --keyid-format=long
gpg --armor --export <KEY_ID>

# Tell Git to use your key and sign by default
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# Optionally use gpg-agent and pinentry for convenience
export GPG_TTY=$(tty)
{{< /clipboard >}}

## SSH Signing (alternative)
{{< clipboard lang="bash" >}}
# Generate a dedicated SSH key for signing (if needed)
ssh-keygen -t ed25519 -C "signing key" -f ~/.ssh/id_ed25519_signing

# Configure Git to sign with SSH
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_signing.pub

# Sign commits and tags
git commit -S -m "feat: add signed commit"
git tag -s v1.2.0 -m "release: v1.2.0"
{{< /clipboard >}}

## Verify Signatures
{{< clipboard lang="bash" >}}
# Verify a specific commit or the latest one
git verify-commit <commit>
git log --show-signature -1

# Verify a tag
git verify-tag v1.2.0
{{< /clipboard >}}

{{< alert "warning" >}}
Publish your public key to your hosting provider (GitHub/GitLab) so signatures can be verified in the UI. Protect private keys (consider hardware tokens and passphrases). Mismatched emails/names can cause verification to appear as "Unverified".
{{< /alert >}}

## Conclusion
Adopt signing where provenance matters.

{{< cards >}}
{{< card title="Tags & Releases" link="/tutorials/git/tags-and-releases/" icon="tag" text="Create annotated/signed tags and generate notes." >}}
{{< card title="Remotes & Sync" link="/tutorials/git/remotes-and-sync/" icon="cloud" text="Push safely and verify signatures in your platform." >}}
{{< /cards >}}

{{< social-share >}}
{{< feedback >}}
