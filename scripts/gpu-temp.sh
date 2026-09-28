#!/bin/bash
t=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
# nvidia-smi can dump NVML init errors to stdout, so validate $t is numeric.
if ! [[ "$t" =~ ^[0-9]+$ ]]; then
    echo '{"text": "N/A", "class": "normal"}'
elif [ "$t" -ge 80 ]; then
    echo "{\"text\": \"${t}°C\", \"class\": \"critical\"}"
else
    echo "{\"text\": \"${t}°C\", \"class\": \"normal\"}"
fi
