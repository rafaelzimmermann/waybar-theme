#!/usr/bin/env bash
# Queries Z.ai API for quota usage
# API key is read from opencode config (or ZAI_API_KEY env var)

CACHE_FILE="/tmp/waybar-zai-usage.cache"
CACHE_TTL=60  # 1 minute

if [[ -f "$CACHE_FILE" ]]; then
    age=$(( $(date +%s) - $(stat -c%Y "$CACHE_FILE") ))
    if (( age < CACHE_TTL )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

OPENCODE_CFG="$HOME/.config/opencode/opencode.json"
API_KEY="${ZAI_API_KEY:-}"

if [[ -z "$API_KEY" ]] && [[ -f "$OPENCODE_CFG" ]]; then
    API_KEY=$(jq -r '.provider["zai-coding-plan"].options.apiKey // empty' "$OPENCODE_CFG" 2>/dev/null)
fi

if [[ -z "$API_KEY" ]]; then
    echo '{"text": "󱊩 --", "class": "disconnected", "tooltip": "Z.ai: no API key found"}'
    exit 0
fi

response=$(curl -s -m 15 \
    -H "Authorization: $API_KEY" \
    -H "Accept-Language: en-US,en" \
    "https://api.z.ai/api/monitor/usage/quota/limit" 2>/dev/null)

if [[ $? -ne 0 ]] || [[ -z "$response" ]]; then
    echo '{"text": "󱊩 err", "class": "error", "tooltip": "Z.ai: connection failed"}'
    exit 0
fi

# Parse the first TOKENS_LIMIT entry: percentage = % used, number = remaining (in M)
pct=$(echo "$response" | jq -r '[.data.limits[] | select(.type == "TOKENS_LIMIT")] | first | .percentage // empty' 2>/dev/null)
remaining=$(echo "$response" | jq -r '[.data.limits[] | select(.type == "TOKENS_LIMIT")] | first | .number // empty' 2>/dev/null)
next_reset=$(echo "$response" | jq -r '[.data.limits[] | select(.type == "TOKENS_LIMIT")] | first | .nextResetTime // empty' 2>/dev/null)

if [[ -z "$pct" ]]; then
    echo '{"text": "󱊩 ok", "class": "normal", "tooltip": "Z.ai: connected"}'
    exit 0
fi

used=$pct
css_class=$( (( used >= 90 )) && echo "critical" || ( (( used >= 70 )) && echo "warning" || echo "normal" ) )

reset_str=""
if [[ -n "$next_reset" ]]; then
    reset_str=$(python3 -c "
import datetime
t = int('$next_reset') / 1000
dt = datetime.datetime.fromtimestamp(t)
delta = dt - datetime.datetime.now()
h = int(delta.total_seconds() // 3600)
m = int((delta.total_seconds() % 3600) // 60)
print(f', resets in {h}h{m:02d}m' if delta.total_seconds() > 0 else '')
" 2>/dev/null)
fi

tooltip="Z.ai: ${used}% used (${remaining}M remaining${reset_str})"
result="{\"text\": \"󱊩 ${used}%\", \"class\": \"${css_class}\", \"tooltip\": \"${tooltip}\"}"
echo "$result" | tee "$CACHE_FILE"
