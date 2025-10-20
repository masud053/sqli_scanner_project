#!/usr/bin/env bash
set -euo pipefail
OUTDIR="${1:-outputs}"
mkdir -p "$OUTDIR/parsed"

echo " Parsing sqlmap and manual outputs in $OUTDIR"

#Extract lines that indicate a vulnerability or injection point from sqlmap logs
grep -RIn "is injectable|is vulnerable|web application DBMS|available databases" "$OUTDIR" -nH || true > "$OUTDIR/parsed/sqlmap_vuln_lines.txt" || true

#Extract database names (simple heuristic)
grep -RIn "database: " "$OUTDIR" -nH || true > "$OUTDIR/parsed/db_names.txt" || true

#Extract payload lines and requests from sqlmap logs
grep -RIn "payload" "$OUTDIR" -nH || true > "$OUTDIR/parsed/payloads_found.txt" || true

#Extract any server-side SQL error messages from manual checks
grep -RInE "SQL syntax|mysql|ORA-|syntax error|SQLSTATE" "$OUTDIR" -nH || true > "$OUTDIR/parsed/server_errors.txt" || true

#Summarize timing anomalies
awk '/sleep/ {print $0}' "$OUTDIR/timing.txt" 2>/dev/null || true > "$OUTDIR/parsed/timing_summary.txt" || true

echo "[*] Parsed outputs saved in $OUTDIR/parsed/"
ls -l "$OUTDIR/parsed" || true
