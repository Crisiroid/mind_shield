# Psychology Backend — Server Operations Guide

## Server Paths Reference

| Item                  | Path                                    |
|-----------------------|-----------------------------------------|
| Deploy directory      | `/opt/psychology-backend`               |
| Binary                | `/opt/psychology-backend/bin/server`    |
| Environment file      | `/opt/psychology-backend/.env`          |
| Uploads directory     | `/opt/psychology-backend/uploads`       |
| Systemd service file  | `/etc/systemd/system/psychology.service`|
| PostgreSQL data       | Default (managed by PostgreSQL service) |

---

## Systemd Service Management

### Check service status
```bash
systemctl status psychology
```

### Start the service
```bash
systemctl start psychology
```

### Stop the service
```bash
systemctl stop psychology
```

### Restart the service
```bash
systemctl restart psychology
```

### Reload service (after editing .service file)
```bash
systemctl daemon-reload
systemctl restart psychology
```

### Enable service (start on boot)
```bash
systemctl enable psychology
```

### Disable service (don't start on boot)
```bash
systemctl disable psychology
```

### Check if service is active (simple check)
```bash
systemctl is-active psychology
```

---

## Viewing Logs

### Live log stream (follow mode)
```bash
journalctl -u psychology -f
```

### Last 50 log lines
```bash
journalctl -u psychology -n 50 --no-pager
```

### Last 100 log lines
```bash
journalctl -u psychology -n 100 --no-pager
```

### Logs since a specific time
```bash
journalctl -u psychology --since "2026-07-19 10:00:00"
```

### Logs between two times
```bash
journalctl -u psychology --since "2026-07-19 10:00:00" --until "2026-07-19 12:00:00"
```

### Today's logs only
```bash
journalctl -u psychology --since today
```

### Yesterday's logs only
```bash
journalctl -u psychology --since yesterday --until today
```

### All logs (no pager, full output)
```bash
journalctl -u psychology --no-pager
```

---

## The Systemd Service File

Location: `/etc/systemd/system/psychology.service`

```ini
[Unit]
Description=Psychology Backend API
After=network.target postgresql.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/psychology-backend
ExecStart=/opt/psychology-backend/bin/server
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=psychology

# Environment
EnvironmentFile=/opt/psychology-backend/.env

[Install]
WantedBy=multi-user.target
```

> **Important:** After editing this file, always run:
> ```bash
> systemctl daemon-reload
> systemctl restart psychology
> ```

---

## Editing the .env File on the Server

```bash
nano /opt/psychology-backend/.env
```

After saving changes, restart the service:
```bash
systemctl restart psychology
```

---

## Firewall (ufw) Setup

### Install ufw (if not installed)
```bash
apt update && apt install ufw -y
```

### Allow SSH (always do this first!)
```bash
ufw allow 22/tcp
```

### Allow the app port
```bash
ufw allow 8080/tcp
```

### Enable the firewall
```bash
ufw enable
```

### Check firewall status
```bash
ufw status
```

### List all rules
```bash
ufw status verbose
```

### Delete a rule (example: remove 8080)
```bash
ufw delete allow 8080/tcp
```

---

## Deployment (from Windows PowerShell)

### Using the deploy script
```powershell
cd c:\Users\Crisiroid\Desktop\KarlancerProject\Psychology\backend
.\deploy.ps1
```

### Manual cross-compile and upload
```powershell
# Step 1: Cross-compile for Linux
cd c:\Users\Crisiroid\Desktop\KarlancerProject\Psychology\backend
$env:GOOS="linux"; $env:GOARCH="amd64"; go build -o bin/server ./cmd/server

# Step 2: Upload binary
scp -P 22 bin/server root@YOUR_SERVER_IP:/opt/psychology-backend/bin/server

# Step 3: SSH into server and restart
ssh root@YOUR_SERVER_IP
chmod +x /opt/psychology-backend/bin/server
systemctl restart psychology
systemctl status psychology
```

---

## Troubleshooting

### 203/EXEC error
Binary is not a Linux executable. Re-cross-compile:
```powershell
$env:GOOS="linux"; $env:GOARCH="amd64"; go build -o bin/server ./cmd/server
```
Then re-upload and `chmod +x`.

### Service fails to start
```bash
# Check detailed error
journalctl -u psychology -n 50 --no-pager

# Check if port is already in use
ss -tlnp | grep 8080

# Check binary exists and is executable
ls -la /opt/psychology-backend/bin/server
file /opt/psychology-backend/bin/server
```

### Database connection refused
```bash
# Check PostgreSQL is running
systemctl status postgresql

# Check connection
psql -U postgres -d psychology_app -c "SELECT 1;"
```

### Check disk space
```bash
df -h
```

### Check memory usage
```bash
free -h
```

### Check running processes
```bash
ps aux | grep psychology
```

### Kill stuck process
```bash
# Find PID
ps aux | grep server

# Kill it
kill -9 <PID>

# Then restart
systemctl start psychology
```

---

## Quick Reference — Common Commands

| Action               | Command                                              |
|----------------------|------------------------------------------------------|
| Status               | `systemctl status psychology`                        |
| Start                | `systemctl start psychology`                         |
| Stop                 | `systemctl stop psychology`                          |
| Restart              | `systemctl restart psychology`                       |
| Live logs            | `journalctl -u psychology -f`                        |
| Last 50 lines        | `journalctl -u psychology -n 50 --no-pager`         |
| Edit env             | `nano /opt/psychology-backend/.env`                  |
| Edit service file    | `nano /etc/systemd/system/psychology.service`        |
| Check port           | `ss -tlnp \| grep 8080`                             |
| Firewall status      | `ufw status`                                         |
| Disk space           | `df -h`                                              |
| Memory               | `free -h`                                            |
