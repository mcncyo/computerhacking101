---
title: "Git Hooks & Automation"
date: 2025-08-18
description: "Master Git hooks to automate your development workflow with pre-commit checks, testing, and deployment triggers."
keywords: ["git hooks", "git automation", "pre-commit", "git workflow", "ci/cd"]
tags: ["git", "automation", "devops"]
draft: false
---

# Git Hooks & Automation

Git hooks are scripts that run automatically before or after specific Git events like commits, pushes, and merges. They're incredibly powerful for automating development workflows and enforcing code quality standards.

## Why Use Git Hooks?

- **Code Quality**: Run linters and formatters before commits
- **Testing**: Ensure all tests pass before pushing changes
- **Workflow Automation**: Automate repetitive tasks like version bumping
- **Security**: Prevent sensitive data from being committed
- **Consistency**: Enforce team standards and best practices

## Types of Git Hooks

### Client-Side Hooks
- **pre-commit**: Runs before commit message is created
- **prepare-commit-msg**: Runs before commit message editor is launched
- **commit-msg**: Validates commit message format
- **post-commit**: Runs after commit is completed
- **pre-push**: Runs before remote references are updated

### Server-Side Hooks
- **pre-receive**: Validates incoming commits
- **update**: Similar to pre-receive but runs per branch
- **post-receive**: Runs after updates are accepted

## Getting Started with Git Hooks

Git hooks are stored in the `.git/hooks` directory of your repository. Example hooks (with `.sample` extension) are created when you initialize a repository.

### Enabling a Hook

1. Navigate to `.git/hooks`
2. Remove the `.sample` extension from the hook you want to use
3. Make the script executable: `chmod +x hook-name`
4. Add your custom logic to the hook script

## Practical Examples

### Pre-commit Hook for Linting

```bash
#!/bin/sh

# Run linter
echo "Running linter..."
npx eslint . --fix

# Capture exit code
ESLINT_EXIT_CODE=$?

# If linting fails, abort the commit
if [ $ESLINT_EXIT_CODE -ne 0 ]; then
  echo "❌ Linting failed. Please fix the issues and try again."
  exit 1
fi

echo "✅ Linting passed!"
exit 0
```

### Pre-push Hook for Running Tests

```bash
#!/bin/sh

echo "Running tests..."
npm test

# Capture exit code
TEST_EXIT_CODE=$?

# If tests fail, abort the push
if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "❌ Tests failed. Please fix the issues and try again."
  exit 1
fi

echo "✅ All tests passed!"
exit 0
```

## Managing Hooks Across a Team

Since `.git/hooks` is not version controlled, you can use these strategies to share hooks:

1. **Template Directory**: Use `git config --global init.templatedir` to set a template directory
2. **Husky**: A popular npm package for managing Git hooks with JavaScript
3. **pre-commit**: A framework for managing and maintaining multi-language pre-commit hooks

## Advanced: Using Husky

1. Install Husky:
   ```bash
   npm install husky --save-dev
   ```

2. Enable Git hooks:
   ```bash
   npx husky install
   ```

3. Add a hook:
   ```bash
   npx husky add .husky/pre-commit "npm test"
   ```

## Best Practices

1. Keep hooks fast and lightweight
2. Make hooks idempotent
3. Provide clear error messages
4. Document your hooks
5. Test hooks in a separate branch
6. Consider using a hook management tool for team projects

## Common Pitfalls

- Forgetting to make hooks executable
- Committing sensitive information in hooks
- Making hooks too complex
- Not handling errors properly
- Forgetting that hooks can be bypassed with `--no-verify`

## Next Steps

- [Git Workflow Best Practices](/tutorials/git/git-workflow-best-practices/)
- [Interactive Rebase Guide](/tutorials/git/rebasing-demystified/)
- [Remotes & Sync](/tutorials/git/remotes-and-sync/)

{{< button "Back to Git Tutorials" "/tutorials/git/" >}}
