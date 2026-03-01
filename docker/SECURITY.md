# 🔒 NurOS Container Security Guide

## AppArmor Strict Profile

This directory contains a **security-hardened** AppArmor profile for NurOS containers.

### Profile Location

```
docker/container-apparmor-profile-strict
```

## Installation

### On Linux (Production)

```bash
# Copy profile to AppArmor directory
sudo cp docker/container-apparmor-profile-strict /etc/apparmor.d/

# Compile and load the profile
sudo apparmor_parser -r /etc/apparmor.d/container-apparmor-profile-strict

# Enable enforce mode
sudo aa-enforce container-nuros-strict

# Verify status
sudo aa-status | grep container-nuros-strict
```

### Check Profile Status

```bash
# Show all AppArmor statuses
sudo aa-status

# Show only NurOS profile
sudo aa-status | grep container-nuros-strict
```

## Usage

### Docker

```bash
docker run --security-opt apparmor=container-nuros-strict \
           --security-opt no-new-privileges:true \
           --read-only \
           --tmpfs /tmp \
           --tmpfs /var/tmp \
           your-image
```

### Podman

```bash
podman run --security-opt apparmor=container-nuros-strict \
           --security-opt no-new-privileges:true \
           --read-only \
           --tmpfs /tmp \
           --tmpfs /var/tmp \
           your-image
```

### Docker Compose

```yaml
services:
  app:
    image: your-image
    security_opt:
      - apparmor=container-nuros-strict
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp
      - /root/.npm
      - /root/.cache
```

## Security Features

### 🔒 Capabilities (Only 7 allowed)

| Capability | Purpose |
|------------|---------|
| `chown` | Change file ownership |
| `fowner` | Bypass permission checks for file owner |
| `fsetid` | Set setuid/setgid bits |
| `kill` | Send signals to processes |
| `setgid` | Set group ID |
| `setuid` | Set user ID |
| `net_bind_service` | Bind to privileged ports (<1024) |
| `audit_write` | Write audit logs |

### ❌ Removed Dangerous Capabilities

- `dac_override` — Ignore file permissions (CRITICAL)
- `dac_read_search` — Read any file (CRITICAL)
- `mknod` — Create device nodes
- `sys_chroot` — Change root directory
- `setpcap` — Modify capabilities
- `setfcap` — Set file capabilities (privilege escalation risk)
- `sys_module` — Load kernel modules (CRITICAL)
- `sys_rawio` — Raw I/O access (CRITICAL)
- `net_raw` — Raw network access
- `net_admin` — Network administration
- `sys_time` — Modify system clock
- `reboot` — Reboot system

### 🌐 Network Restrictions

```apparmor
network inet tcp,      # TCP only
network inet udp,      # UDP only
network inet dgram,    # DNS
# NO ICMP (ping)
# NO raw sockets
```

### 📁 File System Access

**Allowed (Read-Only):**
- `/etc/hosts`, `/etc/resolv.conf`
- `/etc/ssl/**`, `/etc/pki/**`
- `/lib/**`, `/usr/lib/**`
- `/bin/**`, `/usr/bin/**`

**Allowed (Read-Write):**
- `/app/**` — Application directory
- `/workspace/**`, `/src/**`
- `/tmp/**`, `/var/tmp/**` (no execute!)

**Denied:**
- `/home/*/**` — User home directories
- `/root/**` — Root home directory
- `/var/run/docker.sock` — Docker socket
- `/sys/firmware/**`, `/sys/kernel/**`

### 🚫 Execution Restrictions

```apparmor
# Allow execution from known paths
/bin/** ix,
/usr/bin/** ix,
/app/** ix,

# DENY execution from /tmp
deny /tmp/** ix,
deny /var/tmp/** ix,
```

### 🛡️ Additional Protections

- **ptrace**: Denied (no debugging)
- **signal**: Only to same profile
- **mount**: Only proc, sysfs, tmpfs, devpts
- **no-new-privileges**: Enabled

## Monitoring & Auditing

### 🔍 Auditd Setup for Security Logging

**auditd** (Linux Audit Framework) logs all AppArmor denials and security events.

#### Installation

```bash
# Install auditd
sudo apt update
sudo apt install auditd

# Enable and start service
sudo systemctl enable auditd
sudo systemctl start auditd

# Check status
sudo systemctl status auditd
```

#### Configure Audit Rules for AppArmor

```bash
# Add audit rules for AppArmor monitoring
sudo auditctl -w /sys/kernel/apparmor -p rwa -k apparmor
sudo auditctl -w /etc/apparmor.d/container-nuros-strict -p rwa -k apparmor_profile
sudo auditctl -w /var/log/audit/ -p rwa -k audit_logs

# Make rules persistent (survive reboot)
echo "-w /sys/kernel/apparmor -p rwa -k apparmor" | \
    sudo tee -a /etc/audit/rules.d/apparmor.rules
echo "-w /etc/apparmor.d/container-nuros-strict -p rwa -k apparmor_profile" | \
    sudo tee -a /etc/audit/rules.d/apparmor.rules
```

#### View Audit Logs

```bash
# View AppArmor denials (last 24 hours)
sudo ausearch -m apparmor_denied -ts today

# View denials for specific profile
sudo ausearch -k apparmor_profile -m apparmor_denied

# View all container-nuros-strict denials
sudo ausearch -m apparmor_denied | grep "container-nuros-strict"

# Real-time monitoring
sudo tail -f /var/log/audit/audit.log | grep container-nuros-strict

# Search by time range
sudo ausearch -m apparmor_denied -ts recent  # Last 10 minutes
sudo ausearch -m apparmor_denied -ts current  # Current session
```

#### Audit Log Format

Example denial entry:
```
type=AVC msg=audit(1234567890.123:456): apparmor="DENIED" \
  operation="capable" profile="container-nuros-strict" \
  pid=1234 comm="docker" requested="dac_override" has="No"
```

Fields:
- `msg=audit(timestamp:serial)` — Unique event identifier
- `apparmor="DENIED"` — Access was denied
- `operation` — Type of operation (capable, file, network, etc.)
- `profile` — AppArmor profile name
- `requested` — Capability/access that was requested
- `comm` — Command/process that triggered the denial

### 📊 Monitoring Scripts

#### Check Recent Denials

Create `/usr/local/bin/check-apparmor-audit.sh`:

```bash
#!/bin/bash
# Check AppArmor denials for container-nuros-strict profile

echo "=== AppArmor Denials (last 24h) ==="
echo ""

DENIALS=$(ausearch -m apparmor_denied -ts today 2>/dev/null | \
    grep "container-nuros-strict" || echo "No denials found")

echo "$DENIALS"

# Count denials
COUNT=$(echo "$DENIALS" | grep -c "DENIED" || echo "0")
echo ""
echo "Total denials: $COUNT"

# Exit with error if denials found
if [ "$COUNT" -gt "0" ]; then
    exit 1
fi
exit 0
```

Make executable:
```bash
chmod +x /usr/local/bin/check-apparmor-audit.sh
```

#### Continuous Monitoring Script

Create `/usr/local/bin/monitor-apparmor.sh`:

```bash
#!/bin/bash
# Real-time AppArmor monitoring

echo "🔍 Monitoring AppArmor denials in real-time..."
echo "Press Ctrl+C to stop"
echo ""

tail -f /var/log/audit/audit.log 2>/dev/null | \
    grep --line-buffered "container-nuros-strict" | \
    while read line; do
        timestamp=$(echo "$line" | grep -oP 'msg=audit\(\K[0-9.]+' | head -1)
        if [ -n "$timestamp" ]; then
            human_time=$(date -d "@${timestamp%.*}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
        fi
        echo "[$human_time] $line"
    done
```

#### Daily Audit Report

Create `/usr/local/bin/daily-audit-report.sh`:

```bash
#!/bin/bash
# Generate daily AppArmor audit report

REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="/var/log/audit/apparmor-report-${REPORT_DATE}.txt"

echo "=== AppArmor Daily Report ===" > "$REPORT_FILE"
echo "Date: $REPORT_DATE" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "--- Summary ---" >> "$REPORT_FILE"
ausearch -m apparmor_denied -ts today 2>/dev/null | \
    grep "container-nuros-strict" | \
    wc -l | xargs echo "Total denials:" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- Recent Denials ---" >> "$REPORT_FILE"
ausearch -m apparmor_denied -ts today 2>/dev/null | \
    grep "container-nuros-strict" | tail -20 >> "$REPORT_FILE"

echo "Report saved to: $REPORT_FILE"
```

Add to crontab for daily reports:
```bash
# Run daily at 23:59
59 23 * * * /usr/local/bin/daily-audit-report.sh
```

### 📋 Common Denials and Solutions

| Denial | Cause | Solution |
|--------|-------|----------|
| `dac_override` | App trying to bypass file permissions | Review app code, don't allow this capability |
| `ptrace` | App trying to debug/trace processes | Expected denial, ptrace is blocked |
| `/tmp/** ix` | App trying to execute from /tmp | Move executables to /app, /tmp is for data |
| `net_raw` | App using raw sockets (ping, etc.) | Expected, raw sockets are blocked |
| `/home/*/**` | Access to host home directories | Expected, host homes are protected |

### 🔔 Alerting Setup

#### Systemd Service for Monitoring

Create `/etc/systemd/system/apparmor-monitor.service`:

```ini
[Unit]
Description=AppArmor Container Monitoring
After=auditd.service

[Service]
Type=simple
ExecStart=/usr/local/bin/monitor-apparmor.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
```

Enable service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable apparmor-monitor
sudo systemctl start apparmor-monitor
```

### View Audit Logs

```bash
# Install auditd if not installed
sudo apt install auditd

# View AppArmor denials
sudo ausearch -m apparmor_denied

# View all container denials
sudo grep "container-nuros-strict" /var/log/audit/audit.log

# Real-time monitoring
sudo tail -f /var/log/audit/audit.log | grep container-nuros-strict
```

### Common Denials

If your application is denied access, check the logs:

```bash
# Search for recent denials
sudo ausearch -m apparmor_denied -ts recent

# Check specific denial
sudo grep "DENIED" /var/log/audit/audit.log | grep container-nuros-strict
```

### Adjusting the Profile

If you need to allow additional access:

1. Edit `/etc/apparmor.d/container-apparmor-profile-strict`
2. Reload: `sudo apparmor_parser -r /etc/apparmor.d/container-apparmor-profile-strict`
3. Test thoroughly

## Troubleshooting

### Container fails to start

```bash
# Check AppArmor status
sudo aa-status

# Check logs for denials
sudo journalctl -u docker | grep -i apparmor

# Temporarily switch to complain mode for debugging
sudo aa-complain container-nuros-strict

# Check logs again
sudo ausearch -m apparmor_denied -ts recent

# Switch back to enforce mode
sudo aa-enforce container-nuros-strict
```

### Application needs additional permissions

1. Run in complain mode to identify needed permissions:
   ```bash
   sudo aa-complain container-nuros-strict
   ```

2. Check audit logs:
   ```bash
   sudo ausearch -m apparmor_denied -ts recent
   ```

3. Edit profile to allow needed access

4. Reload and enforce:
   ```bash
   sudo apparmor_parser -r /etc/apparmor.d/container-apparmor-profile-strict
   sudo aa-enforce container-nuros-strict
   ```

## Comparison: Strict vs Default

| Feature | Default Profile | NurOS Strict |
|---------|----------------|--------------|
| Capabilities | 20+ | 7 |
| Network | All | TCP/UDP only |
| File Access | Broad | Explicit paths |
| /tmp Execute | Allowed | **Denied** |
| ptrace | Allowed | **Denied** |
| Signal | All | Same profile only |
| Mount | All | Whitelist only |
| setfcap | Allowed | **Denied** |
| setpcap | Allowed | **Denied** |

## Best Practices

1. **Always use `no-new-privileges:true`**
2. **Use read-only root filesystem** when possible
3. **Mount tmpfs** for temporary directories
4. **Monitor audit logs** regularly
5. **Test in complain mode** before production
6. **Keep profile minimal** — remove unused permissions

## References

- [AppArmor Documentation](https://apparmor.net/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Podman Security](https://docs.podman.io/en/latest/markdown/podman-run.1.html#security-configuration)

## License

MIT License — See main repository for details.
