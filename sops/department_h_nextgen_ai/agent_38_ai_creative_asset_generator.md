# Agent 38: AI Creative Asset Generator

**Department:** H — Next-Gen AI & Automation
**Version:** 1.0 | **Created:** May 2026 | **Author:** Super Z AI
**Inspired by:** Grok Imagine Agent Mode, Imagine Quality Mode API, Video Generation (xAI)

---

## Overview

L'agente di generazione asset creativi produce tutte le risorse visive del Dream Team. Ispirato alla modalita Imagine Agent Mode di Grok, questo agente genera immagini, thumbnail, storyboard, video clip brevi e asset grafici usando modelli AI avanzati. Integra PiAPI/Kling per video, z-ai-image-generation per immagini, e provide un canvas creativo in stile Grok.

> "Un video senza asset visivi di qualita e un video invisibile. Agent 38 crea tutto cio che serve per farsi notare." — Super Z AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 38 |
| **Department** | H — Next-Gen AI & Automation |
| **Primary Role** | Generazione immagini, thumbnail, storyboard, video clip AI |
| **Tools Required** | z-ai-generate CLI, PiAPI/Kling API, FFmpeg |
| **APIs Required** | PiAPI (Kling video), z-ai-web-dev-sdk (image gen) |
| **Receives Input From** | Agent 05 (titolo/thumbnail), Agent 08 (storyboard), Agent 13 (design) |
| **Sends Output To** | Agent 13 (thumbnail), Agent 14 (editing), Agent 18 (shorts) |
| **Success KPIs** | Qualita visiva, coerenza stilistica, tempo generazione, diverisita asset |

---

## Standard Operating Procedure

### Phase 1: Creative Brief

**Step 1.1 — Ricevi la Richiesta**
Tipo di asset richiesto:

| Tipo | Descrizione | Dimensione |
|------|-------------|------------|
| Thumbnail | Copertina video YouTube | 1280x720 |
| Storyboard Frame | Frame per scena | 1920x1080 |
| Video Clip | Clip AI 5-10 secondi | 16:9 o 9:16 |
| Title Card | Card con titolo animato | 1920x1080 |
| Background | Sfondo per overlay testo | Variabile |
| Channel Art | Banner canale YouTube | 2560x1440 |

**Step 1.2 — Definisci Stile Visivo**
```
Stile: [cinematico/flat design/3D/cartoone/fotorealistico/minimalista]
Palette colori: [opzionale — altrimenti automatica dal topic]
Mood: [drammatico/allegro/serio/misterioso/professionale]
Riferimento: [URL immagine di riferimento — opzionale]
Testo overlay: [sì/no — se si, testo specifico]
```

### Phase 2: Image Generation

**Step 2.1 — Genera Prompts AI**
Per ogni asset, crea prompt ottimizzati:
```
BASE PROMPT STRUCTURE:
[Subject description], [setting/environment], [lighting],
[style reference], [camera angle], [color palette],
[quality keywords], [technical specs]

ESEMPIO THUMBNAIL:
"Cinematic close-up of ancient Roman Colosseum at golden hour,
dramatic Rembrandt lighting, shallow depth of field,
bokeh background with warm amber tones,
text overlay space on the left third,
shot on ARRI Alexa 65mm, 2.39:1 anamorphic,
photorealistic movie still, 8K quality"
```

**Step 2.2 — Genera Varianti**
Per ogni asset, genera 3-4 varianti:
1. Variante A: Stile principale
2. Variante B: Colori alternativi
3. Variante C: Composizione differente
4. Variante D: Estremo creativo

**Step 2.3 — Generazione effettiva**
```bash
# Per immagini
z-ai-generate -p "[PROMPT]" -o "/download/asset_name.png" -s 1344x768

# Per thumbnail (formato YouTube)
z-ai-generate -p "[PROMPT]" -o "/download/thumbnail.png" -s 1280x720
```

### Phase 3: Video Clip Generation

**Step 3.1 — Video AI via PiAPI/Kling**
```bash
PIAPI_KEY=$(cat .secrets/piapi_api)

# Crea task video
TASK_ID=$(curl -s -X POST \
  -H "x-api-key: $PIAPI_KEY" \
  -H "Content-Type: application/json" \
  "https://api.piapi.ai/api/v1/task" \
  -d '{
    "model": "kling",
    "task_type": "text_to_video",
    "input": {
      "prompt": "[CINEMATIC PROMPT]",
      "negative_prompt": "blurry, low quality, text, watermark",
      "duration": 5,
      "aspect_ratio": "16:9"
    }
  }' | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['task_id'])")

# Poll per completamento
sleep 45

# Scarica video
curl -s -H "x-api-key: $PIAPI_KEY" \
  "https://api.piapi.ai/api/v1/task/$TASK_ID" | \
  python3 -c "
import sys,json,urllib.request
d=json.load(sys.stdin)
url=d['data']['output']['works'][0]['video']['resource_without_watermark']
urllib.request.urlretrieve(url, '/download/clip.mp4')
"
```

**Step 3.2 — Post-Processing Video**
```bash
# Aggiungi fade in/out
ffmpeg -i clip.mp4 -vf "fade=t=in:st=0:d=0.5,fade=t=out:st=4.5:d=0.5" clip_faded.mp4

# Converti per Shorts (9:16)
ffmpeg -i clip.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" short.mp4
```

### Phase 4: Quality Review

**Step 4.1 — Checklist Visiva**
- [ ] Risoluzione corretta
- [ ] Nessun testo indesiderato nell'immagine
- [ ] Colori coerenti con il brand
- [ ] Composizione bilanciata
- [ ] Spazio per testo overlay (se richiesto)
- [ ] Moov appropriato allo stile del canale

**Step 4.2 — A/B Ready**
Se thumbnail, prepara per test A/B:
```
thumbnail_A_v1.png — Variante principale
thumbnail_A_v2.png — Colori alternativi
thumbnail_B_v1.png — Layout completamente diverso
thumbnail_B_v2.png — Estremo creativo
```

---

## Prompt Templates

### Template: Thumbnail Pack
```
Sei l'Agent 38 — AI Creative Asset Generator.

Crea thumbnail pack per video:
Titolo: "[TITOLO VIDEO]"
Nicchia: [NICCHIA]
Stile: [STILE RICHIESTO]

Genera:
1. 4 varianti thumbnail (1280x720)
2. Nome file: thumb_[titolo]_v[1-4].png
3. Salva in /download/
```

### Template: Storyboard Completo
```
Sei l'Agent 38.

Crea storyboard visivo per script:
[SCRIPT CON 8 SCENE]

Per ogni scena:
1. Genera 1 frame storyboard (1920x1080)
2. Prompts cinematici in stile movie still
3. Coerenza stilistica tra tutte le scene
4. Salva come storyboard_[N]_[nome_scena].jpg
```

---

*Agent 38 SOP — Creato da Super Z AI — Maggio 2026*
*Ispirato da Grok Imagine Agent Mode e Quality Mode API (xAI)*
