#!/bin/bash
# =============================================================================
#   ██████╗ ███████╗████████╗██╗   ██╗██████╗ ██╗     ███████╗
#  ██╔════╝ ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║     ██╔════╝
#  ██║  ███╗█████╗     ██║   ██║   ██║██████╔╝██║     ███████╗
#  ██║   ██║██╔══╝     ██║   ██║   ██║██╔══██╗██║     ╚════██║
#  ╚██████╔╝███████╗   ██║   ╚██████╔╝██║  ██║███████╗███████║
#   ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝
#
#              [ Bug Bounty Recon & Enumeration Framework ]
#                       Created by  Omar_ahmed
#                        Version: 1.0  |  Kali Linux
# =============================================================================

# ─────────────────────────────────────────────────────────────
#  COLORS & FORMATTING
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─────────────────────────────────────────────────────────────
#  BANNER
# ─────────────────────────────────────────────────────────────
print_banner() {
    clear
    echo -e "${CYAN}"
    echo '  ██████╗ ███████╗████████╗██╗   ██╗██████╗ ██╗     ███████╗'
    echo ' ██╔════╝ ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║     ██╔════╝'
    echo ' ██║  ███╗█████╗     ██║   ██║   ██║██████╔╝██║     ███████╗'
    echo ' ██║   ██║██╔══╝     ██║   ██║   ██║██╔══██╗██║     ╚════██║'
    echo ' ╚██████╔╝███████╗   ██║   ╚██████╔╝██║  ██║███████╗███████║'
    echo '  ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝'
    echo -e "${RESET}"
    echo -e "${DIM}${WHITE}          ┌─────────────────────────────────────────┐${RESET}"
    echo -e "${DIM}${WHITE}          │    Bug Bounty Recon & Enum Framework    │${RESET}"
    echo -e "${DIM}${WHITE}          │          Created by  Omar_ahmed          │${RESET}"
    echo -e "${DIM}${WHITE}          │           Version 1.0 | Kali Linux       │${RESET}"
    echo -e "${DIM}${WHITE}          └─────────────────────────────────────────┘${RESET}"
    echo ""
}

# ─────────────────────────────────────────────────────────────
#  LOGGING HELPERS
# ─────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}[*]${RESET} $1"; }
success() { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "${RED}[✘]${RESET} $1"; }
section() {
    echo ""
    echo -e "${MAGENTA}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}║  $1${RESET}"
    echo -e "${MAGENTA}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
    echo ""
}
step() { echo -e "  ${BLUE}➤${RESET} $1"; }

# ─────────────────────────────────────────────────────────────
#  USAGE
# ─────────────────────────────────────────────────────────────
usage() {
    print_banner
    echo -e "${WHITE}${BOLD}  USAGE:${RESET}"
    echo -e "    ${CYAN}./geturls.sh${RESET} ${YELLOW}-d <domain>${RESET} [options]"
    echo ""
    echo -e "${WHITE}${BOLD}  OPTIONS:${RESET}"
    echo -e "    ${YELLOW}-d${RESET}  Target domain            (required)  e.g. -d example.com"
    echo -e "    ${YELLOW}-w${RESET}  Wordlist for dir bruteforce           e.g. -w /path/to/list.txt"
    echo -e "    ${YELLOW}-t${RESET}  Threads for tools         (default: 50)"
    echo -e "    ${YELLOW}-s${RESET}  Skip directory bruteforce (faster mode)"
    echo -e "    ${YELLOW}-o${RESET}  Output base directory     (default: ./target)"
    echo -e "    ${YELLOW}-r${RESET}  Rate limit for httpx      (default: 150)"
    echo -e "    ${YELLOW}-h${RESET}  Show this help menu"
    echo ""
    echo -e "${WHITE}${BOLD}  EXAMPLES:${RESET}"
    echo -e "    ${DIM}./geturls.sh -d example.com${RESET}"
    echo -e "    ${DIM}./geturls.sh -d example.com -w /usr/share/wordlists/dirb/big.txt -t 100${RESET}"
    echo -e "    ${DIM}./geturls.sh -d example.com -s -o /home/user/recon${RESET}"
    echo ""
    echo -e "${WHITE}${BOLD}  OUTPUT STRUCTURE:${RESET}"
    echo -e "    ${DIM}target/"
    echo -e "    └── example.com/"
    echo -e "        ├── subdomains.txt         # All unique subdomains"
    echo -e "        ├── live_subdomains.txt    # Only live/responding hosts"
    echo -e "        ├── ips.txt                # Resolved IP addresses"
    echo -e "        ├── urls.txt               # All live URLs (http/https)"
    echo -e "        ├── report.txt             # Full summary report"
    echo -e "        └── directories/           # Directory bruteforce results"
    echo -e "            ├── sub1.example.com-dir.txt"
    echo -e "            └── sub2.example.com-dir.txt${RESET}"
    echo ""
    exit 0
}

# ─────────────────────────────────────────────────────────────
#  DEPENDENCY CHECKER
# ─────────────────────────────────────────────────────────────
REQUIRED_TOOLS=("subfinder" "amass" "httpx" "dnsx" "anew")
OPTIONAL_TOOLS=("assetfinder" "findomain" "gobuster" "ffuf" "feroxbuster" "dirsearch" "nmap" "masscan" "chaos" "waybackurls" "gau" "hakrawler" "getallurls" "sublist3r" "theHarvester" "aquatone" "gowitness" "shuffledns" "puredns" "massdns" "github-subdomains" "shosubgo" "crtsh")

check_dependencies() {
    section "CHECKING DEPENDENCIES"

    local missing_required=()
    local missing_optional=()

    for tool in "${REQUIRED_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            success "$tool found"
        else
            error "$tool NOT found (required)"
            missing_required+=("$tool")
        fi
    done

    echo ""
    info "Checking optional tools..."
    for tool in "${OPTIONAL_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            success "$tool found"
        else
            warn "$tool not found (optional, will be skipped)"
            missing_optional+=("$tool")
        fi
    done

    if [ ${#missing_required[@]} -ne 0 ]; then
        echo ""
        error "Missing required tools: ${missing_required[*]}"
        echo -e "  ${DIM}Run: ${CYAN}bash install_deps.sh${RESET} to install all dependencies"
        exit 1
    fi

    echo ""
    success "All required tools found. Starting recon..."
    sleep 1
}

# ─────────────────────────────────────────────────────────────
#  DIRECTORY SETUP
# ─────────────────────────────────────────────────────────────
setup_dirs() {
    TARGET_DIR="${OUTPUT_BASE}/${DOMAIN}"
    DIR_DIR="${TARGET_DIR}/directories"
    RAW_DIR="${TARGET_DIR}/.raw"          # hidden tmp folder for raw tool output

    mkdir -p "$TARGET_DIR" "$DIR_DIR" "$RAW_DIR"

    SUBDOMAINS_FILE="${TARGET_DIR}/subdomains.txt"
    LIVE_FILE="${TARGET_DIR}/live_subdomains.txt"
    IPS_FILE="${TARGET_DIR}/ips.txt"
    URLS_FILE="${TARGET_DIR}/urls.txt"
    REPORT_FILE="${TARGET_DIR}/report.txt"

    success "Output directory: ${TARGET_DIR}"
}

# ─────────────────────────────────────────────────────────────
#  SUBDOMAIN ENUMERATION
# ─────────────────────────────────────────────────────────────
run_subdomain_enum() {
    section "PHASE 1 — SUBDOMAIN ENUMERATION"

    # ── subfinder ──────────────────────────────────────────
    if command -v subfinder &>/dev/null; then
        step "Running subfinder..."
        subfinder -d "$DOMAIN" -silent -all -recursive \
            -o "${RAW_DIR}/subfinder.txt" 2>/dev/null
        local count
        count=$(wc -l < "${RAW_DIR}/subfinder.txt" 2>/dev/null || echo 0)
        success "subfinder → ${count} results"
    fi

    # ── assetfinder ────────────────────────────────────────
    if command -v assetfinder &>/dev/null; then
        step "Running assetfinder..."
        assetfinder --subs-only "$DOMAIN" \
            > "${RAW_DIR}/assetfinder.txt" 2>/dev/null
        local count
        count=$(wc -l < "${RAW_DIR}/assetfinder.txt" 2>/dev/null || echo 0)
        success "assetfinder → ${count} results"
    fi

    # ── amass (passive) ────────────────────────────────────
    if command -v amass &>/dev/null; then
        step "Running amass (passive mode)..."
        timeout 300 amass enum -passive -d "$DOMAIN" -silent \
            -o "${RAW_DIR}/amass.txt" 2>/dev/null
        local count
        count=$(wc -l < "${RAW_DIR}/amass.txt" 2>/dev/null || echo 0)
        success "amass → ${count} results"
    fi

    # ── findomain ──────────────────────────────────────────
    if command -v findomain &>/dev/null; then
        step "Running findomain..."
        findomain -t "$DOMAIN" -q \
            > "${RAW_DIR}/findomain.txt" 2>/dev/null
        local count
        count=$(wc -l < "${RAW_DIR}/findomain.txt" 2>/dev/null || echo 0)
        success "findomain → ${count} results"
    fi

    # ── sublist3r ──────────────────────────────────────────
    if command -v sublist3r &>/dev/null; then
        step "Running sublist3r..."
        sublist3r -d "$DOMAIN" -o "${RAW_DIR}/sublist3r.txt" -n \
            >/dev/null 2>&1
        local count
        count=$(wc -l < "${RAW_DIR}/sublist3r.txt" 2>/dev/null || echo 0)
        success "sublist3r → ${count} results"
    fi

    # ── chaos (ProjectDiscovery) ───────────────────────────
    if command -v chaos &>/dev/null; then
        step "Running chaos..."
        chaos -d "$DOMAIN" -silent \
            > "${RAW_DIR}/chaos.txt" 2>/dev/null
        local count
        count=$(wc -l < "${RAW_DIR}/chaos.txt" 2>/dev/null || echo 0)
        success "chaos → ${count} results"
    fi

    # ── github-subdomains ──────────────────────────────────
    if command -v github-subdomains &>/dev/null; then
        step "Running github-subdomains..."
        github-subdomains -d "$DOMAIN" -raw \
            > "${RAW_DIR}/github-subdomains.txt" 2>/dev/null
        local count
        count=$(wc -l < "${RAW_DIR}/github-subdomains.txt" 2>/dev/null || echo 0)
        success "github-subdomains → ${count} results"
    fi

    # ── theHarvester ───────────────────────────────────────
    if command -v theHarvester &>/dev/null; then
        step "Running theHarvester..."
        theHarvester -d "$DOMAIN" -b all -f "${RAW_DIR}/theHarvester_out" \
            >/dev/null 2>&1
        # parse subdomains from XML output if exists
        if [ -f "${RAW_DIR}/theHarvester_out.xml" ]; then
            grep -oP '(?<=<hostname>)[^<]+' "${RAW_DIR}/theHarvester_out.xml" \
                > "${RAW_DIR}/theHarvester.txt" 2>/dev/null
        fi
        local count
        count=$(wc -l < "${RAW_DIR}/theHarvester.txt" 2>/dev/null || echo 0)
        success "theHarvester → ${count} results"
    fi

    # ── crt.sh (certificate transparency) ─────────────────
    step "Querying crt.sh (certificate transparency)..."
    curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" 2>/dev/null \
        | tr ',' '\n' \
        | grep -oP '"name_value":"\K[^"]+' \
        | sed 's/\*\.//g' \
        | tr '[:upper:]' '[:lower:]' \
        | grep -E "\.${DOMAIN}$|^${DOMAIN}$" \
        > "${RAW_DIR}/crtsh.txt" 2>/dev/null
    local count
    count=$(wc -l < "${RAW_DIR}/crtsh.txt" 2>/dev/null || echo 0)
    success "crt.sh → ${count} results"

    # ── RapidDNS ───────────────────────────────────────────
    step "Querying RapidDNS..."
    curl -s "https://rapiddns.io/subdomain/${DOMAIN}?full=1" 2>/dev/null \
        | grep -oP '[a-zA-Z0-9.-]+\.'"${DOMAIN}" \
        | tr '[:upper:]' '[:lower:]' \
        > "${RAW_DIR}/rapiddns.txt" 2>/dev/null
    count=$(wc -l < "${RAW_DIR}/rapiddns.txt" 2>/dev/null || echo 0)
    success "RapidDNS → ${count} results"

    # ── SecurityTrails (via curl public endpoint) ──────────
    step "Querying HackerTarget..."
    curl -s "https://api.hackertarget.com/hostsearch/?q=${DOMAIN}" 2>/dev/null \
        | cut -d',' -f1 \
        | grep -E "\.${DOMAIN}$|^${DOMAIN}$" \
        > "${RAW_DIR}/hackertarget.txt" 2>/dev/null
    count=$(wc -l < "${RAW_DIR}/hackertarget.txt" 2>/dev/null || echo 0)
    success "HackerTarget → ${count} results"

    # ── URLScan.io ─────────────────────────────────────────
    step "Querying urlscan.io..."
    curl -s "https://urlscan.io/api/v1/search/?q=domain:${DOMAIN}&size=10000" 2>/dev/null \
        | grep -oP '"domain":"\K[^"]+' \
        | grep -E "\.${DOMAIN}$|^${DOMAIN}$" \
        > "${RAW_DIR}/urlscan.txt" 2>/dev/null
    count=$(wc -l < "${RAW_DIR}/urlscan.txt" 2>/dev/null || echo 0)
    success "urlscan.io → ${count} results"

    # ── Wayback Machine subdomains via waybackurls/gau ─────
    if command -v waybackurls &>/dev/null; then
        step "Running waybackurls for historical subdomains..."
        echo "$DOMAIN" | waybackurls 2>/dev/null \
            | grep -oP '[a-zA-Z0-9.-]+\.'"${DOMAIN}" \
            | tr '[:upper:]' '[:lower:]' \
            > "${RAW_DIR}/wayback_subs.txt"
        count=$(wc -l < "${RAW_DIR}/wayback_subs.txt" 2>/dev/null || echo 0)
        success "waybackurls (subdomains) → ${count} results"
    fi

    if command -v gau &>/dev/null; then
        step "Running gau for historical subdomains..."
        gau --subs "$DOMAIN" 2>/dev/null \
            | grep -oP '[a-zA-Z0-9.-]+\.'"${DOMAIN}" \
            | tr '[:upper:]' '[:lower:]' \
            > "${RAW_DIR}/gau_subs.txt"
        count=$(wc -l < "${RAW_DIR}/gau_subs.txt" 2>/dev/null || echo 0)
        success "gau (subdomains) → ${count} results"
    fi

    # ── shuffledns (bruteforce) ────────────────────────────
    if command -v shuffledns &>/dev/null && [ -f "${WORDLIST}" ]; then
        step "Running shuffledns (DNS bruteforce)..."
        shuffledns -d "$DOMAIN" -w "$WORDLIST" -r /etc/resolv.conf \
            -o "${RAW_DIR}/shuffledns.txt" -silent 2>/dev/null
        count=$(wc -l < "${RAW_DIR}/shuffledns.txt" 2>/dev/null || echo 0)
        success "shuffledns → ${count} results"
    fi

    # ── puredns (bruteforce fallback) ──────────────────────
    if command -v puredns &>/dev/null && [ -f "${WORDLIST}" ]; then
        step "Running puredns (DNS bruteforce)..."
        puredns bruteforce "$WORDLIST" "$DOMAIN" \
            > "${RAW_DIR}/puredns.txt" 2>/dev/null
        count=$(wc -l < "${RAW_DIR}/puredns.txt" 2>/dev/null || echo 0)
        success "puredns → ${count} results"
    fi

    # ── MERGE & DEDUPLICATE ────────────────────────────────
    section "MERGING & DEDUPLICATING SUBDOMAINS"

    cat "${RAW_DIR}"/*.txt 2>/dev/null \
        | grep -E "\.${DOMAIN}$|^${DOMAIN}$" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/^\*\.//' \
        | sed 's/^www\.//' \
        | grep -v "^$" \
        | grep -v " " \
        | sort -u \
        > "$SUBDOMAINS_FILE"

    TOTAL_SUBS=$(wc -l < "$SUBDOMAINS_FILE")
    success "Total unique subdomains found: ${WHITE}${BOLD}${TOTAL_SUBS}${RESET}"
}

# ─────────────────────────────────────────────────────────────
#  DNS RESOLUTION & LIVE HOST DETECTION
# ─────────────────────────────────────────────────────────────
run_live_check() {
    section "PHASE 2 — LIVE HOST DETECTION & IP RESOLUTION"

    # ── DNS resolution with dnsx ───────────────────────────
    step "Resolving IPs with dnsx..."
    dnsx -l "$SUBDOMAINS_FILE" \
         -a -resp -silent \
         -t "$THREADS" \
         -o "${RAW_DIR}/dnsx_resolved.txt" 2>/dev/null

    # Extract just subdomains that resolved
    grep -oP '^[^\s]+' "${RAW_DIR}/dnsx_resolved.txt" 2>/dev/null \
        | sort -u > "${RAW_DIR}/dns_live.txt"

    # Extract IPs
    grep -oP '\[\K[\d.]+(?=\])' "${RAW_DIR}/dnsx_resolved.txt" 2>/dev/null \
        | sort -u > "$IPS_FILE"

    DNS_LIVE=$(wc -l < "${RAW_DIR}/dns_live.txt" 2>/dev/null || echo 0)
    IP_COUNT=$(wc -l < "$IPS_FILE" 2>/dev/null || echo 0)
    success "DNS resolving → ${WHITE}${BOLD}${DNS_LIVE}${RESET} resolved hosts"
    success "Unique IPs → ${WHITE}${BOLD}${IP_COUNT}${RESET}"

    # ── HTTP probing with httpx ────────────────────────────
    step "Probing HTTP/HTTPS with httpx..."
    httpx -l "${RAW_DIR}/dns_live.txt" \
          -silent \
          -threads "$THREADS" \
          -rate-limit "$RATE_LIMIT" \
          -follow-redirects \
          -status-code \
          -title \
          -tech-detect \
          -o "${RAW_DIR}/httpx_out.txt" 2>/dev/null

    # Save clean URLs
    awk '{print $1}' "${RAW_DIR}/httpx_out.txt" 2>/dev/null \
        | sort -u > "$URLS_FILE"

    # Save clean live subdomains (strip scheme)
    sed 's|https\?://||' "$URLS_FILE" \
        | sed 's|/$||' \
        | sort -u > "$LIVE_FILE"

    LIVE_COUNT=$(wc -l < "$LIVE_FILE" 2>/dev/null || echo 0)
    URL_COUNT=$(wc -l < "$URLS_FILE" 2>/dev/null || echo 0)
    success "Live subdomains → ${WHITE}${BOLD}${LIVE_COUNT}${RESET}"
    success "Live URLs (http/https) → ${WHITE}${BOLD}${URL_COUNT}${RESET}"
}

# ─────────────────────────────────────────────────────────────
#  URL HARVESTING (Wayback / GAU / Hakrawler)
# ─────────────────────────────────────────────────────────────
run_url_harvest() {
    section "PHASE 3 — URL HARVESTING"

    local HARVEST_FILE="${TARGET_DIR}/all_urls.txt"

    if command -v waybackurls &>/dev/null; then
        step "Harvesting URLs from Wayback Machine..."
        cat "$LIVE_FILE" | waybackurls 2>/dev/null \
            | sort -u > "${RAW_DIR}/wayback_urls.txt"
        count=$(wc -l < "${RAW_DIR}/wayback_urls.txt" 2>/dev/null || echo 0)
        success "waybackurls → ${count} historical URLs"
    fi

    if command -v gau &>/dev/null; then
        step "Harvesting URLs with gau (GetAllURLs)..."
        cat "$LIVE_FILE" | gau --threads "$THREADS" 2>/dev/null \
            | sort -u > "${RAW_DIR}/gau_urls.txt"
        count=$(wc -l < "${RAW_DIR}/gau_urls.txt" 2>/dev/null || echo 0)
        success "gau → ${count} URLs"
    fi

    if command -v hakrawler &>/dev/null; then
        step "Crawling live hosts with hakrawler..."
        cat "$URLS_FILE" | hakrawler -t "$THREADS" -d 3 -subs 2>/dev/null \
            | sort -u > "${RAW_DIR}/hakrawler_urls.txt"
        count=$(wc -l < "${RAW_DIR}/hakrawler_urls.txt" 2>/dev/null || echo 0)
        success "hakrawler → ${count} URLs"
    fi

    # Merge all harvested URLs
    cat "${RAW_DIR}/wayback_urls.txt" \
        "${RAW_DIR}/gau_urls.txt" \
        "${RAW_DIR}/hakrawler_urls.txt" 2>/dev/null \
        | grep -E "^https?://" \
        | sort -u > "$HARVEST_FILE"

    HARVEST_COUNT=$(wc -l < "$HARVEST_FILE" 2>/dev/null || echo 0)
    success "Total harvested URLs → ${WHITE}${BOLD}${HARVEST_COUNT}${RESET}"
}

# ─────────────────────────────────────────────────────────────
#  DIRECTORY / PATH BRUTEFORCE
# ─────────────────────────────────────────────────────────────
run_dir_brute() {
    section "PHASE 4 — DIRECTORY ENUMERATION"

    if [ "$SKIP_DIRS" = true ]; then
        warn "Directory bruteforce skipped (-s flag used)"
        return
    fi

    if [ -z "$WORDLIST" ] || [ ! -f "$WORDLIST" ]; then
        # Try to find a default wordlist
        for wl in \
            /usr/share/wordlists/dirb/common.txt \
            /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
            /usr/share/seclists/Discovery/Web-Content/common.txt \
            /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt; do
            if [ -f "$wl" ]; then
                WORDLIST="$wl"
                warn "No wordlist specified, using default: ${WORDLIST}"
                break
            fi
        done
    fi

    if [ -z "$WORDLIST" ] || [ ! -f "$WORDLIST" ]; then
        error "No wordlist found. Skipping directory bruteforce."
        warn "Install seclists: sudo apt install seclists"
        return
    fi

    info "Wordlist: ${WORDLIST}"
    info "Running directory bruteforce on ${LIVE_COUNT} live hosts..."
    echo ""

    local idx=0
    while IFS= read -r url; do
        idx=$((idx+1))
        # Create a safe filename from the URL
        local safe_name
        safe_name=$(echo "$url" | sed 's|https\?://||' | sed 's|[/:]|-|g' | sed 's|-$||')
        local out_file="${DIR_DIR}/${safe_name}-dir.txt"

        info "[${idx}/${LIVE_COUNT}] Enumerating: ${CYAN}${url}${RESET}"

        # Try tools in order of preference
        if command -v feroxbuster &>/dev/null; then
            feroxbuster --url "$url" \
                --wordlist "$WORDLIST" \
                --threads "$THREADS" \
                --silent \
                --no-state \
                --filter-status 404,403,400 \
                --output "${out_file}" \
                2>/dev/null &
            FEROX_PID=$!
            # Limit concurrent feroxbuster to 3
            if (( idx % 3 == 0 )); then wait; fi

        elif command -v ffuf &>/dev/null; then
            ffuf -u "${url}/FUZZ" \
                 -w "$WORDLIST" \
                 -t "$THREADS" \
                 -mc 200,201,204,301,302,307,401,403 \
                 -o "${out_file}" \
                 -of csv \
                 -s \
                 2>/dev/null

        elif command -v gobuster &>/dev/null; then
            gobuster dir \
                -u "$url" \
                -w "$WORDLIST" \
                -t "$THREADS" \
                --no-error \
                -q \
                -o "${out_file}" \
                2>/dev/null

        elif command -v dirsearch &>/dev/null; then
            dirsearch -u "$url" \
                -w "$WORDLIST" \
                -t "$THREADS" \
                --plain-text-report="${out_file}" \
                -q \
                2>/dev/null
        else
            warn "No dir bruteforce tool found. Skipping ${url}"
            break
        fi

        # Only show result if file was created
        if [ -f "$out_file" ] && [ -s "$out_file" ]; then
            local found
            found=$(wc -l < "$out_file" 2>/dev/null || echo 0)
            success "  Found ${found} paths → ${out_file}"
        fi

    done < "$URLS_FILE"

    # Wait for any background jobs
    wait

    # Remove empty dir result files
    find "$DIR_DIR" -name "*.txt" -empty -delete 2>/dev/null

    DIR_FILES=$(ls "$DIR_DIR" | wc -l)
    success "Directory enumeration complete → ${WHITE}${BOLD}${DIR_FILES}${RESET} result files"
}

# ─────────────────────────────────────────────────────────────
#  PORT SCANNING (optional / selective)
# ─────────────────────────────────────────────────────────────
run_port_scan() {
    section "PHASE 5 — PORT SCANNING"

    if ! command -v nmap &>/dev/null; then
        warn "nmap not found, skipping port scan"
        return
    fi

    local PORT_FILE="${TARGET_DIR}/open_ports.txt"

    if [ -s "$IPS_FILE" ]; then
        step "Running nmap on resolved IPs (top 1000 ports)..."
        nmap -iL "$IPS_FILE" \
             --top-ports 1000 \
             -T4 \
             --open \
             -oN "$PORT_FILE" \
             2>/dev/null
        success "Port scan saved → ${PORT_FILE}"
    else
        warn "No IPs to scan"
    fi
}

# ─────────────────────────────────────────────────────────────
#  GENERATE FINAL REPORT
# ─────────────────────────────────────────────────────────────
generate_report() {
    section "GENERATING FINAL REPORT"

    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    {
        echo "========================================================"
        echo "           GETURLS - Bug Bounty Recon Report"
        echo "                 Created by Omar_ahmed"
        echo "========================================================"
        echo ""
        echo "  Target       : ${DOMAIN}"
        echo "  Scan Date    : ${TIMESTAMP}"
        echo "  Output Dir   : ${TARGET_DIR}"
        echo ""
        echo "────────────────────────────────────────────────────────"
        echo "  SUBDOMAIN ENUMERATION"
        echo "────────────────────────────────────────────────────────"
        echo "  Total unique subdomains : $(wc -l < "$SUBDOMAINS_FILE" 2>/dev/null || echo 0)"
        echo "  Live subdomains         : $(wc -l < "$LIVE_FILE" 2>/dev/null || echo 0)"
        echo "  Live URLs (http/https)  : $(wc -l < "$URLS_FILE" 2>/dev/null || echo 0)"
        echo ""
        echo "────────────────────────────────────────────────────────"
        echo "  IP ADDRESSES"
        echo "────────────────────────────────────────────────────────"
        echo "  Unique IPs resolved     : $(wc -l < "$IPS_FILE" 2>/dev/null || echo 0)"
        echo ""
        if [ -s "$IPS_FILE" ]; then
            echo "  IP List:"
            cat "$IPS_FILE" | sed 's/^/    /'
            echo ""
        fi
        echo "────────────────────────────────────────────────────────"
        echo "  DIRECTORY ENUMERATION"
        echo "────────────────────────────────────────────────────────"
        echo "  Hosts enumerated        : $(ls "$DIR_DIR" 2>/dev/null | wc -l)"
        echo ""
        echo "────────────────────────────────────────────────────────"
        echo "  OUTPUT FILES"
        echo "────────────────────────────────────────────────────────"
        echo "  subdomains.txt          → All unique subdomains"
        echo "  live_subdomains.txt     → Live/responding subdomains"
        echo "  ips.txt                 → Resolved IP addresses"
        echo "  urls.txt                → All live URLs"
        echo "  directories/            → Per-host directory results"
        echo ""
        echo "  Harvested URL Files:"
        [ -f "${TARGET_DIR}/all_urls.txt" ] && echo "  all_urls.txt            → $(wc -l < "${TARGET_DIR}/all_urls.txt" 2>/dev/null) historical URLs"
        echo ""
        echo "────────────────────────────────────────────────────────"
        echo "  LIVE SUBDOMAINS (httpx)"
        echo "────────────────────────────────────────────────────────"
        cat "${RAW_DIR}/httpx_out.txt" 2>/dev/null | head -100
        echo ""
        echo "========================================================"
        echo "  Scan complete - Happy Hunting!"
        echo "========================================================"
    } > "$REPORT_FILE"

    success "Report saved → ${REPORT_FILE}"
}

# ─────────────────────────────────────────────────────────────
#  CLEANUP
# ─────────────────────────────────────────────────────────────
cleanup() {
    # Remove empty files from directories folder
    find "$DIR_DIR" -name "*.txt" -empty -delete 2>/dev/null
    # Remove the raw tmp dir (optional: keep for debugging)
    # rm -rf "$RAW_DIR"
    :
}

# ─────────────────────────────────────────────────────────────
#  PRINT SUMMARY
# ─────────────────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║              RECON COMPLETE — SUMMARY            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${WHITE}Target      :${RESET} ${YELLOW}${DOMAIN}${RESET}"
    echo -e "  ${WHITE}Subdomains  :${RESET} ${GREEN}$(wc -l < "$SUBDOMAINS_FILE" 2>/dev/null || echo 0) unique${RESET}"
    echo -e "  ${WHITE}Live Hosts  :${RESET} ${GREEN}$(wc -l < "$LIVE_FILE" 2>/dev/null || echo 0) responding${RESET}"
    echo -e "  ${WHITE}Live URLs   :${RESET} ${GREEN}$(wc -l < "$URLS_FILE" 2>/dev/null || echo 0)${RESET}"
    echo -e "  ${WHITE}IPs Found   :${RESET} ${GREEN}$(wc -l < "$IPS_FILE" 2>/dev/null || echo 0) unique${RESET}"
    echo -e "  ${WHITE}Dir Files   :${RESET} ${GREEN}$(ls "$DIR_DIR" 2>/dev/null | wc -l) hosts enumerated${RESET}"
    echo ""
    echo -e "  ${WHITE}Output      :${RESET} ${CYAN}${TARGET_DIR}${RESET}"
    echo -e "  ${WHITE}Report      :${RESET} ${CYAN}${REPORT_FILE}${RESET}"
    echo ""
    echo -e "${DIM}  Created by Omar_ahmed | geturls v1.0${RESET}"
    echo ""
}

# ─────────────────────────────────────────────────────────────
#  DEFAULTS
# ─────────────────────────────────────────────────────────────
DOMAIN=""
WORDLIST=""
THREADS=50
RATE_LIMIT=150
SKIP_DIRS=false
OUTPUT_BASE="./target"

# ─────────────────────────────────────────────────────────────
#  ARGUMENT PARSING
# ─────────────────────────────────────────────────────────────
while getopts "d:w:t:r:o:sh" opt; do
    case $opt in
        d) DOMAIN="$OPTARG" ;;
        w) WORDLIST="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        r) RATE_LIMIT="$OPTARG" ;;
        o) OUTPUT_BASE="$OPTARG" ;;
        s) SKIP_DIRS=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# ─────────────────────────────────────────────────────────────
#  ENTRYPOINT
# ─────────────────────────────────────────────────────────────
print_banner

if [ -z "$DOMAIN" ]; then
    error "No domain specified. Use -d <domain>"
    echo ""
    usage
fi

# Validate domain format
if ! echo "$DOMAIN" | grep -qP '^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'; then
    error "Invalid domain format: ${DOMAIN}"
    exit 1
fi

info "Target: ${YELLOW}${BOLD}${DOMAIN}${RESET}"
info "Threads: ${THREADS} | Rate limit: ${RATE_LIMIT} req/s"
info "Skip dir brute: ${SKIP_DIRS}"
echo ""

check_dependencies
setup_dirs
run_subdomain_enum
run_live_check
run_url_harvest
run_dir_brute
run_port_scan
generate_report
cleanup
print_summary
