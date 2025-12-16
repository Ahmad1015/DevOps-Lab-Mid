# 🔒 Security Setup Instructions

This repository has been cleaned of all sensitive data. Before deploying, you must configure your own credentials.

## ⚠️ NEVER COMMIT THESE FILES:
- `.env`
- `infra/terraform.tfvars`
- `k8s/secrets/app-secrets.yaml`
- `infra/terraform.tfstate*`
- Any files containing passwords, API keys, or AWS credentials

## 🚀 Quick Setup

### 1. Environment Variables

```bash
# Copy example file
cp .env.example .env

# Edit with your values
nano .env
```

### 2. Terraform Variables

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars

# Edit with your AWS and database credentials
nano terraform.tfvars
```

### 3. Kubernetes Secrets

```bash
cd k8s/secrets
cp app-secrets.yaml.example app-secrets.yaml

# Encode your values with base64:
echo -n "your_value" | base64

# Edit the file with encoded values
nano app-secrets.yaml
```

## 🔐 GitHub Secrets (for CI/CD)

If using GitHub Actions, add these secrets to your repository:

1. Go to: Settings → Secrets and variables → Actions
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `DB_PASSWORD`
   - `MONGO_PASSWORD`
   - Any other sensitive values

## ✅ Verify Security

Before pushing to GitHub, check:

```bash
# Make sure no sensitive files are tracked
git status

# Check what would be pushed
git diff origin/main

# Verify .gitignore is working
git check-ignore .env infra/terraform.tfvars k8s/secrets/app-secrets.yaml
```

All three should show as ignored. If not, **DO NOT PUSH!**

## 🚨 If You Accidentally Commit Secrets

1. **Immediately rotate all credentials** (change passwords, regenerate keys)
2. Run the cleanup script again: `./cleanup-repo.sh`
3. Force push the cleaned history: `git push origin main --force`

## 📚 Resources

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [git-filter-repo documentation](https://github.com/newren/git-filter-repo)
- [AWS IAM best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
