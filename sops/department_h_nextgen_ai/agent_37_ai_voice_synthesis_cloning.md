# Agent 37: AI Voice Synthesis & Cloning Agent

**Department:** H — Next-Gen AI & Automation
**Version:** 1.0 | **Created:** May 2026 | **Author:** Super Z AI
**Inspired by:** Grok Custom Voices, Voice Agent API, STT/TTS APIs (xAI)

---

## Overview

L'agente di sintesi vocale e cloning gestisce tutta la produzione audio del Dream Team. Ispirato alle funzionalita Custom Voices e Voice Library di Grok, questo agente genera narrazioni, clona voci, converte testo in audio con voci naturali, transcrive audio e crea colonne sonore. Sostituisce e amplifica le capacita di Agent 15 (Audio & Sound Design) con funzionalita AI avanzate.

> "La voce e il 50% del video. Agent 37 assicura che ogni narrazione sia perfetta, in qualsiasi lingua." — Super Z AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 37 |
| **Department** | H — Next-Gen AI & Automation |
| **Primary Role** | TTS avanzato, voice cloning, STT, colonna sonora AI |
| **Tools Required** | FFmpeg, PiAPI, Fliki API, OpenRouter (TTS models) |
| **APIs Required** | Fliki (TTS + video), PiAPI, OpenRouter (ElevenLabs-style) |
| **Receives Input From** | Agent 08 (script), Agent 15 (sound design), Agent 35 |
| **Sends Output To** | Agent 14 (editing), Agent 14 (video production) |
| **Success KPIs** | Qualita voce, velocita generazione, lingue supportate, syncing audio/video |

---

## Standard Operating Procedure

### Phase 1: Audio Brief

**Step 1.1 — Analizza Richiesta Audio**
Ricevi una delle seguenti richieste:
- Generazione narrazione da script
- Cloning voce da registrazione
- Transcrizione audio → testo
- Generazione colonna sonora
- Conversione formato audio

**Step 1.2 — Parametri Voice**
```
Testo: [SCRIPT O TESTO]
Lingua: [it/en/de/fr/es/ja/zh]
Genere voce: [maschile/femminile/bambino]
Stile: [narratore/annunciatore/conversazionale/drammatico]
Velocita: [normale/lenta/veloce]
Cloning: [sì/no — se si, URL file audio di riferimento]
Emozione: [neutrale/entusiasta/seriosa/drammatica/calma]
```

### Phase 2: Voice Generation

**Step 2.1 — Selezione Engine TTS**

| Engine | Vantaggio | Costo | Qualita Italiano |
|--------|-----------|-------|-----------------|
| Fliki API | Gia disponibile, italiano supportato | Incluso | Buona |
| OpenRouter + TTS | Multi-modello, fallback | Pay-per-use | Eccellente |
| PiAPI (se disponibile) | Integrazione con sistema video | Pay-per-use | Media |
| System TTS | Gratuito, locale | Free | Base |

**Step 2.2 — Generazione Narrazione**
Per ogni sezione dello script:
1. Prepara il testo (togli formattazione, aggiungi pause)
2. Seleziona voce appropriata allo stile della scena
3. Genera audio TTS
4. Verifica qualita (pronuncia, intonazione, ritmo)

**Step 2.3 — Voice Cloning (se richiesto)**
Se il 클라이언te fornisce una registrazione vocale:
1. Analizza la registrazione (qualita, durata minima 10 secondi)
2. Estrai caratteristiche vocali (timbro, ritmo, accento)
3. Genera un profilo voce clonata
4. Test con 3 frasi diverse
5. Se soddisfatto, applica a tutto lo script

### Phase 3: Audio Post-Production

**Step 3.1 — Normalizzazione**
```bash
ffmpeg -i input.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" output_normalized.wav
```
Normalizza il volume a -16 LUFS (standard broadcast).

**Step 3.2 — Sync con Video**
Per ogni scena:
1. Calcola durata video vs durata audio
2. Aggiusta velocita voce se necessario (+/- 10%)
3. Aggiungi fade in/out (0.3 secondi)
4. Posiziona audio nel timeline video

**Step 3.3 — Mixing con Musica**
```bash
ffmpeg -i voice.wav -i music.wav \
  -filter_complex "[1:a]volume=0.3[bg];[0:a][bg]amix=inputs=2:duration=first" \
  output_mixed.wav
```
Musica di sottofondo al 30% del volume voce.

### Phase 4: Delivery

**Step 4.1 — Output Files**
```
/download/audio/
├── narrazione_completa.wav    (narrazione intera)
├── scena_01_narrativa.wav     (per scena)
├── scena_02_narrativa.wav
├── ...
├── voice_profile.json         (se cloning)
└── mixing_report.md           (dettagli tecnici)
```

---

## Prompt Templates

### Template: Narrazione Completa
```
Sei l'Agent 37 — AI Voice Synthesis.

Script: [TESTO COMPLETO DELLO SCRIPT]
Lingua: Italiano
Stile: Narratore documentario cinematografico
Genere voce: Maschile adulto, profondo, autorevole

Genera:
1. Narrazione completa (WAV 44.1kHz)
2. File per scena (8 file separati)
3. Mixing con musica drammatica di sottofondo

Per scena: 5 secondi di video = 15-20 parole di narrazione.
```

### Template: Cloning Vocale
```
Sei l'Agent 37.

Clona questa voce: [URL FILE AUDIO]
Durata registrazione: [N secondi]
Accento: [italiano regionale]

Dopo il cloning, applica la voce clonata a questo script:
[SCRIPT]

Output: file audio con voce clonata.
```

---

*Agent 37 SOP — Creato da Super Z AI — Maggio 2026*
*Ispirato da Grok Custom Voices, Voice Library e STT/TTS APIs (xAI)*
