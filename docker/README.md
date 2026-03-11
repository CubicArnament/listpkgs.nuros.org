# Docker Configuration

Complete Docker setup for local development and production deployment.

## Structure

```
docker/
├── local/
│   ├── Dockerfile         # Development container (with nginx + dev servers)
│   ├── nginx.conf         # Nginx config for dev (HMR reverse proxy)
│   └── supervisord.conf   # Process manager config
├── production/
│   └── Dockerfile         # Production container (minimal, multi-stage)
├── security/
│   └── apparmor-nuros.profile  # Security profile for both envs
└── README.md             # This file
```

## Quick Start

### Local Development

```bash
# Build and start development environment
docker-compose -f docker-compose.local.yml up --build

# Access:
# - Frontend: http://localhost
# - Docs: http://localhost/docs
# - Direct dev servers: localhost:5173, localhost:5174

# View logs
docker-compose -f docker-compose.local.yml logs -f

# Stop
docker-compose -f docker-compose.local.yml down
```

### Production Build

```bash
# Build production image
docker-compose -f docker-compose.prod.yml build

# Start production container
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f nuros-app

# Stop
docker-compose -f docker-compose.prod.yml down
```

## Development Container (Local)

### Features

- **Hot Reload**: Changes reflected immediately via Vite HMR
- **Nginx Reverse Proxy**: Routes /docs and / to Dev servers
- **Supervisord**: Manages nginx + frontend + docs dev servers
- **All Tools**: pnpm, git, curl, vim, etc.
- **No Build Step**: Runs with npm scripts directly

### Commands

Inside container:

```bash
# Install dependencies
pnpm install

# View logs
tail -f /var/log/nginx/access.log
tail -f /var/log/frontend.log
tail -f /var/log/docs.log

# Execute commands
pnpm format
pnpm lint
pnpm test
```

### Mounted Volumes

- `.:/workspace` - Entire project source
- `./logs/local:/var/log` - Application logs

### Network Ports

- `80` - Nginx reverse proxy (frontend + docs)
- `5173` - Frontend dev server (Vite)
- `5174` - Docs dev server (VitePress)
- `3000` - Backend API (if needed)

## Production Container

### Features

- **Multi-Stage Build**: Optimized final image size
- **Non-Root User**: Security hardening
- **AppArmor Profile**: Additional isolation
- **Resource Limits**: CPU and memory constraints
- **Health Checks**: Container auto-restart on failure
- **Minimal Base**: Alpine Linux for smallest footprint
- **No Nginx**: Expects reverse proxy in front (separate service)

### Environment Variables

```bash
NODE_ENV=production
LOG_LEVEL=info
```

Configure in `.env.prod`:

```bash
# Database (if using)
DB_USER=nuros
DB_PASSWORD=secure_password
DB_NAME=nuros
DB_HOST=postgres-prod
```

### Security

#### AppArmor Profile

Load the profile on host:

```bash
# Load profile
sudo apparmor_parser -r docker/security/apparmor-nuros.profile

# Verify
sudo aa-status | grep nuros-app
```

#### Auditd (optional)

Monitor production container with auditd:

```bash
# Install (on host Linux)
sudo apt-get install auditd

# Add audit rule for container
sudo auditctl -w /var/lib/docker/containers -p wa -k docker_containers

# View audit logs
sudo ausearch -k docker_containers
```

#### Capabilities

Container drops all capabilities except:

- `NET_BIND_SERVICE` - Listen on port 3000

### Network

Production containers communicate via internal Docker network:

```
nuros-prod (Docker bridge network)
└── 10.0.0.0/24 subnet
```

Reverse proxy should route external traffic to container port 3000.

### Data Persistence

- logs stored in `./logs/production/`
- Config files should be mounted read-only
- Database (if used) requires separate service or managed DB

## Nginx Configuration

### Local Development (docker/local/nginx.conf)

- Reverse proxies to Vite dev server (port 5173)
- Reverse proxies to VitePress dev server (port 5174)
- Handles hot module reload (HMR)
- Includes security headers
- Path `/docs` → docs dev server
- Path `/api` → optional backend

### Production

Production uses external reverse proxy (nginx, Traefik, etc.). Configure to:

1. Listen on port 80/443
2. Proxy to container port 3000
3. Handle SSL/TLS
4. Apply rate limiting
5. Set security headers

Example Caddy config (in production):

```
:80 {
    reverse_proxy nuros-app:3000
    encode gzip
    header X-Frame-Options "SAMEORIGIN"
    header X-Content-Type-Options "nosniff"
}
```

## Logging

### Local Development

Logs automatically written to `./logs/local/`:

- `/var/log/nginx/access.log` - Nginx access logs
- `/var/log/nginx/error.log` - Nginx errors
- `/var/log/frontend.log` - Frontend dev server logs
- `/var/log/docs.log` - Docs dev server logs

View in real-time:

```bash
tail -f ./logs/local/nginx/access.log
```

### Production

Logs stored in `./logs/production/`:

- Container logs: via docker-compose logs
- Application logs: JSON formatted
- Nginx/proxy logs: depends on proxy configuration

Configure log rotation:

```bash
# docker-compose.prod.yml logrotate
max-size: '100m'  # Rotate when reaching 100MB
max-file: '10'    # Keep 10 rotated files
```

## Monitoring

### Health Checks

Both environments include health checks:

```bash
# Local
curl http://localhost/health

# Production
curl http://localhost:3000/health
```

Container automatically restarts if health check fails.

### Resource Monitoring

Production containers have limits:

- **CPU**: Max 2 cores, reserved 1 core
- **Memory**: Max 1GB, reserved 512MB

Monitor with:

```bash
docker stats nuros-prod
```

## Troubleshooting

### Local Development Issues

**Ports in use:**

```bash
# Find what's using ports
lsof -i :80
lsof -i :5173

# Kill process
kill -9 <PID>
```

**Rebuild after major changes:**

```bash
docker-compose -f docker-compose.local.yml down -v
docker-compose -f docker-compose.local.yml up --build
```

**Dependencies not installing:**

```bash
# Clear pnpm cache
docker-compose -f docker-compose.local.yml exec nuros-dev pnpm store prune

# Reinstall
docker-compose -f docker-compose.local.yml exec nuros-dev pnpm install
```

### Production Issues

**Container exits immediately:**

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs nuros-app

# Inspect image
docker run -it nuros-listpkgs:latest sh
```

**Health check failing:**

```bash
# Manually check
docker exec nuros-prod curl http://localhost:3000/health

# View container logs
docker logs --tail 100 nuros-prod
```

## Best Practices

### Local Development

1. Use hot reload - save files and see changes instantly
2. Run pnpm format/lint inside container
3. Check logs in `./logs/local/`
4. Restart services via supervisorctl if needed

### Production

1. Always use `.env.prod` for secrets
2. Mount AppArmor profile before running
3. Use external reverse proxy (Don't expose app directly)
4. Set resource limits appropriately for your hardware
5. Monitor logs and health checks
6. Regular backups of ./logs/production data
7. Review AppArmor audit logs regularly

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Build Docker image
  run: |
    docker build -f docker/production/Dockerfile -t nuros:${{ github.sha }} .

- name: Push to registry
  run: |
    docker tag nuros:${{ github.sha }} registry/nuros:latest
    docker push registry/nuros:latest
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file)
- [AppArmor Documentation](https://gitlab.com/apparmor/apparmor/-/wikis/home)
- [Nginx Documentation](https://nginx.org/en/docs)
- [Supervisord Documentation](http://supervisord.org)

---

For issues or improvements, open a GitHub issue!
