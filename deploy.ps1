<#
===============================================================================
 Psychology - One-Click Deployment Script (Windows -> Linux)
===============================================================================
 WHAT IT DOES
   1. Builds the React/Vite admin panel for production on this Windows machine.
   2. Cross-compiles the Go (Echo) backend for linux/amd64 on this machine.
   3. Packages everything (binaries + dist, excluding node_modules / .env /
      local uploads) and uploads it to your Linux server over SSH/SCP
      (password auth).
   4. On the server (Ubuntu/Debian):
        - Installs nginx, postgresql, rsync, curl, ufw, fail2ban
        - Creates a dedicated non-root system user for the app
        - Provisions a dedicated PostgreSQL role + database
        - Generates a production .env on the server (auto-generated
          JWT_SECRET + DB password, BASE_URL from your domain)
        - Installs the backend as a hardened systemd service (Go binary).
          GORM AutoMigrate runs automatically on every service start.
        - Serves the admin panel with nginx at /admin + reverse-proxies
          /api/ and /uploads/ to the Go backend (WebSocket-ready)
        - Configures the UFW firewall (SSH / 80 / 443 only) + fail2ban
   5. Verifies the deployment with health checks and prints a summary.

 USAGE
   1. Fill in the CONFIGURATION block below.
   2. Run from PowerShell:  .\deploy.ps1
      (If blocked: powershell -ExecutionPolicy Bypass -File .\deploy.ps1)

 UPDATE MODE ($IsUpdate = $true)
   Skips system package installation, user creation and firewall setup.
   Only re-uploads binary/dist, refreshes configs and restarts services.
   Server-side uploads/ and .env are always preserved.
===============================================================================
#>

# =============================================================================
#  CONFIGURATION  --  EDIT THESE VALUES
# =============================================================================
$ServerIP        = "87.248.153.76"           # <-- your Linux server IP
$Username        = "root"                     # <-- SSH username (root or sudo-capable user)
$Password        = "Nabat1371"            # <-- SSH password
$IsUpdate        = $true                     # $false = first full deploy, $true = update only

# --- Optional settings -------------------------------------------------------
$SSHPort         = 9011                       # SSH port of the server
$Domain          = ""                         # your domain (empty = serve on http://$ServerIP)
$EnableSSL       = $false                     # unused; SSL handled at CDN/DNS level
$SSLEmail        = ""                         # unused; kept for reference only

# --- Database + app config written into the server .env (first deploy) --------
# backend\.env is never uploaded, so these values are the single source of
# truth for production config. Leave a password/key empty to auto-generate it.
$DbName          = "psychology_app"
$DbUser          = "psychology_app"
$DbSchema        = "admin_panel"               # extra schema some models use (admin_users, roles, ...)
$DbPassword      = "GSDLKJG3423rewuf9wfjasd9fj289jsd9a8hg934j9rsij5938gj35"                         # letters/digits ONLY (kept out of Go env parsing headaches)
$JwtSecret       = ""                         # JWT signing key (empty = auto-generate)
$JwtExpiration   = "24h"                      # access token lifetime written to the server .env

# --- Server-side paths / names (usually no need to change) -------------------
$AppUser         = "psychology"
$AppDir          = "/opt/psychology"
$WebDir          = "/var/www/psychology-admin"
$ServiceName     = "psychology-backend"
$BackendPort     = 8080

# =============================================================================
#  INTERNALS - do not edit below unless you know what you are doing
# =============================================================================
$ErrorActionPreference = "Stop"
$ScriptRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir   = Join-Path $ScriptRoot "backend"
$AdminDir     = Join-Path $ScriptRoot "admin"
$LogFile      = Join-Path $ScriptRoot ("deploy_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$StageDir     = Join-Path $env:TEMP ("psychology_deploy_" + (Get-Date -Format "yyyyMMddHHmmss"))
$script:SSHSession = $null
$script:Credential = $null

# ----------------------------------------------------------------- logging --
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "OK", "WARN", "ERROR", "STEP", "REMOTE")]
        [string]$Level = "INFO"
    )
    $ts   = Get-Date -Format "HH:mm:ss"
    $line = "[$ts][$Level] $Message"
    switch ($Level) {
        "OK"     { Write-Host $line -ForegroundColor Green }
        "WARN"   { Write-Host $line -ForegroundColor Yellow }
        "ERROR"  { Write-Host $line -ForegroundColor Red }
        "STEP"   { Write-Host ""; Write-Host ("=" * 70) -ForegroundColor Cyan; Write-Host $line -ForegroundColor Cyan; Write-Host ("=" * 70) -ForegroundColor Cyan }
        "REMOTE" { Write-Host $line -ForegroundColor DarkGray }
        default  { Write-Host $line }
    }
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Fail {
    param([string]$Message)
    Write-Log $Message "ERROR"
    Write-Log "Deployment FAILED. Full log: $LogFile" "ERROR"
    Cleanup
    exit 1
}

function Cleanup {
    if ($script:SSHSession) {
        try { Remove-SSHSession -SSHSession $script:SSHSession | Out-Null } catch {}
        $script:SSHSession = $null
    }
    if (Test-Path $StageDir) {
        try { Remove-Item -Recurse -Force $StageDir -ErrorAction SilentlyContinue } catch {}
    }
}

# ------------------------------------------------------------- remote exec --
function Get-SudoPrefix {
    if ($Username -eq "root") { return "" }
    $escaped = $Password.Replace("'", "'\''")
    return "printf '%s\n' '$escaped' | sudo -S -p '' "
}

function Invoke-Remote {
    param(
        [string]$Command,
        [string]$Description,
        [int]$TimeoutSec = 1800,
        [switch]$AllowFail
    )
    if ($Description) { Write-Log $Description "INFO" }
    $result = Invoke-SSHCommand -SSHSession $script:SSHSession -Command $Command -TimeOut $TimeoutSec
    foreach ($l in @($result.Output)) {
        if ($null -ne $l -and "$l".Trim().Length -gt 0) { Write-Log "  | $l" "REMOTE" }
    }
    foreach ($l in @($result.Error)) {
        if ($null -ne $l -and "$l".Trim().Length -gt 0) { Write-Log "  ! $l" "REMOTE" }
    }
    if ($result.ExitStatus -ne 0 -and -not $AllowFail) {
        Fail "Remote command failed (exit $($result.ExitStatus)): $Description"
    }
    return $result
}

function Invoke-RemotePhase {
    param([string]$Phase, [string]$Description)
    $sudo = Get-SudoPrefix
    Invoke-Remote -Command "${sudo}bash /tmp/psychology_deploy.sh $Phase" -Description $Description | Out-Null
    Write-Log "Phase '$Phase' completed." "OK"
}

function Send-File {
    param([string]$LocalPath, [string]$RemoteDir)
    $name = Split-Path -Leaf $LocalPath
    $size = "{0:N1} MB" -f ((Get-Item $LocalPath).Length / 1MB)
    Write-Log "Uploading $name ($size) -> ${RemoteDir}/ ..." "INFO"
    Set-SCPItem -ComputerName $ServerIP -Port $SSHPort -Credential $script:Credential `
                -Path $LocalPath -Destination $RemoteDir -AcceptKey -ErrorAction Stop
    Write-Log "Uploaded $name" "OK"
}

# =============================================================================
#  STEP 0 - PRE-FLIGHT CHECKS
# =============================================================================
Write-Log "Psychology deployment started (IsUpdate = $IsUpdate)" "STEP"
Write-Log "Log file: $LogFile"

if ($ServerIP -eq "YOUR_SERVER_IP" -or [string]::IsNullOrWhiteSpace($ServerIP)) {
    Fail "Please set `$ServerIP at the top of the script."
}
if ([string]::IsNullOrWhiteSpace($Username) -or $Password -eq "YOUR_PASSWORD" -or [string]::IsNullOrWhiteSpace($Password)) {
    Fail "Please set `$Username and `$Password at the top of the script."
}
if (-not (Test-Path (Join-Path $BackendDir "go.mod")))                    { Fail "backend\go.mod not found - run this script from the project root." }
if (-not (Test-Path (Join-Path $BackendDir "cmd\server\main.go")))        { Fail "backend\cmd\server\main.go not found - run this script from the project root." }
if (-not (Test-Path (Join-Path $AdminDir "package.json")))                { Fail "admin\package.json not found - run this script from the project root." }
if ($DbPassword -and $DbPassword -notmatch '^[A-Za-z0-9]+$') {
    Fail "`$DbPassword may only contain letters and digits to stay safe inside the generated .env and shell heredocs."
}
if ($DbSchema -and $DbSchema -notmatch '^[a-z_][a-z0-9_]*$') {
    Fail "`$DbSchema must be a plain PostgreSQL identifier (lowercase letters, digits, underscores)."
}

# --- credentials for the generated server .env (auto-generated when not set) --
function New-RandomSecret {
    param([int]$Length)
    -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $Length | ForEach-Object { [char]$_ })
}
$SecretsGenerated = $false
if ([string]::IsNullOrWhiteSpace($DbPassword)) { $DbPassword = New-RandomSecret 24; $SecretsGenerated = $true }
if ([string]::IsNullOrWhiteSpace($JwtSecret))  { $JwtSecret  = New-RandomSecret 48; $SecretsGenerated = $true }

# Public base the backend uses to build media URLs
# (SSL is handled at the CDN/DNS level - the origin server only listens on HTTP)
$PublicBase = if ($Domain) { "https://$Domain" } else { "http://$ServerIP" }

# --- tools on Windows ---
Write-Log "Checking local tools (go, node, npm, tar)..." "INFO"
if (-not (Get-Command go -ErrorAction SilentlyContinue))   { Fail "Go toolchain not found in PATH. Install Go 1.24+ and try again." }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Fail "Node.js not found in PATH. Install Node.js 18+ and try again." }
if (-not (Get-Command npm -ErrorAction SilentlyContinue))  { Fail "npm not found in PATH. Install Node.js 18+ (it ships with npm) and try again." }
if (-not (Get-Command tar -ErrorAction SilentlyContinue))  { Fail "'tar' not found. It ships with Windows 10 1803+ - please update Windows." }
Write-Log "go + node + npm + tar found." "OK"

# --- Posh-SSH module (auto-install) ---
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Write-Log "Posh-SSH module not found - installing (one time only)..." "WARN"
    try {
        if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
        }
        Install-Module -Name Posh-SSH -Scope CurrentUser -Force -AllowClobber
        Write-Log "Posh-SSH installed." "OK"
    } catch {
        Fail "Could not auto-install Posh-SSH: $($_.Exception.Message). Install manually: Install-Module Posh-SSH -Scope CurrentUser"
    }
}
Import-Module Posh-SSH
Write-Log "Posh-SSH module loaded." "OK"

# --- server reachability ---
Write-Log "Checking that $ServerIP is reachable on port $SSHPort..." "INFO"
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $async = $tcp.BeginConnect($ServerIP, $SSHPort, $null, $null)
    if (-not $async.AsyncWaitHandle.WaitOne(8000)) { throw "timeout" }
    $tcp.EndConnect($async); $tcp.Close()
    Write-Log "Server is reachable." "OK"
} catch {
    Fail "Cannot reach ${ServerIP}:${SSHPort} - check IP / firewall / VPN."
}

# =============================================================================
#  STEP 1 - BUILD ARTIFACTS ON WINDOWS
# =============================================================================
Write-Log "STEP 1/6 - Building admin panel (Vite) + backend (Go, linux/amd64)" "STEP"

Push-Location $AdminDir
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
try {
    if (Test-Path (Join-Path $AdminDir "package-lock.json")) {
        Write-Log "Running 'npm ci'..." "INFO"
        & npm ci 2>&1 | ForEach-Object { $m = if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" }; Write-Log "  | $m" "REMOTE" }
        if ($LASTEXITCODE -ne 0) { Fail "'npm ci' failed (exit $LASTEXITCODE)." }
    } else {
        Write-Log "Running 'npm install'..." "INFO"
        & npm install 2>&1 | ForEach-Object { $m = if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" }; Write-Log "  | $m" "REMOTE" }
        if ($LASTEXITCODE -ne 0) { Fail "'npm install' failed (exit $LASTEXITCODE)." }
    }

    Write-Log "Running 'npm run build'..." "INFO"
    & npm run build 2>&1 | ForEach-Object { $m = if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" }; Write-Log "  | $m" "REMOTE" }
    if ($LASTEXITCODE -ne 0) { Fail "'npm run build' failed (exit $LASTEXITCODE)." }
} finally {
    $ErrorActionPreference = $prevEAP
    Pop-Location
}

$AdminBuildDir = Join-Path $AdminDir "dist"
if (-not (Test-Path (Join-Path $AdminBuildDir "index.html"))) { Fail "Admin build output missing (admin\dist\index.html not found)." }

$IndexHtml = Get-Content -Raw (Join-Path $AdminBuildDir "index.html")
if ($IndexHtml -notmatch '/admin/assets/') {
    Fail "admin\dist\index.html does not reference /admin/assets/ - the Vite 'base' setting is missing or wrong, so nginx would serve the panel with 404 CSS/JS."
}
Write-Log "Admin panel built successfully (assets are rooted at /admin/)." "OK"

New-Item -ItemType Directory -Path $StageDir -Force | Out-Null

Push-Location $BackendDir
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    Write-Log "Cross-compiling Go backend for linux/amd64 (this can take a few minutes)..." "INFO"
    $env:GOOS = "linux"; $env:GOARCH = "amd64"; $env:CGO_ENABLED = "0"
    & go build -o (Join-Path $StageDir "server") ./cmd/server 2>&1 | ForEach-Object { $m = if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" }; Write-Log "  | $m" "REMOTE" }
    if ($LASTEXITCODE -ne 0) { Fail "Go build failed (exit $LASTEXITCODE)." }
} finally {
    Remove-Item Env:GOOS, Env:GOARCH, Env:CGO_ENABLED -ErrorAction SilentlyContinue
    $ErrorActionPreference = $prevEAP
    Pop-Location
}
if (-not (Test-Path (Join-Path $StageDir "server"))) { Fail "Backend binary was not produced (server not found in staging dir)." }
Write-Log "Backend binary built successfully." "OK"

# =============================================================================
#  STEP 2 - PACKAGE EVERYTHING
# =============================================================================
Write-Log "STEP 2/6 - Packaging artifacts" "STEP"

$BackendStage = Join-Path $StageDir "backend"
New-Item -ItemType Directory -Path $BackendStage -Force | Out-Null

Write-Log "Staging backend (binary + go.mod/go.sum + .env.example, excluding .env/uploads)..." "INFO"
Copy-Item (Join-Path $StageDir "server") (Join-Path $BackendStage "server")
foreach ($f in @("go.mod", "go.sum", ".env.example")) {
    $src = Join-Path $BackendDir $f
    if (Test-Path $src) { Copy-Item $src (Join-Path $BackendStage $f) }
}

$BackendTar = Join-Path $StageDir "psychology_backend_dist.tar.gz"
$AdminTar   = Join-Path $StageDir "psychology_admin_dist.tar.gz"

Write-Log "Creating backend archive..." "INFO"
& tar -czf $BackendTar -C $BackendStage .
if ($LASTEXITCODE -ne 0) { Fail "tar failed for backend archive." }

Write-Log "Creating admin panel archive..." "INFO"
& tar -czf $AdminTar -C $AdminBuildDir .
if ($LASTEXITCODE -ne 0) { Fail "tar failed for admin archive." }

Write-Log "All artifacts packaged." "OK"

# =============================================================================
#  STEP 3 - GENERATE THE SERVER-SIDE DEPLOY SCRIPT
# =============================================================================
Write-Log "STEP 3/6 - Generating server-side deploy script" "STEP"

$BashTemplate = @'
#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

PHASE="${1:-all}"
APP_DIR="__APP_DIR__"
WEB_DIR="__WEB_DIR__"
APP_USER="__APP_USER__"
SERVICE_NAME="__SERVICE_NAME__"
BACKEND_PORT="__BACKEND_PORT__"
IS_UPDATE="__IS_UPDATE__"
DOMAIN="__DOMAIN__"
SSH_PORT="__SSH_PORT__"
DB_NAME="__DB_NAME__"
DB_USER="__DB_USER__"
DB_PASSWORD="__DB_PASSWORD__"
DB_SCHEMA="__DB_SCHEMA__"
JWT_SECRET="__JWT_SECRET__"
JWT_EXPIRATION="__JWT_EXPIRATION__"
PUBLIC_BASE="__PUBLIC_BASE__"
SERVER_NAME="${DOMAIN:-_}"

log() { echo "[remote][$PHASE] $*"; }

if ! command -v apt-get >/dev/null 2>&1; then
    log "ERROR: this script supports Debian/Ubuntu servers (apt-get not found)."
    exit 1
fi

run_as_postgres() {
    if [ "$(id -u)" -eq 0 ]; then
        su postgres -c "$1"
    else
        sudo -u postgres bash -c "$1"
    fi
}

bootstrap_database() {
    log "Ensuring PostgreSQL server is installed and running..."
    if ! command -v psql >/dev/null 2>&1; then
        apt-get update -y -qq
        apt-get install -y -qq postgresql postgresql-contrib >/dev/null
    fi
    systemctl enable --now postgresql >/dev/null 2>&1 || service postgresql start >/dev/null 2>&1 || true
    ready=0
    for i in 1 2 3 4 5 6 7 8 9 10; do
        if pg_isready -q -h 127.0.0.1 -p 5432; then ready=1; break; fi
        sleep 2
    done
    [ "$ready" = "1" ] || { log "ERROR: PostgreSQL did not become ready on 127.0.0.1:5432."; exit 1; }

    role_exists=$(run_as_postgres "psql -At -c \"SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'\"" 2>/dev/null || true)
    if [ -z "$role_exists" ]; then
        run_as_postgres "psql -v ON_ERROR_STOP=1 -c \"CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}'\"" >/dev/null
        log "PostgreSQL role '${DB_USER}' created."
    elif [ "$SYNC_DB_PASSWORD" = "true" ]; then
        run_as_postgres "psql -v ON_ERROR_STOP=1 -c \"ALTER ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}'\"" >/dev/null
        log "PostgreSQL role '${DB_USER}' password synced to the generated .env."
    else
        log "PostgreSQL role '${DB_USER}' already exists - keeping its current password (existing .env preserved)."
    fi

    db_exists=$(run_as_postgres "psql -At -c \"SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'\"" 2>/dev/null || true)
    if [ -z "$db_exists" ]; then
        run_as_postgres "psql -v ON_ERROR_STOP=1 -c \"CREATE DATABASE ${DB_NAME} OWNER ${DB_USER}\"" >/dev/null
        log "Database '${DB_NAME}' created."
    else
        log "Database '${DB_NAME}' already exists."
    fi
    run_as_postgres "psql -v ON_ERROR_STOP=1 -d ${DB_NAME} -c \"ALTER SCHEMA public OWNER TO ${DB_USER}\"" >/dev/null 2>&1 || true
    run_as_postgres "psql -v ON_ERROR_STOP=1 -d ${DB_NAME} -c \"GRANT ALL ON SCHEMA public TO ${DB_USER}\"" >/dev/null
    if [ -n "$DB_SCHEMA" ]; then
        run_as_postgres "psql -v ON_ERROR_STOP=1 -d ${DB_NAME} -c \"GRANT CREATE ON DATABASE ${DB_NAME} TO ${DB_USER}\"" >/dev/null
        run_as_postgres "psql -v ON_ERROR_STOP=1 -d ${DB_NAME} -c \"CREATE SCHEMA IF NOT EXISTS ${DB_SCHEMA} AUTHORIZATION ${DB_USER}\"" >/dev/null
        log "Schema '${DB_SCHEMA}' provisioned for role '${DB_USER}'."
    fi
    log "Database '${DB_NAME}' provisioned for role '${DB_USER}'."
}

prepare_env_file() {
    if [ -f "$APP_DIR/backend/.env" ]; then
        log "Existing server-side .env preserved (dev .env is never uploaded)."
        sync_base_url_env
        return 0
    fi
    log "Generating production .env (dev .env was excluded from upload)..."
    mkdir -p "$APP_DIR/backend"
    cat > "$APP_DIR/backend/.env" <<EOF
APP_PORT=${BACKEND_PORT}
APP_ENV=production
DB_HOST=localhost
DB_PORT=5432
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_SSLMODE=disable
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRATION=${JWT_EXPIRATION}
UPLOAD_DIR=./uploads
BASE_URL=${PUBLIC_BASE}
EOF
    chmod 600 "$APP_DIR/backend/.env"
    log "Production .env written (chmod 600)."
}

# Keep BASE_URL in an already existing server .env in sync with this script,
# so domain changes reach production media URLs on every update deploy.
sync_base_url_env() {
    local env_file="$APP_DIR/backend/.env"
    if grep -q "^BASE_URL=" "$env_file"; then
        sed -i "s|^BASE_URL=.*|BASE_URL=${PUBLIC_BASE}|" "$env_file"
    else
        echo "BASE_URL=${PUBLIC_BASE}" >> "$env_file"
    fi
    log "Synced BASE_URL into the server .env."
}

phase_system() {
    log "Updating apt package index..."
    apt-get update -y -qq
    log "Installing required system packages (nginx, rsync, curl, ufw, fail2ban, postgresql client...)..."
    apt-get install -y -qq nginx rsync curl ufw fail2ban postgresql postgresql-contrib >/dev/null
    log "System packages installed."
    if ! id -u "$APP_USER" >/dev/null 2>&1; then
        log "Creating dedicated system user '$APP_USER' (no login shell)..."
        useradd --system --create-home --shell /usr/sbin/nologin "$APP_USER"
    else
        log "System user '$APP_USER' already exists."
    fi
}

phase_backend() {
    command -v rsync >/dev/null 2>&1 || apt-get install -y -qq rsync >/dev/null
    log "Extracting backend archive..."
    rm -rf /tmp/psychology_backend_new && mkdir -p /tmp/psychology_backend_new
    tar -xzf /tmp/psychology_backend_dist.tar.gz -C /tmp/psychology_backend_new
    mkdir -p "$APP_DIR/backend"
    log "Syncing backend into $APP_DIR/backend (uploads & .env preserved)..."
    rsync -a --delete --exclude 'uploads' --exclude '.env' /tmp/psychology_backend_new/ "$APP_DIR/backend/"
    mkdir -p "$APP_DIR/backend/uploads/weekly-media"
    if [ "$IS_UPDATE" = "false" ] && [ -f "$APP_DIR/backend/.env" ]; then
        log "Full deploy mode: removing old .env to force regeneration..."
        rm -f "$APP_DIR/backend/.env"
    fi
    if [ -f "$APP_DIR/backend/.env" ]; then
        SYNC_DB_PASSWORD=false
    else
        SYNC_DB_PASSWORD=true
    fi
    bootstrap_database
    prepare_env_file
    log "Setting ownership and secret-file permissions..."
    chmod +x "$APP_DIR/backend/server"
    chown -R "$APP_USER:$APP_USER" "$APP_DIR"
    chmod 600 "$APP_DIR/backend/.env" || true
    log "Backend deployed (schema migrations run automatically via GORM on service start)."
}

phase_admin() {
    log "Extracting admin panel archive..."
    rm -rf /tmp/psychology_admin_new && mkdir -p /tmp/psychology_admin_new
    tar -xzf /tmp/psychology_admin_dist.tar.gz -C /tmp/psychology_admin_new
    mkdir -p "$WEB_DIR"
    log "Syncing admin panel into $WEB_DIR..."
    rsync -a --delete /tmp/psychology_admin_new/ "$WEB_DIR/"
    chown -R www-data:www-data "$WEB_DIR"
    chmod -R a+rX "$WEB_DIR"
    log "Admin panel deployed."
}

phase_config() {
    log "Writing systemd service ($SERVICE_NAME)..."
    cat > /etc/systemd/system/${SERVICE_NAME}.service <<EOF
[Unit]
Description=Psychology Go backend (Echo)
After=network.target postgresql.service

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}/backend
ExecStart=${APP_DIR}/backend/server
Restart=always
RestartSec=5
EnvironmentFile=-${APP_DIR}/backend/.env
Environment=PYTHONUNBUFFERED=1
Environment=LANG=C.UTF-8
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full

[Install]
WantedBy=multi-user.target
EOF

    log "Writing nginx websocket map..."
    cat > /etc/nginx/conf.d/psychology_websocket_map.conf <<EOF
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}
EOF

    log "Writing nginx site config..."
    cat > /etc/nginx/sites-available/psychology <<EOF
server {
    listen 80;
    server_name ${SERVER_NAME};

    server_tokens off;
    client_max_body_size 120m;

    gzip off;

    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;

    location /admin/ {
        alias ${WEB_DIR}/;
        index index.html;
        try_files \$uri \$uri/ /admin/index.html;
    }

    location = /admin {
        return 301 /admin/;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:${BACKEND_PORT}/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$http_x_forwarded_proto;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_buffering off;
    }

    location /uploads/ {
        alias ${APP_DIR}/backend/uploads/;
        add_header Cache-Control "public, max-age=86400";
    }

    location = /health {
        proxy_pass http://127.0.0.1:${BACKEND_PORT}/health;
    }

    location = / {
        return 301 /admin/;
    }
}
EOF
    ln -sf /etc/nginx/sites-available/psychology /etc/nginx/sites-enabled/psychology
    rm -f /etc/nginx/sites-enabled/default
    log "Testing nginx configuration..."
    nginx -t
    log "Configuration written."
}

phase_security() {
    log "Configuring UFW firewall (allow SSH:${SSH_PORT}, 80, 443)..."
    ufw allow "${SSH_PORT}/tcp"  >/dev/null
    ufw allow 80/tcp             >/dev/null
    ufw allow 443/tcp            >/dev/null
    ufw --force enable           >/dev/null
    ufw status | while read -r l; do log "  ufw: $l"; done
    log "Enabling fail2ban (SSH brute-force protection)..."
    systemctl enable --now fail2ban >/dev/null 2>&1 || log "WARNING: fail2ban could not be started."
    log "Security phase done."
}

phase_start() {
    log "Reloading systemd + (re)starting backend service..."
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME" >/dev/null 2>&1 || true
    systemctl restart "$SERVICE_NAME"
    log "Restarting nginx..."
    systemctl enable nginx >/dev/null 2>&1 || true
    systemctl restart nginx
    log "Waiting for backend to come up (first start also runs GORM AutoMigrate)..."
    ok=0
    for i in $(seq 1 30); do
        sleep 2
        if curl -fsS "http://127.0.0.1:${BACKEND_PORT}/health" >/dev/null 2>&1; then ok=1; break; fi
    done
    if [ "$ok" = "1" ]; then
        log "Backend health check PASSED (http://127.0.0.1:${BACKEND_PORT}/health)."
    else
        log "ERROR: backend health check FAILED. Last service logs:"
        journalctl -u "$SERVICE_NAME" -n 40 --no-pager | while read -r l; do log "  $l"; done
        exit 1
    fi
    systemctl is-active --quiet nginx && log "nginx is active." || { log "ERROR: nginx is not active"; exit 1; }
    log "All services are running."
}

phase_cleanup() {
    log "Cleaning up temporary files on server..."
    rm -rf /tmp/psychology_backend_new /tmp/psychology_admin_new
    rm -f /tmp/psychology_backend_dist.tar.gz /tmp/psychology_admin_dist.tar.gz /tmp/psychology_deploy.sh
    log "Cleanup done."
}

case "$PHASE" in
    system)   phase_system ;;
    backend)  phase_backend ;;
    admin)    phase_admin ;;
    config)   phase_config ;;
    security) phase_security ;;
    start)    phase_start ;;
    cleanup)  phase_cleanup ;;
    *) log "Unknown phase: $PHASE"; exit 1 ;;
esac
'@

$Bash = $BashTemplate.Replace("__APP_DIR__", $AppDir).
                      Replace("__WEB_DIR__", $WebDir).
                      Replace("__APP_USER__", $AppUser).
                      Replace("__SERVICE_NAME__", $ServiceName).
                      Replace("__BACKEND_PORT__", "$BackendPort").
                      Replace("__IS_UPDATE__", $IsUpdate.ToString().ToLower()).
                      Replace("__DOMAIN__", $Domain).
                      Replace("__SSH_PORT__", "$SSHPort").
                      Replace("__DB_NAME__", $DbName).
                      Replace("__DB_USER__", $DbUser).
                      Replace("__DB_PASSWORD__", $DbPassword).
                      Replace("__DB_SCHEMA__", $DbSchema).
                      Replace("__JWT_SECRET__", $JwtSecret).
                      Replace("__JWT_EXPIRATION__", $JwtExpiration).
                      Replace("__PUBLIC_BASE__", $PublicBase)
$Bash = $Bash -replace "`r`n", "`n"

$BashPath = Join-Path $StageDir "psychology_deploy.sh"
[System.IO.File]::WriteAllText($BashPath, $Bash, (New-Object System.Text.UTF8Encoding($false)))
Write-Log "Server script generated ($BashPath)." "OK"

# =============================================================================
#  STEP 4 - CONNECT + UPLOAD
# =============================================================================
Write-Log "STEP 4/6 - Connecting to server and uploading artifacts" "STEP"

$SecurePass = ConvertTo-SecureString $Password -AsPlainText -Force
$script:Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePass)

try { Get-SSHSession | Remove-SSHSession | Out-Null } catch {}
Write-Log "Opening SSH session to $Username@${ServerIP}:${SSHPort}..." "INFO"
try {
    $script:SSHSession = New-SSHSession -ComputerName $ServerIP -Port $SSHPort -Credential $script:Credential -AcceptKey -ConnectionTimeout 30 -ErrorAction Stop
} catch {
    Fail "SSH connection failed: $($_.Exception.Message)"
}
Write-Log "SSH session established." "OK"

# sanity: sudo available for non-root users
if ($Username -ne "root") {
    $r = Invoke-Remote -Command "command -v sudo" -Description "Verifying sudo is available for non-root user..." -AllowFail
    if ($r.ExitStatus -ne 0) { Fail "User '$Username' is not root and 'sudo' is not installed on the server." }
}

Send-File -LocalPath $BackendTar -RemoteDir "/tmp"
Send-File -LocalPath $AdminTar   -RemoteDir "/tmp"
Send-File -LocalPath $BashPath   -RemoteDir "/tmp"
Invoke-Remote -Command "chmod 700 /tmp/psychology_deploy.sh" -Description "Marking server script executable (owner-only; contains generated secrets)..." | Out-Null

# =============================================================================
#  STEP 5 - RUN SERVER-SIDE PHASES
# =============================================================================
Write-Log "STEP 5/6 - Running server-side deployment" "STEP"

if (-not $IsUpdate) {
    Invoke-RemotePhase -Phase "system"   -Description "Phase 1/6: installing system packages + creating app user..."
} else {
    Write-Log "Update mode: skipping system package installation." "WARN"
}
Invoke-RemotePhase -Phase "backend"      -Description "Phase 2/6: deploying backend (binary + database provisioning)..."
Invoke-RemotePhase -Phase "admin"        -Description "Phase 3/6: deploying admin panel..."
Invoke-RemotePhase -Phase "config"       -Description "Phase 4/6: writing systemd + nginx configuration..."
if (-not $IsUpdate) {
    Invoke-RemotePhase -Phase "security" -Description "Phase 5/6: firewall (ufw) + fail2ban..."
} else {
    Write-Log "Update mode: skipping firewall/security setup." "WARN"
}
Invoke-RemotePhase -Phase "start"        -Description "Phase 6/6: starting services + health check..."
Invoke-RemotePhase -Phase "cleanup"      -Description "Cleaning up temporary files on the server..."

# =============================================================================
#  STEP 6 - FINAL VERIFICATION FROM WINDOWS
# =============================================================================
Write-Log "STEP 6/6 - Final verification from this machine" "STEP"

try {
    $resp = Invoke-WebRequest -Uri "$PublicBase/health" -UseBasicParsing -TimeoutSec 20
    Write-Log "External health check PASSED: $PublicBase/health -> $($resp.StatusCode) $($resp.Content.Length) bytes" "OK"
} catch {
    Write-Log "External health check failed: $($_.Exception.Message)" "WARN"
    Write-Log "The server may still be fine - check firewall/DNS, or test $PublicBase/health in a browser." "WARN"
}

try {
    $resp = Invoke-WebRequest -Uri "$PublicBase/admin/" -UseBasicParsing -TimeoutSec 20
    if ($resp.StatusCode -eq 200) { Write-Log "Admin panel is being served: $PublicBase/admin/ -> 200 OK" "OK" }
} catch {
    Write-Log "Admin panel check failed: $($_.Exception.Message)" "WARN"
}

Cleanup
Write-Log "DEPLOYMENT FINISHED" "STEP"
Write-Log "Admin panel : $PublicBase/admin/" "OK"
Write-Log "API         : $PublicBase/api/v1" "OK"
Write-Log "Health      : $PublicBase/health" "OK"
Write-Log "Media       : $PublicBase/api/v1/media/weekly/* (served through nginx /uploads/ alias)" "OK"
Write-Log "Database    : PostgreSQL $DbName / role $DbUser on 127.0.0.1:5432 (password in $AppDir/backend/.env)" "OK"
Write-Log "Server .env : $AppDir/backend/.env (generated on first deploy; chmod 600)" "INFO"
Write-Log "Backend svc : systemctl status $ServiceName   (on the server)" "INFO"
Write-Log "Backend log : journalctl -u $ServiceName -f   (on the server)" "INFO"
Write-Log "Full deploy log saved to: $LogFile" "INFO"
if ($SecretsGenerated) {
    Write-Log "Generated DB password and JWT secret were written only to the server .env (never logged)." "WARN"
    Write-Log "To view them: ssh -p $SSHPort $Username@$ServerIP 'cat $AppDir/backend/.env'" "WARN"
}
exit 0
