#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-http://testphp.vulnweb.com}"
OUTDIR="outputs"
mkdir -p "$OUTDIR"

echo " Target = $TARGET"
echo "1) Reconnaissance - fetch front page and all links"
curl -s "$TARGET" -o "$OUTDIR/recon_home.html"
# extract URLs
grep -Eo '(http|https)://[^"\'> ]+' "$OUTDIR/recon_home.html" | sort -u > "$OUTDIR/recon_links.txt" || true
echo "[+] Saved recon links -> $OUTDIR/recon_links.txt (count=$(wc -l < $OUTDIR/recon_links.txt))"

echo " 2) Run manual checks"
./manual_checks.sh "$TARGET" "$OUTDIR"

echo "3) Run sqlmap detection (non-destructive) for top GET parameters discovered"
# Simple example: test a common parameter 'artist=1' on testphp site.
# You can edit/extend this list or pass a URL as $TARGET?param=1
SAMPLE_URL="${TARGET%/}/artists.php?artist=1"
./sqlmap_scan.sh "$SAMPLE_URL" "$OUTDIR"

echo "4) Parse results and extract interesting lines with grep/sed/awk"
./parse_results.sh "$OUTDIR"

echo "All done. Check the outputs/ directory for logs and parsed findings.
