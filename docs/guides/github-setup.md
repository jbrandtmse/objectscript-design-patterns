# Setting Up the ObjectScript Design Patterns Project in GitHub

This guide walks you through setting up your local ObjectScript Design Patterns project in GitHub.

## Prerequisites

- Git installed on your local machine
- A GitHub account
- GitHub CLI (optional, but recommended) or access to github.com

## Step 1: Initialize Local Git Repository

First, initialize Git in your project directory:

```bash
# Navigate to your project directory
cd c:/objectscript-design-patterns

# Initialize git repository
git init

# Add all files to staging
git add .

# Create initial commit
git commit -m "Initial commit: Project setup and structure"
```

## Step 2: Create GitHub Repository

### Option A: Using GitHub CLI (Recommended)

```bash
# Install GitHub CLI if not already installed
# Windows: winget install --id GitHub.cli
# Or download from: https://cli.github.com/

# Authenticate with GitHub
gh auth login

# Create repository and push
gh repo create objectscript-design-patterns --public --source=. --remote=origin --push
```

### Option B: Using GitHub Web Interface

1. Go to https://github.com
2. Click the "+" icon in the top right
3. Select "New repository"
4. Configure the repository:
   - Repository name: `objectscript-design-patterns`
   - Description: "Comprehensive implementation of Gang of Four and PoEAA design patterns in InterSystems ObjectScript"
   - Visibility: Public (or Private if preferred)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

## Step 3: Connect Local Repository to GitHub

If you used Option B above, connect your local repository:

```bash
# Add remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/objectscript-design-patterns.git

# Verify remote was added
git remote -v

# Push to GitHub
git push -u origin main
```

## Step 4: Set Up Git Flow Branching

As specified in the project requirements, set up Git Flow:

```bash
# Create and switch to develop branch
git checkout -b develop

# Push develop branch to GitHub
git push -u origin develop

# Set develop as the default branch (optional)
# This can also be done in GitHub Settings > Branches
```

## Step 5: Configure Branch Protection (Recommended)

In your GitHub repository settings:

1. Go to Settings > Branches
2. Add a branch protection rule for `main`:
   - Require pull request reviews before merging
   - Dismiss stale pull request approvals when new commits are pushed
   - Require status checks to pass before merging
   - Include administrators
3. Add a branch protection rule for `develop`:
   - Require pull request reviews before merging

## Step 6: Update Repository Settings

In your GitHub repository:

1. **Add Topics**: Go to the gear icon next to "About" and add topics:
   - `objectscript`
   - `design-patterns`
   - `intersystems-iris`
   - `gof-patterns`
   - `poeaa`
   - `iris`

2. **Update Description**: Add the project description from README

3. **Add Website**: If you have documentation hosted, add the URL

## Step 7: Create Initial Feature Branch

Following Git Flow, create your first feature branch:

```bash
# Make sure you're on develop
git checkout develop

# Create a feature branch for your first pattern implementation
git checkout -b feature/singleton-pattern

# After making changes, push the feature branch
git push -u origin feature/singleton-pattern
```

## Git Flow Branch Naming Conventions

- **Main Branches**:
  - `main` - Production-ready code
  - `develop` - Integration branch for features

- **Supporting Branches**:
  - `feature/*` - New features (e.g., `feature/factory-pattern`)
  - `release/*` - Prepare for production release (e.g., `release/1.0.0`)
  - `hotfix/*` - Quick fixes to production (e.g., `hotfix/critical-bug`)

## Common Git Commands for This Project

```bash
# Check status
git status

# Add specific files
git add src/Patterns/GoF/Creational/Singleton.cls

# Commit with descriptive message
git commit -m "feat: Implement Singleton pattern with thread safety"

# Push changes
git push

# Pull latest changes
git pull

# Create and switch to new branch
git checkout -b feature/new-pattern

# Merge feature into develop
git checkout develop
git merge feature/new-pattern

# Delete local branch after merge
git branch -d feature/new-pattern

# Delete remote branch after merge
git push origin --delete feature/new-pattern
```

## Commit Message Conventions

Follow conventional commits for clear history:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: Add Factory Method pattern implementation
fix: Correct Singleton thread safety issue
docs: Update README with Observer pattern example
test: Add unit tests for Builder pattern
```

## GitHub Actions (Optional)

Consider adding GitHub Actions for CI/CD. Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    # Add IRIS-specific testing steps here
    - name: Run tests
      run: |
        echo "Add IRIS testing configuration"
```

## Troubleshooting

### Issue: Permission Denied
```bash
# If you get permission denied, ensure you're authenticated
git config --global user.email "your.email@example.com"
git config --global user.name "Your Name"
```

### Issue: Different Default Branch Name
```bash
# If your Git uses 'master' instead of 'main'
git branch -m master main
git push -u origin main
```

### Issue: Large Files
If you have large files, consider using Git LFS:
```bash
git lfs track "*.dat"
git lfs track "*.DAT"
git add .gitattributes
```

## Next Steps

1. ✅ Repository is now set up in GitHub
2. ✅ Git Flow branching structure is configured
3. 📝 Start implementing patterns in feature branches
4. 🔄 Follow the Git Flow workflow for development
5. 📚 Keep documentation updated with each pattern

## Additional Resources

- [GitHub Docs](https://docs.github.com)
- [Git Flow Cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
