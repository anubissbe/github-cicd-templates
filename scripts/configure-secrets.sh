#!/bin/bash
# 🔐 CI/CD Secrets Configuration Script
# Configure CodeCov, SonarCloud, and PyPI tokens for repositories

set -euo pipefail

echo "🔐 CI/CD Secrets Configuration Script"
echo "===================================="
echo ""
echo "This script will help you configure required secrets for CI/CD pipelines."
echo ""

# Check if GitHub CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI not authenticated. Please run: gh auth login"
    exit 1
fi

# Function to configure secrets for a repository
configure_repo_secrets() {
    local repo=$1
    local codecov_token=$2
    local sonar_token=$3
    local pypi_token=${4:-""}
    
    echo "🔧 Configuring secrets for $repo..."
    
    # Configure CodeCov token
    if gh secret set CODECOV_TOKEN --body "$codecov_token" --repo "$repo" 2>/dev/null; then
        echo "  ✅ CodeCov token configured"
    else
        echo "  ❌ Failed to configure CodeCov token"
        return 1
    fi
    
    # Configure SonarCloud token
    if gh secret set SONAR_TOKEN --body "$sonar_token" --repo "$repo" 2>/dev/null; then
        echo "  ✅ SonarCloud token configured"
    else
        echo "  ❌ Failed to configure SonarCloud token"
        return 1
    fi
    
    # Configure PyPI token if provided
    if [[ -n "$pypi_token" ]]; then
        if gh secret set PYPI_API_TOKEN --body "$pypi_token" --repo "$repo" 2>/dev/null; then
            echo "  ✅ PyPI token configured"
        else
            echo "  ❌ Failed to configure PyPI token"
            return 1
        fi
    fi
    
    return 0
}

# Main script
echo "📋 Please provide the following tokens:"
echo ""
echo "1. CodeCov Token"
echo "   - Visit: https://app.codecov.io/gh"
echo "   - Select your repository"
echo "   - Go to Settings > General"
echo "   - Copy the Repository Upload Token"
echo ""
read -p "Enter CodeCov Token: " CODECOV_TOKEN

echo ""
echo "2. SonarCloud Token"
echo "   - Visit: https://sonarcloud.io"
echo "   - Go to: My Account > Security"
echo "   - Generate a new token"
echo "   - Copy the token value"
echo ""
read -p "Enter SonarCloud Token: " SONAR_TOKEN

echo ""
echo "3. PyPI Token (optional, for Python packages)"
echo "   - Visit: https://pypi.org/manage/account/"
echo "   - Go to: API tokens"
echo "   - Create a new API token"
echo "   - Copy the token (starts with 'pypi-')"
echo ""
read -p "Enter PyPI Token (press Enter to skip): " PYPI_TOKEN

echo ""
echo "🎯 Configuration Options:"
echo "1. Configure a single repository"
echo "2. Configure multiple repositories"
echo "3. Configure all repositories in an organization"
echo ""
read -p "Select option (1-3): " OPTION

case $OPTION in
    1)
        read -p "Enter repository (format: owner/repo): " REPO
        if configure_repo_secrets "$REPO" "$CODECOV_TOKEN" "$SONAR_TOKEN" "$PYPI_TOKEN"; then
            echo "✅ Successfully configured secrets for $REPO"
        else
            echo "❌ Failed to configure secrets for $REPO"
        fi
        ;;
    
    2)
        echo "Enter repositories one per line (press Ctrl+D when done):"
        while IFS= read -r repo; do
            if [[ -n "$repo" ]]; then
                configure_repo_secrets "$repo" "$CODECOV_TOKEN" "$SONAR_TOKEN" "$PYPI_TOKEN"
            fi
        done
        ;;
    
    3)
        read -p "Enter organization name: " ORG
        echo "Fetching repositories for $ORG..."
        
        # Get all non-forked repositories
        repos=$(gh repo list "$ORG" --limit 1000 --json nameWithOwner,isFork --jq '.[] | select(.isFork == false) | .nameWithOwner')
        
        if [[ -z "$repos" ]]; then
            echo "❌ No repositories found or access denied"
            exit 1
        fi
        
        echo "Found $(echo "$repos" | wc -l) repositories"
        read -p "Configure all? (y/n): " CONFIRM
        
        if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
            while IFS= read -r repo; do
                configure_repo_secrets "$repo" "$CODECOV_TOKEN" "$SONAR_TOKEN" "$PYPI_TOKEN"
                sleep 1  # Rate limiting
            done <<< "$repos"
        fi
        ;;
    
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "🔍 Verification:"
echo "To verify secrets are configured, run:"
echo "  gh secret list --repo OWNER/REPO"
echo ""
echo "✅ Configuration complete!"