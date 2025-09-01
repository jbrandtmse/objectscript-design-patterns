#!/bin/bash

# ObjectScript Design Patterns - GitHub Setup Script
# This script helps automate the initial GitHub setup

echo "======================================"
echo "ObjectScript Design Patterns"
echo "GitHub Repository Setup Script"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if git is installed
if ! command_exists git; then
    echo -e "${RED}Error: Git is not installed!${NC}"
    echo "Please install Git from https://git-scm.com/"
    exit 1
fi

echo -e "${GREEN}✓ Git is installed${NC}"

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -f "module.xml" ]; then
    echo -e "${RED}Error: This script must be run from the project root directory${NC}"
    echo "Please navigate to the objectscript-design-patterns directory"
    exit 1
fi

echo -e "${GREEN}✓ Running from project root${NC}"

# Check if git is already initialized
if [ -d ".git" ]; then
    echo -e "${YELLOW}Git repository already initialized${NC}"
else
    echo "Initializing Git repository..."
    git init
    echo -e "${GREEN}✓ Git repository initialized${NC}"
fi

# Configure git user if not set
if [ -z "$(git config user.name)" ]; then
    echo ""
    echo "Git user configuration needed:"
    read -p "Enter your name: " username
    git config user.name "$username"
fi

if [ -z "$(git config user.email)" ]; then
    read -p "Enter your email: " useremail
    git config user.email "$useremail"
fi

echo -e "${GREEN}✓ Git user configured${NC}"

# Add all files to staging
echo ""
echo "Adding files to Git..."
git add .
echo -e "${GREEN}✓ Files added to staging${NC}"

# Create initial commit if no commits exist
if ! git log -1 >/dev/null 2>&1; then
    echo "Creating initial commit..."
    git commit -m "Initial commit: Project setup and structure"
    echo -e "${GREEN}✓ Initial commit created${NC}"
else
    echo -e "${YELLOW}Repository already has commits${NC}"
fi

# Check for GitHub CLI
if command_exists gh; then
    echo -e "${GREEN}✓ GitHub CLI is installed${NC}"
    echo ""
    echo "Would you like to create the GitHub repository automatically? (y/n)"
    read -p "> " create_repo
    
    if [ "$create_repo" == "y" ] || [ "$create_repo" == "Y" ]; then
        # Check if authenticated
        if ! gh auth status >/dev/null 2>&1; then
            echo "Please authenticate with GitHub:"
            gh auth login
        fi
        
        # Create repository
        echo "Creating GitHub repository..."
        gh repo create objectscript-design-patterns \
            --public \
            --description "Comprehensive implementation of Gang of Four and PoEAA design patterns in InterSystems ObjectScript" \
            --source=. \
            --remote=origin \
            --push
        
        echo -e "${GREEN}✓ GitHub repository created and code pushed${NC}"
    else
        echo ""
        echo -e "${YELLOW}Manual setup required:${NC}"
        echo "1. Go to https://github.com/new"
        echo "2. Create a repository named: objectscript-design-patterns"
        echo "3. Run the following commands:"
        echo ""
        read -p "Enter your GitHub username: " github_username
        echo -e "${YELLOW}"
        echo "git remote add origin https://github.com/$github_username/objectscript-design-patterns.git"
        echo "git push -u origin main"
        echo -e "${NC}"
    fi
else
    echo -e "${YELLOW}GitHub CLI not installed${NC}"
    echo ""
    echo "For automated setup, install GitHub CLI:"
    echo "  Windows: winget install --id GitHub.cli"
    echo "  Mac: brew install gh"
    echo "  Linux: See https://github.com/cli/cli#installation"
    echo ""
    echo -e "${YELLOW}Manual setup required:${NC}"
    echo "1. Go to https://github.com/new"
    echo "2. Create a repository named: objectscript-design-patterns"
    echo "3. Run the following commands:"
    echo ""
    read -p "Enter your GitHub username: " github_username
    echo -e "${YELLOW}"
    echo "git remote add origin https://github.com/$github_username/objectscript-design-patterns.git"
    echo "git push -u origin main"
    echo -e "${NC}"
fi

# Set up Git Flow branches
echo ""
echo "Setting up Git Flow branching..."

# Check if develop branch exists
if ! git show-ref --verify --quiet refs/heads/develop; then
    git checkout -b develop
    echo -e "${GREEN}✓ Created develop branch${NC}"
    
    # Push develop branch if remote exists
    if git remote get-url origin >/dev/null 2>&1; then
        git push -u origin develop
        echo -e "${GREEN}✓ Pushed develop branch to GitHub${NC}"
    fi
else
    echo -e "${YELLOW}Develop branch already exists${NC}"
fi

echo ""
echo "======================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. If not done automatically, push your code to GitHub"
echo "2. Configure branch protection rules in GitHub settings"
echo "3. Start developing in feature branches"
echo ""
echo "Create your first feature branch:"
echo "  git checkout develop"
echo "  git checkout -b feature/singleton-pattern"
echo ""
echo "Happy coding! 🚀"
