# geturls

```
  ██████╗ ███████╗████████╗██╗   ██╗██████╗ ██╗     ███████╗
 ██╔════╝ ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║     ██╔════╝
 ██║  ███╗█████╗     ██║   ██║   ██║██████╔╝██║     ███████╗
 ██║   ██║██╔══╝     ██║   ██║   ██║██╔══██╗██║     ╚════██║
 ╚██████╔╝███████╗   ██║   ╚██████╔╝██║  ██║███████╗███████║
  ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝

           [ Bug Bounty Recon & Enumeration Framework ]
                    Created by  Omar_ahmed 
```

> **geturls** is an all-in-one automated recon framework for bug bounty hunters.  
> One command → full subdomain map, live host detection, IP resolution, and deep directory enumeration — all organized, deduplicated, and clean.

---

## Features

| Phase | What it does | Tools used |
|-------|-------------|------------|
| **Subdomain Enum** | Passive + active subdomain discovery | subfinder, amass, assetfinder, findomain, sublist3r, chaos, github-subdomains, theHarvester, crt.sh, RapidDNS, HackerTarget, urlscan.io, shuffledns, puredns |
| **DNS Resolution** | Resolves all subdomains, extracts IPs | dnsx |
| **Live Host Probe** | Checks HTTP/HTTPS, grabs status, title, tech | httpx |
| **URL Harvesting** | Historical + crawled URLs | waybackurls, gau, hakrawler |
| **Dir Enumeration** | Deep path bruteforce per live host | feroxbuster, ffuf, gobuster, dirsearch |
| **Port Scanning** | Top 1000 ports on resolved IPs | nmap |
| **Deduplication** | All results sorted, unique, and filtered | sort, anew |

---

## Installation

### 1. Clone the repo

```bash
git clone https://github.com/omarahmedalx/geturls.git
cd geturls
```

### 2. Run the installer (Kali Linux)

```bash
sudo bash install_deps.sh
source /etc/profile
```

### 3. Make the script executable

```bash
chmod +x geturls.sh
```

---

## Usage

```
./geturls.sh -d <domain> [options]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-d` | **Target domain** (required) | — |
| `-w` | Wordlist for dir bruteforce | auto-detect |
| `-t` | Threads | `50` |
| `-r` | Rate limit (req/s for httpx) | `150` |
| `-s` | Skip directory bruteforce | `false` |
| `-o` | Output base directory | `./target` |
| `-h` | Help menu | — |

### Examples

```bash
# Basic scan
./geturls.sh -d example.com

# Full scan with custom wordlist and 100 threads
./geturls.sh -d example.com -w /usr/share/seclists/Discovery/Web-Content/big.txt -t 100

# Fast mode — skip directory bruteforce
./geturls.sh -d example.com -s

# Custom output directory
./geturls.sh -d example.com -o /home/user/bugbounty
```

---

## Output Structure

```
target/
└── example.com/
    ├── subdomains.txt          ← All unique subdomains
    ├── live_subdomains.txt     ← Only live/responding hosts
    ├── ips.txt                 ← Resolved IP addresses
    ├── urls.txt                ← All live URLs (http + https)
    ├── all_urls.txt            ← Historical URLs (wayback/gau)
    ├── open_ports.txt          ← Nmap port scan results
    ├── report.txt              ← Full summary report
    └── directories/
        ├── sub1.example.com-dir.txt
        ├── api.example.com-dir.txt
        └── dev.example.com-dir.txt
```

---

## Tools Required

### Required (must be installed)
- `subfinder`
- `httpx`
- `dnsx`
- `amass`
- `anew`

### Optional (auto-skipped if missing)
- `assetfinder`, `findomain`, `chaos`, `sublist3r`, `theHarvester`
- `shuffledns`, `puredns`, `massdns`
- `github-subdomains`
- `waybackurls`, `gau`, `hakrawler`
- `feroxbuster`, `ffuf`, `gobuster`, `dirsearch`
- `nmap`, `masscan`

> **All optional tools are installed automatically via `install_deps.sh`**

---

## Recommended Wordlists

For best results, use [SecLists](https://github.com/danielmiessler/SecLists):

```bash
sudo apt install seclists
```

Then use:
```bash
./geturls.sh -d example.com -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
```

---

## How It Works

```
Target Domain
      │
      ▼
┌─────────────────────────────────────────┐
│  PHASE 1 — Subdomain Enumeration        │
│  15+ tools + public APIs                │
│  → subdomains.txt (deduplicated)        │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  PHASE 2 — Live Detection & IPs         │
│  dnsx → DNS resolution + IP extract     │
│  httpx → HTTP/HTTPS probing             │
│  → live_subdomains.txt + ips.txt        │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  PHASE 3 — URL Harvesting               │
│  waybackurls, gau, hakrawler            │
│  → all_urls.txt                         │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  PHASE 4 — Directory Enumeration        │
│  feroxbuster / ffuf / gobuster          │
│  → directories/<host>-dir.txt           │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  PHASE 5 — Port Scanning                │
│  nmap top 1000 ports                    │
│  → open_ports.txt                       │
└────────────────┬────────────────────────┘
                 │
                 ▼
          report.txt + summary
```

---

## Disclaimer

> This tool is for **educational purposes** and **authorized security testing only**.  
> Do **NOT** run this against domains you don't own or don't have explicit permission to test.  
> The author is not responsible for any misuse.

---

## Author

**Created by Omar_ahmed**

If this tool helped you, leave a ⭐ on GitHub!

---

## License

MIT License — free to use, modify, and distribute.
