# Git & GitHub CLI Cheat Sheet for Grocery & Recipe Manager

This cheat sheet provides the essential commands for creating feature
branches, pushing changes, and opening PRs for the AI Test Review
workflow.

------------------------------------------------------------------------

## 1. Update Local Main

``` bash
git checkout main        # Switch to main branch
git pull origin main     # Sync with GitHub
```

## 2. Create a Feature Branch

``` bash
git checkout -b feature/your-branch-name
```

## 3. Make Changes → Stage → Commit

``` bash
git add .                         # Stage all changes
git commit -m "Describe changes"  # Commit
```

## 4. Push Feature Branch

``` bash
git push -u origin feature/your-branch-name
# -u creates upstream tracking for easier pushes later
```

## 5. Open a Pull Request (PR)

### Auto-fill title/body from commits:

``` bash
gh pr create --fill
```

### Or specify title and body:

``` bash
gh pr create --title "Feature" --body "Details" --base main
```

## 6. After Additional Local Changes

``` bash
git add .
git commit -m "More changes"
git push                     # Pushes to same PR branch
```

## 7. Check PR Status

``` bash
gh pr status
```

## 8. View PR in Browser

``` bash
gh pr view --web
```

## 9. Merge PR

### Squash merge:

``` bash
gh pr merge --squash
```

### Rebase + merge:

``` bash
gh pr merge --rebase
```

## 10. Cleanup After Merge

``` bash
git checkout main
git pull origin main
git branch -d feature/your-branch-name
```

------------------------------------------------------------------------
