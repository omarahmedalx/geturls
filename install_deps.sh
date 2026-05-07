#!/bin/bash
# =============================================================================
#  geturls — Dependency Installer
#  Created by Omar_ahmed
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[*]${RESET} $1"; }
success() { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "${RED}[✘]${RESET} $1"; }
section() { echo -e "\n${WHITE}${BOLD}══ $1 ══${RESET}\n"; }

# ── Root check ────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    error "Please run as root: sudo bash install_deps.sh"
    exit 1
fi

echo -e "${CYAN}"
echo "  Installing geturls dependencies..."
echo "  Created by Omar_ahmed"
echo -e "${RESET}"

# ── Update system ─────────────────────────────────────────────
section "Updating package lists"
apt-get update -qq

# ── Go language (needed for many tools) ───────────────────────
section "Go Language"
if ! command -v go &>/dev/null; then
    info "Installing Go..."
    apt-get install -y golang-go 2>/dev/null || {
        # Download latest Go manually
        GO_VER="1.22.3"
        wget -q "https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
        rm -rf /usr/local/go
        tar -C /usr/local -xzf /tmp/go.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> /etc/profile
        export PATH=$PATH:/usr/local/go/bin
    }
    success "Go installed"
else
    success "Go already installed: $(go version)"
fi

# Make sure Go bin is in PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

# ── APT packages ──────────────────────────────────────────────
section "APT Packages"
APT_PKGS=(
    "nmap"
    "curl"
    "wget"
    "git"
    "python3"
    "python3-pip"
    "dnsutils"
    "masscan"
    "seclists"
    "dirb"
    "dirbuster"
    "gobuster"
    "nikto"
    "whatweb"
    "whois"
    "jq"
)

for pkg in "${APT_PKGS[@]}"; do
    if dpkg -l "$pkg" &>/dev/null; then
        success "${pkg} already installed"
    else
        info "Installing ${pkg}..."
        apt-get install -y "$pkg" -qq && success "${pkg} installed" || warn "${pkg} failed to install"
    fi
done

# ── Go tools ──────────────────────────────────────────────────
section "Go-based Recon Tools"

install_go_tool() {
    local name=$1
    local pkg=$2
    if command -v "$name" &>/dev/null; then
        success "${name} already installed"
    else
        info "Installing ${name}..."
        GOPATH=$HOME/go go install "${pkg}@latest" 2>/dev/null \
            && success "${name} installed" \
            || warn "${name} failed to install"
        # Copy to /usr/local/bin for system-wide access
        [ -f "$HOME/go/bin/${name}" ] && cp "$HOME/go/bin/${name}" /usr/local/bin/ 2>/dev/null
    fi
}

install_go_tool "subfinder"    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
install_go_tool "httpx"        "github.com/projectdiscovery/httpx/cmd/httpx"
install_go_tool "dnsx"         "github.com/projectdiscovery/dnsx/cmd/dnsx"
install_go_tool "amass"        "github.com/owasp-amass/amass/v4/..."
install_go_tool "assetfinder"  "github.com/tomnomnom/assetfinder"
install_go_tool "anew"         "github.com/tomnomnom/anew"
install_go_tool "waybackurls"  "github.com/tomnomnom/waybackurls"
install_go_tool "gau"          "github.com/lc/gau/v2/cmd/gau"
install_go_tool "hakrawler"    "github.com/hakluke/hakrawler"
install_go_tool "shuffledns"   "github.com/projectdiscovery/shuffledns/cmd/shuffledns"
install_go_tool "chaos"        "github.com/projectdiscovery/chaos-client/cmd/chaos"
install_go_tool "ffuf"         "github.com/ffuf/ffuf/v2"
install_go_tool "feroxbuster"  "github.com/epi052/feroxbuster"   # note: Rust binary usually
install_go_tool "puredns"      "github.com/d3mondev/puredns/v2"
install_go_tool "github-subdomains" "github.com/gwen001/github-subdomains"

# ── feroxbuster (Rust binary) ─────────────────────────────────
section "feroxbuster (Rust)"
if ! command -v feroxbuster &>/dev/null; then
    info "Installing feroxbuster via curl installer..."
    curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh \
        | bash -s /usr/local/bin 2>/dev/null \
        && success "feroxbuster installed" \
        || warn "feroxbuster install failed, use: sudo apt install feroxbuster"
fi

# ── findomain ─────────────────────────────────────────────────
section "findomain"
if ! command -v findomain &>/dev/null; then
    info "Installing findomain..."
    FINDOMAIN_URL="https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux-i386.zip"
    wget -q "$FINDOMAIN_URL" -O /tmp/findomain.zip \
        && unzip -q /tmp/findomain.zip -d /tmp/findomain_bin \
        && chmod +x /tmp/findomain_bin/findomain \
        && mv /tmp/findomain_bin/findomain /usr/local/bin/ \
        && success "findomain installed" \
        || warn "findomain install failed"
fi

# ── sublist3r ─────────────────────────────────────────────────
section "sublist3r"
if ! command -v sublist3r &>/dev/null; then
    info "Installing sublist3r..."
    pip3 install sublist3r --quiet 2>/dev/null \
        && success "sublist3r installed" \
        || warn "sublist3r install failed"
fi

# ── dirsearch ─────────────────────────────────────────────────
section "dirsearch"
if ! command -v dirsearch &>/dev/null; then
    info "Installing dirsearch..."
    pip3 install dirsearch --quiet 2>/dev/null \
        && success "dirsearch installed" \
        || {
            git clone --quiet https://github.com/maurosoria/dirsearch /opt/dirsearch 2>/dev/null
            ln -sf /opt/dirsearch/dirsearch.py /usr/local/bin/dirsearch
            success "dirsearch cloned to /opt/dirsearch"
        }
fi

# ── massdns ───────────────────────────────────────────────────
section "massdns"
if ! command -v massdns &>/dev/null; then
    info "Installing massdns..."
    git clone --quiet https://github.com/blechschmidt/massdns /tmp/massdns 2>/dev/null \
        && cd /tmp/massdns \
        && make -s \
        && cp bin/massdns /usr/local/bin/ \
        && cd - >/dev/null \
        && success "massdns installed" \
        || warn "massdns install failed"
fi

# ── theHarvester ──────────────────────────────────────────────
section "theHarvester"
if ! command -v theHarvester &>/dev/null; then
    info "Installing theHarvester..."
    apt-get install -y theharvester -qq 2>/dev/null \
        && success "theHarvester installed" \
        || warn "theHarvester not available via apt, try: pip3 install theHarvester"
fi

# ── PATH export for future sessions ───────────────────────────
section "PATH Setup"
PROFILE_LINE='export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
if ! grep -q "go/bin" /etc/profile; then
    echo "$PROFILE_LINE" >> /etc/profile
    success "Added Go bin to /etc/profile"
fi
if ! grep -q "go/bin" ~/.bashrc 2>/dev/null; then
    echo "$PROFILE_LINE" >> ~/.bashrc
    success "Added Go bin to ~/.bashrc"
fi

# ── Final summary ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  Installation complete!${RESET}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════${RESET}"
echo ""
echo -e "  Run: ${CYAN}source /etc/profile${RESET} to reload PATH"
echo -e "  Then: ${CYAN}./geturls.sh -d example.com${RESET}"
echo ""

# Check what's installed
echo -e "${WHITE}${BOLD}  Tool Status:${RESET}"
for tool in subfinder httpx dnsx amass assetfinder findomain sublist3r \
            chaos shuffledns puredns ffuf gobuster feroxbuster dirsearch \
            waybackurls gau hakrawler nmap masscan anew theHarvester; do
    if command -v "$tool" &>/dev/null; then
        echo -e "  ${GREEN}✔${RESET} $tool"
    else
        echo -e "  ${RED}✘${RESET} $tool"
    fi
done
echo ""
