# Docker Commands Reference

## Quick Start

### Preview (One Command)
```bash
docker compose --profile preview run --rm preview-init
```

---

## Local Development

### Start Development Server
```bash
docker compose up dev
```

### Stop Development Server
```bash
docker compose down
```

---

## Preview Production Build

### Full Preview (Generate + Build + Start)
```bash
docker compose --profile preview run --rm preview-init
```

### Manual Steps (2 Commands)

**Step 1: Generate repodata.json**
```bash
docker compose --profile preview run --rm generate-repodata
```

**Step 2: Build and Start Preview**
```bash
docker compose --profile preview up --build preview
```

### Stop Preview
```bash
docker compose --profile preview down
```

### Clean Rebuild
```bash
docker compose --profile preview down --volumes --rmi all
docker compose --profile preview run --rm preview-init
```

---

## CI/CD Commands

### Run Lint
```bash
docker compose --profile ci run --rm lint
```

### Run Tests
```bash
docker compose --profile ci run --rm test
```

### Build Frontend
```bash
docker compose --profile ci run --rm build
```

### Update Package List
```bash
docker compose --profile ci run --rm update-list
```

---

## Cleanup

### Remove All Containers and Volumes
```bash
docker compose --profile preview down --volumes
docker compose --profile ci down --volumes
docker compose down --volumes
```

### Remove All Images
```bash
docker compose --profile preview down --rmi all
docker compose --profile ci down --rmi all
```

### Full Cleanup
```bash
docker compose --all down --volumes --rmi all
```

---

## Access

| Service | URL | Port |
|---------|-----|------|
| Preview | http://localhost:8080 | 8080 |
| Dev Server | http://localhost:5173 | 5173 |
| Health Check | http://localhost:8080/health | 8080 |
