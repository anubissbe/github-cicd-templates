# 🚀 CI/CD Implementation Guide

## 📋 Quick Implementation Checklist

### Step 1: Configure Secrets (5 minutes)
1. **Get CodeCov Token:**
   - Visit https://codecov.io/login
   - Login with GitHub
   - Get repository token from settings

2. **Get SonarCloud Token:**
   - Visit https://sonarcloud.io/login
   - Login with GitHub  
   - Generate token in Security settings

3. **Add to Repository:**
   ```bash
   gh secret set CODECOV_TOKEN --body "your-token" --repo anubissbe/REPO_NAME
   gh secret set SONAR_TOKEN --body "your-token" --repo anubissbe/REPO_NAME
   ```

### Step 2: Deploy Pipeline (2 minutes)
```bash
# Option A: Direct download
curl -o .github/workflows/ci-cd.yml \
  https://raw.githubusercontent.com/anubissbe/github-cicd-templates/main/workflows/universal-pipeline-optimized.yml

# Option B: Copy from local
cp /path/to/universal-pipeline-optimized.yml .github/workflows/ci-cd.yml

# Commit and push
git add .github/workflows/ci-cd.yml
git commit -m "fix: deploy optimized CI/CD pipeline"
git push
```

### Step 3: Verify Success (5 minutes)
```bash
# Check pipeline status
gh run list --limit 1

# Should show: "queued" or "in_progress" (NOT "startup_failure")
```

---

## 🔧 Detailed Implementation

### For New Repositories

1. **Create project structure:**
   ```bash
   mkdir -p .github/workflows
   ```

2. **Download optimized template:**
   ```bash
   curl -o .github/workflows/ci-cd.yml \
     https://raw.githubusercontent.com/anubissbe/github-cicd-templates/main/workflows/universal-pipeline-optimized.yml
   ```

3. **Configure repository secrets:**
   ```bash
   # Required
   gh secret set CODECOV_TOKEN --body "token-from-codecov"
   gh secret set SONAR_TOKEN --body "token-from-sonarcloud"
   
   # Optional for Python
   gh secret set PYPI_API_TOKEN --body "pypi-token"
   ```

4. **Push and monitor:**
   ```bash
   git add .
   git commit -m "feat: add optimized CI/CD pipeline"
   git push
   
   # Monitor execution
   gh run watch
   ```

### For Existing Repositories with Broken CI/CD

1. **Backup existing workflow:**
   ```bash
   mv .github/workflows/ci-cd.yml .github/workflows/ci-cd.yml.backup
   ```

2. **Replace with optimized version:**
   ```bash
   curl -o .github/workflows/ci-cd.yml \
     https://raw.githubusercontent.com/anubissbe/github-cicd-templates/main/workflows/universal-pipeline-optimized.yml
   ```

3. **Commit the fix:**
   ```bash
   git add .github/workflows/ci-cd.yml
   git commit -m "fix: replace broken CI/CD with optimized pipeline
   
   - Eliminates startup failures
   - Reduces resource usage by 30%
   - Adds error resilience"
   git push
   ```

---

## 🎯 Success Indicators

### ✅ Working Pipeline Shows:
- Status: `queued`, `in_progress`, `success`, or `failure`
- Execution time: 5-60 minutes total
- Jobs progressing through stages
- Cleanup completing successfully

### ❌ Failed Pipeline Shows:
- Status: `startup_failure`
- Execution time: 1 second
- No job progression
- Resource errors

---

## 🛠️ Troubleshooting

### Issue: Still Getting Startup Failures

**Solution:**
1. Verify correct template is deployed
2. Check runner labels match: `[self-hosted, linux, docker]`
3. Remove conflicting workflow files

### Issue: Pipeline Slower Than Expected

**Expected Performance:**
- Total time: 20-60 minutes
- Setup: 5 minutes
- Testing: 20 minutes
- Build: 15 minutes

**Solutions:**
- Check runner availability
- Review job logs for bottlenecks
- Consider caching dependencies

### Issue: Specific Job Failing

**Debug Steps:**
```bash
# View job details
gh run view --job=JOB_ID

# View job logs
gh run view --log --job=JOB_ID

# Check specific step
gh run view --log | grep -A10 -B10 "step-name"
```

---

## 🔐 Security Best Practices

### Secret Management
- ✅ Use repository secrets (not organization)
- ✅ Rotate tokens every 6-12 months
- ✅ Never commit tokens to code
- ✅ Use least privilege access

### Token Sources
- **CodeCov:** https://app.codecov.io/gh/YOUR_ORG
- **SonarCloud:** https://sonarcloud.io/account/security
- **PyPI:** https://pypi.org/manage/account/

---

## 📊 Monitoring & Maintenance

### Daily Monitoring
```bash
# Check recent runs
gh run list --limit 10

# Check for failures
gh run list --status failure --limit 5
```

### Weekly Maintenance
- Review pipeline performance metrics
- Check for security updates
- Update dependencies

### Monthly Review
- Rotate tokens if needed
- Review resource usage
- Optimize slow jobs

---

## 🚀 Advanced Configuration

### Custom Build Matrix
```yaml
strategy:
  matrix:
    node: [18, 20]
    os: [ubuntu-latest]
```

### Conditional Deployment
```yaml
deploy:
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### Custom Timeouts
```yaml
jobs:
  test:
    timeout-minutes: 30  # Increase for longer tests
```

---

## 📚 Additional Resources

- **GitHub Actions Docs:** https://docs.github.com/actions
- **CodeCov Setup:** https://docs.codecov.com/docs
- **SonarCloud Setup:** https://docs.sonarcloud.io
- **Self-hosted Runners:** https://docs.github.com/actions/hosting-your-own-runners