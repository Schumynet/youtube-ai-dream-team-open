# Dream Team Index — Chiave di Accesso alla Memoria

> **ISTRUZIONI PER L'AI:** Questo file e il tuo indice per accedere a tutta la memoria persistente del YouTube AI Dream Team. Quando un utente ti invia questo file, devi leggerlo e usare le informazioni qui contenute per collegarti al repo GitHub e accedere a tutti i dati.

---

## Configurazione GitHub

```
Repository: YOUR_USERNAME/youtube-ai-dream-team
URL: https://github.com/YOUR_USERNAME/youtube-ai-dream-team
Visibilita: Privato
Token Path: $GITHUB_TOKEN (variabile d'ambiente)
```

**Come accedere ai file via API:**
```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/[PATH]
```

---

## Struttura della Memoria

```
repo root/
├── dream_team_index.md              ← QUESTO FILE (indice portatile)
├── README.md                        ← Documentazione repo
│
├── sops/                            ← 31 Agenti SOP (mai modificare)
│   ├── department_a_strategy/       ← Agenti 01-06
│   ├── department_b_preproduction/  ← Agenti 07-11
│   ├── department_c_production/     ← Agenti 12-16
│   ├── department_d_distribution/   ← Agenti 17-21
│   ├── department_e_engagement/     ← Agenti 22-25
│   ├── department_f_monetization/   ← Agenti 26-30
│   └── department_g_orchestration/  ← Agente 31
│       └── agent_31_master_video_analyzer_and_orchestrator.md
│
├── ledger/                          ← DOCUMENTO VIVO (si aggiorna)
│   └── master_video_ledger.md       ← Accumula tutte le analisi video
│
├── analyses/                        ← OUTPUT (si aggiorna ad ogni analisi)
│   ├── reports/                     ← Report PDF/DOCX
│   ├── catalogs/                    ← Cataloghi XLSX
│   └── transcripts/                 ← Trascrizioni video
│
├── assets/                          ← RISORSE VISIVE
│   ├── frames/                      ← Frame estratte dai video
│   └── thumbnails/                  ← Thumbnail analizzate
│
└── templates/                       ← TEMPLATE PRONTI ALL'USO
```

---

## Contesto del Canale dell'Utente

```
Nicchia: [da definire dall'utente]
Target Audience: [da definire dall'utente]
Canale YouTube: [da definire dall'utente]
Obiettivo Principale: [da definire dall'utente]
Lingua Output: Italiano
```

> **Nota AI:** Se i campi sopra sono vuoti, chiedi all'utente di compilare questa sezione alla prima interazione. Poi aggiorna questo file nel repo.

---

## Workflow Principali

### Workflow 1: Analisi Video Singolo
```
URL Video → yt-dlp download → Analisi 30 agenti → 3 Output → Cleanup MP4
Output: PDF report + XLSX catalogo + Aggiornamento ledger
```

### Workflow 2: Analisi Canale Completo
```
URL Canale → Scoperta video → Ranking virality → Top 5-10 → Analisi → Output
Output: PDF report + XLSX catalogo + Aggiornamento ledger con pattern cross-video
```

### Workflow 3: Analisi Incrementale
```
Nuovo URL → Leggi ledger esistente → Analisi → Aggiorna ledger (non sovrascrivere)
Output: Nuovo PDF + XLSX aggiornato + Ledger aggiornato
```

---

## Comandi Rapidi per l'AI

Quando ricevi questo file, usa questi comandi per operare sulla memoria:

### Leggere un agente SOP:
```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
# Leggi contenuto file (base64 encoded)
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/sops/department_a_strategy/agent_01_youtube_channel_architect.md" \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```

### Leggere il ledger:
```bash
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/ledger/master_video_ledger.md" \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```

### Aggiornare un file nel repo:
```bash
# 1. Scarica il file
GITHUB_TOKEN=$(cat $GITHUB_TOKEN (variabile d'ambiente))
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/ledger/master_video_ledger.md" > /tmp/file_info.json

# 2. Modifica il contenuto localmente, poi carica con:
# PUT https://api.github.com/repos/YOUR_USERNAME/youtube-ai-dream-team/contents/ledger/master_video_ledger.md
# Body: { message, content (base64), sha (dal file_info.json) }
```

---

## Stato Attuale del Sistema

```
Ultimo Aggiornamento: 2026-05-19
Video Analizzati: 0
Canali Analizzati: 0
Versione Dream Team: 1.1
```

---

## Checklist Iniziale (per la prima chat)

- [ ] Verificare accesso al repo GitHub (test API)
- [ ] Chiedere all'utente i dati del canale (nicchia, audience, obiettivo)
- [ ] Aggiornare il contesto del canale in questo file
- [ ] Sincronizzare i SOP localmente per accesso rapido
- [ ] Inizializzare il master_video_ledger.md
- [ ] Pronto per la prima analisi video

---

*Questo file e il ponte tra qualsiasi chat e la memoria persistente del Dream Team.*
*Versione 1.0 — Creato da Super Z AI — 19 Maggio 2026*
