# GitHub Repository Setup Script for ObjectScript Design Patterns (PowerShell)
# This script automates the GitHub repository setup process for Windows users

# Color output functions
function Write-Success {
    param($Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Info {
    param($Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Warning {
    param($Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host $Message -ForegroundColor Red
}

function Write-Step {
    param($Step, $Message)
    Write-Host "[$Step] $Message" -ForegroundColor Blue
}

# ASCII Art Header
Write-Host @"

  ██████╗ ██████╗ ██████╗     ██╗███████╗███████╗████████╗██╗   ██╗██████╗ 
 ██╔═══██╗██╔══██╗██╔══██╗   ██╔╝██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
 ██║   ██║██████╔╝██║  ██║  ██╔╝ ███████╗█████╗     ██║   ██║   ██║██████╔╝
 ██║   ██║██╔══██╗██║  ██║ ██╔╝  ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
 ╚██████╔╝██████╔╝██████╔╝██╔╝   ███████║███████╗   ██║   ╚██████╔╝██║     
  ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                                                             
  ObjectScript Design Patterns - GitHub Repository Setup (PowerShell)
"@ -ForegroundColor Cyan

Write-Host ""
Write-Info "This script will help you set up your GitHub repository for the ObjectScript Design Patterns project."
Write-Host ""

# Function to check if a command exists
function Test-CommandExists {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function to prompt for user input with default value
function Read-InputWithDefault {
    param(
        [string]$Prompt,
        [string]$Default
    )
    $input = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    }
    return $input
}

# Function to prompt for yes/no
function Read-YesNo {
    param([string]$Prompt)
    do {
        $response = Read-Host "$Prompt (y/n)"
    } until ($response -match '^[yn]$')
    return $response -eq 'y'
}

# Step 1: Check prerequisites
Write-Step "1/7" "Checking prerequisites..."

# Check for Git
if (-not (Test-CommandExists "git")) {
    Write-Error "Git is not installed!"
    Write-Info "Please install Git from: https://git-scm.com/download/win"
    Write-Info "Or use: winget install Git.Git"
    exit 1
}
Write-Success "✓ Git is installed: $(git --version)"

# Check for GitHub CLI (optional but recommended)
$hasGhCli = Test-CommandExists "gh"
if ($hasGhCli) {
    Write-Success "✓ GitHub CLI is installed: $(gh --version | Select-Object -First 1)"
} else {
    Write-Warning "⚠ GitHub CLI is not installed (optional but recommended)"
    Write-Info "Install with: winget install GitHub.cli"
    if (Read-YesNo "Would you like to continue without GitHub CLI?") {
        Write-Info "Continuing without GitHub CLI - you'll need to create the repository manually on GitHub"
    } else {
        Write-Info "Please install GitHub CLI and run this script again"
        exit 0
    }
}

Write-Host ""

# Step 2: Configure Git user
Write-Step "2/7" "Configuring Git user..."

# Check current Git config
$currentName = git config --global user.name 2>$null
$currentEmail = git config --global user.email 2>$null

if ([string]::IsNullOrWhiteSpace($currentName) -or [string]::IsNullOrWhiteSpace($currentEmail)) {
    Write-Warning "Git user configuration not found. Let's set it up:"
    $gitName = Read-Host "Enter your full name for Git commits"
    $gitEmail = Read-Host "Enter your email for Git commits"
    
    git config --global user.name "$gitName"
    git config --global user.email "$gitEmail"
    Write-Success "✓ Git user configured"
} else {
    Write-Info "Current Git configuration:"
    Write-Host "  Name: $currentName"
    Write-Host "  Email: $currentEmail"
    
    if (Read-YesNo "Would you like to change these settings?") {
        $gitName = Read-InputWithDefault "Enter your full name" $currentName
        $gitEmail = Read-InputWithDefault "Enter your email" $currentEmail
        
        git config --global user.name "$gitName"
        git config --global user.email "$gitEmail"
        Write-Success "✓ Git user configuration updated"
    }
}

Write-Host ""

# Step 3: Initialize Git repository
Write-Step "3/7" "Initializing Git repository..."

if (Test-Path ".git") {
    Write-Info "Git repository already initialized"
    if (Read-YesNo "Would you like to reinitialize?") {
        Remove-Item -Recurse -Force .git
        git init
        Write-Success "✓ Git repository reinitialized"
    }
} else {
    git init
    Write-Success "✓ Git repository initialized"
}

Write-Host ""

# Step 4: Create initial commit
Write-Step "4/7" "Creating initial commit..."

# Check if there are already commits
$commitCount = git rev-list --count HEAD 2>$null
if ($commitCount -gt 0) {
    Write-Info "Repository already has $commitCount commit(s)"
    if (-not (Read-YesNo "Skip creating initial commit?")) {
        git add .
        git commit -m "feat: initial project structure for ObjectScript Design Patterns library" 2>$null
        Write-Success "✓ Created new commit"
    }
} else {
    Write-Info "Adding all files to git..."
    git add .
    
    $commitMessage = Read-InputWithDefault "Enter initial commit message" "feat: initial project structure for ObjectScript Design Patterns library"
    git commit -m "$commitMessage"
    Write-Success "✓ Initial commit created"
}

Write-Host ""

# Step 5: GitHub repository setup
Write-Step "5/7" "Setting up GitHub repository..."

$githubUsername = Read-InputWithDefault "Enter your GitHub username" $env:USERNAME
$repoName = Read-InputWithDefault "Enter repository name" "objectscript-design-patterns"
$repoVisibility = if (Read-YesNo "Make repository public?") { "public" } else { "private" }

if ($hasGhCli) {
    Write-Info "Using GitHub CLI to create repository..."
    
    # Check if authenticated
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Not authenticated with GitHub CLI"
        Write-Info "Running: gh auth login"
        gh auth login
    }
    
    # Create repository
    Write-Info "Creating repository on GitHub..."
    $repoDescription = "A comprehensive library of design patterns implemented in InterSystems ObjectScript"
    
    try {
        gh repo create "$githubUsername/$repoName" `
            --$repoVisibility `
            --description "$repoDescription" `
            --source . `
            --push `
            --remote origin
        
        Write-Success "✓ Repository created and pushed to GitHub!"
        $repoUrl = "https://github.com/$githubUsername/$repoName"
    } catch {
        Write-Warning "Failed to create repository with GitHub CLI"
        $manualSetup = $true
    }
} else {
    $manualSetup = $true
}

if ($manualSetup) {
    Write-Info "Manual GitHub setup required:"
    Write-Host ""
    Write-Host "1. Go to: https://github.com/new" -ForegroundColor Yellow
    Write-Host "2. Repository name: $repoName" -ForegroundColor Yellow
    Write-Host "3. Set visibility to: $repoVisibility" -ForegroundColor Yellow
    Write-Host "4. DON'T initialize with README, .gitignore, or license" -ForegroundColor Yellow
    Write-Host "5. Click 'Create repository'" -ForegroundColor Yellow
    Write-Host ""
    
    if (Read-YesNo "Have you created the repository on GitHub?") {
        $repoUrl = "https://github.com/$githubUsername/$repoName.git"
        
        Write-Info "Adding remote origin..."
        git remote add origin $repoUrl 2>$null
        if ($LASTEXITCODE -ne 0) {
            git remote set-url origin $repoUrl
        }
        
        Write-Info "Pushing to GitHub..."
        git push -u origin main 2>$null
        if ($LASTEXITCODE -ne 0) {
            git push -u origin master 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to push. You may need to push manually:"
                Write-Host "  git push -u origin main" -ForegroundColor Yellow
            }
        } else {
            Write-Success "✓ Code pushed to GitHub!"
        }
    }
}

Write-Host ""

# Step 6: Set up Git Flow branches
Write-Step "6/7" "Setting up Git Flow branches..."

if (Read-YesNo "Would you like to set up Git Flow branches (develop, etc.)?") {
    # Create and push develop branch
    git checkout -b develop 2>$null
    if ($LASTEXITCODE -eq 0) {
        git push -u origin develop
        Write-Success "✓ Created develop branch"
    } else {
        Write-Info "Develop branch already exists"
    }
    
    # Return to main/master
    git checkout main 2>$null
    if ($LASTEXITCODE -ne 0) {
        git checkout master 2>$null
    }
    
    Write-Info "Git Flow branches configured:"
    Write-Host "  - main/master: Production-ready code"
    Write-Host "  - develop: Integration branch for features"
    Write-Host "  - feature/*: Feature branches (create as needed)"
    Write-Host "  - release/*: Release preparation branches"
    Write-Host "  - hotfix/*: Emergency fixes for production"
}

Write-Host ""

# Step 7: Final setup
Write-Step "7/7" "Finalizing setup..."

Write-Success @"

✅ GitHub repository setup complete!

Repository URL: https://github.com/$githubUsername/$repoName

Next steps:
1. Review and update README.md with any project-specific details
2. Set up branch protection rules on GitHub (Settings → Branches)
3. Configure GitHub Actions for CI/CD (optional)
4. Add collaborators if working in a team (Settings → Manage access)
5. Create your first feature branch: git checkout -b feature/pattern-name

Useful commands:
- Create feature: git checkout -b feature/pattern-name
- Push changes: git add . && git commit -m "message" && git push
- Update from develop: git checkout develop && git pull
- Create PR: Use GitHub web interface or 'gh pr create'

For more details, see: docs/guides/github-setup.md

Happy coding! 🚀
"@

# Prompt to open repository in browser
if (Read-YesNo "Would you like to open the repository in your browser?") {
    Start-Process "https://github.com/$githubUsername/$repoName"
}
