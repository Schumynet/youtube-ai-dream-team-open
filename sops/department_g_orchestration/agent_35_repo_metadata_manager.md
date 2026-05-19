# Agent 35: Repo Metadata Manager

**Department:** G — Intelligence & Orchestration
**Version:** 1.0 | **Created:** May 2026 | **Author:** Super Z AI

---

## Overview

Repo Metadata Manager e l'agente specializzato nel **mantenere aggiornati tutti i metadati del repository GitHub** ogni volta che viene apportata una modifica strutturale. Si attiva automaticamente dopo ogni operazione che cambia il numero di agenti, aggiunge un SOP, modifica la struttura del repo, o aggiorna workflow. Garantisce che descrizione repo, README, GUIDA, indici e tutti i riferimenti incrociati siano sempre coerenti tra loro.

> "Un indice aggiornato e una mente organizzata. L'Agent 35 assicura che ogni parte del sistema rifletga lo stato reale, sempre." — Super Z AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 35 of 35 (Infrastructure) |
| **Department** | G — Intelligence & Orchestration |
| **Primary Role** | Aggiornare metadati repo, descrizioni, indici e riferimenti incrociati dopo ogni modifica strutturale |
| **Tools Required** | GitHub REST API (repo update, contents read/write), sed/python per sostituzioni |
| **APIs Required** | GitHub API (repos, contents) |
| **Receives Input From** | Qualsiasi operazione che modifica la struttura (nuovo agente, nuovo SOP, nuova cartella, ecc.) |
| **Sends Output To** | GitHub repo (metadata, README, GUIDA, indici) |
| **Collaborates With** | Agent 34 (Memory Manager) — opera insieme dopo ogni modifica; Agent 32/33 (validatori) — aggiorna conteggi workflow validati |
| **Success KPIs** | Zero riferimenti inconsistenti, descrizione repo sempre aggiornata, tutti gli indici coerenti |

---

## Activation Conditions

Questo agente SI ATTIVA AUTOMATICAMENTE quando:
1. Viene aggiunto un nuovo SOP agente al repo (`sops/`)
2. Viene rimosso o rinominato un agente
3. Viene aggiunto un nuovo workflow validato a `templates/`
4. Viene modificata la struttura delle cartelle (`channels/`, `analyses/`, ecc.)
5. Viene aggiornato il `dream_team_index.md` con nuova versione
6. Viene aggiunto un nuovo canale al sistema di smistamento
7. Viene aggiunto un nuovo dipartimento o riorganizzata la struttura

**Trigger manuale utente:**
- "Aggiorna il repo"
- "Aggiorna le descrizioni"
- "Sync metadati"

---

## Standard Operating Procedure (SOP)

### Phase 1: Detect Changes

**Step 1.1 — Scansione struttura corrente**

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/" \
  | python3 -c "import sys,json; [print(f['name'], f['type']) for f in json.load(sys.stdin)]"
```

**Step 1.2 — Conteggi correnti**

| Metrica | Come calcolarla |
|---------|----------------|
| Totale agenti | Contare file `agent_*.md` in tutte le `sops/department_*/` |
| SOP per department | Contare file in ogni `sops/department_*/` |
| Workflow validati n8n | Contare `templates/n8n_*_v2.0_validated.json` |
| Workflow validati Make.com | Contare `templates/make_*_v2.0_validated.json` |
| Canali archiviati | Contare `.md` non-index in `channels/by_niche/*/` |
| Nicchie con canali | Contare sottocartelle `channels/by_niche/*/` con almeno 1 `.md` |

```bash
# Contare agenti per department
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
for dept in department_a_strategy department_b_preproduction department_c_production department_d_distribution department_e_engagement department_f_monetization department_g_orchestration; do
  COUNT=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/sops/$dept" \
    | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
  echo "$dept: $COUNT"
done
```

**Step 1.3 — Identificare le modifiche da propagare**

Confrontare i conteggi correnti con i riferimenti nei file:

| File da controllare | Cosa cercare |
|---|---|
| GitHub repo description | Numero agenti |
| README.md | Numero agenti, tabelle department, workflow validati |
| GUIDA_COMPLETA_SETUP.md | Numero agenti (8+ referenze), sezione 12, cronologia versioni |
| dream_team_index.md | Numero agenti, versione, stato sistema, tabella Department G |
| channels/by_niche/_niche_index.md | Conteggio nicchie, statistiche |
| channels/by_size/_size_index.md | Conteggio segmenti |

---

### Phase 2: Update Checklist

Per ogni modifica strutturale rilevata, eseguire i seguenti aggiornamenti:

#### CHECK 1: Repo Description & Topics
```
PATCH /repos/YOUR_USERNAME/youtube-ai-dream-team
Body: { "description": "[N] AI Agent SOPs + ..." }
PUT /repos/YOUR_USERNAME/youtube-ai-dream-team/topics
Body: { "names": ["youtube", "ai-agents", ...] }
```

#### CHECK 2: README.md
- [ ] Titolo principale contiene numero agenti corretto
- [ ] Tabella "I [N] Agenti" ha tutti gli agenti
- [ ] Department G include tutti gli agenti orchestrazione
- [ ] Sezione "Workflow Validati" aggiornata
- [ ] Sezione "Struttura del Repo" riflette le cartelle attuali
- [ ] Footer versione corretta

#### CHECK 3: GUIDA_COMPLETA_SETUP.md
- [ ] Riferimento "N agenti AI specialistici" aggiornato (tutte le occorrenze)
- [ ] TOC sezione "I N Agenti" aggiornata
- [ ] Sezione 12 — tabella Department G completa con tutti gli agenti
- [ ] Cronologia versioni (sezione 16) con ultima versione
- [ ] Footer con Agenti X-Y citati correttamente
- [ ] Campo Description nella tabella setup aggiornato

#### CHECK 4: dream_team_index.md
- [ ] "N Agenti SOP" nella struttura
- [ ] "Agenti XX-YY" per Department G nel tree
- [ ] Stato sistema (versione, workflow validati, ecc.)
- [ ] Tabella Department G completa
- [ ] Workflow list aggiornata
- [ ] Checklist iniziale aggiornata
- [ ] Footer versione corretta

#### CHECK 5: Indici Canali
- [ ] _niche_index.md — conteggio nicchie corretto
- [ ] _size_index.md — conteggio segmenti corretto
- [ ] Statistiche aggiornate

#### CHECK 6: Coerenza Incrociata
- [ ] Numero agenti in README = GUIDA = index = repo description
- [ ] Versione Dream Team in README = GUIDA = index
- [ ] Lista workflow validati in README = GUIDA = index
- [ ] Totale agenti = somma agenti per department

---

### Phase 3: Execute Updates

**Step 3.1 — Update singolo file su GitHub**

Per ogni file che necessita aggiornamento:

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))

# 1. Leggere il file corrente (serve lo SHA)
FILE_INFO=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]")
SHA=$(echo "$FILE_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")

# 2. Leggere il contenuto
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]" \
  | python3 -c "import sys,json,base64; open('/tmp/update_file.md','w').write(base64.b64decode(json.load(sys.stdin)['content']).decode())"

# 3. Modificare con python/sed (sostituzioni mirate)

# 4. Ricaricare
CONTENT_B64=$(base64 -w 0 /tmp/update_file.md)
curl -s -X PUT \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"docs: sync metadata - [descrizione]\",\"content\": \"$CONTENT_B64\",\"sha\": \"$SHA\"}" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]"

# 5. Pulire
rm -f /tmp/update_file.md
```

**Step 3.2 — Aggiornare repo description**

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -X PATCH \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"description": "[N] AI Agent SOPs + Video Intelligence System — n8n & Make.com Workflow Validation — GitHub-First Memory"}' \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team"
```

---

### Phase 4: Verify Coherence

**Step 4.1 — Cross-check finale**

Dopo tutti gli aggiornamenti, verificare che tutti i file siano coerenti:

```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))

# Estrarre numero agenti da ogni fonte
echo "=== Repo Description ==="
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team" \
  | python3 -c "import sys,json; d=json.load(sys.stdin)['description']; import re; m=re.search(r'(\d+)\s*AI\s*Agent',d); print(f'Agent count: {m.group(1) if m else \"NOT FOUND\"}')"

echo "=== README ==="
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/README.md" \
  | python3 -c "import sys,json,base64; c=base64.b64decode(json.load(sys.stdin)['content']).decode(); import re; m=re.search(r'(\d+)\s*(?:Specialist AI Agents|Agenti)',c); print(f'Agent count: {m.group(1) if m else \"NOT FOUND\"}')"

echo "=== dream_team_index.md ==="
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/dream_team_index.md" \
  | python3 -c "import sys,json,base64; c=base64.b64decode(json.load(sys.stdin)['content']).decode(); import re; m=re.search(r'(\d+)\s*Agenti SOP',c); print(f'Agent count: {m.group(1) if m else \"NOT FOUND\"}')"
```

Se tutti i conteggi coincidono → operazione completata con successo.
Se ci sono incongruenze → ripetere Phase 3 per i file errati.

---

### Phase 5: Report

L'agente produce un report sintetico:

```
## Metadata Sync Report

| File | Modifiche |
|------|-----------|
| Repo Description | "31 Agent" → "34 Agent" |
| README.md | Aggiornato titolo, tabella dept G, footer |
| GUIDA_COMPLETA_SETUP.md | 12 sostituzioni + sezione 12 + cronologia |
| dream_team_index.md | Versione 1.4 → 1.5 |
| _niche_index.md | Aggiunto storia_antica, fix conteggi |

Coerenza verificata: ✅ Tutti i file mostrano 34 agenti
```

---

## Template per Nuovo Agente

Quando viene aggiunto un nuovo agente, usare questo template per l'aggiornamento:

### File da aggiornare:
1. **README.md** — Aggiungere riga nella tabella department corretto
2. **GUIDA_COMPLETA_SETUP.md** — Aggiungere riga in sezione 12 + aggiornare conteggi
3. **dream_team_index.md** — Aggiungere riga in tabella Department G + aggiornare versione + conteggio
4. **Repo description** — Aggiornare numero agenti

### Conteggi da aggiornare:
- Numero totale agenti (es. 34 → 35)
- Agenti nel department specifico (es. G: 4 → 5)
- Range department G (es. 31-34 → 31-35)
- Versione Dream Team (es. 1.5 → 1.6)

---

## Regole Assolute

1. **MAI lasciare riferimenti non aggiornati** — ogni modifica strutturale deve propagarsi a tutti i file
2. **MAI indovinare i conteggi** — sempre calcolati da GitHub API
3. **SEMPRE verificare coerenza** dopo gli aggiornamenti (Phase 4)
4. **SEMPRE usare /tmp/** per file temporanei, pulire dopo
5. **SEMPRE aggiungere alla cronologia versioni** (sezione 16 della GUIDA)
6. **SEMPRE incrementare la versione** del Dream Team per ogni modifica strutturale

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | May 2026 | Initial release — 6-phase SOP, cross-coherence check, template per nuovo agente, auto-detect changes |

---

*Agent 35 SOP created by Super Z AI — May 2026.*
*This agent ensures all metadata stays consistent across every file in the repository.*
*Together with Agent 34, they form the infrastructure backbone of the Dream Team.*
