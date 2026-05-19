#!/bin/bash
# PiAPI Video Generator — Kling Integration v1.0
# Uso: source .piapi_video.sh

PIAPI_KEY=$(cat /home/z/my-project/.secrets/piapi_api)
BASE_URL="https://api.piapi.ai/api/v1"
TASK_DIR="/home/z/my-project/download/video_tasks"
mkdir -p "$TASK_DIR"

# Genera video da prompt
generate_video() {
    local PROMPT="$1"
    local NEGATIVE="${2:-modern buildings cars phones electricity}"
    local DURATION="${3:-5}"
    local ASPECT="${4:-16:9}"
    local LABEL="${5:-scene_$(date +%s)}"
    
    echo "Generazione video: $LABEL"
    echo "Prompt: ${PROMPT:0:80}..."
    
    local RESP=$(curl -s -X POST "$BASE_URL/task" \
        -H "x-api-key: $PIAPI_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"kling\",
            \"task_type\": \"text_to_video\",
            \"input\": {
                \"prompt\": $(python3 -c "import json; print(json.dumps('$PROMPT'))"),
                \"negative_prompt\": \"$NEGATIVE\",
                \"duration\": $DURATION,
                \"aspect_ratio\": \"$ASPECT\"
            },
            \"config\": {\"service_mode\": \"public\"}
        }")
    
    local TASK_ID=$(echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('task_id',''))" 2>/dev/null)
    
    if [ -z "$TASK_ID" ]; then
        echo "ERRORE: $(echo $RESP | head -c 200)"
        return 1
    fi
    
    echo "Task ID: $TASK_ID"
    echo "$TASK_ID|$LABEL|$PROMPT" >> "$TASK_DIR/tasks.log"
    echo "$TASK_ID"
}

# Controlla stato task
check_task() {
    local TASK_ID="$1"
    
    curl -s -X POST "$BASE_URL/task/status" \
        -H "x-api-key: $PIAPI_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"task_id\": \"$TASK_ID\"}" | python3 -c "
import sys, json
d = json.load(sys.stdin)
data = d.get('data', {})
status = data.get('status', 'unknown')
print(f'Status: {status}')

output = data.get('output', {})
if output and output.get('works'):
    works = output['works']
    for w in works:
        url = w.get('url', '')
        if url:
            print(f'VIDEO_URL: {url}')
else:
    progress = data.get('meta', {}).get('detail', {}).get('progress', 0)
    if progress:
        print(f'Progress: {progress}%')
"
}

# Attendi completamento e scarica
wait_and_download() {
    local TASK_ID="$1"
    local OUTPUT_FILE="${2:-/home/z/my-project/download/video_output.mp4}"
    local MAX_WAIT=600  # 10 minuti max
    local POLL_INTERVAL=15
    
    echo "Attendo completamento task $TASK_ID..."
    local ELAPSED=0
    
    while [ $ELAPSED -lt $MAX_WAIT ]; do
        RESULT=$(check_task "$TASK_ID")
        STATUS=$(echo "$RESULT" | head -1)
        
        echo "[$ELAPSED s] $STATUS"
        
        if echo "$RESULT" | grep -q "VIDEO_URL:"; then
            VIDEO_URL=$(echo "$RESULT" | grep "VIDEO_URL:" | sed 's/VIDEO_URL: //')
            echo "Scarico video da $VIDEO_URL..."
            curl -s -L -o "$OUTPUT_FILE" "$VIDEO_URL"
            echo "Salvato: $OUTPUT_FILE"
            echo "$TASK_ID|$OUTPUT_FILE|$(date -Iseconds)" >> "$TASK_DIR/completed.log"
            return 0
        fi
        
        if echo "$STATUS" | grep -qi "fail\|error"; then
            echo "ERRORE: Task fallito"
            return 1
        fi
        
        sleep $POLL_INTERVAL
        ELAPSED=$((ELAPSED + POLL_INTERVAL))
    done
    
    echo "TIMEOUT: Task non completato in ${MAX_WAIT}s"
    return 1
}

echo "PiAPI Video Generator caricato"
echo "Comandi: generate_video, check_task, wait_and_download"
