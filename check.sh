#!/usr/bin/env bash
# Checks tcgpriser.se and api.tcgpriser.se by content, from outside the VPS.
#
# Each check must see real content, not just a status code: on 2026-11-01 a 200 from the wrong
# server hid a six-day outage. Every URL carries a unique query string, because Cloudflare caches
# /health for 12 hours and a cached "healthy" says nothing about the origin.
#
# Exit 0 when every check passes, 1 otherwise. Prints one line per failure.
set -uo pipefail

UA="tcgpriser-uptime (+https://github.com/SebbeJohansson/tcgpriser-uptime)"
bust() { echo "_uptime=$(date +%s%N)"; }

failures=()

# check NAME URL GREP_PATTERN — passes when the body matches the pattern (case-insensitive).
check() {
  local name=$1 url=$2 pattern=$3 attempt body code
  for attempt in 1 2; do
    body=$(curl -s -m 20 -A "$UA" -w '\n%{http_code}' "$url") || body=$'\n000'
    code=${body##*$'\n'}
    body=${body%$'\n'*}
    if [ "$code" = "200" ] && grep -qiE "$pattern" <<<"$body"; then
      return 0
    fi
    [ "$attempt" = 1 ] && sleep 20
  done
  failures+=("$name: HTTP $code from $url")
}

check "Website home"        "https://tcgpriser.se/?$(bust)"                 '<title>[^<]*tcgpriser'
check "Website expansions"  "https://tcgpriser.se/pokemon/expansions?$(bust)" '<title>[^<]*Expansioner'
check "API health (origin)" "https://api.tcgpriser.se/health?$(bust)"        '"status":"healthy"'
check "API data"            "https://api.tcgpriser.se/brands?$(bust)"        '"data":\[\{'

if [ ${#failures[@]} -eq 0 ]; then
  echo "All checks passed."
  exit 0
fi
printf '%s\n' "${failures[@]}"
exit 1
