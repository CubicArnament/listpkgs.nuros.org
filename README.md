# NurOS Package List

Automated package registry for NurOS. This repository aggregates metadata from all packages in the [NurOS-Packages](https://github.com/NurOS-Packages) organization and publishes a unified `packages.json` to GitHub Pages.

## How It Works

A GitHub Actions workflow runs every 6 hours (or on manual trigger) and:

1. Fetches all repositories from the NurOS-Packages organization
2. Retrieves `metadata.json` from each repository
3. Validates required fields (`name`, `version`)
4. Aggregates everything into a single `packages.json`
5. Deploys to GitHub Pages

## Package Registry

The package list is available at:

```
https://listpkgs.nuros.org/packages.json
```

### Response Format

```json
{
  "package-name": {
    "name": "package-name",
    "version": "1.0.0",
    "description": "Package description",
    "license": "MIT",
    "_source_repo": "https://github.com/NurOS-Packages/package-name",
    "_last_updated": "2025-02-01T12:00:00Z"
  }
}
```

## Adding a New Package

1. Create a repository in the [NurOS-Packages](https://github.com/NurOS-Packages) organization
2. Add a `metadata.json` file to the root of the repository (see below)
3. The package will appear in the registry within 6 hours (or trigger the workflow manually)

### metadata.json Schema

Required fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Package name (must be unique) |
| `version` | string | Package version (semver recommended) |

Optional fields:

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Short package description |
| `license` | string | License identifier (e.g., MIT, GPL-3.0) |
| `homepage` | string | Project homepage URL |
| `maintainers` | array | List of maintainer names or emails |
| `dependencies` | object | Runtime dependencies |
| `build_dependencies` | object | Build-time dependencies |

Example:

```json
{
  "name": "example-package",
  "version": "1.2.3",
  "description": "An example package for NurOS",
  "license": "MIT",
  "homepage": "https://example.com",
  "maintainers": [
    "maintainer@example.com"
  ],
  "dependencies": {
    "glibc": ">=2.17"
  }
}
```

## Repository Structure

```
.
├── .ci/
│   └── main.py           # Package aggregation script
├── .github/
│   └── workflows/
│       └── update-packages.yml
├── packages.json         # Generated package list (do not edit)
└── README.md
```

## Manual Trigger

To manually update the package list:

1. Go to **Actions** tab
2. Select **Update NurOS Package List**
3. Click **Run workflow**

## Ignored Repositories

The following repositories are excluded from aggregation:

- Repositories starting with `.`
- `status`
- `.github`
- `template`
- `docs`

## License

This is free and unencumbered software released into the public domain. See [UNLICENSE](UNLICENSE) for details.
