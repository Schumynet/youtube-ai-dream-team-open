#!/bin/bash
###############################################################################
#  sync_to_public.sh — YouTube AI Dream Team
#  Sincronizza il repo PRIVATO → PUBBLICO con pulizia automatica dati sensibili
#
#  Uso:  ./sync_to_public.sh [--dry-run] [--verbose]
#
#  Cosa fa:
#    1. Clona/aggiorna il repo privato
#    2. Copia i file in una directory temporanea
#    3. Rimuove tutti i dati sensibili (token, path, username)
#    4. Aggiunge README pubblico, LICENSE, CONTRIBUTING se mancanti
#    5. Push al repo pubblico
#    6. Pulisce i file temporanei
###############################################################################

set -euo pipefail

# ─── Configurazione ──────────────────────────────────────────────────────────
PRIVATE_REPO="Schumynet/youtube-ai-dream-team"
PUBLIC_REPO="Schumynet/youtube-ai-dream-team-open"
TOKEN_FILE="/home/z/my-project/.secrets/github_token"
WORK_DIR="/tmp/youtube-sync-$$"

DRY_RUN=false
VERBOSE=false
SYNC_LOG="/home/z/my-project/download/sync_log.txt"
FILE_COUNT=0

# Parse args
for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --verbose)  VERBOSE=true ;;
    --help|-h)
      echo "Uso: $0 [--dry-run] [--verbose]"
      echo "  --dry-run   Simula senza pushare"
      echo "  --verbose   Output dettagliato"
      exit 0
      ;;
  esac
done

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log()       { echo -e "${BLUE}[SYNC]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()   { echo -e "${RED}[ERR]${NC} $1"; }
log_info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

# ─── Pre-flight checks ───────────────────────────────────────────────────────
log "=== YouTube AI Dream Team — Sync Privato → Pubblico ==="
echo ""

# Check token
if [[ ! -f "$TOKEN_FILE" ]]; then
  log_err "Token non trovato: $TOKEN_FILE"
  exit 1
fi
TOKEN=$(cat "$TOKEN_FILE")
if [[ -z "$TOKEN" ]]; then
  log_err "Token vuoto in $TOKEN_FILE"
  exit 1
fi

# Verify token works
USER_LOGIN=$(curl -s -H "Authorization: Bearer $TOKEN" https://api.github.com/user 2>/dev/null | jq -r '.login' || echo "")
if [[ -z "$USER_LOGIN" ]] || [[ "$USER_LOGIN" == "null" ]]; then
  log_err "Token non valido o scaduto"
  exit 1
fi
log_ok "Token valido: $USER_LOGIN"

# Verify both repos accessible
for REPO in "$PRIVATE_REPO" "$PUBLIC_REPO"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/$REPO")
  if [[ "$STATUS" != "200" ]]; then
    log_err "Repo non accessibile: $REPO (HTTP $STATUS)"
    exit 1
  fi
  log_ok "Repo accessibile: $REPO"
done

# ─── Step 1: Clone/Update Private Repo ──────────────────────────────────────
log ""
log "━━━ STEP 1/6: Clone repo privato ━━━"

PRIVATE_DIR="$WORK_DIR/private"
PUBLIC_DIR="$WORK_DIR/public"

mkdir -p "$WORK_DIR"

if [[ -d "$PRIVATE_DIR/.git" ]]; then
  cd "$PRIVATE_DIR" && git pull --rebase origin main 2>/dev/null && cd /
  log_ok "Repo privato aggiornato (git pull)"
else
  git clone "https://x-access-token:${TOKEN}@github.com/${PRIVATE_REPO}.git" "$PRIVATE_DIR" 2>/dev/null
  log_ok "Repo privato clonato"
fi

if [[ "$VERBOSE" == true ]]; then
  log_info "File nel privato: $(find "$PRIVATE_DIR" -name "*.md" -not -path "*/.git/*" | wc -l) md, $(find "$PRIVATE_DIR" -name "*.json" -not -path "*/.git/*" | wc -l) json, $(find "$PRIVATE_DIR" -name "*.html" -not -path "*/.git/*" | wc -l) html"
fi

# ─── Step 2: Copy to Public Dir ────────────────────────────────────────────
log ""
log "━━━ STEP 2/6: Copia file ━━━"

rm -rf "$PUBLIC_DIR"
mkdir -p "$PUBLIC_DIR"

# Copy everything except .git
rsync -a --exclude='.git' "$PRIVATE_DIR/" "$PUBLIC_DIR/"
log_ok "File copiati: $(find "$PUBLIC_DIR" -type f | wc -l) files"

# Remove test/tmp files
find "$PUBLIC_DIR" -name "test.txt" -delete 2>/dev/null
find "$PUBLIC_DIR" -name ".DS_Store" -delete 2>/dev/null
find "$PUBLIC_DIR" -name "*.tmp" -delete 2>/dev/null

# ─── Step 3: Sanitize Sensitive Data ────────────────────────────────────────
log ""
log "━━━ STEP 3/6: Pulizia dati sensibili ━━━"

SANITIZE_COUNT=0

# 3a — Markdown files
while IFS= read -r -d '' file; do
  CHANGES=0

  # Replace token paths
  if grep -q "/home/z/my-project/.secrets/github_token" "$file" 2>/dev/null; then
    sed -i 's|/home/z/my-project/.secrets/github_token|$GITHUB_TOKEN (variabile d'\''ambiente)|g' "$file"
    CHANGES=$((CHANGES + 1))
  fi

  # Replace local paths
  if grep -q "/home/z/my-project/" "$file" 2>/dev/null; then
    sed -i -e 's|/home/z/my-project/download/|./download/|g' \
           -e 's|/home/z/my-project/git_sync/|./git_sync/|g' \
           -e 's|/home/z/my-project/.env|.env|g' \
           -e 's|/home/z/my-project/LOCAL_CONFIG.md|./LOCAL_CONFIG.md|g' \
           -e 's|/home/z/my-project/skills/|./skills/|g' \
           -e 's|/home/z/my-project/||g' \
           "$file"
    CHANGES=$((CHANGES + 1))
  fi

  # Replace repo references
  if grep -q "Schumynet/youtube-ai-dream-team" "$file" 2>/dev/null; then
    sed -i 's|Schumynet/youtube-ai-dream-team|YOUR_USERNAME/youtube-ai-dream-team|g' "$file"
    CHANGES=$((CHANGES + 1))
  fi

  # Replace username references (only in specific contexts, not copyright)
  if grep -q "Schumynet" "$file" 2>/dev/null; then
    sed -i 's|Schumynet|YOUR_USERNAME|g' "$file"
    CHANGES=$((CHANGES + 1))
  fi

  # Replace token fragments
  if grep -qE "github_pat_[A-Za-z0-9_]+" "$file" 2>/dev/null; then
    sed -i -E 's|github_pat_[A-Za-z0-9_]{10,}|github_pat_XXXXXXXXXXXX|g' "$file"
    CHANGES=$((CHANGES + 1))
  fi

  if [[ $CHANGES -gt 0 ]]; then
    SANITIZE_COUNT=$((SANITIZE_COUNT + CHANGES))
    [[ "$VERBOSE" == true ]] && log_info "Pulito: $(basename "$file") ($CHANGES sostituzioni)"
  fi

done < <(find "$PUBLIC_DIR" -name "*.md" -print0)

# 3b — Python files
while IFS= read -r -d '' file; do
  if grep -q "/home/z/" "$file" 2>/dev/null; then
    sed -i "s|/home/z/my-project/[^'\"]*|./|g" "$file"
    SANITIZE_COUNT=$((SANITIZE_COUNT + 1))
    [[ "$VERBOSE" == true ]] && log_info "Pulito: $(basename "$file")"
  fi
done < <(find "$PUBLIC_DIR" -name "*.py" -print0)

# 3c — HTML files
while IFS= read -r -d '' file; do
  CHANGES=0
  if grep -q "Schumynet" "$file" 2>/dev/null; then
    sed -i -e 's|Schumynet — AI Dream Team Command Center|AI Dream Team — Command Center|g' \
           -e 's|Schumynet/youtube-ai-dream-team|YOUR_USERNAME/youtube-ai-dream-team|g' \
           -e 's|github.com/Schumynet|github.com/YOUR_USERNAME|g' \
           -e 's|Schumynet AI Dream Team|AI Dream Team|g' \
           "$file"
    CHANGES=$((CHANGES + 1))
  fi
  if grep -qE "github_pat_[A-Za-z0-9_]+" "$file" 2>/dev/null; then
    sed -i -E 's|github_pat_[A-Za-z0-9_]{10,}|github_pat_XXXXXXXXXXXX|g' "$file"
    CHANGES=$((CHANGES + 1))
  fi
  if [[ $CHANGES -gt 0 ]]; then
    SANITIZE_COUNT=$((SANITIZE_COUNT + CHANGES))
    [[ "$VERBOSE" == true ]] && log_info "Pulito: $(basename "$file") ($CHANGES sostituzioni)"
  fi
done < <(find "$PUBLIC_DIR" -name "*.html" -print0)

log_ok "Pulizia completata: $SANITIZE_COUNT sostituzioni in $(find "$PUBLIC_DIR" -type f | wc -l) file"

# ─── Step 4: Verify No Leaks ────────────────────────────────────────────────
log ""
log "━━━ STEP 4/6: Verifica sicurezza ━━━"

LEAK_FOUND=false

# Check for leaked paths
LEAK_PATHS=$(grep -rn "/home/z/" "$PUBLIC_DIR" --include="*.md" --include="*.html" --include="*.py" --include="*.json" 2>/dev/null || true)
if [[ -n "$LEAK_PATHS" ]]; then
  log_warn "Trovati path locali residui:"
  echo "$LEAK_PATHS" | head -5
  LEAK_FOUND=true
fi

# Check for leaked tokens (exclude XXXX placeholders)
LEAK_TOKENS=$(grep -rnE "github_pat_[A-Za-z0-9]{12,}" "$PUBLIC_DIR" --include="*.md" --include="*.html" --include="*.py" --include="*.json" 2>/dev/null | grep -v "XXXXXXXX" || true)
if [[ -n "$LEAK_TOKENS" ]]; then
  log_warn "Trovati token residui (non placeholder):"
  echo "$LEAK_TOKENS" | head -5
  LEAK_FOUND=true
fi

# Check for leaked API keys
LEAK_KEYS=$(grep -rnE "(sk_live|sk_test|ghp_|gho_|ghu_|ghs_|ghc_)[A-Za-z0-9]{20,}" "$PUBLIC_DIR" --include="*.md" --include="*.html" --include="*.py" --include="*.json" 2>/dev/null || true)
if [[ -n "$LEAK_KEYS" ]]; then
  log_err "TROVATE CHIAVI API! Intercetto il sync."
  echo "$LEAK_KEYS" | head -5
  exit 1
fi

if [[ "$LEAK_FOUND" == true ]]; then
  log_warn "Alcuni dati residui trovati — verifica manuale consigliata"
else
  log_ok "Nessun dato sensibile rilevato ✅"
fi

# ─── Step 5: Add Open-Source Files ──────────────────────────────────────────
log ""
log "━━━ STEP 5/6: File open-source ━━━"

# Add/update .gitignore if missing
if [[ ! -f "$PUBLIC_DIR/.gitignore" ]]; then
  cat > "$PUBLIC_DIR/.gitignore" << 'GITIGNORE'
# Secrets — MAI committare
.env
.env.*
.secrets/
*.key
*.pem
*.token

# OS
.DS_Store
Thumbs.db

# Temp
*.tmp
*.log
*.bak

# IDE
.vscode/
.idea/
*.swp
GITIGNORE
  log_ok ".gitignore creato"
fi

log_ok "File open-source verificati"

# ─── Step 6: Push to Public Repo ────────────────────────────────────────────
log ""
log "━━━ STEP 6/6: Push al repo pubblico ━━━"

if [[ "$DRY_RUN" == true ]]; then
  log_warn "DRY RUN — nessun push eseguito"
  log_info "File che sarebbero stati pushati: $(find "$PUBLIC_DIR" -type f | wc -l)"
else
  # Init git if needed
  cd "$PUBLIC_DIR"
  rm -rf .git
  git init
  git checkout -b main 2>/dev/null || git checkout main
  git config user.name "Schumynet"
  git config user.email "schumynet@users.noreply.github.com"

  # Count changes
  FILE_COUNT=$(find "$PUBLIC_DIR" -type f -not -path "*/.git/*" | wc -l)

  # Add, commit, push
  git add -A

  # Check if there are actual changes
  CHANGED=$(git diff --cached --stat 2>/dev/null | wc -l)
  if [[ "$CHANGED" -eq 0 ]]; then
    log_info "Nessuna modifica da pushare — repo aggiornato"
  else
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    COMMIT_MSG="sync: auto-sync from private repo ($TIMESTAMP)

- $FILE_COUNT file sincronizzati
- $SANITIZE_COUNT sostituzioni sicurezza applicate
- Dati sensibili rimossi automaticamente"

    git commit -m "$COMMIT_MSG" --allow-empty 2>&1 | tail -3

    # Push
    git remote add origin "https://x-access-token:${TOKEN}@github.com/${PUBLIC_REPO}.git" 2>/dev/null || \
      git remote set-url origin "https://x-access-token:${TOKEN}@github.com/${PUBLIC_REPO}.git"

    PUSH_OUTPUT=$(git push -f origin main 2>&1)
    PUSH_RC=$?

    if [[ $PUSH_RC -eq 0 ]]; then
      log_ok "Push completato: $FILE_COUNT file → $PUBLIC_REPO"
    else
      log_err "Push fallito — verifica il token"
      exit 1
    fi
  fi

  cd /
fi

# ─── Cleanup ────────────────────────────────────────────────────────────────
rm -rf "$WORK_DIR"

# ─── Log ─────────────────────────────────────────────────────────────────────
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "" >> "$SYNC_LOG" 2>/dev/null
echo "[$END_TIME] sync: $SANITIZE_COUNT sanitizzazioni, $FILE_COUNT file → $PUBLIC_REPO" >> "$SYNC_LOG" 2>/dev/null

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════"
log_ok "SYNC COMPLETATO"
echo ""
echo "  Repo privato:  https://github.com/$PRIVATE_REPO"
echo "  Repo pubblico: https://github.com/$PUBLIC_REPO"
echo "  File syncati:  $FILE_COUNT"
echo "  Sanitizzazioni: $SANITIZE_COUNT"
echo "  Timestamp:     $END_TIME"
echo "═══════════════════════════════════════════════════"
echo ""
