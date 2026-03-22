#!/usr/bin/env bash
# Queries Claude plan usage via OAuth token (same data as /usage command)
# Reads OAuth token from ~/.claude/.credentials.json

CACHE_FILE="/tmp/waybar-claude-usage.cache"
CACHE_TTL=300  # 5 minutes

if [[ -f "$CACHE_FILE" ]]; then
    age=$(( $(date +%s) - $(stat -c%Y "$CACHE_FILE") ))
    if (( age < CACHE_TTL )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

CREDENTIALS="$HOME/.claude/.credentials.json"
if [[ ! -f "$CREDENTIALS" ]]; then
    echo '{"text": "󰭻 --", "class": "disconnected", "tooltip": "Claude: not logged in"}'
    exit 0
fi

ACCESS_TOKEN=$(python3 -c "import json; print(json.load(open('$CREDENTIALS'))['claudeAiOauth']['accessToken'])" 2>/dev/null)
if [[ -z "$ACCESS_TOKEN" ]]; then
    echo '{"text": "󰭻 --", "class": "disconnected", "tooltip": "Claude: no OAuth token"}'
    exit 0
fi

headers=$(curl -si -m 15 \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "anthropic-version: 2023-06-01" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "content-type: application/json" \
    -d '{"model":"claude-haiku-4-5","max_tokens":1,"messages":[{"role":"user","content":"Hi"}]}' \
    "https://api.anthropic.com/v1/messages" 2>/dev/null | grep -i 'ratelimit-unified')

if [[ -z "$headers" ]]; then
    echo '{"text": "󰭻 err", "class": "error", "tooltip": "Claude: failed to fetch usage"}'
    exit 0
fi

result=$(python3 - <<EOF
import re, datetime

headers = """$headers"""

def get(name):
    m = re.search(rf'{name}:\s*(\S+)', headers, re.IGNORECASE)
    return m.group(1) if m else None

# Get the representative claim (five_hour or seven_day)
claim = get('representative-claim') or 'five_hour'
prefix = '5h' if 'five' in claim else '7d'

utilization = float(get(f'{prefix}-utilization') or 0)
reset_ts    = int(get(f'{prefix}-reset') or 0)
status      = get('unified-status') or 'allowed'

pct = round(utilization * 100)

# Time until reset
if reset_ts:
    delta = reset_ts - int(datetime.datetime.now().timestamp())
    h, m = divmod(max(0, delta), 3600)
    m //= 60
    reset_str = f'{h}h{m:02d}m'
else:
    reset_str = '?'

# CSS class
if status == 'rejected' or pct >= 90:
    css = 'critical'
elif pct >= 70:
    css = 'warning'
else:
    css = 'normal'

window = '5h' if 'five' in claim else '7d'
tooltip = f"Claude: {pct}% of {window} quota used, resets in {reset_str}"
print(f'{{"text": "󰭻 {pct}%", "class": "{css}", "tooltip": "{tooltip}"}}')
EOF
)

echo "$result" | tee "$CACHE_FILE"
