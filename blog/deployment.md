# Deployment Guide

## Overview

The NurOS Package List uses GitHub Actions for continuous integration and deployment to GitHub
Pages. This guide explains the deployment process.

## Deployment Architecture

```
GitHub Repository
    ↓
    Trigger: Manual or Scheduled
    ↓
    ├─ Workflow 1: Update Package List (Every 6 hours)
    ├─ Workflow 2: Build Frontend (On list update)
    └─ Workflow 3: Deploy to Pages (On build success)
    ↓
    GitHub Pages
    ↓
    https://listpkgs.nuros.org
```

## Workflow Files

### 1. Update Package List (`update-list.yml`)

**Purpose**: Aggregate package metadata from all repositories

**Schedule**: Every 6 hours (0:00, 6:00, 12:00, 18:00 UTC)

**Steps**:

1. Checkout repository
1. Authenticate GitHub CLI
1. Fetch metadata from NurOS-Packages organization
1. Generate `packages.json`
1. Create checksum (`packages.json.sha256`)
1. Upload as artifact
1. Create deployment summary

**Triggers**:

- Scheduled cron job
- Manual dispatch via workflow_dispatch

**Artifacts**:

- `packages.json` - Full package catalog
- `packages.json.sha256` - Integrity verification

### 2. Build Frontend (`build_frontend.yml`)

**Purpose**: Build optimized frontend with latest package data

**Trigger**: After successful `update-list.yml` run (or manual dispatch)

**Prerequisites**:

- Package list must be updated
- Lint workflow must pass

**Steps**:

1. Checkout code
1. Download package data artifact
1. Verify source data exists
1. Install pnpm 9.x
1. Setup Node.js 22
1. Install dependencies (frozen lockfile)
1. Build with Vite
1. Verify build artifacts
1. Upload as artifact
1. Provide build summary

**Build configuration** (`vite.config.ts`):

```typescript
{
  command: 'build',
  base: '/listpkgs.nuros.org/',
  outDir: 'dist',
  minify: 'esbuild'
}
```

**Artifacts**:

- `frontend-dist` - Built application (HTML, JS, CSS)
- Retention: 7 days

### 3. Deploy to Pages (`deploy_on_pages.yml`)

**Purpose**: Deploy built frontend to GitHub Pages

**Trigger**: After successful `build_frontend.yml` run (or manual dispatch)

**Steps**:

1. Download build artifact
1. Verify deployment contents
1. Configure GitHub Pages
1. Upload pages artifact
1. Deploy to GitHub Pages
1. Create deployment summary

**Result**:

- Live at `https://listpkgs.nuros.org`
- GitHub Pages at `https://NurOS-Linux.github.io/listpkgs.nuros.org/`

## Manual Deployment

### Trigger Workflows Manually

1. **GitHub Web UI**:

   - Go to Actions tab
   - Select workflow (e.g., "Build Frontend")
   - Click "Run workflow"
   - Confirm branch and options
   - Click "Run workflow"

1. **GitHub CLI**:

   ```bash
   # Trigger update list
   gh workflow run update-list.yml -r main

   # Trigger frontend build
   gh workflow run build_frontend.yml -r main

   # Trigger deploy
   gh workflow run deploy_on_pages.yml -r main
   ```

1. **Full Pipeline**:

   ```bash
   # Run all workflows in sequence
   gh workflow run update-list.yml -r main
   gh workflow run build_frontend.yml -r main
   gh workflow run deploy_on_pages.yml -r main
   ```

## Environment Variables & Secrets

### Required Secrets

| Secret | Purpose | Where | | ------------------------ | ----------------------------- |
--------------------- | | `GITHUB_TOKEN` | GitHub Actions authentication | Automatic (GitHub) | |
(Optional) Custom domain | CNAME for custom domain | GitHub Pages settings |

### Configuration Files

#### `vite.config.ts`

```typescript
export default {
  server: { port: 5173 },
  base: '/listpkgs.nuros.org/',
  build: {
    outDir: 'dist',
  },
};
```

#### GitHub Pages Settings

- **Source**: GitHub Actions
- **Branch**: (automatic deployment)
- **Custom domain**: listpkgs.nuros.org (via CNAME)

## Monitoring Deployments

### Check Deployment Status

1. **GitHub Actions Dashboard**:

   - Go to Actions tab
   - View workflow run details
   - Check logs for errors

1. **Deployment History**:

   - Settings → Pages
   - View deployment history
   - Check GitHub status page

1. **Package List Updates**:

   ```bash
   # Check latest workflow run
   gh run list --workflow=update-list.yml --limit=5

   # View detailed logs
   gh run view <run-id> --log
   ```

## Troubleshooting

### Build Fails

**Problem**: Build step fails in `build_frontend.yml`

**Solutions**:

1. Check Node.js version is 22
1. Verify `pnpm-lock.yaml` is committed
1. Run `pnpm install --frozen-lockfile` locally
1. Check for TypeScript errors: `pnpm lint`
1. Review logs for specific errors

### Deployment Not Updated

**Problem**: Page not showing latest version

**Solutions**:

1. Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
1. Clear browser cache
1. Check GitHub Pages settings
1. Verify workflow completed successfully
1. Check DNS propagation (if custom domain)

### Package Data Missing

**Problem**: Package list not updated

**Solutions**:

1. Check `update-list.yml` logs
1. Verify GitHub token permission
1. Ensure repositories in organization are accessible
1. Check for permission issues
1. Manually trigger workflow

### 404 on Subpath

**Problem**: Getting 404 on `/listpkgs.nuros.org/` path

**Solutions**:

1. Check `vite.config.ts` base path setting
1. Verify GitHub Pages source is GitHub Actions
1. Check artifact upload step succeeded
1. Clear CDN cache (if applicable)

## Performance & Optimization

### Build Performance

- Typical build time: 2-3 minutes
- Artifact size: ~500KB (compressed)
- No build optimization needed currently

### Deployment Performance

- Pages deployment: ~30 seconds
- CDN integration: Automatic
- Cache headers: Set by GitHub

### Caching Strategy

- Static assets cached by browser (1 year)
- HTML not cached (always fresh)
- API responses cached in-memory

## Security

### Workflow Security

- `GITHUB_TOKEN` limited to this workflow
- No external secrets required
- All operations within GitHub
- Audit logs available

### Branch Protection

```yaml
# Recommended: main branch protection
- Require PR reviews
- Require status checks pass
- Require branches up to date
- Dismiss stale reviews
```

### Artifact Security

- Artifacts auto-expire after 7 days
- No sensitive data in artifacts
- Workflow logs public by default

## Rollback Procedure

If deployment breaks live site:

1. **Quick Fix Option** (recommended):

   ```bash
   # Trigger previous successful workflow
   gh workflow run build_frontend.yml -r main
   ```

1. **Revert Code**:

   ```bash
   # If code change caused issue
   git revert <commit-hash>
   git push
   # Workflows auto-trigger
   ```

1. **Manual Rollback**:

   ```bash
   # Checkout previous working version
   git checkout <commit-hash> -- listpkgs.nuros.front-end/
   git commit -m "rollback: revert to working version"
   git push
   ```

1. **GitHub Pages Rollback**:

   - Go to Settings → Pages
   - View deployment history
   - Click "Restore" on previous deployment

## Monitoring & Alerts

### GitHub Actions Notifications

- Email notifications for workflow failures
- Subscribe to repository notifications
- Custom hooks via GitHub Apps

### Status Checks

- GitHub status page: https://www.githubstatus.com/
- Workflow status badges in README
- Custom status checks possible

## Advanced Configuration

### Custom Domain

Already configured:

```
CNAME file contains: listpkgs.nuros.org
```

### Custom SSL Certificate

- Automatic via GitHub Pages
- Updated automatically
- Renewal automatic

### Custom Deployment Keys

Currently not needed (using default GITHUB_TOKEN)

## Access Control

### Team Permissions

```yaml
# Repository settings
- Admin: Full access
- Maintain: Can deploy
- Write: Can commit
- Read: View only
```

### Workflow Permissions

```yaml
contents: read # Read repository
pages: write # Deploy pages
id-token: write # OIDC token
```

______________________________________________________________________

See [Architecture](architecture.md) for system overview | [Contributing](contributing.md) for
development guide
