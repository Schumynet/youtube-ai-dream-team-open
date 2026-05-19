# YouTube AI Dream Team v1.1 — Guida Completa al Setup

## Replicare tutto da zero: dal repo all'analisi video

> Questa guida documenta l'intero processo di configurazione del YouTube AI Dream Team v1.1 con memoria persistente su GitHub. Seguila passo passo per replicare l'installazione su qualsiasi nuovo ambiente o chat AI.

---

## Indice

1. [Cos'e il YouTube AI Dream Team](#1-cose-il-youtube-ai-dream-team)
2. [Prerequisiti](#2-prerequisiti)
3. [Creare il Repository GitHub Privato](#3-creare-il-repository-github-privato)
4. [Generare il Personal Access Token (PAT)](#4-generare-il-personal-access-token-pat)
5. [Connettere l'AI al Repo](#5-connettere-lai-al-repo)
6. [Struttura del Repository](#6-struttura-del-repository)
7. [Il File dream_team_index.md — La Chiave Portatile](#7-il-file-dream_team_indexmd--la-chiave-portatile)
8. [Come Funziona la Memoria Persistente](#8-come-funziona-la-memoria-persistente)
9. [Workflow di Analisi Video](#9-workflow-di-analisi-video)
10. [Output Generati](#10-output-generati)
11. [Come Usare in una Nuova Chat](#11-come-usare-in-una-nuova-chat)
12. [I 31 Agenti — Riepilogo Completo](#12-i-31-agenti--riepilogo-completo)
13. [Prompt Templates Pronti](#13-prompt-templates-pronti)
14. [Limitazioni e Note Importanti](#14-limitazioni-e-note-importanti)
15. [Risoluzione Problemi Comuni](#15-risoluzione-problemi-comuni)
16. [Cronologia Versioni](#16-cronologia-versioni)

---

## 1. Cos'e il YouTube AI Dream Team

Il YouTube AI Dream Team e un sistema di **31 agenti AI specialistici** per YouTube, organizzati in 7 dipartimenti. Ogni agente ha un proprio Standard Operating Procedure (SOP) che definisce il suo ruolo, il suo workflow e i suoi output.

Il sistema e composto da:

- **Agenti 01-30**: Framework originale di Ritesh Kanjee (Augmented AI) — coprono strategia, pre-produzione, produzione, distribuzione, engagement e monetizzazione
- **Agente 31** (Nuovo): Master Video Analyzer & Orchestrator — il meta-agente che scarica video YouTube, li analizza con tutte le prospettive dei 30 agenti, e genera output strutturati (PDF, XLSX, Markdown)

La memoria persistente su GitHub permette di mantenere tutti i dati tra diverse sessioni di chat.

---

## 2. Prerequisiti

Di seguito tutto cio che serve prima di iniziare:

| Requisito | Dettaglio | Note |
|---|---|---|
| Account GitHub | Account gratuito | https://github.com/signup |
| Chat AI (Super Z / Claude / ChatGPT) | Accesso a un AI con capability di lettura/scrittura file e chiamate API | Super Z usato in questa guida |
| yt-dlp | Installato nell'ambiente AI | Strumento CLI per scaricare video YouTube |
| FFmpeg | Installato nell'ambiente AI | Per estrarre frame e audio dai video |
| Vision AI Model | Modello AI con capacita visive | GPT-4o o Claude 3.5 Sonnet |
| Nessun costo | Tutto gratuito | GitHub free, yt-dlp free, FFmpeg free |

**Nota:** Se usi Super Z (l'ambiente di questa guida), yt-dlp, FFmpeg e l'AI sono gia preinstallati. Devi solo configurare GitHub.

---

## 3. Creare il Repository GitHub Privato

### Step 3.1 — Accedi a GitHub

Vai su https://github.com e accedi con il tuo account.

### Step 3.2 — Crea il nuovo repository

Vai su https://github.com/new e compila i campi come segue:

| Campo | Valore da inserire |
|---|---|
| **Repository name** | `youtube-ai-dream-team` |
| **Description** | `AI Dream Team — 31 Agent SOPs + Video Intelligence System` |
| **Visibility** | Seleziona **Private** (il radiobutton con il lucchetto) |
| **Add a README file** | Spunta la casella (cerchia il punto "Add a README file") |
| **Add .gitignore** | Lascia su "None" |
| **Choose a license** | Lascia su "None" |

### Step 3.3 — Clicca "Create repository"

Dopo aver cliccato, verrai reindirizzato alla pagina del tuo nuovo repository vuoto. L'URL sara qualcosa del tipo:
```
https://github.com/TUO_USERNAME/youtube-ai-dream-team
```

Annotati questo URL — ti servira nel passaggio successivo.

---

## 4. Generare il Personal Access Token (PAT)

Il PAT e la "chiave" che permette all'AI di leggere e scrivere nel tuo repo in modo sicuro, senza bisogno di username e password.

### Step 4.1 — Vai alla pagina dei token

Vai su: https://github.com/settings/tokens?type=beta

In alternativa: GitHub Avatar (in alto a destra) → Settings → Developer settings → Personal access tokens → Fine-grained tokens

### Step 4.2 — Genera un nuovo token

Clicca il pulsante **"Generate new token"**

### Step 4.3 — Configura il token

Compila i campi come segue:

**Token name:**
```
dream-team-api
```

**Expiration:**
Seleziona **"No expiration"** oppure **"Custom"** → 90 giorni (se preferisci maggiore sicurezza, ricordati di rinnovarlo)

**Repository access:**
Seleziona **"Only select repositories"** e poi scegli `youtube-ai-dream-team` dal menu a tendina.

**Permissions → Repository permissions:**

Vai nella sezione "Repository permissions" e imposta:

| Permesso | Impostazione |
|---|---|
| **Contents** | Read and Write |
| **Metadata** | Read-only (di default) |

Tutti gli altri permessi possono restare su "No access".

### Step 4.4 — Genera e copia il token

Clicca **"Generate token"** alla fine della pagina.

Verrai mostrato il token nella forma:
```
github_pat_XXXXXXXXXXXX
```

**COPIA IL TOKEN IMMEDIATAMENTE** — Non potrai vederlo di nuovo dopo aver chiuso la pagina.

Salvalo in un posto sicuro (es. note del telefono, password manager, ecc.)

### Step 4.5 — Revoca (per sicurezza)

Se in futuro vuoi revocare l'accesso:
Vai su https://github.com/settings/tokens?type=beta → clicca sul token → "Delete token"

---

## 5. Connettere l'AI al Repo

### Step 5.1 — Fornisci le credenziali all'AI

In una nuova chat con l'AI, invia il seguente messaggio:

```
Configura il Dream Team con GitHub.

Owner: [il tuo username GitHub]
Token: [il tuo PAT token copiato al passaggio 4.4]
```

Ad esempio:
```
Configura il Dream Team con GitHub.

Owner: YOUR_USERNAME
Token: github_pat_XXXXXXXXXXXX...
```

### Step 5.2 — Cosa fa l'AI automaticamente

Dopo aver ricevuto le credenziali, l'AI esegue queste operazioni in sequenza:

1. **Salva il token** in modo sicuro nel filesystem locale (mai visibile in chat)
   ```
   $GITHUB_TOKEN (variabile d'ambiente)
   ```

2. **Verifica l'accesso** al repo tramite API GitHub:
   ```bash
   curl -H "Authorization: Bearer $TOKEN" \
     https://api.github.com/repos/OWNER/youtube-ai-dream-team
   ```

3. **Crea la struttura delle cartelle** nel repo:
   ```
   sops/department_a_strategy/      (Agenti 01-06)
   sops/department_b_preproduction/ (Agenti 07-11)
   sops/department_c_production/    (Agenti 12-16)
   sops/department_d_distribution/  (Agenti 17-21)
   sops/department_e_engagement/    (Agenti 22-25)
   sops/department_f_monetization/  (Agenti 26-30)
   sops/department_g_orchestration/ (Agente 31)
   ledger/
   analyses/reports/
   analyses/catalogs/
   analyses/transcripts/
   assets/frames/
   assets/thumbnails/
   templates/
   ```

4. **Carica i 31 file SOP** dei agenti nelle rispettive cartelle

5. **Crea il dream_team_index.md** — il file portatile

6. **Crea il master_video_ledger.md** — il documento vivo

7. **Crea il README.md** del repo

8. **Fa commit e push** di tutto su GitHub

### Step 5.3 — Verifica che sia tutto OK

Dopo che l'AI ha finito, vai su:
```
https://github.com/TUO_USERNAME/youtube-ai-dream-team
```

Dovresti vedere:
- La struttura delle cartelle
- I 31 file SOP
- Il file dream_team_index.md
- Il file README.md
- Il ledger vuoto pronto per essere popolato

---

## 6. Struttura del Repository

Ecco la struttura completa del repo una volta configurato:

```
youtube-ai-dream-team/
│
├── README.md                        ← Documentazione del repo
├── dream_team_index.md              ← LA CHIAVE PORTATILE (leggi sezione 7)
├── GUIDA_COMPLETA_SETUP.md          ← Questo file
│
├── sops/                            ← Standard Operating Procedures
│   ├── department_a_strategy/       │
│   │   ├── agent_01_youtube_channel_architect.md
│   │   ├── agent_02_niche_and_competitor_analyst.md
│   │   ├── agent_03_viral_topic_ideation_engine.md
│   │   ├── agent_04_keyword_and_seo_strategist.md
│   │   ├── agent_05_title_and_thumbnail_concept_generator.md
│   │   └── agent_06_audience_avatar_builder.md
│   │
│   ├── department_b_preproduction/  │
│   │   ├── agent_07_hook_and_intro_writer.md
│   │   ├── agent_08_core_script_and_storyboard_writer.md
│   │   ├── agent_09_retention_and_pacing_optimiser.md
│   │   ├── agent_10_call-to-action_cta_strategist.md
│   │   └── agent_11_shot_list_and_b-roll_planner.md
│   │
│   ├── department_c_production/     │
│   │   ├── agent_12_metadata_and_description_writer.md
│   │   ├── agent_13_thumbnail_design_director.md
│   │   ├── agent_14_video_editing_director.md
│   │   ├── agent_15_audio_and_sound_design_consultant.md
│   │   └── agent_16_subtitle_and_caption_optimiser.md
│   │
│   ├── department_d_distribution/   │
│   │   ├── agent_17_upload_and_publishing_coordinator.md
│   │   ├── agent_18_youtube_shorts_creator.md
│   │   ├── agent_19_cross-platform_repurposing_agent.md
│   │   ├── agent_20_community_tab_strategist.md
│   │   └── agent_21_newsletter_integration_specialist.md
│   │
│   ├── department_e_engagement/     │
│   │   ├── agent_22_comment_moderation_and_reply_engine.md
│   │   ├── agent_23_viewer_sentiment_analyst.md
│   │   ├── agent_24_superfan_identification_agent.md
│   │   └── agent_25_collaboration_and_outreach_scout.md
│   │
│   ├── department_f_monetization/   │
│   │   ├── agent_26_lead_generation_and_funnel_architect.md
│   │   ├── agent_27_sponsorship_and_brand_deal_negotiator.md
│   │   ├── agent_28_youtube_analytics_interpreter.md
│   │   ├── agent_29_a_b_testing_coordinator.md
│   │   └── agent_30_revenue_and_roi_tracker.md
│   │
│   └── department_g_orchestration/  │
│       └── agent_31_master_video_analyzer_and_orchestrator.md
│
├── ledger/                          ← DOCUMENTO VIVO
│   └── master_video_ledger.md       ← Si aggiorna ad ogni analisi
│
├── analyses/                        ← OUTPUT DELLE ANALISI
│   ├── reports/                     ← PDF/DOCX generati
│   ├── catalogs/                    ← XLSX generati
│   └── transcripts/                 ← Trascrizioni video
│
├── assets/                          ← RISORSE VISIVE
│   ├── frames/                      ← Frame estratte dai video
│   └── thumbnails/                  ← Thumbnail scaricate
│
└── templates/                       ← TEMPLATE (futuro)
    └── .gitkeep
```

---

## 7. Il File dream_team_index.md — La Chiave Portatile

### Cos'e

Il file `dream_team_index.md` e il **ponte** tra qualsiasi chat AI e la tua memoria persistente su GitHub. Contiene tutte le informazioni necessarie affinche l'AI possa:

- Connettersi al tuo repo
- Leggere i SOP dei 31 agenti
- Accedere al ledger delle analisi
- Scrivere nuovi output

### Come funziona

```
CHAT NUOVA
    ↓
Tu scrivi: "Usa il dream_team_index.md che ti allego"
    ↓
Tu alleghi il file dream_team_index.md
    ↓
L'AI legge il file → Trova le credenziali GitHub → Si connette al repo
    ↓
L'AI ha accesso a TUTTO: SOP, ledger, analisi, output
    ↓
L'AI puo: analizzare video, aggiornare il ledger, generare report
```

### Come scaricarlo

**Metodo 1 — Dal repo GitHub:**
1. Vai su https://github.com/TUO_USERNAME/youtube-ai-dream-team
2. Clicca su `dream_team_index.md`
3. Clicca il pulsante "Raw" (in alto a destra)
4. Salva la pagina (Ctrl+S) come file `.md`

**Metodo 2 — Dall'AI:**
In una chat attiva dove il sistema e gia configurato, chiedi:
```
Scarica il dream_team_index.md per me
```
L'AI te lo salvera nella cartella download.

### Cosa contiene

Il file include:

| Sezione | Contenuto |
|---|---|
| Configurazione GitHub | Owner, URL repo, path token |
| Struttura Memoria | Mappa completa del repo |
| Contesto Canale | Nicchia, audience, obiettivo (da compilare) |
| Workflow Principali | Istruzioni per i 3 workflow |
| Comandi API | Comandi curl per leggere/scrivere sul repo |
| Stato Sistema | Contatore video/canali analizzati |
| Checklist Iniziale | Cose da fare alla prima connessione |

---

## 8. Come Funziona la Memoria Persistente

### Architettura

```
┌─────────────────────────────────────────────────┐
│                  CHAT AI                        │
│                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │  SOPs    │    │  Ledger  │    │  Output  │  │
│  │  (31 md) │    │  (md)    │    │ (pdf/xlsx)│  │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘  │
│       │               │               │         │
└───────┼───────────────┼───────────────┼─────────┘
        │               │               │
        ▼               ▼               ▼
┌─────────────────────────────────────────────────┐
│           GITHUB REPO (Privato)                 │
│                                                 │
│  sops/           ledger/          analyses/     │
│  31 agenti SOP   documento vivo   output        │
│                                                 │
└─────────────────────────────────────────────────┘
        ▲
        │ git push / API
        │
┌───────┴─────────────────────────────────────────┐
│           FILESYSTEM LOCALE                      │
│  $GITHUB_TOKEN (variabile d'ambiente)       │
│  ./download/                   │
│  ./git_sync/                   │
└─────────────────────────────────────────────────┘
```

### Flusso dei dati durante un'analisi

1. **Lettura:** L'AI legge i SOP dal repo e il ledger esistente
2. **Elaborazione:** Scarica il video, analizza con tutti e 30 gli agenti
3. **Scrittura locale:** Genera PDF, XLSX, Markdown localmente
4. **Scrittura repo:** Aggiorna il ledger e carica gli output sul repo
5. **Cleanup:** Elimina i file MP4 per liberare memoria

### Cosa viene salvato dove

| Dato | Repo GitHub | Filesystem Locale |
|---|:---:|:---:|
| SOP dei 31 agenti | ✅ Sempre | ✅ Copia cache |
| Token GitHub | ❌ Mai | ✅ Solo in .secrets/ |
| Ledger analisi | ✅ Sempre | ✅ Copia sincronizzata |
| Report PDF | ✅ Dopo analisi | ✅ /download/ |
| Catalogo XLSX | ✅ Dopo analisi | ✅ /download/ |
| Video MP4 | ❌ Mai | ❌ Cancellato dopo analisi |
| Frame estratte | ✅ Come asset | ✅ /tmp/ (temporaneo) |
| Trascrizioni | ✅ Come asset | ✅ /tmp/ (temporaneo) |

---

## 9. Workflow di Analisi Video

### Workflow A — Analisi Video Singolo

**Quando usarlo:** Hai trovato un video YouTube che vuoi analizzare in profondita.

**Prompt da inviare:**
```
Analizza questo video YouTube con tutti i 31 agenti:

URL: https://www.youtube.com/watch?v=XXXXXXXXXXX

Il mio canale:
- Nicchia: [la tua nicchia]
- Audience: [descrizione target]
- Obiettivo: [il tuo obiettivo]
```

**Cosa succede:**
```
URL → yt-dlp download MP4
       ↓
    FFmpeg estrae frame (1 ogni 30 sec)
       ↓
    yt-dlp estrae trascrizione (SRT)
       ↓
    yt-dlp estrae metadata (titolo, views, ecc.)
       ↓
    Vision AI analizza frame
       ↓
    LLM analizza con prospettive dei 30 agenti
       ↓
    Genera PDF report completo
       ↓
    Genera XLSX catalogo multi-foglio
       ↓
    Aggiorna master_video_ledger.md
       ↓
    Push aggiornamenti su GitHub
       ↓
    Elimina MP4 (cleanup)
       ↓
    Consegna summary + link download
```

**Durata stimata:** 10-20 minuti (dipende dalla lunghezza del video)

### Workflow B — Analisi Canale Completo

**Quando usarlo:** Vuoi analizzare un canale competitor per identificare i pattern di successo.

**Prompt da inviare:**
```
Analizza il canale YouTube completo:

URL: https://www.youtube.com/@CanaleCompetitor

Il mio canale:
- Nicchia: [la tua nicchia]
- Audience: [descrizione target]
- Obiettivo: [il tuo obiettivo]

Analizza i 5 video piu virali degli ultimi 6 mesi.
```

**Cosa succede:**
```
URL Canale → yt-dlp scopre lista video (ultimi 50)
       ↓
    Ranking con Virality Score
       ↓
    Selezione Top 5 video
       ↓
    Per ogni video: download → analisi → cleanup
       ↓
    Aggregazione risultati cross-video
       ↓
    Genera PDF report comparativo
       ↓
    Genera XLSX catalogo (fogli extra per confronto)
       ↓
    Aggiorna ledger con pattern cross-video
       ↓
    Push su GitHub
       ↓
    Cleanup tutti i MP4
       ↓
    Consegna summary
```

**Durata stimata:** 30-60 minuti (dipende dal numero di video)

### Workflow C — Modalita Interattiva (Automatica)

**Quando usarlo:** Non sei sicuro se vuoi un video solo o l'intero canale.

**Prompt da inviare:**
```
Analizza questo URL: https://www.youtube.com/watch?v=XXXXXXXXXXX
```

**Cosa succede:**
L'AI riconosce automaticamente se l'URL e un video o un canale e ti chiede:

- Se e un **video**: "Vuoi analizzare solo questo video o anche i migliori del suo canale?"
- Se e un **canale**: "Analizzero i video piu virali recenti. Procedo?"

Tu rispondi e l'AI prosegue con il workflow corretto.

### Workflow D — Quick Scan (Rapido)

**Quando usarlo:** Vuoi una panoramica veloce senza analisi approfondita.

**Prompt da inviare:**
```
Quick scan di questo video:
https://www.youtube.com/watch?v=XXXXXXXXXXX

Fai un'analisi rapida con solo 5 agenti chiave:
- Hook (Agent 07)
- Titolo/Thumbnail (Agent 05)
- Script Structure (Agent 08)
- Viral Topic (Agent 03)
- Analytics (Agent 28)
```

**Durata stimata:** 5-10 minuti

---

## 10. Output Generati

Per ogni video analizzato, vengono generati 3 output:

### 10.1 Report PDF/DOCX

Report completo con analisi di tutti i 30 agenti:

```
📄 Copertina
   Titolo, data, canale, nicchia

📋 Indice

1. Executive Summary (1 pagina)
   - Overview, top 3 findings, top 3 raccomandazioni
   - Score composito 0-100

2. Video Fingerprint
   - Metadata completa del video
   - Thumbnail (immagine incorporata)

3. Analisi Strategica (Dipartimento A - Agenti 01-06)
   - Posizionamento canale
   - Analisi competitor
   - 10 idee topic con viral score
   - Keyword research
   - Deconstruct titolo/thumbnail
   - Profilo audience avatar

4. Analisi Pre-Produzione (Dipartimento B - Agenti 07-11)
   - Analisi hook (0-10)
   - Script ricostruito completo
   - Analisi ritmo e retention
   - Mappa CTA con timestamp
   - Shot list completa

5. Analisi Produzione (Dipartimento C - Agenti 12-16)
   - Strategia metadata
   - Brief thumbnail con prompt AI
   - Brief editing
   - Analisi audio e sound design
   - Linee guida sottotitoli

6. Analisi Distribuzione (Dipartimento D - Agenti 17-21)
   - Strategia pubblicazione
   - 5 concept Shorts con timestamp
   - Content kit multi-piattaforma
   - Strategia community tab
   - Piano newsletter

7. Analisi Engagement (Dipartimento E - Agenti 22-25)
   - Report sentiment
   - Strategia superfan
   - Mappa collaborazioni

8. Analisi Monetizzazione (Dipartimento F - Agenti 26-30)
   - Stima revenue
   - Analisi sponsorship
   - Blueprint lead funnel
   - Piano A/B testing
   - Calcolo ROI

9. Blueprint — Piano Azione 30 Giorni
   - Settimana per settimana
   - Risorse necessarie
   - Valutazione rischi
```

### 10.2 Catalogo XLSX

Foglio di calcolo con 10 fogli:

| Foglio | Contenuto |
|---|---|
| **Video Overview** | Metadata completa, score composito |
| **Agent Scores** | Punteggio 0-10 per ogni agente, finding, raccomandazione |
| **Keyword Research** | Parole chiave, volume, competizione, priorita |
| **Content Calendar** | Idee video derivate con viral score |
| **Shorts Opportunities** | Momenti ottimi per Shorts con timestamp e script |
| **CTA Analysis** | Tutti i CTA con timestamp, tipo, efficacia |
| **Shot List** | Lista completa dei shot con tipo e complessita |
| **Revenue Estimation** | Stima revenue per stream (AdSense, sponsor, ecc.) |
| **Action Plan 30gg** | Piano azione settimanale con priorita |
| **Cross-Platform Kit** | Content per Twitter, LinkedIn, Blog, Instagram, TikTok, Newsletter |

### 10.3 Markdown Master Ledger

Documento vivo che si aggiorna nel tempo:

```markdown
# Master Video Intelligence Ledger

## Indice Video Analizzati
| # | Titolo | Canale | Views | Score | Data |
|---|---|---|---|---|---|

## Pattern Cross-Video
### Hook Piu Efficaci
### Strutture Script Migliori
### Pattern Thumbnail Vincenti
### Topic a Maggior Potenziale

## Per-Video Blueprints
### [Video 1]
### [Video 2]
...

## Piano Azione 30 Giorni
### Settimana 1
### Settimana 2
...
```

Il ledger **non viene mai sovrascritto** — ogni nuova analisi si aggiunge e i pattern si aggiornano.

---

## 11. Come Usare in una Nuova Chat

Questa e la procedura da seguire ogni volta che apri una nuova chat e vuoi continuare a usare il Dream Team.

### Metodo 1 — Con il file portatile (consigliato)

**Step 1:** Scarica il file `dream_team_index.md`
- Dal repo: https://github.com/TUO_USERNAME/youtube-ai-dream-team → clicca su dream_team_index.md → Raw → Salva
- Oppure scaricalo dalla chat precedente se l'AI te lo ha salvato

**Step 2:** Apri una nuova chat

**Step 3:** Invia questo messaggio esatto:
```
Usa il dream_team_index.md che ti allego per connetterti alla mia memoria persistente del Dream Team.
```

**Step 4:** Allega il file dream_team_index.md al messaggio

**Step 5:** L'AI leggera il file, si connettera al repo, e sara pronto.

### Metodo 2 — Con le credenziali (se hai perso il file)

Se non hai piu il file index, puoi ricrearlo fornendo le credenziali:

```
Configura il Dream Team con GitHub.

Owner: [il tuo username]
Token: [il tuo PAT]
```

L'AI eseguira tutto il setup da zero.

### Metodo 3 — Se l'ambiente ha il token salvato

Se stai usando lo stesso ambiente (stessa sessione server) e il token e gia stato salvato in `$GITHUB_TOKEN (variabile d'ambiente)`, puoi semplicemente dire:

```
Connettiti al repo Dream Team. Il token dovrebbe essere gia salvato.
```

---

## 12. I 31 Agenti — Riepilogo Completo

### Dipartimento A — Strategia & Ideazione (Agenti 01-06)

| # | Agente | Ruolo |
|---|---|---|
| 01 | YouTube Channel Architect | Orchestra la strategia complessiva del canale, definisce la nicchia |
| 02 | Niche & Competitor Analyst | Analizza i competitor per identificare gap e formati vincenti |
| 03 | Viral Topic Ideation Engine | Genera idee video ad alto potenziale virale |
| 04 | Keyword & SEO Strategist | Identifica keyword ad alto volume e bassa competizione |
| 05 | Title & Thumbnail Concept Generator | Sviluppa varianti titolo e concept thumbnail ad alto CTR |
| 06 | Audience Avatar Builder | Crea e mantiene il profilo dettagliato del viewer target |

### Dipartimento B — Pre-Produzione & Copione (Agenti 07-11)

| # | Agente | Ruolo |
|---|---|---|
| 07 | Hook & Intro Writer | Scrive i cruciali primi 30 secondi del copione |
| 08 | Core Script & Storyboard Writer | Scrive il copione principale con framework narrativi |
| 09 | Retention & Pacing Optimiser | Ottimizza ritmo, pattern interrupt e engagement |
| 10 | Call-to-Action CTA Strategist | Progetta CTA efficaci senza interrompere la visione |
| 11 | Shot List & B-Roll Planner | Genera shot list e suggerimenti B-Roll |

### Dipartimento C — Produzione & Post-Produzione (Agenti 12-16)

| # | Agente | Ruolo |
|---|---|---|
| 12 | Metadata & Description Writer | Scrive descrizioni SEO-optimized, capitoli e tag |
| 13 | Thumbnail Design Director | Fornisce prompt e layout per thumbnail |
| 14 | Video Editing Director | Fornisce brief di editing con note ritmo ed effetti |
| 15 | Audio & Sound Design Consultant | Suggerisce musica, effetti sonori e note audio |
| 16 | Subtitle & Caption Optimiser | Genera sottotitoli SRT/VTT accurati e coinvolgenti |

### Dipartimento D — Distribuzione & Repurposing (Agenti 17-21)

| # | Agente | Ruolo |
|---|---|---|
| 17 | Upload & Publishing Coordinator | Gestisce upload, metadata e impostazioni |
| 18 | YouTube Shorts Creator | Identifica e scripta i momenti migliori per Shorts |
| 19 | Cross-Platform Repurposing Agent | Adatta contenuti per Twitter, LinkedIn, Blog |
| 20 | Community Tab Strategist | Crea post community, sondaggi e behind-the-scenes |
| 21 | Newsletter Integration Specialist | Scrive copy newsletter per promuovere video |

### Dipartimento E — Engagement & Community (Agenti 22-25)

| # | Agente | Ruolo |
|---|---|---|
| 22 | Comment Moderation & Reply Engine | Analizza commenti e drafta risposte coinvolgenti |
| 23 | Viewer Sentiment Analyst | Analizza sentiment per valutare reazione audience |
| 24 | Superfan Identification Agent | Identifica i commenter piu attivi e leali |
| 25 | Collaboration & Outreach Scout | Identifica collaboratori e drafta email outreach |

### Dipartimento F — Analytics & Monetizzazione (Agenti 26-30)

| # | Agente | Ruolo |
|---|---|---|
| 26 | Lead Generation & Funnel Architect | Progetta strategia viewer-to-lead |
| 27 | Sponsorship & Brand Deal Negotiator | Crea media kit e identifica sponsor |
| 28 | YouTube Analytics Interpreter | Analizza CTR, AVD, retention per trend |
| 29 | A/B Testing Coordinator | Pianifica e traccia A/B test thumbnail/titoli |
| 30 | Revenue & ROI Tracker | Traccia tutti gli stream revenue e calcola ROI |

### Dipartimento G — Intelligence & Orchestrazione (Agente 31)

| # | Agente | Ruolo |
|---|---|---|
| **31** | **Master Video Analyzer & Orchestrator** | **Meta-agente che scarica video, li analizza con tutti 30 agenti, e genera PDF + XLSX + Markdown** |

---

## 13. Prompt Templates Pronti

### Analisi Video Singolo
```
Analizza questo video YouTube con tutti i 31 agenti:

URL: [INSERISCI URL VIDEO]

Il mio canale:
- Nicchia: [LA TUA NICCHIA]
- Audience: [LA TUA AUDIENCE TARGET]
- Obiettivo: [IL TUO OBIETTIVO]
- Lingua output: Italiano
```

### Analisi Canale
```
Analizza questo canale YouTube:

URL: [INSERISCI URL CANALE]

Il mio canale:
- Nicchia: [LA TUA NICCHIA]
- Audience: [LA TUA AUDIENCE TARGET]
- Obiettivo: [IL TUO OBIETTIVO]
- Lingua output: Italiano

Seleziona i video piu virali degli ultimi 6 mesi e analizzali tutti.
```

### Quick Scan
```
Quick scan di questo video:
[INSERISCI URL VIDEO]

Analisi rapida con 5 agenti chiave (hook, titolo, script, topic, analytics).
Output: solo summary + aggiorna ledger.
```

### Aggiornare il Contesto del Canale
```
Aggiorna il contesto del mio canale nel dream_team_index.md e nel ledger:

- Nicchia: [NUOVA NICCHIA]
- Target Audience: [NUOVA DESCRIZIONE]
- Canale YouTube: [URL DEL TUO CANALE]
- Obiettivo: [NUOVO OBIETTIVO]
```

### Leggere un SOP Specifico
```
Leggi il SOP dell'agente [NUMERO] dal repo e riassumimi:
- Il suo ruolo
- Il suo workflow
- I suoi output
- Come posso usarlo manualmente
```

---

## 14. Limitazioni e Note Importanti

### Limitazioni Tecniche

| Limitazione | Dettaglio | Soluzione |
|---|---|---|
| **Dimensione video** | Video molto lunghi (>2 ore) possono superare i limiti di elaborazione | Usare il Quick Scan per video lunghi |
| **Frame extraction** | Analisi visiva limitata a frame campionati (1 ogni 30 sec) | Aumentare frequenza per video brevi |
| **Trascrizione** | Sottotitoli non disponibili per tutti i video | Fallback: transcription da frame con Vision AI |
| **Commenti** | Non sempre accessibili senza API YouTube Analytics | Usare available data + stimare |
| **Thumbnail** | Qualita ridotta se il video e vecchio o rimosso | Scaricare thumbnail appena possibile |

### Note di Sicurezza

- **Il PAT token** e salvato solo nel filesystem locale, mai visibile in chat
- **I file MP4** vengono cancellati dopo ogni analisi per liberare memoria
- **Il repo e privato** — solo tu e l'AI avete accesso
- **Git history** — ogni modifica e tracciata, puoi sempre tornare indietro

### Quando il Token Scade

Se il token scade o viene revocato:
1. Vai su https://github.com/settings/tokens?type=beta
2. Crea un nuovo token (segui la Sezione 4 di questa guida)
3. Invia il nuovo token all'AI:
   ```
   Aggiorna il token GitHub: [NUOVO TOKEN]
   ```
4. L'AI aggiornera il file delle credenziali

---

## 15. Risoluzione Problemi Comuni

### Problema: "yt-dlp download fallisce"

**Causa:** YouTube aggiorna frequentemente le sue protezioni.

**Soluzione:**
```
Aggiorna yt-dlp all'ultima versione:
pip install -U yt-dlp

Se ancora non funziona, prova con:
yt-dlp --extractor-args "youtube:player_client=ios" [URL]
```

### Problema: "Nessun sottotitolo disponibile"

**Causa:** Il video non ha sottotitoli automatici o manuali.

**Soluzione:** L'AI usera la Vision AI per trascrivere visivamente dai frame, oppure estrara l'audio e usera un modello di speech-to-text.

### Problema: "Il repo non si aggiorna"

**Causa:** Token scaduto o permessi insufficienti.

**Soluzione:**
1. Verifica che il token sia ancora valido su GitHub
2. Controlla che il permission "Contents" sia su "Read and Write"
3. Genera un nuovo token se necessario (Sezione 4)

### Problema: "Il ledger diventa troppo grande"

**Causa:** Molte analisi accumulate.

**Soluzione:** L'AI puo archiviare le analisi piu vecchie di 90 giorni in un file `ledger_archive.md` separato, mantenendo solo i pattern e il piano azione.

### Problema: "Analisi troppo generica"

**Causa:** Contesto del canale non compilato o insufficiente.

**Soluzione:** Compila sempre il contesto del canale (nicchia, audience, obiettivo) nel dream_team_index.md prima delle analisi. Più contesto fornisci, piu mirata sara l'analisi.

### Problema: "Non trovo il file dream_team_index.md"

**Causa:** Potresti averlo cancellato o non averlo scaricato.

**Soluzione:** Scaricalo direttamente dal repo GitHub:
```
https://github.com/TUO_USERNAME/youtube-ai-dream-team/blob/main/dream_team_index.md
→ Clicca "Raw" → Salva come file
```

Oppure chiedi all'AI:
```
Rigenera il dream_team_index.md per me
```

---

## 16. Cronologia Versioni

| Versione | Data | Novita |
|---|---|---|
| **1.0** | Aprile 2026 | Release originale — 30 agenti SOP (Augmented AI) |
| **1.1** | Maggio 2026 | Aggiunto Agente 31 (Master Video Analyzer & Orchestrator), sistema memoria persistente GitHub, dream_team_index.md portatile, master_video_ledger.md documento vivo, GUIDA_COMPLETA_SETUP.md |

---

## Links Utili

| Risorsa | URL |
|---|---|
| Repository GitHub | https://github.com/YOUR_USERNAME/youtube-ai-dream-team |
| Token GitHub | https://github.com/settings/tokens?type=beta |
| yt-dlp | https://github.com/yt-dlp/yt-dlp |
| FFmpeg | https://ffmpeg.org |
| Augmented AI (canale) | https://youtube.com/@augmentedai |
| Augmented AI (community) | https://skool.com/augmentedai |

---

*Basato sul YouTube AI Dream Team di Ritesh Kanjee (Augmented AI).*
*Agente 31, sistema memoria e guida creati da Super Z AI — Maggio 2026.*
*Ultimo aggiornamento: 2026-05-19*
