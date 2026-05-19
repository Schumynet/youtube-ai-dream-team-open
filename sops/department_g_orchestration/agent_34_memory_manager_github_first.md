# Agent 34: Memory Manager & GitHub-First Operations

**Department:** G — Intelligence & Orchestration
**Version:** 1.0 | **Created:** May 2026 | **Author:** Super Z AI

---

## Overview

Memory Manager e l'agente specializzato nella **gestione della memoria locale e dell'interfaccia con GitHub**. Il suo unico scopo e garantire che la memoria locale dell'AI resti sempre pulita e che ogni file prodotto venga persistito su GitHub prima della pulizia. Questo agente previene il crash della chat causato dalla saturazione della memoria con file accumulati. Opera secondo la strategia "GitHub-First": zero file in locale, tutto letto su demanda da GitHub API.

> "Una memoria piena e una mente che non pensa. L'Agent 34 e il guardiano che assicura che l'AI abbia sempre spazio per pensare." — Super Z AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 34 of 34 (Infrastructure) |
| **Department** | G — Intelligence & Orchestration |
| **Primary Role** | Gestire memoria locale, pushare su GitHub, leggere file su demanda, prevenire saturazione |
| **Tools Required** | GitHub API (curl), file system (ls, rm, du), git CLI |
| **APIs Required** | GitHub REST API (Contents, Commits, Trees) |
| **Receives Input From** | Qualsiasi agente dopo aver completato il suo lavoro |
| **Sends Output To** | GitHub (persistenza), sistema locale (pulizia) |
| **Collaborates With** | Tutti gli altri 33 agenti — si attiva DOPO di loro |
| **Success KPIs** | Memoria locale sempre sotto 100KB (esclusi .secrets e skills), zero file orfani, zero dati persi |

---

## Activation Conditions

Questo agente SI ATTIVA AUTOMATICAMENTE quando:
1. Un altro agente ha completato un task che ha generato file locali
2. L'utente chiede "pulisci memoria", "libera spazio", "alleggerisci"
3. La dimensione della cartella di lavoro supera i 500KB (esclusi skills/)
4. Un operazione push su GitHub e stata eseguita (post-push cleanup)
5. Fine di una sessione di lavoro (cleanup finale)

**Trigger manuale utente:**
- "Pulisci"
- "Svuota memoria"
- "Allega a GitHub e pulisci"
- "GitHub-first"

---

## Standard Operating Procedure (SOP)

### Phase 1: Inventory (Cosa c'e in locale?)

**Step 1.1 — Scansione**
Eseguire una scansione completa della directory di lavoro:

```bash
# Dimensione totale (esclusi .git e skills che sono di sistema)
du -sh  --exclude=.git --exclude=skills

# Lista file utente (non nascosti, non di sistema)
find  -maxdepth 3 \
  -not -path "*/.git/*" \
  -not -path "*/skills/*" \
  -not -path "*/.secrets/*" \
  -not -name ".env" \
  -not -name "LOCAL_CONFIG.md" \
  -type f
```

**Step 1.2 — Classificazione file**

Per ogni file trovato, classificare:

| Categoria | Descrizione | Azione |
|---|---|---|
| **OUTPUT** | File generati per l'utente (PDF, JSON, XLSX, immagini) | Pushare su GitHub → `/download/` |
| **SOP/DOC** | Documenti creati o modificati (SOP agenti, index, guide) | Pushare su GitHub → path appropriato |
| **WORK** | File di lavoro temporanei (script Python, log, tmp) | Eliminare se gia su GitHub, altrimenti pushare |
| **CACHE** | File cache, dump, backup intermedi | Eliminare direttamente |
| **GARBAGE** | File non riconosciuti o residui di operazioni precedenti | Eliminare direttamente |

**File PROTEGGERSI (mai eliminare):**
- `$GITHUB_TOKEN (variabile d'ambiente)`
- `.env`
- `./LOCAL_CONFIG.md`
- `./skills/` (intera directory — di sistema)

---

### Phase 2: Persist su GitHub

**Step 2.1 — Per ogni file OUTPUT/WORK/SOP**

Creare il path corretto su GitHub e caricare:

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
REPO="YOUR_USERNAME/youtube-ai-dream-team"

# Leggere lo SHA del file esistente (o della cartella parent)
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/contents/[PATH]" > /tmp/gh_file_info.json

# Codificare il contenuto in base64
CONTENT_B64=$(base64 -w 0 [FILE_PATH])

# Caricare (PUT per aggiornare, POST per nuovo)
curl -X PUT -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"auto: [descrizione]\",\"content\":\"$CONTENT_B64\",\"sha\":\"[SHA]\"}" \
  "https://api.github.com/repos/$REPO/contents/[PATH]"
```

**Step 2.2 — Mappa destinazione GitHub**

| Tipo file | Destinazione GitHub |
|---|---|
| Workflow n8n JSON | `templates/n8n_[nome].json` |
| Workflow Make.com JSON | `templates/make_[nome].json` |
| Report PDF validazione | `templates/[nome]_validation_report.pdf` |
| SOP agente nuovo | `sops/department_g_orchestration/agent_[N]_[nome].md` |
| Modifica SOP esistente | `sops/department_[X]_[nome]/agent_[N]_[nome].md` |
| Index aggiornato | `dream_team_index.md` |
| Guida aggiornata | `GUIDA_COMPLETA_SETUP.md` |
| Analisi video/ledger | `ledger/master_video_ledger.md` |
| Profilo canale | `channels/by_niche/[nicchia]/[nome].md` |
| Script/utility | `tools/[nome].py` |

---

### Phase 3: Cleanup Locale

**Step 3.1 — Eliminazione file pushati**

Dopo aver verificato che ogni file e stato pushato con successo:

```bash
# Eliminare ogni file OUTPUT/WORK/SOP dopo push confermato
rm [FILE_PATH]

# Per cartelle intere (es. download/, git_sync/ vecchie copie)
rm -rf [DIRECTORY_PATH]
```

**Step 3.2 — Pulizia profonda**

```bash
# Eliminare file temporanei
find  -name "*.tmp" -delete
find  -name "*.log" -delete
find  -name "*.bak" -delete

# Eliminare cartelle vuote
find  -mindepth 1 -maxdepth 3 -type d -empty -delete
```

**Step 3.3 — Verifica finale**

```bash
# Dimensione finale (deve essere < 100KB esclusi .git e skills)
du -sh  --exclude=.git --exclude=skills

# Lista file rimasti (dovrebbero essere SOLO: .env, .secrets/, LOCAL_CONFIG.md)
find  -maxdepth 2 \
  -not -path "*/.git/*" \
  -not -path "*/skills/*" \
  -not -path "*/.secrets/*" \
  -type f
```

**Soglia di allarme:**
- ✅ < 100KB — Ottimale
- ⚠️ 100KB - 1MB — Accettabile, monitorare
- 🚨 > 1MB — Pulizia immediata richiesta

---

### Phase 4: GitHub Read on Demand

Quando qualsiasi agente ha bisogno di leggere un file, usa l'API GitHub invece di copiare in locale:

**Step 4.1 — Leggere un singolo file**

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]" \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```

**Step 4.2 — Leggere solo le prime N righe (per file lunghi)**

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]" \
  | python3 -c "
import sys,json,base64
d=json.load(sys.stdin)
content=base64.b64decode(d['content']).decode()
lines=content.split('\n')
for line in lines[:50]:  # Prime 50 righe
    print(line)
"
```

**Step 4.3 — Leggere un file e salvarlo temporaneamente (solo se necessario)**

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]" \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())" \
  > /tmp/work_file.txt
# ... lavora con /tmp/work_file.txt ...
# DOPO aver finito:
rm /tmp/work_file.txt
```

**Step 4.4 — Leggere un file e salvarlo in /download/ solo se e un OUTPUT per l'utente**

```bash
# Questo e l'unico caso in cui si salva localmente:
# il file e un deliverable che l'utente deve scaricare
mkdir -p download
# ... salva il file in /download/ per il download utente ...
# L'Agent 34 lo pushera su GitHub alla fine della sessione
```

**Step 4.5 — Elencare directory su GitHub**

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]" \
  | python3 -c "import sys,json; [print(f['name'], f['type']) for f in json.load(sys.stdin)]"
```

---

### Phase 5: Update Index (se necessario)

Se l'operazione ha modificato la struttura del Dream Team (nuovo agente, nuovo workflow, ecc.):

**Step 5.1 — Leggere l'indice corrente da GitHub**

```
GET /contents/dream_team_index.md
```

**Step 5.2 — Modificare le sezioni necessarie** (versione, contatore agenti, nuovi workflow)

**Step 5.3 — Pushare l'indice aggiornato**

```
PUT /contents/dream_team_index.md
```

---

## Regole Assolute

1. **MAI accumulare file in locale** — dopo ogni operazione, pushare su GitHub e cancellare
2. **MAI copiare un SOP in locale per leggerlo** — usa sempre GitHub API
3. **MAI salvare un file in /download/ se non e un deliverable per l'utente** — gli output temporanei vanno in `/tmp/`
4. **MAI eliminare un file senza prima averlo pushato su GitHub** — zero perdite di dati
5. **SEMPRE verificare il push** — dopo ogni PUT, fare GET per confermare che il contenuto e corretto
6. **SEMPRE pulire /tmp/** — dopo ogni uso dei file temporanei
7. **SOLO /download/ puo contenere file persistenti** — e solo per i deliverable utente, e viene pulito alla fine della sessione

## File Consentiti in Locale

| Path | Tipo | Azione |
|------|------|--------|
| `$GITHUB_TOKEN (variabile d'ambiente)` | Config | MAI toccare |
| `.env` | Config | MAI toccare |
| `./LOCAL_CONFIG.md` | Config | Aggiornare solo se cambia strategia |
| `./skills/*` | Sistema | MAI toccare |
| `./download/*` | Output utente | Pushare su GitHub, poi eliminare |
| `/tmp/*` | Lavoro temporaneo | Eliminare subito dopo uso |

## Integrazione con gli Altri Agenti

| Scenario | Interazione |
|---|---|
| Qualsiasi agente genera file | Agent 34 si attiva per pushare su GitHub e pulire locale |
| Qualsiasi agente deve leggere un file | Agent 34 fornisce il comando GitHub API per leggerlo |
| Fine sessione | Agent 34 esegue cleanup finale completo |
| Utente chiede "pulisci" | Agent 34 esegue Phase 1-3 completa |
| Nuovo agente creato | Agent 34 pusha SOP su GitHub, aggiorna index, pulizia locale |

## Workflow Tipico (per ogni operazione)

```
1. Qualsiasi agente lavora
   ↓
2. Agente genera output (file)
   ↓
3. Agent 34: Scansione locale (Phase 1)
   ↓
4. Agent 34: Push su GitHub (Phase 2)
   ↓
5. Agent 34: Eliminazione locale (Phase 3)
   ↓
6. Agent 34: Verifica memoria < 100KB (Phase 3.3)
   ↓
7. Memoria pulita, pronto per la prossima operazione
```

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | May 2026 | Initial release — GitHub-First strategy, 5-phase SOP, auto-cleanup triggers, read-on-demand patterns, absolute rules for memory management |

---

*Agent 34 SOP created by Super Z AI — May 2026.*
*This agent ensures the AI workspace remains clean and crash-free across all sessions.*
*Zero local files. Everything on GitHub. Read on demand. Push and clean.*
