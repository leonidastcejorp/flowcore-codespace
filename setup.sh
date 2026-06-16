#!/bin/bash
# ============================================================================
# ═╗ ╦╦╔═╗╦═╗  ╔═╗╦═╗╔═╗╔═╗╔═╗╔═╗╦═╗╔╗╔╔═╗╦ ╦╦╔═╗╦═╗
# ╔╩╦╝║║ ╦╠╦╝  ╠═╝╠╦╝║ ║║ ╦║╣ ║ ║║║║╠═╣╚╦╝║║╣ ╠╦╝
# ╩ ╚═╩╚═╝╩╚═  ╩  ╩╚═╚═╝╚═╝╚═╝╚═╝╩ ╩╝╚╝╩ ╩ ╩ ╩╚═╝╩╚═
#
# FlowCore Codespace — One-Command Setup Script
# Supports Ubuntu 22.04 AND 24.04 (GitHub Codespaces default)
# Idempotent — safe to run multiple times
# No "set -e" — each step is handled independently
# ============================================================================

# ── Configuration ──────────────────────────────────────────────────────────
GO_VERSION="1.22.5"
NODE_VERSION="20"
NVM_VERSION="v0.39.7"
REQUIREMENTS_BASE="playwright aiohttp aiohttp-socks pyyaml requests beautifulsoup4 lxml"
LOG_FILE="/tmp/flowcore-codespace-setup-$(date +%Y%m%d-%H%M%S).log"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Tracker ───────────────────────────────────────────────────────────────
SUCCESS_STEPS=()
FAILED_STEPS=()

log()   { echo -e "$1" | tee -a "$LOG_FILE"; }
ok()    { log "  ✅ $1"; SUCCESS_STEPS+=("$1"); }
fail()  { log "  ❌ $1"; FAILED_STEPS+=("$1"); }
skip()  { log "  ⏭️  $1"; }
info()  { log "  ℹ️  $1"; }

# ── Banner ─────────────────────────────────────────────────────────────────
show_banner() {
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║       FLOWCORE CODESPACE — Environment Setup                        ║
║       Supports Ubuntu 22.04 & 24.04                                 ║
║       Idempotent — safe to re-run anytime                           ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo ""
    info "Log file: $LOG_FILE"
    echo ""
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 1: OS Detection
# ══════════════════════════════════════════════════════════════════════════
detect_os() {
    log "━━━ [1/8] OS Detection ━━━"

    local OS_VERSION="unknown"
    local OS_CODENAME="unknown"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_VERSION="$VERSION_ID"
        OS_CODENAME="$UBUNTU_CODENAME"
    elif command -v lsb_release &>/dev/null; then
        OS_VERSION=$(lsb_release -rs 2>/dev/null)
        OS_CODENAME=$(lsb_release -cs 2>/dev/null)
    fi

    info "Detected: Ubuntu ${OS_VERSION} (${OS_CODENAME})"

    if [ "$OS_VERSION" = "22.04" ] || [ "$OS_VERSION" = "24.04" ]; then
        ok "Ubuntu ${OS_VERSION} — supported"
    elif [ "$OS_VERSION" = "unknown" ]; then
        fail "Could not detect OS version"
    else
        info "Ubuntu ${OS_VERSION} — not officially tested but should work"
        ok "OS detected: Ubuntu ${OS_VERSION}"
    fi

    echo "$OS_VERSION" "$OS_CODENAME"
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 2: Pre-Flight Check
# ══════════════════════════════════════════════════════════════════════════
pre_flight_check() {
    log "━━━ [2/8] Pre-Flight Check ━━━"

    local ALL_CLEAR=true

    # ── Internet check ──
    if command -v ping &>/dev/null; then
        if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
            info "Internet: ✅ reachable"
        else
            fail "Internet: ❌ not reachable (check network)"
            ALL_CLEAR=false
        fi
    else
        # Fallback: check via curl
        if curl -s --max-time 5 https://github.com >/dev/null 2>&1; then
            info "Internet: ✅ reachable"
        else
            fail "Internet: ❌ not reachable (check network)"
            ALL_CLEAR=false
        fi
    fi

    # ── Disk space check ──
    if command -v df &>/dev/null; then
        local DISK_AVAIL
        DISK_AVAIL=$(df -m / | awk 'NR==2 {print $4}')
        info "Disk available: ${DISK_AVAIL} MB"
        if [ "$DISK_AVAIL" -lt 2048 ] 2>/dev/null; then
            fail "Disk space: ❌ only ${DISK_AVAIL} MB available (need ≥ 2GB)"
            ALL_CLEAR=false
        else
            ok "Disk space: ✅ ${DISK_AVAIL} MB available"
        fi
    fi

    # ── RAM check ──
    if command -v free &>/dev/null; then
        local RAM_AVAIL
        RAM_AVAIL=$(free -m | awk '/^Mem:/ {print $7}')
        info "RAM available: ${RAM_AVAIL} MB"
        if [ "$RAM_AVAIL" -lt 256 ] 2>/dev/null; then
            fail "RAM: ❌ only ${RAM_AVAIL} MB available (need ≥ 256 MB)"
            ALL_CLEAR=false
        else
            ok "RAM: ✅ ${RAM_AVAIL} MB available"
        fi
    fi

    # ── Apt lock check ──
    local APT_LOCKED=false
    for lock in /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock /var/lib/apt/lists/lock; do
        if [ -f "$lock" ] && fuser "$lock" &>/dev/null 2>&1; then
            APT_LOCKED=true
            break
        fi
    done
    if [ "$APT_LOCKED" = "true" ]; then
        fail "Apt lock: ❌ locked by another process"
        ALL_CLEAR=false
    else
        ok "Apt lock: ✅ not locked"
    fi

    # ── Background updates check ──
    if pgrep -x "unattended-upgrade" &>/dev/null || \
       pgrep -x "apt-get" &>/dev/null || \
       pgrep -x "dpkg" &>/dev/null || \
       pgrep -x "apt" &>/dev/null; then
        info "Background updates: ⚠️ running (may slow installs)"
    else
        ok "Background updates: ✅ not running"
    fi

    # ── Sudo check (Codespace user is often non-root) ──
    if command -v sudo &>/dev/null; then
        if sudo -n true 2>/dev/null; then
            ok "Sudo: ✅ available (passwordless)"
        else
            info "Sudo: ⚠️ password required — will prompt when needed"
        fi
    else
        fail "Sudo: ❌ not available"
        ALL_CLEAR=false
    fi

    if [ "$ALL_CLEAR" = "true" ]; then
        ok "Pre-flight: ✅ all checks passed"
    else
        fail "Pre-flight: ⚠️ some checks failed — proceeding anyway"
    fi
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 3: System Packages
# ══════════════════════════════════════════════════════════════════════════
install_system_packages() {
    log "━━━ [3/8] System Packages ━━━"

    # Detect OS version for version-specific packages
    local OS_VERSION="24.04"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_VERSION="$VERSION_ID"
    fi

    # Update package lists
    info "Updating package lists..."
    sudo apt-get update -qq 2>>"$LOG_FILE" || {
        fail "apt update failed (may be transient)"
        return 1
    }

    # Base packages
    local BASE_PKGS="python3-pip git curl wget unzip ca-certificates"

    info "Installing: ${BASE_PKGS}"
    sudo apt-get install -y -qq $BASE_PKGS 2>>"$LOG_FILE" || {
        fail "System packages installation failed"
        return 1
    }

    # Verify key packages
    local ALL_GOOD=true
    for pkg in python3 git curl wget unzip; do
        if ! command -v "$pkg" &>/dev/null; then
            fail "${pkg} not found after install"
            ALL_GOOD=false
        fi
    done

    if [ "$ALL_GOOD" = "true" ]; then
        ok "System packages installed ($(python3 --version 2>&1 | cut -d' ' -f2))"
    fi
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 4: Python Dependencies
# ══════════════════════════════════════════════════════════════════════════
install_python_deps() {
    log "━━━ [4/8] Python Dependencies ━━━"

    # Upgrade pip first
    info "Upgrading pip..."
    python3 -m pip install --upgrade pip 2>>"$LOG_FILE" || {
        fail "pip upgrade failed"
        return 1
    }

    # Install base requirements
    info "Installing: ${REQUIREMENTS_BASE}"
    python3 -m pip install $REQUIREMENTS_BASE 2>>"$LOG_FILE" || {
        fail "Python dependency installation failed"
        return 1
    }

    # Verify playwright
    if python3 -c "import playwright" 2>/dev/null; then
        ok "Python dependencies installed (playwright, aiohttp, pyyaml, etc.)"
    else
        fail "Playwright module not importable after install"
    fi
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 5: Playwright + Chromium
# ══════════════════════════════════════════════════════════════════════════
install_playwright_chromium() {
    log "━━━ [5/8] Playwright + Chromium ━━━"

    # Check if already installed
    if python3 -c "from playwright.sync_api import sync_playwright; p=sync_playwright().start(); p.chromium.launch(headless=True); p.stop()" 2>/dev/null; then
        ok "Playwright + Chromium already installed and working"
        return 0
    fi

    # Try installing playwright browsers
    info "Installing Playwright browsers..."

    # First try regular install
    if python3 -m playwright install chromium 2>>"$LOG_FILE"; then
        ok "Playwright Chromium installed"
        return 0
    fi

    # Fallback: install with system deps
    info "Trying with system dependencies..."
    if python3 -m playwright install --with-deps chromium 2>>"$LOG_FILE"; then
        ok "Playwright Chromium installed (with system deps)"
        return 0
    fi

    # Final fallback: try installing system deps then chromium separately
    info "Installing system dependencies first..."
    python3 -m playwright install-deps chromium 2>>"$LOG_FILE" || true
    if python3 -m playwright install chromium 2>>"$LOG_FILE"; then
        ok "Playwright Chromium installed (after deps)"
        return 0
    fi

    fail "Playwright Chromium installation — run manually: playwright install --with-deps chromium"
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 6: Go 1.22.5
# ══════════════════════════════════════════════════════════════════════════
install_go() {
    log "━━━ [6/8] Go ${GO_VERSION} ━━━"

    # Check if already installed with correct version
    if command -v go &>/dev/null; then
        local GO_CURRENT
        GO_CURRENT=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown")
        if [ "$GO_CURRENT" = "$GO_VERSION" ]; then
            ok "Go ${GO_VERSION} already installed"
            return 0
        fi
        info "Go ${GO_CURRENT} found — upgrading to ${GO_VERSION}"
    fi

    info "Downloading Go ${GO_VERSION}..."
    cd /tmp || { fail "Cannot cd to /tmp"; return 1; }

    local GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
    wget -q "https://golang.org/dl/${GO_TAR}" -O "${GO_TAR}" 2>>"$LOG_FILE" || {
        fail "Go download failed"
        return 1
    }

    info "Extracting Go..."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${GO_TAR}" 2>>"$LOG_FILE" || {
        fail "Go extraction failed"
        rm -f "${GO_TAR}"
        return 1
    }
    rm -f "${GO_TAR}"

    # Add to PATH if not already there
    if ! grep -q '/usr/local/go/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    fi
    export PATH="$PATH:/usr/local/go/bin"

    if command -v go &>/dev/null && go version | grep -q "go${GO_VERSION}"; then
        ok "Go ${GO_VERSION} installed"
    else
        fail "Go installation verification failed"
    fi
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 7: NVM + Node 20
# ══════════════════════════════════════════════════════════════════════════
install_node_nvm() {
    log "━━━ [7/8] Node.js ${NODE_VERSION} (via NVM) ━━━"

    # Source NVM if already available
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        . "$NVM_DIR/nvm.sh"
    fi

    # Check if Node is already installed with correct version
    if command -v node &>/dev/null; then
        local NODE_CURRENT
        NODE_CURRENT=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_CURRENT" = "${NODE_VERSION}" ]; then
            ok "Node.js v${NODE_VERSION} already installed"
            return 0
        fi
        info "Node.js v$(node --version | cut -d'v' -f2) found — installing v${NODE_VERSION}"
    fi

    # Install NVM if not present
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        info "Installing NVM ${NVM_VERSION}..."
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash 2>>"$LOG_FILE" || {
            fail "NVM installation failed"
            return 1
        }

        # Source NVM in current shell
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        else
            fail "NVM script not found after installation"
            return 1
        fi
    else
        info "NVM already installed"
    fi

    # Install Node via NVM
    info "Installing Node.js v${NODE_VERSION} (this may take a moment)..."
    nvm install "${NODE_VERSION}" 2>>"$LOG_FILE" || {
        fail "Node.js v${NODE_VERSION} installation failed"
        return 1
    }

    nvm use "${NODE_VERSION}" 2>>"$LOG_FILE" || true
    nvm alias default "${NODE_VERSION}" 2>>"$LOG_FILE" || true

    # Ensure NVM is sourced in bashrc
    if ! grep -q 'NVM_DIR' ~/.bashrc 2>/dev/null; then
        cat >> ~/.bashrc << 'EOF'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
EOF
    fi

    if command -v node &>/dev/null; then
        ok "Node.js $(node --version) installed"
    else
        fail "Node.js verification failed"
    fi
}

# ══════════════════════════════════════════════════════════════════════════
# STEP 8: Install flowcore as editable package
# ══════════════════════════════════════════════════════════════════════════
install_flowcore_package() {
    log "━━━ [8/8] FlowCore Editable Package ━━━"

    local FLOWCORE_DIR="$REPO_DIR/tools/flowcore"

    if [ ! -d "$FLOWCORE_DIR" ]; then
        fail "FlowCore directory not found at ${FLOWCORE_DIR}"
        return 1
    fi

    # Check if already installed
    if python3 -c "import flowcore; print(flowcore.__file__)" 2>/dev/null; then
        local INSTALLED_PATH
        INSTALLED_PATH=$(python3 -c "import flowcore; print(flowcore.__file__)" 2>/dev/null)
        if echo "$INSTALLED_PATH" | grep -q "$FLOWCORE_DIR"; then
            ok "FlowCore already installed as editable from tools/flowcore"
            return 0
        fi
        info "FlowCore installed from different path — reinstalling editable"
    fi

    info "Installing flowcore as editable package..."
    cd "$FLOWCORE_DIR" || { fail "Cannot cd to ${FLOWCORE_DIR}"; return 1; }
    python3 -m pip install -e . 2>>"$LOG_FILE" || {
        fail "FlowCore editable install failed"
        return 1
    }

    # Verify
    if python3 -c "import flowcore; print('flowcore imported from', flowcore.__file__)" 2>>"$LOG_FILE"; then
        ok "FlowCore installed as editable package"
        info "Package location: $FLOWCORE_DIR"
    else
        fail "FlowCore import verification failed"
    fi
}

# ══════════════════════════════════════════════════════════════════════════
# OPTIONAL: Git Hooks / Alias
# ══════════════════════════════════════════════════════════════════════════
setup_git_helpers() {
    log "━━━ [Optional] Git Config ━━━"

    # Set up a useful git alias
    if git config --global alias.ff 2>/dev/null | grep -q .; then
        info "Git alias 'ff' already configured"
    else
        git config --global alias.ff "pull --ff-only" 2>/dev/null && \
        ok "Git alias 'ff' configured (git ff = git pull --ff-only)" || \
        info "Could not set git alias"
    fi

    # Enable rerere (reuse recorded resolution) for merge conflicts
    if ! git config --global rerere.enabled 2>/dev/null | grep -q "true"; then
        git config --global rerere.enabled true 2>/dev/null && \
        ok "Git rerere enabled (auto-resolve repeated merge conflicts)" || \
        true
    fi

    info "Git config complete"
}

# ══════════════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════════════
show_summary() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║              ✅ FLOWCORE CODESPACE SETUP COMPLETE                    ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📋 Summary:"
    echo "   ✅ ${#SUCCESS_STEPS[@]} steps succeeded"
    echo "   ❌ ${#FAILED_STEPS[@]} steps failed"
    echo ""

    if [ ${#SUCCESS_STEPS[@]} -gt 0 ]; then
        echo "   Successful:"
        for s in "${SUCCESS_STEPS[@]}"; do
            echo "     ✅ $s"
        done
        echo ""
    fi

    if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
        echo "   Failed / Issues:"
        for f in "${FAILED_STEPS[@]}"; do
            echo "     ❌ $f"
        done
        echo ""
        echo "   🔧 Re-run this script to retry failed steps (it's idempotent)."
        echo ""
    fi

    echo "📝 Log file: $LOG_FILE"
    echo ""
    echo "🚀 Quick start commands:"
    echo "   python3 tools/system_monitor.py    # Check system health"
    echo "   python3 tools/pipeline.py          # Run income pipeline"
    echo "   python3 -m flowcore.modules.registrar --help  # FlowCore CLI"
    echo ""
    echo "📖 Read the full guide: cat TUTORIAL.md"
    echo ""
}

# ══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════

show_banner

# Run detection first (returns version for reference)
detect_os
echo ""

# Pre-flight check
pre_flight_check
echo ""

# Installation steps
install_system_packages
echo ""

install_python_deps
echo ""

install_playwright_chromium
echo ""

install_go
echo ""

install_node_nvm
echo ""

install_flowcore_package
echo ""

setup_git_helpers
echo ""

show_summary
