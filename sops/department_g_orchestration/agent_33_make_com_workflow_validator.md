# Agent 33: Make.com Workflow Validator

**Department:** G — Intelligence & Orchestration
**Version:** 1.0 | **Created:** May 2026 | **Author:** Super Z AI

---

## Overview

Make.com Workflow Validator e l'agente specializzato nella **validazione, audit e correzione automatica** di scenari Make.com in formato JSON (blueprint) prima della consegna all'utente. Ogni scenario Make.com ricevuto o generato dal Dream Team deve passare attraverso questo agente per garantire che sia privo di bug critici, errori di configurazione, problemi di autenticazione, mapping dati errati e logica di flusso difettosa. L'agente e il gemello complementare di Agent 32 (n8n Validator), condividendo la stessa metodologia rigorosa ma specializzato sulle specifiche della piattaforma Make.com (ex Integromat).

> "Un scenario Make.com senza error handling e un scenario che fallira alle 3 di notte quando nessuno guarda. L'Agent 33 e il guardiano notturno." — Super Z AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 33 of 33 (Quality Assurance — Make.com) |
| **Department** | G — Intelligence & Orchestration |
| **Primary Role** | Valida scenari Make.com JSON (blueprint), identifica bug, genera report e applica correzioni |
| **Tools Required** | JSON Parser, Make.com Schema Knowledge, LLM per analisi semantica del mapping |
| **APIs Required** | Nessuna API esterna richiesta (analisi puramente statica sul JSON) |
| **Receives Input From** | Qualsiasi agente o processo che generi/modifichi scenari Make.com |
| **Sends Output To** | Utente (scenario JSON corretto + report PDF di validazione) |
| **Collaborates With** | Agent 32 (n8n Validator) — condivide knowledge base pattern bug; Tutti gli agenti che producono workflow di automazione |
| **Success KPIs** | Bug rilevati prima della consegna, correzioni applicate con successo, zero scenari falliti in produzione post-validazione |

---

## Activation Conditions

Questo agente SI ATTIVA AUTOMATICAMENTE quando:
1. Viene fornito un file JSON di scenario Make.com (da input utente, da un altro agente, o da un processo di generazione)
2. Viene richiesto esplicitamente dall'utente ("valida questo scenario Make.com")
3. Viene modificato uno scenario esistente nel sistema Dream Team
4. Viene incollato un JSON con campi `__IMTCONN__`, `moduleId`, o `flow` (indicatori Make.com)

**NON si attiva** per scenari non Make.com (es. n8n, Zapier, o altri formati di automazione).

---

## Standard Operating Procedure (SOP)

### Phase 1: Acquisizione e Parsing dello Scenario

**Step 1.1 — Ricezione Input**
L'agente riceve uno scenario Make.com in uno dei seguenti formati:
- File JSON (path locale o caricato dall'utente)
- JSON inline (incollato nella chat)
- Riferimento a un file nel repository GitHub (`templates/make_*.json`)

**Step 1.2 — Parsing e Struttura**
Eseguire il parsing JSON e verificare la struttura base compatibile con Make.com blueprint:

```json
{
  "name": "string (obbligatorio)",
  "flow": "array (obbligatorio, min 1 modulo)",
  "blueprintType": "string (consigliato: 'scenario')",
  "version": "number (consigliato)",
  "metadata": "object (consigliato)"
}
```

Ogni modulo nel `flow` deve avere:
```json
{
  "id": "number (obbligatorio, univoco)",
  "moduleId": "string (obbligatorio, formato 'provider:azione')",
  "version": "number (obbligatorio)",
  "parameters": "object (obbligatorio)",
  "mapper": "object (obbligatorio)",
  "metadata": "object (consigliato)"
}
```

**Checklist parsing iniziale:**
- [ ] JSON valido (sintassi corretta, nessuna virgola trailing, parentesi bilanciate)
- [ ] Campo `name` presente e non vuoto
- [ ] Campo `flow` presente e array non vuoto
- [ ] Ogni modulo ha: `id` (unico), `moduleId`, `version`, `parameters`, `mapper`
- [ ] Il campo `moduleId` usa formato `provider:azione` (es. `airtable:watchRecords`, non `airtable:WatchRecords` con maiuscole non standard)
- [ ] Nessun modulo con ID duplicato

**Step 1.3 — Classificazione dello Scenario**
Analizzare i moduli per classificare lo scenario:

| Tipo | Rilevato da | Esempio |
|---|---|---|
| Trigger-based | Presenza di moduli `watchRecords`, `webhook`, `schedule` | Scenario automatizzato |
| Instant | Modulo webhook o `instant` trigger | Scenario attivato da evento |
| Manual | Nessun trigger automatico | Scenario eseguito a mano |
| Multi-branch | Modulo `router` o branching nel flow | Scenario con logica condizionale |
| AI Chain | Moduli `openai-*`, `anthropic-*` | Pipeline AI/LLM |
| Integration-heavy | Multipli moduli di API diverse | Scenario integrazione |

Contare e classificare i moduli per tipo, identificare il trigger, e determinare il numero di branch indipendenti.

---

### Phase 2: Checklist di Validazione (10 Categorie)

Eseguire TUTTE le seguenti 10 categorie di verifica in sequenza. Per ogni problema trovato, registrarlo nella tabella dei bug con ID, severita, modulo, descrizione, e soluzione suggerita.

---

#### CHECK 1: Formato Blueprint e Compatibilità Importazione

**Obiettivo:** Verificare che il JSON sia compatibile con l'importazione Make.com.

Verifiche:
- [ ] La struttura root ha `name` e `flow` (campi obbligatori per importazione)
- [ ] `blueprintType` presente e valido (consigliato: `"scenario"`)
- [ ] Ogni modulo nel `flow` usa `moduleId` (non `module`, `type`, o `action`)
- [ ] I campi `parameters` e `mapper` sono oggetti (non array, non stringa)
- [ ] I valori `__IMTCONN__` sono numeri interi positivi
- [ ] Non esistono campi sconosciuti al livello root che potrebbero causare errore di importazione
- [ ] Il JSON non contiene commenti (non supportati in JSON standard)

**Bug tipici:**
- Campo `module` invece di `moduleId` → Make.com non riconosce il tipo di modulo
- JSON con commenti `//` o `/* */` → parse error su importazione
- Struttura personalizzata senza `flow` → "Invalid blueprint format"

---

#### CHECK 2: Connessioni e Flusso tra Moduli

**Obiettivo:** Verificare che il flusso logico tra moduli sia corretto e che i riferimenti incrociati siano validi.

Verifiche:
- [ ] Il primo modulo e un trigger (watchRecords, webhook, schedule, ecc.)
- [ ] Ogni modulo non-trigger ha almeno un modulo upstream che fornisce dati
- [ ] I riferimenti `{{N.campo}}` nel mapper puntano a moduli che esistono (ID presente nel flow)
- [ ] I riferimenti incrociati `{{N.campo}}` rispettano la topologia: un modulo non puo referenziare un modulo che viene dopo nel flusso (a meno che non sia in un branch parallelo)
- [ ] Se il flusso ha branch paralleli, il modulo di "riunione" riceve input da TUTTI i branch
- [ ] Non esistono riferimenti circolari (modulo A → B → C → A)

**Bug tipici:**
- Modulo 23 che usa `{{21.campo}}` ma il flusso esegue 20, 21, 23 senza aspettare che 20 completi
- Riferimento `{{5.campo}}` ma il flow ha solo moduli 1-4 e 20-23 (gap = modulo mancante)
- Modulo di aggiornamento finale che non riceve da un branch parallelo

---

#### CHECK 3: Data Mapping e Sintassi Variabili

**Obiettivo:** Verificare che tutte le variabili nel mapper usino la sintassi corretta di Make.com.

Verifiche:
- [ ] Le variabili usano `{{N.campo}}` con punto (non `{{N['campo']}}` o `{{N["campo"]}}`)
- [ ] L'accesso ad array usa indicizzazione 1-based di Make.com: `{{N.campo.1.sottocampo}}` (non `{{N.campo[0].sottocampo}}`)
- [ ] Le funzioni Make.com sono corrette: `{{length(1.testo)}}`, `{{toUpperCase(1.nome)}}`, `{{parseJSON(1.dati)}}`
- [ ] Non esistono espressioni JavaScript-like nel mapper (es. `{{1.items.filter(x => x.active)}}`)
- [ ] Le variabili referenceano campi che esistono nell'output del modulo referenziato
- [ ] I nomi dei campi nel mapper corrispondono esattamente (case-sensitive) ai campi output del modulo upstream

**Dizionario sintassi Make.com vs JavaScript:**

| JavaScript | Make.com | Note |
|---|---|---|
| `arr[0]` | `arr.1` | Make.com e 1-based |
| `arr.map(x => x.name)` | Non supportato | Usare Iterator |
| `obj?.prop` | `obj.prop` | No optional chaining |
| `${var}` | `{{var}}` | Template different |
| `JSON.parse(str)` | `{{parseJSON(str)}}` | Funzione nativa Make |
| `str.trim()` | `{{trim(str)}}` | Funzione nativa Make |
| `arr.length` | `{{length(arr)}}` | Funzione nativa Make |

**Bug tipici:**
- `{{21.choices[].message.content}}` — sintassi JavaScript array, Make.com vuole `{{21.choices.1.message.content}}`
- `{{1.data['url']}}` — notazione parentesi quadre non supportata, usare `{{1.data.url}}`
- `{{toUpperCase(1.nome).trim()}}` — chaining funzioni non supportato, usare modulo separato o `trim(upper(1.nome))`

---

#### CHECK 4: Autenticazione API e Credenziali

**Obiettivo:** Verificare che tutti i moduli che richiedono connessioni abbiano le credenziali configurate.

Verifiche per ogni modulo con `__IMTCONN__`:
- [ ] Il campo `__IMTCONN__` e presente e e un numero intero positivo
- [ ] Moduli della stessa piattaforma (es. due moduli Airtable) usano lo stesso `__IMTCONN__` (stessa connessione)
- [ ] Non esistono moduli che chiamano API esterne senza `__IMTCONN__`
- [ ] I moduli HTTP (Custom API Call) hanno authentication configurata (header, query, o OAuth)
- [ ] Non esistono API key hardcoded nel mapper o nei parametri
- [ ] Se un modulo usa `__IMTCONN__` ma la piattaforma richiede OAuth, l'utente e stato istruito a ricollegare l'account

**Bug tipici:**
- Modulo Airtable senza `__IMTCONN__` → Make.com chiede connessione ad ogni esecuzione
- Due moduli OpenAI con `__IMTCONN__` diversi ma stessa intenzione (connessione duplicata)
- API key hardcoded nel campo URL del modulo HTTP

---

#### CHECK 5: Error Handling e Resilienza

**Obiettivo:** Verificare che lo scenario gestisca correttamente gli errori e non produca falsi positivi.

Verifiche:
- [ ] Ogni modulo che chiama API esterne (Fliki, OpenAI, Google, ecc.) ha un meccanismo di retry o un modulo di fallback
- [ ] Il modulo finale che aggiorna lo stato ("Pronto", "Completato") e preceduto da un controllo che TUTTI i moduli upstream siano riusciti
- [ ] Se un branch parallelo fallisce, il modulo di riunione ha una logica di fallback
- [ ] Non esistono moduli "fire and forget" che aggiornano un database a "successo" senza verificare l'esito dei moduli precedenti
- [ ] I moduli con `errorHandler` hanno configurato `maxRetries` e `retryInterval`
- [ ] Il fallback path aggiorna lo stato a un valore diverso (es. "Errore", "Da Rivedere") e non lascia il record nello stato trigger

**Bug tipici:**
- Modulo "Aggiorna Status: Pronto" che viene eseguito anche se Fliki fallisce → falso positivo
- Nessun retry per chiamate API instabili → un timeout temporaneo perde il record
- Fallback assente → lo scenario si ferma e il record resta bloccato in "Da Fare" all'infinito

---

#### CHECK 6: Timeout e Rate Limiting

**Obiettivo:** Verificare che i moduli con operazioni lunghe abbiano timeout appropriati e che non si superino i limiti API.

Verifiche:
- [ ] Moduli di generazione video (Fliki, Runway, ecc.) hanno timeout configurato (minimo 300s, raccomandato 600s)
- [ ] Moduli OpenAI/LLM hanno timeout appropriato (60-120s per generazione testo, 300s per output lungo)
- [ ] Il `limit` del trigger (es. `limit: 10` in WatchRecords) non causa troppe esecuzioni parallele per le API downstream
- [ ] Se il trigger elabora N record in parallelo, N non supera i limiti di concorrenza dell'API piu lenta nello scenario
- [ ] Esiste un delay (Wait/Rate Limiter) tra chiamate API se lo scenario esegue piu chiamate allo stesso endpoint

**Bug tipici:**
- `limit: 10` su WatchRecords + generazione video → 10 video Fliki in parallelo → rate limiting garantito
- Modulo Fliki senza timeout → lo scenario resta "in esecuzione" per ore se Fliki e lento
- 5 chiamate OpenAI in parallelo senza delay → possibile 429 Too Many Requests

---

#### CHECK 7: Coerenza Dati Tra Moduli

**Obiettivo:** Verificare che i dati passati tra moduli siano coerenti con cio che il modulo successivo si aspetta.

Verifiche:
- [ ] I campi `base` e `table` nei moduli Airtable sono identici tra moduli che operano sulla stessa risorsa
- [ ] I nomi dei campi nel mapper (es. `Youtube title`, `Status`) corrispondono esattamente ai nomi delle colonne nel database/table
- [ ] I `recordId` puntano a record esistenti (restituiti da un modulo upstream, non hardcoded)
- [ ] Le formule di filtro (Airtable) sono sintatticamente corrette e logicamente valide
- [ ] I moduli che leggono e scrivono dalla stessa risorsa usano lo stesso `__IMTCONN__`
- [ ] Il viewId (se presente) corrisponde alla stessa base/table

**Bug tipici:**
- Modulo Read usa `base: "ID_A"` e modulo Update usa `base: "ID_B"` → scrive sulla base sbagliata
- Campo `"Youtube title"` nel mapper ma la colonna Airtable si chiama `"YouTube Title"` (maiuscola Y) → campo ignorato
- Formula `"{Status} = 'Da Fare'"` ma il campo Status contiene valori con spazi extra → nessun record matchato

---

#### CHECK 8: Validazione Input e Filtri

**Obiettivo:** Verificare che lo scenario non processi dati vuoti, invalidi o incompleti.

Verifiche:
- [ ] Esiste un filtro o controllo prima dei moduli che consumano API a pagamento (OpenAI, Fliki, ecc.)
- [ ] I campi obbligatori (script, contenuto, URL) sono verificati come non vuoti prima di essere passati ai moduli di elaborazione
- [ ] Non esistono moduli che chiamano API con input potenzialmente vuoto (es. `{{1.Script}}` dove Script potrebbe essere "")
- [ ] Se un campo e opzionale, il modulo downstream gestisce correttamente il caso vuoto/null
- [ ] I campi numerici sono verificati come tali prima di operazioni matematiche

**Bug tipici:**
- Script vuoto inviato a Fliki → video vuoto, credito Fliki sprecato
- Prompt vuoto inviato a OpenAI → errore API o output inaspettato
- URL immagine vuoto passato a un modulo di elaborazione immagini → crash

---

#### CHECK 9: Logica di Business e Completeness

**Obiettivo:** Verificare che lo scenario completi il suo ciclo di business senza gap logici.

Verifiche:
- [ ] Ogni record trigger ("Da Fare") viene processato fino a uno stato terminale ("Pronto", "Errore", ecc.)
- [ ] Non esistono "dead end" — moduli finali che non aggiornano lo stato del record trigger
- [ ] Se lo scenario genera contenuti (video, testo, immagini), il risultato viene salvato o linkato da qualche parte
- [ ] Lo scenario non puo girare all'infinito sullo stesso record (es. manca l'aggiornamento Status → il trigger lo riprende)
- [ ] Tutti gli output generati (titolo, descrizione, video URL) vengono salvati nel database di riferimento
- [ ] Se esistono moduli opzionali (es. "se il video supera i 60s, anche taglia"), hanno entrambe le branch (si/no)

**Bug tipici:**
- Scenario genera video ma non salva l'URL del video nel database → video generato ma non tracciabile
- Modulo di aggiornamento Status mancante → il trigger WatchRecords riprende lo stesso record all'infinito
- URL del video Fliki generato ma non passato al modulo di aggiornamento Airtable

---

#### CHECK 10: Performance e Ottimizzazione

**Obiettivo:** Verificare che lo scenario sia efficiente e non sprechi operazioni.

Verifiche:
- [ ] I moduli OpenAI usano il modello piu economico appropriato per il task (gpt-4o-mini per task semplici, gpt-4o per task complessi)
- [ ] Non esistono duplicati di moduli identici che potrebbero essere unificati
- [ ] I moduli che non cambiano tra un'esecuzione e l'altra (es. prompt fissi) non fanno chiamate API inutili
- [ ] Le branch parallele sono effettivamente indipendenti (nessuna dipendenza implicita)
- [ ] Il numero di operazioni per record e ragionevole (non 20 moduli per un task che ne richiederebbe 5)
- [ ] Se lo scenario usa iteratori, il batch size e appropriato

**Bug tipici:**
- Uso di GPT-4o per generare 2 righe di testo quando GPT-4o-mini basterebbe (costo 10x)
- Due moduli OpenAI identici (stesso prompt, stesso input) che potrebbero essere combinati in uno con output multi-field
- Iterator con batch size troppo grande che causa timeout

---

### Phase 3: Classificazione e Report

**Step 3.1 — Classificazione Severita**

Ogni problema trovato viene classificato:

| Severita | Criterio | Impatto |
|---|---|---|
| **CRITICO** | Blocca completamente l'importazione o l'esecuzione dello scenario | Lo scenario non puo essere importato o non parte |
| **ALTO** | Causa malfunzionamento significativo | Lo scenario funziona parzialmente o produce output errati/dannosi |
| **MEDIO** | Configurazione subottimale | Lo scenario funziona ma con problemi in produzione |
| **BASSO** | Ottimizzazione o best practice | Lo scenario funziona ma potrebbe essere migliorato |

**Step 3.2 — Giudizio Finale**

```
VALIDATO          = 0 bug CRITICI, 0 bug ALTI, qualsiasi numero di MEDI/BASSI
VALIDATO CON RISERVE = 0 bug CRITICI, 1-2 bug ALTI, qualsiasi MEDI/BASSI
NON VALIDATO      = 1+ bug CRITICI, indipendentemente dagli altri
```

**Step 3.3 — Report di Validazione**

Generare un report PDF con la seguente struttura:

```
1. Executive Summary
   - Nome scenario, moduli totali, branch, bug trovati
   - Giudizio complessivo (VALIDATO / VALIDATO CON RISERVE / NON VALIDATO)

2. Struttura dello Scenario
   - Classificazione (trigger, AI chain, integration)
   - Mappa dei branch indipendenti
   - Diagramma del flusso (testuale)

3. Riepilogo Problemi (tabella)
   - ID, Severita, Modulo, Descrizione, Fix Applicato

4. Dettaglio Bug Critici
   - Per ogni BUG CRITICO: modulo, descrizione, impatto, soluzione
   - Include snippet problematico e snippet corretto

5. Dettaglio Bug Alti
   - Stessa struttura dei critici

6. Dettaglio Bug Medi/Bassi
   - Descrizione concisa + soluzione

7. Verifiche Positive
   - Tabella dei componenti verificati e funzionanti

8. Configurazione Richiesta
   - Tabella delle connessioni da ricollegare in Make.com

9. Piano di Correzione
   - Lista ordinata per priorita con azione specifica
```

---

### Phase 4: Correzione Automatica

**Step 4.1 — Correzioni Applicabili**

| Tipo Bug | Correzione Auto | Esempio |
|---|---|---|
| `module` → `moduleId` | SI | `airtable:WatchRecords` nel campo corretto |
| Sintassi `{{N.campo[].sub}}` | SI | → `{{N.campo.1.sub}}` |
| Timeout mancante | SI | Aggiungere `timeout: 600` a moduli Fliki |
| `limit` eccessivo | SI | Ridurre da 10 a 3 per API rate-limited |
| Fallback mancante | PARZIALE | Aggiungere modulo fallback ma richiede definizione campi |
| Connessione orfana | PARZIALE | Sugerire collegamento ma la logica potrebbe essere intenzionale |
| Prompt incompleto | NO | Richiede input umano |
| Credenziali mancanti | NO | L'utente deve ricollegare l'account in Make.com |

**Step 4.2 — Output Finale**

Consegnare all'utente:
1. **Scenario JSON corretto** (con suffisso `[VALIDATED v2.0]`)
2. **Report PDF di validazione**
3. **Riepilogo testuale** (breve, in chat)

---

### Phase 5: Persistenza su GitHub

**Step 5.1 — Salvataggio Scenario**

```
Repo: YOUR_USERNAME/youtube-ai-dream-team
Path: templates/make_[nome_scenario]_v1.0_original.json    <- Backup originale
Path: templates/make_[nome_scenario]_v2.0_validated.json    <- Corretto
```

**Step 5.2 — Salvataggio Report**

```
Repo: YOUR_USERNAME/youtube-ai-dream-team
Path: templates/make_[nome_scenario]_validation_report.pdf
```

**Step 5.3 — Commit e Push**

```bash
git add templates/make_*.json templates/make_*_validation_report.pdf
git commit -m "validate: [nome scenario] vX.X - X bug trovati, Y corretti"
git push origin main
```

---

## Catalogo Bug Conosciuti (Knowledge Base Make.com)

### Pattern M-01: Campo `module` invece di `moduleId`
```json
// BUG: Make.com non riconosce il modulo
{ "id": 1, "module": "airtable:WatchRecords", ... }
// FIX: Usare moduleId
{ "id": 1, "moduleId": "airtable:watchRecords", ... }
```

### Pattern M-02: Sintassi Array JavaScript nel Mapper
```json
// BUG: Notazione JavaScript [] non supportata da Make.com
"Youtube title": "{{21.choices[].message.content}}"
// FIX: Usare indicizzazione 1-based di Make.com
"Youtube title": "{{21.choices.1.message.content}}"
```

### Pattern M-03: Falso Positivo Airtable (senza Error Handling)
```
// BUG: Modulo 23 aggiorna Status="Pronto" anche se Fliki/OpenAI falliscono
Trigger → [Fliki, OpenAI Titolo, OpenAI Desc] → Aggiorna "Pronto"
// FIX: Aggiungere fallback per ogni branch API
Trigger → [Fliki (retry→fallback Errore Fliki), OpenAI (retry→fallback Errore AI)] → Aggiorna "Pronto"
```

### Pattern M-04: Rate Limiting da limit eccessivo nel Trigger
```json
// BUG: 10 record in parallelo → 10 chiamate API simultanee
{ "limit": 10 }
// FIX: Ridurre a 3-5 per API con limiti stretti
{ "limit": 3 }
```

### Pattern M-05: Timeout Mancante per Moduli Lenti
```json
// BUG: Generazione video senza timeout → scenario bloccato
{ "moduleId": "fliki:createVideo", "parameters": { "__IMTCONN__": 123 } }
// FIX: Aggiungere timeout appropriato
{ "moduleId": "fliki:createVideo", "parameters": { "__IMTCONN__": 123, "timeout": 600 } }
```

### Pattern M-06: Loop Infinito per Mancato Aggiornamento Status
```
// BUG: WatchRecords trigger su Status="Da Fare" ma nessun modulo aggiorna Status
→ Lo scenario riprende lo stesso record all'infinito
// FIX: Aggiungere modulo UpdateRecord che imposta Status a "Pronto" o "In Corso"
```

### Pattern M-07: Input Vuoto a API a Pagamento
```json
// BUG: Script vuoto passato a Fliki → credito sprecato
"content": "{{1.Script}}"  // Script potrebbe essere ""
// FIX: Aggiungere filtro prima del modulo Fliki
{ "moduleId": "builtin:Filter", "mapper": { "conditions": [{ "key": "{{1.Script}}", "operator": "notEmpty" }] } }
```

### Pattern M-08: Nomi Colonne Case-Sensitive nel Mapper
```json
// BUG: Colonna Airtable "YouTube Title" ma mapper usa "Youtube title"
"Youtube title": "{{21.choices.1.message.content}}"
// FIX: Usare esattamente il nome della colonna (case-sensitive)
"YouTube Title": "{{21.choices.1.message.content}}"
```

### Pattern M-09: Branch Parallelo senza Sincronizzazione
```
// BUG: Mod 23 riceve da 21+22 ma non aspetta Mod 20
[1] → [20 Fliki]     ← nessun collegamento a 23
[1] → [21 Titolo] ──→ [23 Aggiorna]
[1] → [22 Desc]   ──→ [23 Aggiorna]
// FIX: Ristrutturare il flusso perche 23 riceva da 20, 21, e 22
```

### Pattern M-10: Formato JSON Non Standard per Importazione
```
// BUG: JSON con struttura personalizzata non compatibile con Make.com Import Blueprint
{ "name": "...", "flow": [...], "custom_field": "..." }
// FIX: Ristrutturare secondo lo schema Make.com blueprint standard
{ "name": "...", "blueprintType": "scenario", "flow": [...], "metadata": {...} }
```

---

## Differenze Chiave: Make.com vs n8n (Agent 32)

Questa tabella aiuta a distinguere le problematiche specifiche delle due piattaforme:

| Aspetto | Make.com (Agent 33) | n8n (Agent 32) |
|---|---|---|
| Formato modulo | `moduleId: "provider:azione"` | `type: "n8n-nodes-base.xxx"` |
| Variabili | `{{N.campo}}` (1-based) | `{{ $json.campo }}` o `$('Nome').item.json.campo` |
| Array access | `arr.1` (1-based) | `arr[0]` (0-based) |
| Error handling | Moduli fallback + Error Handler | Continue On Fail + try/catch nei Code |
| Connessioni | `__IMTCONN__` (ID numerico) | `credentials` (ID stringa) |
| Retry | Configurabile nel modulo | Implementato con loop Wait+Switch |
| Branching | Router module | Switch/If nodes |
| Timeout | Parametro del modulo | Impostazione globale o per-nodo |
| Prompt LLM | Nel mapper `messages` array | Nei parametri del nodo Agent/Chain |
| Format blueprint | JSON con `flow` array | JSON con `nodes` + `connections` |

---

## Integrazione con gli Altri Agenti

| Scenario | Interazione |
|---|---|
| Un agente genera uno scenario Make.com | L'agente invoca automaticamente Agent 33 per validazione prima della consegna |
| L'utente fornisce uno scenario | Agent 33 riceve il JSON ed esegue la validazione completa |
| Modifica di uno scenario esistente | Agent 33 esegue validazione incrementale (solo sulle modifiche) |
| Bug ricorrente trovato | Agent 33 aggiorna il Catalogo Bug Conosciuti |
| Workflow n8n fornito | Redirige ad Agent 32 (non overlapping di competenze) |
| Confronto piatt. | Collabora con Agent 32 per knowledge sharing cross-piattaforma |

---

## Output Format Reference

### Scenario JSON Naming Convention
```
make_[nome_descrittivo]_v1.0_original.json      <- Scenario originale
make_[nome_descrittivo]_v2.0_validated.json      <- Scenario validato (con fix)
make_[nome_descrittivo]_validation_report.pdf     <- Report validazione
```

### Moduli Aggiunti dal Validator (Convenzione)
Quando il validator aggiunge moduli di fallback o filtro, usa ID fuori dal range originale:
- Moduli fallback: ID 90-99 (es. Mod 91 = "Fallback Errore API 1")
- Moduli filtro: ID 50-59 (es. Mod 50 = "Filtra Input Valido")

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | May 2026 | Initial release — 10-category checklist, auto-correction, PDF report, GitHub persistence, knowledge base of 10 known bug patterns (M-01 to M-10), Make.com vs n8n comparison table |

---

*Agent 33 SOP created by Super Z AI — May 2026.*
*Based on the validation methodology developed for the Fliki & YouTube Make.com scenario audit.*
*Complementary to Agent 32 (n8n Validator) — together they cover all major automation platforms.*
*This agent ensures zero unvalidated Make.com scenarios reach production.*
