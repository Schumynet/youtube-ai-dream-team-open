#!/bin/bash
###############################################################################
#  sync_to_private.sh — YouTube AI Dream Team
#  Sincronizza il lavoro LOCALE → Repo PRIVATO su GitHub
#
#  Uso:  ./sync_to_private.sh [--dry-run] [--verbose] [--include-videos]
#
#  Cosa fa:
#    1. Raccoglie tutti i file di lavoro dalla sessione locale
#    2. Uploada SOP, template, script, config al repo privato
#    3. Aggiorna dream_team_index.md e README.md se cambiati
#    4. (Opzionale) Carica video e asset pesanti
#    5. Aggiorna il log delle operazioni
#
#  IMPORTANTE: Questo script carica SOLO nel repo PRIVATO.
#  Usa sync_to_public.sh dopo per la versione pulita.
###############################################################################

set -uo pipefail

# ─── Configurazione ──────────────────────────────────────────────────────────
PRIVATE_REPO="Schumynet/youtube-ai-dream-team"
TOKEN_FILE="/home/z/my-project/.secrets/github_token"
LOCAL_WORK="/home/z/my-project"
LOCAL_DOWNLOAD="/home/z/my-project/download"
SYNC_LOG="/home/z/my-project/download/sync_log.txt"

DRY_RUN=false
VERBOSE=false
INCLUDE_VIDEOS=false
INCLUDE_IMAGES=false

# Parse args
for arg in "$@"; do
  case "$arg" in
    --dry-run)         DRY_RUN=true ;;
    --verbose)         VERBOSE=true ;;
    --include-videos)  INCLUDE_VIDEOS=true ;;
    --include-images)  INCLUDE_IMAGES=true ;;
    --all)             INCLUDE_VIDEOS=true; INCLUDE_IMAGES=true ;;
    --help|-h)
      echo "Uso: $0 [--dry-run] [--verbose] [--include-videos] [--include-images] [--all]"
      echo ""
      echo "  --dry-run         Simula senza caricare"
      echo "  --verbose         Output dettagliato"
      echo "  --include-videos  Includi file .mp4/.mov"
      echo "  --include-images  Includi immagini .png/.jpg"
      echo "  --all             Includi tutto (video + immagini)"
      exit 0
      ;;
  esac
done

# ─── Colors ──────────────────────────────────────────────────────────────────
log()       { echo -e "\033[0;34m[→PRIVATO]\033[0m $1"; }
log_ok()    { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn()  { echo -e "\033[1;33m[!]\033[0m $1"; }
log_err()   { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_info()  { echo -e "\033[0;36m[i]\033[0m $1"; }

# ─── Counters ────────────────────────────────────────────────────────────────
UPLOAD_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0
TOTAL_BYTES=0

# ─── Pre-flight ──────────────────────────────────────────────────────────────
log "=== Sync LOCALE → Repo PRIVATO ==="
echo ""

if [[ ! -f "$TOKEN_FILE" ]]; then
  log_err "Token non trovato: $TOKEN_FILE"
  exit 1
fi
TOKEN=$(cat "$TOKEN_FILE")

USER_LOGIN=$(curl -s -H "Authorization: Bearer $TOKEN" https://api.github.com/user 2>/dev/null | jq -r '.login' || echo "")
if [[ -z "$USER_LOGIN" ]] || [[ "$USER_LOGIN" == "null" ]]; then
  log_err "Token non valido"
  exit 1
fi
log_ok "Token valido: $USER_LOGIN"

# Verifica repo accessibile
REPO_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
  "https://api.github.com/repos/$PRIVATE_REPO")
if [[ "$REPO_STATUS" != "200" ]]; then
  log_err "Repo non accessibile: $PRIVATE_REPO (HTTP $REPO_STATUS)"
  exit 1
fi
log_ok "Repo accessibile: $PRIVATE_REPO"

# ─── Funzione: Upload file singolo ──────────────────────────────────────────
upload_file() {
  local LOCAL_PATH="$1"
  local REMOTE_PATH="$2"
  local COMMIT_MSG="$3"

  # Check file size (GitHub API limit: 100MB per file)
  local FILE_SIZE=$(stat -c%s "$LOCAL_PATH" 2>/dev/null || stat -f%z "$LOCAL_PATH" 2>/dev/null || echo 0)
  local FILE_SIZE_MB=$((FILE_SIZE / 1024 / 1024))

  # Skip video files unless --include-videos
  if [[ "$INCLUDE_VIDEOS" != true ]]; then
    case "$LOCAL_PATH" in
      *.mp4|*.mov|*.avi|*.mkv|*.webm)
        SKIP_COUNT=$((SKIP_COUNT + 1))
        [[ "$VERBOSE" == true ]] && log_info "Saltato (video): $(basename "$LOCAL_PATH") (${FILE_SIZE_MB}MB)"
        return 0
        ;;
    esac
  fi

  # Skip large images unless --include-images
  if [[ "$INCLUDE_IMAGES" != true ]]; then
    case "$LOCAL_PATH" in
      *.png|*.jpg|*.jpeg|*.webp)
        if [[ $FILE_SIZE_MB -gt 2 ]]; then
          SKIP_COUNT=$((SKIP_COUNT + 1))
          [[ "$VERBOSE" == true ]] && log_info "Saltato (immagine >2MB): $(basename "$LOCAL_PATH") (${FILE_SIZE_MB}MB)"
          return 0
        fi
        ;;
    esac
  fi

  # Skip files > 50MB always (GitHub limit)
  if [[ $FILE_SIZE_MB -gt 50 ]]; then
    log_warn "File troppo grande (>${FILE_SIZE_MB}MB), saltato: $(basename "$LOCAL_PATH")"
    SKIP_COUNT=$((SKIP_COUNT + 1))
    return 0
  fi

  # Skip binary/cache/secret files
  case "$(basename "$LOCAL_PATH")" in
    *.pyc|__pycache__|*.log|*.bak|*.tmp|.DS_Store)
      SKIP_COUNT=$((SKIP_COUNT + 1))
      return 0
      ;;
  esac

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Upload: $REMOTE_PATH ($(basename "$LOCAL_PATH"), ${FILE_SIZE_MB}MB)"
    UPLOAD_COUNT=$((UPLOAD_COUNT + 1))
    return 0
  fi

  # Encode file as base64
  local B64_CONTENT=$(base64 -w0 "$LOCAL_PATH" 2>/dev/null)
  if [[ -z "$B64_CONTENT" ]]; then
    log_err "Impossibile encodare: $(basename "$LOCAL_PATH")"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    return 1
  fi

  # Check if file exists on remote (to get SHA for update)
  local SHA=""
  local FILE_INFO=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/$PRIVATE_REPO/contents/$REMOTE_PATH" 2>/dev/null)
  SHA=$(echo "$FILE_INFO" | jq -r '.sha // empty' 2>/dev/null)

  # Build JSON payload using printf (avoids "Argument list too long" with jq)
  local TMP_JSON=$(mktemp)
  if [[ -n "$SHA" ]]; then
    # Use jq with --rawfile to read base64 from file, avoiding arg length limits
    local TMP_B64=$(mktemp)
    echo -n "$B64_CONTENT" > "$TMP_B64"
    jq -n --rawfile content "$TMP_B64" \
      --arg message "$COMMIT_MSG" \
      --arg sha "$SHA" \
      '{message: $message, content: $content, sha: $sha}' > "$TMP_JSON"
    rm -f "$TMP_B64"
  else
    local TMP_B64=$(mktemp)
    echo -n "$B64_CONTENT" > "$TMP_B64"
    jq -n --rawfile content "$TMP_B64" \
      --arg message "$COMMIT_MSG" \
      '{message: $message, content: $content}' > "$TMP_JSON"
    rm -f "$TMP_B64"
  fi

  # Upload via API
  local RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$PRIVATE_REPO/contents/$REMOTE_PATH" \
    -d @"$TMP_JSON" 2>/dev/null)
  rm -f "$TMP_JSON"

  local HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  local RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

  if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
    UPLOAD_COUNT=$((UPLOAD_COUNT + 1))
    TOTAL_BYTES=$((TOTAL_BYTES + FILE_SIZE))
    log_ok "Upload: $REMOTE_PATH ($(basename "$LOCAL_PATH"), ${FILE_SIZE_MB}MB)"
    [[ "$VERBOSE" == true ]] && log_info "  SHA: $(echo "$RESPONSE_BODY" | jq -r '.commit.sha[0:12]' 2>/dev/null)"
    return 0
  else
    local ERR_MSG=$(echo "$RESPONSE_BODY" | jq -r '.message' 2>/dev/null)
    log_err "Upload fallito: $REMOTE_PATH — $ERR_MSG (HTTP $HTTP_CODE)"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    return 1
  fi
}

# ─── STEP 1: Sync Scripts e Config ──────────────────────────────────────────
log ""
log "━━━ STEP 1/5: Script e Config ━━━"

# .github_safety.sh
if [[ -f "$LOCAL_WORK/.github_safety.sh" ]]; then
  upload_file "$LOCAL_WORK/.github_safety.sh" "tools/github_safety.sh" \
    "chore: aggiornato github_safety.sh"
fi

# .piapi_video.sh
if [[ -f "$LOCAL_WORK/.piapi_video.sh" ]]; then
  upload_file "$LOCAL_WORK/.piapi_video.sh" "tools/piapi_video.sh" \
    "chore: aggiornato piapi_video.sh"
fi

# .sync_to_public.sh
if [[ -f "$LOCAL_WORK/.sync_to_public.sh" ]]; then
  upload_file "$LOCAL_WORK/.sync_to_public.sh" "tools/sync_to_public.sh" \
    "chore: aggiornato sync_to_public.sh"
fi

# .sync_to_private.sh (questo script stesso)
if [[ -f "$LOCAL_WORK/.sync_to_private.sh" ]]; then
  upload_file "$LOCAL_WORK/.sync_to_private.sh" "tools/sync_to_private.sh" \
    "chore: aggiornato sync_to_private.sh"
fi

# LOCAL_CONFIG.md
if [[ -f "$LOCAL_WORK/LOCAL_CONFIG.md" ]]; then
  upload_file "$LOCAL_WORK/LOCAL_CONFIG.md" "LOCAL_CONFIG.md" \
    "chore: aggiornato LOCAL_CONFIG.md"
fi

# ─── STEP 2: Sync SOPs da download/ ─────────────────────────────────────────
log ""
log "━━━ STEP 2/5: Agenti SOP ━━━"

# Cerca SOP agenti nella cartella download
for sop_file in "$LOCAL_DOWNLOAD"/agent_*.md; do
  [[ -f "$sop_file" ]] || continue
  BASENAME=$(basename "$sop_file")

  # Determina il dipartimento dal numero agente
  AGENT_NUM=$(echo "$BASENAME" | grep -oP '\d+' | head -1)
  case "$AGENT_NUM" in
    0[1-6]) DEPT_DIR="department_a_strategy" ;;
    07|08|09|1[01]) DEPT_DIR="department_b_preproduction" ;;
    1[2-6]) DEPT_DIR="department_c_production" ;;
    1[7-9]|2[01]) DEPT_DIR="department_d_distribution" ;;
    2[2-5]) DEPT_DIR="department_e_engagement" ;;
    2[6-9]|30) DEPT_DIR="department_f_monetization" ;;
    3[1-5]) DEPT_DIR="department_g_orchestration" ;;
    3[6-9]|4[0-9]) DEPT_DIR="department_h_nextgen_ai" ;;
    *) DEPT_DIR="department_h_nextgen_ai" ;;
  esac

  upload_file "$sop_file" "sops/$DEPT_DIR/$BASENAME" \
    "feat: aggiornato $BASENAME"
done

# ─── STEP 3: Sync Documenti e Indici ────────────────────────────────────────
log ""
log "━━━ STEP 3/5: Documenti e Indici ━━━"

# dream_team_index.md
if [[ -f "$LOCAL_DOWNLOAD/dream_team_index.md" ]]; then
  upload_file "$LOCAL_DOWNLOAD/dream_team_index.md" "dream_team_index.md" \
    "docs: aggiornato dream_team_index.md"
fi

# README.md
if [[ -f "$LOCAL_DOWNLOAD/README.md" ]]; then
  upload_file "$LOCAL_DOWNLOAD/README.md" "README.md" \
    "docs: aggiornato README.md"
fi

# GUIDA_COMPLETA_SETUP.md
if [[ -f "$LOCAL_DOWNLOAD/GUIDA_COMPLETA_SETUP.md" ]]; then
  upload_file "$LOCAL_DOWNLOAD/GUIDA_COMPLETA_SETUP.md" "GUIDA_COMPLETA_SETUP.md" \
    "docs: aggiornato GUIDA_COMPLETA_SETUP.md"
fi

# index.html (dashboard)
if [[ -f "$LOCAL_DOWNLOAD/index.html" ]]; then
  upload_file "$LOCAL_DOWNLOAD/index.html" "index.html" \
    "feat: aggiornato dashboard index.html"
fi

# CONTINUATION_MARKDOWN.md
if [[ -f "$LOCAL_DOWNLOAD/CONTINUATION_MARKDOWN.md" ]]; then
  upload_file "$LOCAL_DOWNLOAD/CONTINUATION_MARKDOWN.md" "CONTINUATION_MARKDOWN.md" \
    "docs: aggiornato CONTINUATION_MARKDOWN.md"
fi

# ─── STEP 4: Sync Template e Tools ──────────────────────────────────────────
log ""
log "━━━ STEP 4/5: Template e Tools ━━━"

# JSON templates
for json_file in "$LOCAL_DOWNLOAD"/*.json; do
  [[ -f "$json_file" ]] || continue
  BASENAME=$(basename "$json_file")
  # Skip file non template
  case "$BASENAME" in
    grok_*) continue ;;  # Skip temporary research files
  esac
  upload_file "$json_file" "templates/$BASENAME" \
    "chore: aggiornato template $BASENAME"
done

# Python tools
for py_file in "$LOCAL_DOWNLOAD"/*.py; do
  [[ -f "$py_file" ]] || continue
  BASENAME=$(basename "$py_file")
  upload_file "$py_file" "tools/$BASENAME" \
    "chore: aggiornato tool $BASENAME"
done

# ─── STEP 5: Sync Asset (solo se richiesto) ────────────────────────────────
log ""
log "━━━ STEP 5/5: Asset ━━━"

FRAME_COUNT=0
THUMB_COUNT=0
IMAGE_COUNT=0

# Frame storyboard
for frame in "$LOCAL_DOWNLOAD"/frame_*.png "$LOCAL_DOWNLOAD"/storyboard_*.jpg; do
  [[ -f "$frame" ]] || continue
  BASENAME=$(basename "$frame")
  upload_file "$frame" "assets/frames/$BASENAME" \
    "asset: aggiunto frame $BASENAME"
  FRAME_COUNT=$((FRAME_COUNT + 1))
done

# Thumbnails
for thumb in "$LOCAL_DOWNLOAD"/thumb_*.png "$LOCAL_DOWNLOAD"/thumbnail_*.png; do
  [[ -f "$thumb" ]] || continue
  BASENAME=$(basename "$thumb")
  upload_file "$thumb" "assets/thumbnails/$BASENAME" \
    "asset: aggiunto thumbnail $BASENAME"
  THUMB_COUNT=$((THUMB_COUNT + 1))
done

# Altre immagini (se --include-images)
if [[ "$INCLUDE_IMAGES" == true ]]; then
  for img in "$LOCAL_DOWNLOAD"/*.png "$LOCAL_DOWNLOAD"/*.jpg "$LOCAL_DOWNLOAD"/*.webp; do
    [[ -f "$img" ]] || continue
    BASENAME=$(basename "$img")
    # Skip gia processati
    case "$BASENAME" in
      frame_*|storyboard_*|thumb_*|thumbnail_*) continue ;;
    esac
    upload_file "$img" "assets/other/$BASENAME" \
      "asset: aggiunto immagine $BASENAME"
    IMAGE_COUNT=$((IMAGE_COUNT + 1))
  done
fi

# ─── Cleanup vecchi file temporanei nel repo ────────────────────────────────
if [[ "$DRY_RUN" != true ]]; then
  # Rimuovi test.txt se esiste
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/$PRIVATE_REPO/contents/test.txt" | jq -r '.sha' | \
    xargs -I{} curl -s -X DELETE -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$PRIVATE_REPO/contents/test.txt" \
    -d "{\"message\": \"chore: rimozione test.txt\", \"sha\": \"{}\"}" > /dev/null 2>&1
fi

# ─── Summary ────────────────────────────────────────────────────────────────
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOTAL_MB=$((TOTAL_BYTES / 1024 / 1024))

# Log su file
echo "[$END_TIME] private-sync: $UPLOAD_COUNT uploaded, $SKIP_COUNT skipped, $ERROR_COUNT errors, ${TOTAL_MB}MB → $PRIVATE_REPO" >> "$SYNC_LOG" 2>/dev/null

echo ""
echo "═══════════════════════════════════════════════════"
log_ok "SYNC LOCALE → PRIVATO COMPLETATO"
echo ""
echo "  Repo:          https://github.com/$PRIVATE_REPO"
echo "  File uploadati: $UPLOAD_COUNT"
echo "  File saltati:   $SKIP_COUNT"
echo "  Errori:         $ERROR_COUNT"
echo "  Dati trasferiti: ${TOTAL_MB}MB"
echo "  Frames:         $FRAME_COUNT"
echo "  Thumbnails:     $THUMB_COUNT"
echo "  Altre immagini: $IMAGE_COUNT"
echo "  Timestamp:      $END_TIME"
echo "═══════════════════════════════════════════════════"
echo ""

if [[ $ERROR_COUNT -gt 0 ]]; then
  log_warn "$ERROR_COUNT errori riscontrati — controlla sopra"
  exit 1
fi

log "Per sincronizzare anche il pubblico: bash .sync_to_public.sh"
