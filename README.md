# SQLi-Scanner-Project (safe, educational, test-targeted)

**Purpose:**  
A collection of safe, practical command-line scripts and helpers to discover and confirm SQL injection vulnerabilities **on authorized/test targets only** (example default: `http://testphp.vulnweb.com`). This project is intended for learning, automation of non-destructive checks, and evidence collection during authorized testing.

**Important legal & safety notice:**  
Only run these scripts against systems you own or against targets you have explicit written permission to test. The default target used in examples (`testphp.vulnweb.com`) is provided as a public test site and is allowed to be scanned for learning purposes. Avoid destructive sqlmap options (e.g., `--os-shell`, `--os-pwn`, `--file-write`) unless you have explicit permission.


## What’s included
- `run_all.sh` — main orchestrator: reconnaissance -> manual checks -> automated sqlmap checks -> parsing/grep extraction.
- `manual_checks.sh` — simple curl-based non-destructive checks (error, boolean, time-based).
- `sqlmap_scan.sh` — safe sqlmap automation (detect, fingerprint, list DBs/tables/columns). By default it runs discovery (`--dbs`). Dump options are included but commented and require explicit enabling.
- `parse_results.sh` — uses `grep`, `sed`, and `awk` to extract relevant findings (DB names, payloads, evidence).
- `requirements.txt` — python packages used by small helpers (if you use the optional Python parser).
- `tools.txt` — list of external tools required (sqlmap, curl, jq, gobuster).
- `outputs/` — folder where outputs will be saved (created when you run).

## Quick start (Debian/Ubuntu)
1. Install required packages (system tools):
```bash
sudo apt update
sudo apt install -y sqlmap curl jq gobuster
```
2. (Optional) Install Python requirements:
```bash
python3 -m pip install -r requirements.txt
```
3. Make scripts executable and run:
```bash
chmod +x *.sh
mkdir -p outputs
# **Default target is testphp.vulnweb.com** (safe public test target)
./run_all.sh
```

## How the scripts use `grep`
Every step saves raw output to `outputs/` and `parse_results.sh` runs `grep`/`sed`/`awk` patterns to extract:
- SQLi confirmation lines (e.g., lines mentioning "is vulnerable" from sqlmap).
- Database names (`grep "available databases"` or parse `sqlmap` output).
- Payloads used (grep for `payload` strings in sqlmap logs).
- Error messages (grep for "SQL syntax", "error in your SQL", etc.)


## Notes & customization
- Edit `TARGET` in `run_all.sh` to point to a different authorized/test target.
- To run more aggressive sqlmap tests, open `sqlmap_scan.sh` and enable the `--dump` line after reviewing and ensuring permission.
- The project intentionally avoids destructive options by default.

