#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  GITHUB SAFETY SYSTEM — Anti-Disconnessione v2.0           ║
# ║  Prevende perdita di accesso al repo Dream Team             ║
# ║  Creato: 20 Maggio 2026 — Super Z AI                       ║
# ╚══════════════════════════════════════════════════════════════╝

REPO_OWNER="Schumynet"
REPO_NAME="youtube-ai-dream-team"
REPO_FULL="$REPO_OWNER/$REPO_NAME"
API_BASE="https://api.github.com/repos/$REPO_FULL"
TOKEN_FILE="/home/z/my-project/.secrets/github_token"
ENV_FILE="/home/z/my-project/.env"
CONFIG_FILE="/home/z/my-project/LOCAL_CONFIG.md"

# ═════════════════════════════════════════════
# FUNZIONE 1: Carica token con fallback multi-locazione
# ═════════════════════════════════════════════
load_token() {
    # Priority 1: File .secrets (primario)
    if [ -f "$TOKEN_FILE" ]; then
        TOKEN=$(cat "$TOKEN_FILE" | tr -d '\n\r ')
        if [ ${#TOKEN} -gt 10 ]; then
            echo "TOKEN_OK:secrets"
            export GITHUB_TOKEN="$TOKEN"
            return 0
        fi
    fi
    
    # Priority 2: Variabile ambiente
    if [ ${#GITHUB_TOKEN:-0} -gt 10 ]; then
        echo "TOKEN_OK:env"
        return 0
    fi
    
    # Priority 3: .env file
    if [ -f "$ENV_FILE" ]; then
        ENV_TOKEN=$(grep -oP 'GITHUB_TOKEN=\K.*' "$ENV_FILE" 2>/dev/null | tr -d '"' | tr -d "'" | tr -d '\n\r ')
        if [ ${#ENV_TOKEN:-0} -gt 10 ]; then
            echo "TOKEN_OK:dotenv"
            export GITHUB_TOKEN="$ENV_TOKEN"
            return 0
        fi
    fi
    
    # Priority 4: Backup crittografato
    if [ -f "$TOKEN_FILE.bak" ]; then
        BACKUP_TOKEN=$(cat "$TOKEN_FILE.bak" | tr -d '\n\r ')
        if [ ${#BACKUP_TOKEN} -gt 10 ]; then
            echo "TOKEN_OK:backup"
            export GITHUB_TOKEN="$BACKUP_TOKEN"
            return 0
        fi
    fi
    
    echo "TOKEN_MISSING: Nessun token trovato"
    return 1
}

# ═════════════════════════════════════════════
# FUNZIONE 2: Salva token in tutte le locazioni
# ═════════════════════════════════════════════
save_token() {
    local NEW_TOKEN="$1"
    
    if [ ${#NEW_TOKEN} -lt 10 ]; then
        echo "ERRORE: Token troppo corto (${#NEW_TOKEN} chars)"
        return 1
    fi
    
    # Salva in .secrets (primario)
    mkdir -p /home/z/my-project/.secrets
    echo "$NEW_TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    
    # Backup .secrets
    cp "$TOKEN_FILE" "$TOKEN_FILE.bak"
    chmod 600 "$TOKEN_FILE.bak"
    
    # Aggiorna .env se esiste
    if [ -f "$ENV_FILE" ]; then
        if grep -q "GITHUB_TOKEN=" "$ENV_FILE" 2>/dev/null; then
            sed -i "s|GITHUB_TOKEN=.*|GITHUB_TOKEN=$NEW_TOKEN|" "$ENV_FILE"
        else
            echo "GITHUB_TOKEN=$NEW_TOKEN" >> "$ENV_FILE"
        fi
    fi
    
    # Esporta nella sessione
    export GITHUB_TOKEN="$NEW_TOKEN"
    
    echo "TOKEN_SAVED: Salvato in 3 locazioni"
    return 0
}

# ═════════════════════════════════════════════
# FUNZIONE 3: Health Check GitHub
# ═════════════════════════════════════════════
health_check() {
    load_token
    if [ $? -ne 0 ]; then
        echo "HEALTH:CRITICAL — Nessun token disponibile"
        return 2
    fi
    
    local HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        "$API_BASE")
    
    case $HTTP_CODE in
        200) echo "HEALTH:OK — Repo accessibile (HTTP $HTTP_CODE)"; return 0 ;;
        401) echo "HEALTH:TOKEN_EXPIRED — Token scaduto o non valido (HTTP $HTTP_CODE)"; return 2 ;;
        403) echo "HEALTH:FORBIDDEN — Permessi insufficienti (HTTP $HTTP_CODE)"; return 2 ;;
        404) echo "HEALTH:REPO_NOT_FOUND — Repo non trovato o accesso negato (HTTP $HTTP_CODE)"; return 2 ;;
        429) echo "HEALTH:RATE_LIMITED — Rate limit raggiunto, riprova tra 60s (HTTP $HTTP_CODE)"; return 1 ;;
        *)   echo "HEALTH:UNKNOWN — Errore imprevisto (HTTP $HTTP_CODE)"; return 2 ;;
    esac
}

# ═════════════════════════════════════════════
# FUNZIONE 4: Leggi file da GitHub con retry
# ═════════════════════════════════════════════
github_read() {
    local FILE_PATH="$1"
    local MAX_RETRIES=3
    local RETRY_DELAY=2
    
    load_token
    if [ $? -ne 0 ]; then
        echo "ERROR: Impossibile caricare il token GitHub"
        return 1
    fi
    
    for i in $(seq 1 $MAX_RETRIES); do
        local RESPONSE=$(curl -s -w "\n%{http_code}" \
            -H "Authorization: Bearer $GITHUB_TOKEN" \
            "$API_BASE/contents/$FILE_PATH")
        
        local HTTP_CODE=$(echo "$RESPONSE" | tail -1)
        local BODY=$(echo "$RESPONSE" | head -n -1)
        
        case $HTTP_CODE in
            200)
                echo "$BODY" | python3 -c "
import sys, json, base64
try:
    d = json.load(sys.stdin)
    content = d.get('content', '')
    print(base64.b64decode(content).decode('utf-8'))
except Exception as e:
    print(f'PARSE_ERROR: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null
                return 0
                ;;
            401)
                echo "ERROR: Token non valido. Usa: source /home/z/my-project/.github_safety.sh && save_token <NUOVO_TOKEN>"
                return 1
                ;;
            403)
                echo "ERROR: Accesso negato al file $FILE_PATH"
                return 1
                ;;
            404)
                echo "ERROR: File non trovato: $FILE_PATH"
                return 1
                ;;
            429)
                if [ $i -lt $MAX_RETRIES ]; then
                    echo "WARN: Rate limit, attendo ${RETRY_DELAY}s... (tentativo $i/$MAX_RETRIES)"
                    sleep $((RETRY_DELAY * i))
                    RETRY_DELAY=$((RETRY_DELAY * 2))
                else
                    echo "ERROR: Rate limit superato dopo $MAX_RETRIES tentativi"
                    return 1
                fi
                ;;
            *)
                if [ $i -lt $MAX_RETRIES ]; then
                    echo "WARN: Errore HTTP $HTTP_CODE, retry $i/$MAX_RETRIES..."
                    sleep $((RETRY_DELAY * i))
                else
                    echo "ERROR: Impossibile leggere $FILE_PATH dopo $MAX_RETRIES tentativi (HTTP $HTTP_CODE)"
                    return 1
                fi
                ;;
        esac
    done
    return 1
}

# ═════════════════════════════════════════════
# FUNZIONE 5: Scrivi file su GitHub con retry
# ═════════════════════════════════════════════
github_write() {
    local FILE_PATH="$1"
    local CONTENT="$2"
    local COMMIT_MSG="${3:-Update via GitHub Safety System}"
    local MAX_RETRIES=3
    local RETRY_DELAY=2
    
    load_token
    if [ $? -ne 0 ]; then
        echo "ERROR: Impossibile caricare il token GitHub"
        return 1
    fi
    
    # Ottieni SHA del file esistente (necessario per update)
    local SHA=""
    local SHA_RESPONSE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
        "$API_BASE/contents/$FILE_PATH")
    
    SHA=$(echo "$SHA_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sha',''))" 2>/dev/null)
    
    # Codifica contenuto in base64
    local B64_CONTENT=$(echo "$CONTENT" | python3 -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())")
    
    # Costruisci JSON payload
    local JSON_PAYLOAD=$(python3 -c "
import json
payload = {
    'message': '''$COMMIT_MSG''',
    'content': '$B64_CONTENT'
}
sha = '''$SHA'''
if sha:
    payload['sha'] = sha
print(json.dumps(payload))
")
    
    for i in $(seq 1 $MAX_RETRIES); do
        local RESPONSE=$(curl -s -w "\n%{http_code}" \
            -X PUT \
            -H "Authorization: Bearer $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$JSON_PAYLOAD" \
            "$API_BASE/contents/$FILE_PATH")
        
        local HTTP_CODE=$(echo "$RESPONSE" | tail -1)
        
        case $HTTP_CODE in
            200|201)
                echo "OK: File $FILE_PATH aggiornato con successo"
                return 0
                ;;
            401)
                echo "ERROR: Token non valido per scrittura"
                return 1
                ;;
            409)
                echo "ERROR: Conflitto - file modificato esternamente. Rifare github_read prima di github_write."
                return 1
                ;;
            422)
                echo "ERROR: Payload non valido o campo mancante"
                return 1
                ;;
            429)
                if [ $i -lt $MAX_RETRIES ]; then
                    echo "WARN: Rate limit, attendo ${RETRY_DELAY}s..."
                    sleep $((RETRY_DELAY * i))
                    RETRY_DELAY=$((RETRY_DELAY * 2))
                else
                    echo "ERROR: Rate limit dopo $MAX_RETRIES tentativi"
                    return 1
                fi
                ;;
            *)
                if [ $i -lt $MAX_RETRIES ]; then
                    echo "WARN: Errore HTTP $HTTP_CODE, retry $i/$MAX_RETRIES..."
                    sleep $((RETRY_DELAY * i))
                else
                    echo "ERROR: Scrittura fallita dopo $MAX_RETRIES tentativi (HTTP $HTTP_CODE)"
                    return 1
                fi
                ;;
        esac
    done
    return 1
}

# ═════════════════════════════════════════════
# FUNZIONE 6: Lista directory GitHub
# ═════════════════════════════════════════════
github_list() {
    local DIR_PATH="${1:-}"
    local URL="$API_BASE/contents/$DIR_PATH"
    
    load_token
    if [ $? -ne 0 ]; then
        echo "ERROR: Impossibile caricare il token"
        return 1
    fi
    
    curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$URL" | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list):
        for item in data:
            icon = 'DIR ' if item['type'] == 'dir' else 'FILE'
            print(f'{icon}  {item[\"name\"]}')
    else:
        print(f'ERROR: {data.get(\"message\", \"Risposta imprevista\")}')
except Exception as e:
    print(f'PARSE_ERROR: {e}')
" 2>/dev/null
}

# ═════════════════════════════════════════════
# FUNZIONE 7: Status completo del sistema
# ═════════════════════════════════════════════
status() {
    echo "╔══════════════════════════════════════════════════╗"
    echo "║  GITHUB SAFETY SYSTEM — Status Report            ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo ""
    
    # Token locations
    echo "--- TOKEN LOCATIONS ---"
    [ -f "$TOKEN_FILE" ] && echo "[OK] .secrets/github_token ($(wc -c < $TOKEN_FILE) bytes)" || echo "[!!] .secrets/github_token NON ESISTE"
    [ -f "$TOKEN_FILE.bak" ] && echo "[OK] .secrets/github_token.bak ($(wc -c < $TOKEN_FILE.bak) bytes)" || echo "[!!] Backup NON ESISTE"
    grep -q "GITHUB_TOKEN=" "$ENV_FILE" 2>/dev/null && echo "[OK] .env contiene GITHUB_TOKEN" || echo "[!!] .env NON contiene GITHUB_TOKEN"
    [ ${#GITHUB_TOKEN} -gt 10 ] && echo "[OK] GITHUB_TOKEN in env (${#GITHUB_TOKEN} chars)" || echo "[!!] GITHUB_TOKEN non in env"
    echo ""
    
    # Health check
    echo "--- REPO HEALTH ---"
    health_check
    echo ""
    
    # Repo info
    echo "--- REPO INFO ---"
    load_token 2>/dev/null
    if [ ${#GITHUB_TOKEN:-0} -gt 10 ]; then
        curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$API_BASE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'  Repo:      {d.get(\"full_name\", \"N/A\")}')
print(f'  Private:   {d.get(\"private\", \"N/A\")}')
print(f'  Branch:    {d.get(\"default_branch\", \"N/A\")}')
print(f'  Size:      {d.get(\"size\", 0)} KB')
print(f'  Updated:   {d.get(\"updated_at\", \"N/A\")}')
" 2>/dev/null
    fi
    
    # File structure
    echo ""
    echo "--- REPO ROOT ---"
    github_list ""
}

# ═════════════════════════════════════════════
# AUTO-INIT: Carica token alla source
# ═════════════════════════════════════════════
load_token 2>/dev/null

# ═════════════════════════════════════════════
# HELP
# ═════════════════════════════════════════════
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo ""
    echo "GITHUB SAFETY SYSTEM v2.0 — Comandi:"
    echo ""
    echo "  source .github_safety.sh              Carica il sistema"
    echo "  save_token <TOKEN>                    Salva in tutte le locazioni"
    echo "  health_check                          Verifica connessione"
    echo "  github_read <PATH>                    Leggi file dal repo"
    echo "  github_write <PATH> <CONTENT> [MSG]   Scrivi file nel repo"
    echo "  github_list [PATH]                    Lista directory"
    echo "  status                                Status completo"
    echo "  load_token                            Ricarica token"
    echo ""
fi
