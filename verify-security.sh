#!/bin/bash

# Quick verification script to ensure repo is safe to push to public GitHub

echo "=========================================="
echo "  🔍 REPOSITORY SECURITY CHECK"
echo "=========================================="
echo ""

cd /home/mahme/Lab_Final/DevOps-Lab-Mid

ISSUES=0

# Check 1: Look for common secret patterns in tracked files
echo "1. Checking for secret patterns in tracked files..."
if git grep -iE "(password|secret|api_key|aws_access_key|private_key)\s*=\s*['\"][^'\"]+['\"]" -- ':(exclude).env.example' ':(exclude)*.example' ':(exclude)SECURITY_SETUP.md' >/dev/null 2>&1; then
    echo "   ⚠️  WARNING: Found potential secrets in tracked files:"
    git grep -iE "(password|secret|api_key|aws_access_key|private_key)\s*=\s*['\"][^'\"]+['\"]" --name-only -- ':(exclude).env.example' ':(exclude)*.example' ':(exclude)SECURITY_SETUP.md'
    ISSUES=$((ISSUES + 1))
else
    echo "   ✅ No obvious secrets found in tracked files"
fi

# Check 2: Verify sensitive files are ignored
echo ""
echo "2. Verifying .gitignore is working..."
IGNORED_COUNT=0
for file in .env infra/terraform.tfvars k8s/secrets/app-secrets.yaml infra/terraform.tfstate; do
    if git check-ignore -q "$file" 2>/dev/null; then
        IGNORED_COUNT=$((IGNORED_COUNT + 1))
    else
        echo "   ⚠️  WARNING: $file is NOT ignored!"
        ISSUES=$((ISSUES + 1))
    fi
done

if [ $IGNORED_COUNT -eq 4 ]; then
    echo "   ✅ All sensitive files are properly ignored"
fi

# Check 3: Look for AWS credentials patterns
echo ""
echo "3. Checking for AWS credentials..."
if git grep -E "AKIA[0-9A-Z]{16}" >/dev/null 2>&1; then
    echo "   ⚠️  WARNING: Found AWS Access Key ID pattern!"
    git grep -E "AKIA[0-9A-Z]{16}" --name-only
    ISSUES=$((ISSUES + 1))
else
    echo "   ✅ No AWS access keys found"
fi

# Check 4: Verify example files exist
echo ""
echo "4. Checking for example files..."
EXAMPLE_COUNT=0
for file in .env.example infra/terraform.tfvars.example k8s/secrets/app-secrets.yaml.example; do
    if [ -f "$file" ]; then
        EXAMPLE_COUNT=$((EXAMPLE_COUNT + 1))
    else
        echo "   ⚠️  Missing: $file"
    fi
done

if [ $EXAMPLE_COUNT -eq 3 ]; then
    echo "   ✅ All example files present"
else
    echo "   ⚠️  Some example files are missing"
    ISSUES=$((ISSUES + 1))
fi

# Check 5: Look for sensitive files in working directory
echo ""
echo "5. Checking working directory for sensitive files..."
SENSITIVE_FILES_FOUND=0
for file in .env infra/terraform.tfstate infra/terraform.tfvars k8s/secrets/app-secrets.yaml; do
    if [ -f "$file" ]; then
        echo "   ⚠️  Found: $file (should be deleted or ignored)"
        SENSITIVE_FILES_FOUND=$((SENSITIVE_FILES_FOUND + 1))
    fi
done

if [ $SENSITIVE_FILES_FOUND -eq 0 ]; then
    echo "   ✅ No sensitive files in working directory"
else
    ISSUES=$((ISSUES + 1))
fi

# Check 6: Verify git history is clean
echo ""
echo "6. Checking git history for sensitive files..."
HISTORY_CLEAN=true
for file in .env infra/terraform.tfstate infra/terraform.tfvars k8s/secrets/app-secrets.yaml; do
    if git log --all --full-history -- "$file" >/dev/null 2>&1; then
        echo "   ⚠️  WARNING: $file exists in git history!"
        HISTORY_CLEAN=false
        ISSUES=$((ISSUES + 1))
    fi
done

if [ "$HISTORY_CLEAN" = true ]; then
    echo "   ✅ Git history is clean"
fi

# Final summary
echo ""
echo "=========================================="
if [ $ISSUES -eq 0 ]; then
    echo "  ✅ REPOSITORY IS SAFE TO MAKE PUBLIC!"
    echo "=========================================="
    echo ""
    echo "You can now push to GitHub with:"
    echo "  git push origin main --force"
    echo ""
    echo "Or if this is a new repo:"
    echo "  git remote add origin https://github.com/yourusername/yourrepo.git"
    echo "  git push -u origin main"
else
    echo "  ⚠️  FOUND $ISSUES ISSUE(S) - DO NOT PUSH YET!"
    echo "=========================================="
    echo ""
    echo "Please fix the issues above before making the repo public."
    echo "If you need to clean history again, run: ./cleanup-repo.sh"
fi
echo "=========================================="
