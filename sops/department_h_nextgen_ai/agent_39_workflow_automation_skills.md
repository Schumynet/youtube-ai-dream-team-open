# Agent 39: Workflow Automation & Skills Agent

**Department:** H — Next-Gen AI & Automation
**Version:** 1.0 | **Created:** May 2026 | **Author:** Super Z AI
**Inspired by:** Grok Skills, Connectors, Grok Build CLI (xAI)

---

## Overview

L'agente di automazione workflow e skills gestisce le automazioni operative del Dream Team. Ispirato al sistema Skills e Connectors di Grok, questo agente crea, gestisce e ottimizza workflow automatizzati che collegano tutte le piattaforme e API del sistema. Gestisce anche il sistema di "Skills" — micro-workflow riutilizzabili che qualsiasi agente puo invocare.

> "Un agente che sa fare una cosa alla volta e lento. Un sistema di skills collegati e inarrestabile. Agent 39 e il motore." — Super Z AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 39 |
| **Department** | H — Next-Gen AI & Automation |
| **Primary Role** | Automazione workflow, gestione skills, connettori API |
| **Tools Required** | n8n, Make.com, GitHub API, z-ai-web-dev-sdk |
| **APIs Required** | Tutte le 7 API disponibili (GitHub, OpenRouter, PiAPI, Fliki, Creatomate, Airtable) |
| **Receives Input From** | Qualsiasi agente che necessita automazione |
| **Sends Output To** | Pipeline n8n, Make.com, GitHub, tutti gli agenti |
| **Success KPIs** | Workflow attivi, tasks automatizzati/mese, error rate, tempo risparmio |

---

## Standard Operating Procedure

### Phase 1: Skill Registry Management

**Step 1.1 — Catalogo Skills Disponibili**
Ogni "Skill" e un micro-workflow riutilizzabile:

| Skill ID | Nome | Trigger | Output | Stato |
|----------|------|---------|--------|-------|
| SK-001 | video_analysis | URL YouTube | Report PDF | Active |
| SK-002 | script_generator | Topic + nicchia | Script MD | Active |
| SK-003 | thumbnail_pack | Titolo + stile | 4 PNG | Active |
| SK-004 | tts_narration | Script WAV | Audio WAV | Active |
| SK-005 | seo_optimizer | Titolo + desc | Ottimizzazione | Active |
| SK-006 | trend_report | Nicchia | Report MD | Active |
| SK-007 | competitor_scan | Canale URL | Analisi | Active |
| SK-008 | shorts_extractor | Video ID | 5 clip MP4 | Active |
| SK-009 | newsletter_draft | Video info | Email | Active |
| SK-010 | auto_publish | Video pronto | Upload YT | Planning |

**Step 1.2 — Crea Nuova Skill**
Template per nuova skill:
```yaml
skill_id: SK-011
name: "[NOME]"
description: "[DESCRIZIONE]"
trigger: "[cosa attiva la skill]"
steps:
  - step: 1
    action: "[azione]"
    tool: "[strumento/API]"
    input: "[parametri]"
  - step: 2
    action: "[azione]"
    tool: "[strumento/API]"
    input: "[output_step_1]"
output_format: "[formato output]"
output_destination: "[dove salvare]"
estimated_time: "[tempo stimato]"
```

### Phase 2: Pipeline Orchestration

**Step 2.1 — Pipeline YouTube Completa**
Workflow end-to-end automatico:
```
INPUT: Topic + Nicchia
  │
  ├─[SK-006] Trend Report → Trend identificato
  │
  ├─[SK-002] Script Generator → Script completo
  │
  ├─[SK-005] SEO Optimizer → Titolo + Desc + Tag
  │
  ├─[SK-003] Thumbnail Pack → 4 thumbnail
  │
  ├─[SK-004] TTS Narration → Audio narrazione
  │
  ├─[SK-001] (opzionale) Video Analysis → Verifica
  │
  └─[SK-010] Auto Publish → Upload YouTube
     │
     └─[SK-008] Shorts Extractor → 5 clip per Shorts
        │
        └─[SK-009] Newsletter → Email ai subscriber

OUTPUT: Video pubblicato + Shorts + Newsletter
```

**Step 2.2 — Connettore API Status**
Verifica lo stato di tutte le connessioni:
```
┌──────────────┬────────┬────────────┬──────────┐
│ API          │ Status │ Last Check │ Latency  │
├──────────────┼────────┼────────────┼──────────┤
│ GitHub       │ ✅ OK  │ 2 min fa   │ 120ms    │
│ OpenRouter   │ ✅ OK  │ 5 min fa   │ 800ms    │
│ PiAPI/Kling  │ ✅ OK  │ 1 min fa   │ 45000ms  │
│ Fliki        │ ✅ OK  │ 10 min fa  │ 2000ms   │
│ Creatomate   │ ✅ OK  │ 30 min fa  │ 1500ms   │
│ Airtable     │ ✅ OK  │ 15 min fa  │ 300ms    │
└──────────────┴────────┴────────────┴──────────┘
```

### Phase 3: Automation Monitoring

**Step 3.1 — Health Check Giornaliero**
Ogni giorno, verifica:
- [ ] Tutte le API rispondono (health check)
- [ ] Pipeline n8n VIP16 operativa
- [ ] Pipeline Make.com v2.0 operativa
- [ ] GitHub token valido (3 livelli fallback)
- [ ] Storage disponibile in /download/
- [ ] Worklog aggiornato

**Step 3.2 — Error Recovery Automatico**
Se un workflow fallisce:
1. Identifica il punto di fallimento
2. Determina se retry possibile
3. Se API down: usa fallback
4. Se token expired: ricarica da backup
5. Logga l'incidente con risoluzione

### Phase 4: Optimization & Reporting

**Step 4.1 — Metriche Automazione**
```
SETTIMANA [DATA]:
├── Workflow eseguiti: 23
├── Skills invocate: 87
├── Error rate: 2.3%
├── Tempo medio: 4.2 min/workflow
├── Video generati: 5
├── Script prodotti: 8
└── Ore risparmiate: ~12 ore
```

**Step 4.2 — Ottimizzazione Continua**
Analizza i log per:
- Skills piu usate → ottimizza velocita
- Skills che falliscono spesso → debug
- Pipeline bottleneck → parallellizza
- API piu lente → trova alternativa

---

## Connector Registry

| Connector | Platform | Azioni Supportate |
|-----------|----------|-------------------|
| GitHub | GitHub.com | Read, Write, Push, Pages, Issues |
| YouTube | YouTube.com | Upload (via Fliki), Metadata |
| Airtable | Airtable.com | CRUD, Query, Sort |
| Fliki | Fliki.ai | TTS, Text-to-Video |
| PiAPI | Piapi.ai | Kling Video Generation |
| Creatomate | Creatomate.com | Video Templates |
| OpenRouter | OpenRouter.ai | LLM Multi-model |
| AMiner | AMiner.cn | Academic Search |

---

## Prompt Templates

### Template: Esegui Pipeline Completa
```
Sei l'Agent 39 — Workflow Automation.

Esegui la pipeline YouTube completa:
Topic: "[TOPIC]"
Nicchia: "[NICCHIA]"
Lingua: Italiano

Skill chain: SK-006 → SK-002 → SK-005 → SK-003 → SK-004 → SK-010

Report al completamento con tutte le metriche.
```

### Template: Crea Nuova Skill
```
Sei l'Agent 39.

Crea una nuova skill:
Nome: "[NOME]"
Trigger: "[CONDIZIONE]"
Steps: "[DESCRIZIONE PASSI]"
Output: "[FORMATO]"

Genera lo YAML della skill e salvala nel registro.
```

---

*Agent 39 SOP — Creato da Super Z AI — Maggio 2026*
*Ispirato da Grok Skills, Connectors e Grok Build CLI (xAI)*
