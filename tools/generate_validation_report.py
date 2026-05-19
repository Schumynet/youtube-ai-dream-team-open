import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'skills', 'pdf', 'scripts'))
from pdf import install_font_fallback

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch, mm
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.pdfmetrics import registerFontFamily

# ─── Fonts ───
pdfmetrics.registerFont(TTFont('WenKai', '/usr/share/fonts/truetype/lxgw-wenkai/LXGWWenKai-Regular.ttf'))
pdfmetrics.registerFont(TTFont('Carlito', '/usr/share/fonts/truetype/english/Carlito-Regular.ttf'))
pdfmetrics.registerFont(TTFont('Carlito-Bold', '/usr/share/fonts/truetype/english/Carlito-Bold.ttf'))
pdfmetrics.registerFont(TTFont('DejaVuSans', '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'))
pdfmetrics.registerFont(TTFont('DejaVuSansMono', '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'))
registerFontFamily('Carlito', normal='Carlito', bold='Carlito-Bold')
registerFontFamily('DejaVuSans', normal='DejaVuSans', bold='DejaVuSans')
install_font_fallback()

# ─── Palette ───
ACCENT = colors.HexColor('#5127cf')
TEXT_PRIMARY = colors.HexColor('#21201e')
TEXT_MUTED = colors.HexColor('#8f8b83')
BG_SURFACE = colors.HexColor('#e8e5e0')
BG_PAGE = colors.HexColor('#f0efed')
RED_CRIT = colors.HexColor('#c0392b')
ORANGE_HIGH = colors.HexColor('#d35400')
YELLOW_MED = colors.HexColor('#b7950b')
GREEN_OK = colors.HexColor('#27ae60')

# ─── Styles ───
body = ParagraphStyle('Body', fontName='Carlito', fontSize=10.5, leading=17, alignment=TA_JUSTIFY, spaceAfter=6)
body_left = ParagraphStyle('BodyLeft', fontName='Carlito', fontSize=10.5, leading=17, alignment=TA_LEFT, spaceAfter=6)
h1 = ParagraphStyle('H1', fontName='Carlito', fontSize=20, leading=26, textColor=TEXT_PRIMARY, spaceBefore=18, spaceAfter=10)
h2 = ParagraphStyle('H2', fontName='Carlito', fontSize=15, leading=21, textColor=ACCENT, spaceBefore=14, spaceAfter=8)
h3 = ParagraphStyle('H3', fontName='Carlito', fontSize=12, leading=17, textColor=TEXT_PRIMARY, spaceBefore=10, spaceAfter=6)
code_style = ParagraphStyle('Code', fontName='DejaVuSansMono', fontSize=8.5, leading=13, backColor=colors.HexColor('#f5f3f0'), leftIndent=12, rightIndent=12, spaceBefore=4, spaceAfter=4)
header_cell = ParagraphStyle('HeaderCell', fontName='Carlito', fontSize=10, textColor=colors.white, alignment=TA_CENTER)
cell = ParagraphStyle('Cell', fontName='Carlito', fontSize=9.5, leading=14, alignment=TA_LEFT)
cell_center = ParagraphStyle('CellCenter', fontName='Carlito', fontSize=9.5, leading=14, alignment=TA_CENTER)
cell_bold = ParagraphStyle('CellBold', fontName='Carlito', fontSize=9.5, leading=14, alignment=TA_LEFT, textColor=TEXT_PRIMARY)
caption_style = ParagraphStyle('Caption', fontName='Carlito', fontSize=9, leading=13, textColor=TEXT_MUTED, alignment=TA_CENTER, spaceBefore=3, spaceAfter=6)

severity_styles = {
    'CRITICO': ParagraphStyle('Critico', fontName='Carlito', fontSize=9.5, leading=14, textColor=colors.white, alignment=TA_CENTER),
    'ALTO': ParagraphStyle('Alto', fontName='Carlito', fontSize=9.5, leading=14, textColor=colors.white, alignment=TA_CENTER),
    'MEDIO': ParagraphStyle('Medio', fontName='Carlito', fontSize=9.5, leading=14, textColor=colors.white, alignment=TA_CENTER),
    'OK': ParagraphStyle('OK', fontName='Carlito', fontSize=9.5, leading=14, textColor=colors.white, alignment=TA_CENTER),
}

# ─── Document ───
output_path = './'
doc = SimpleDocTemplate(output_path, pagesize=A4,
    leftMargin=1.0*inch, rightMargin=1.0*inch,
    topMargin=1.0*inch, bottomMargin=1.0*inch)

story = []

# ═══════════════════════════════════════════════════
# COVER (rendered separately via Playwright)
# We skip the cover for a technical validation report.
# Start directly with content.
# ═══════════════════════════════════════════════════

# ─── TITLE ───
story.append(Spacer(1, 30))
story.append(Paragraph('<b>Report di Validazione</b>', h1))
story.append(Paragraph('<b>Workflow n8n VIP16</b>', ParagraphStyle('SubH1', fontName='Carlito', fontSize=16, leading=22, textColor=ACCENT, spaceAfter=6)))
story.append(Paragraph('A 16 VIP - Video ASMR - Stile Ghibli (Ottimizzato)', body_left))
story.append(Spacer(1, 8))
story.append(HRFlowable(width='100%', thickness=1, color=ACCENT, spaceAfter=12))

story.append(Paragraph('<b>Data:</b> 19 Maggio 2026', body_left))
story.append(Paragraph('<b>Nodo analizzati:</b> 29', body_left))
story.append(Paragraph('<b>Cicli indipendenti:</b> 2', body_left))
story.append(Paragraph('<b>Problemi trovati:</b> 8 (3 critici, 3 alti, 2 medi)', body_left))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 1. EXECUTIVE SUMMARY
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>1. Executive Summary</b>', h1))
story.append(Paragraph(
    'Il workflow n8n "A 16 VIP - Video ASMR - Stile Ghibli (Ottimizzato)" e stato sottoposto a una validazione completa di tutti i 29 nodi, '
    'le connessioni, la logica di flusso, la gestione degli errori e l\'autenticazione API. Il workflow e composto da due cicli indipendenti: '
    'il Ciclo 1 (CREA IDEA) che genera nuove idee video tramite GPT-4.1 e le salva su Google Sheets, e il Ciclo 2 (INIZIA PROCESSO) che '
    'legge le idee, genera lo storyboard ASMR Ghibli di 41 scene, produce i video tramite Kie.ai (grok-imagine/text-to-video), li unisce '
    'tramite Fal.ai (ffmpeg-api/merge-videos) e aggiorna lo stato su Google Sheets.',
    body))
story.append(Paragraph(
    'L\'analisi ha rilevato 8 problemi complessivi. Di questi, 3 sono classificati come <b>CRITICI</b> perche bloccano completamente '
    'l\'esecuzione del workflow, 3 come <b>ALTI</b> perche causano malfunzionamenti parziali ma significativi, e 2 come <b>MEDI</b> perche '
    'rappresentano configurazioni subottimali che potrebbero causare problemi in produzione. In particolare, il nodo "wait for all" contiene '
    'un errore di autenticazione che rende impossibile il polling dello stato dei task Kie.ai, e il nodo "nuove idee" ha un riferimento a un '
    'foglio Google Sheets appartenente a un documento diverso, impedendo la scrittura delle nuove idee generate.',
    body))
story.append(Paragraph(
    'Pur essendo presenti questi problemi significativi, l\'architettura generale del workflow e solida: la struttura a due cicli separati '
    'per generazione idee e produzione video e ben concepita, il meccanismo di batch processing con SplitInBatches per gestire le 41 scene e '
    'correttamente implementato, il sistema di polling con Switch per attendere il completamento dei task asincroni e logicamente corretto, '
    'e il prompt engineering per lo storyboard Ghibli ASMR e estremamente dettagliato e professionale. Con le correzioni suggerite in questo '
    'report, il workflow sara pienamente operativo.',
    body))
story.append(Spacer(1, 12))

# ═══════════════════════════════════════════════════
# 2. OVERVIEW DEI CICLI
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>2. Struttura del Workflow</b>', h1))

story.append(Paragraph('<b>2.1 Ciclo 1 - CREA IDEA (Generazione Idee)</b>', h2))
story.append(Paragraph(
    'Il primo ciclo si attiva ogni giorno alle ore 20:02 tramite il nodo Schedule Trigger "CREA IDEA". Il flusso inizia dal nodo "idea mia" '
    'che inizializza un campo custom_idea vuoto, prosegue con "lavori precedenti" che legge tutte le righe dal Google Sheet "studio ghibli" per '
    'recuperare il contesto storico. I titoli dei lavori precedenti vengono aggregati tramite "Aggregate1" e passati al nodo "idea generator", '
    'un agente LangChain basato su GPT-4.1 con un parser di output strutturato. L\'agente genera una nuova idea video completa di Titolo, '
    'Caption, Thumbnail_Prompt, GLOBAL_INSTRUCTIONS (incluso CHARACTER DNA), che viene poi salvata su Google Sheets tramite il nodo "nuove idee" '
    'con stato "for production". Questo ciclo alimenta il ciclo di produzione con nuove idee da elaborare.',
    body))

story.append(Paragraph('<b>2.2 Ciclo 2 - INIZIA PROCESSO (Pipeline di Produzione)</b>', h2))
story.append(Paragraph(
    'Il secondo ciclo si attiva ogni 2 ore tramite il nodo Schedule Trigger "INIZIA PROCESSO". Legge dal Google Sheet la prima riga con stato '
    '"for production", poi passa al nodo "ASMR GHIBLI" (agente LangChain + GPT-4.1) che genera lo storyboard completo di 41 scene con prompt '
    'tecnici per la generazione video. Il nodo "split_out" estrae l\'array delle scene, che passano attraverso "DNA placeholders" per la '
    'sostituzione dei placeholder di personaggio, poi "order_id" assegna un indice progressivo. Il nodo "Loop Over Items1" (SplitInBatches, '
    'batch=50) gestisce il ciclo di generazione video: invia le scene a Kie.ai, esegue il polling dello stato tramite "wait for all" + Switch3, '
    'e quando tutti i video sono pronti li passa a "prepara per merge" che ordina gli URL per order_id. Il nodo "crea video" chiama Fal.ai '
    'per unire i video, con polling tramite Wait + Get status3 + If1. Infine "GET videos" recupera l\'URL finale e "URL NOSTRO" aggiorna il '
    'Google Sheet con stato "done" e l\'URL del video completato.',
    body))
story.append(Spacer(1, 12))

# ═══════════════════════════════════════════════════
# 3. TABELLA RIASSUNTIVA BUG
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>3. Riepilogo Problemi Riscontrati</b>', h1))

bugs_data = [
    [Paragraph('<b>ID</b>', header_cell), Paragraph('<b>Severita</b>', header_cell),
     Paragraph('<b>Nodo</b>', header_cell), Paragraph('<b>Descrizione</b>', header_cell)],
    [Paragraph('BUG-01', cell_center), Paragraph('CRITICO', severity_styles['CRITICO']),
     Paragraph('wait for all', cell_bold), Paragraph('Autenticazione Kie.ai mancante - this.getWorkflowStaticData restituisce undefined', cell)],
    [Paragraph('BUG-02', cell_center), Paragraph('CRITICO', severity_styles['CRITICO']),
     Paragraph('nuove idee', cell_bold), Paragraph('sheetName URL punta a un foglio Google diverso dal documentId', cell)],
    [Paragraph('BUG-03', cell_center), Paragraph('CRITICO', severity_styles['CRITICO']),
     Paragraph('idea generator', cell_bold), Paragraph('Prompt troncato - le istruzioni del compito sono incomplete', cell)],
    [Paragraph('BUG-04', cell_center), Paragraph('ALTO', severity_styles['ALTO']),
     Paragraph('DNA placeholders', cell_bold), Paragraph('Nomi DNA incoerenti (Suspect/Officer/Witness) per contesto ASMR Ghibli', cell)],
    [Paragraph('BUG-05', cell_center), Paragraph('ALTO', severity_styles['ALTO']),
     Paragraph('wait for all', cell_bold), Paragraph('Nessun meccanismo di retry per task Kie.ai falliti - video_url rimane null', cell)],
    [Paragraph('BUG-06', cell_center), Paragraph('ALTO', severity_styles['ALTO']),
     Paragraph('Wait / Wait3', cell_bold), Paragraph('Nessuna durata di attesa configurata - polling loop senza delay', cell)],
    [Paragraph('BUG-07', cell_center), Paragraph('MEDIO', severity_styles['MEDIO']),
     Paragraph('wait for all', cell_bold), Paragraph('Variabile authHeader calcolata ma mai utilizzata nel codice', cell)],
    [Paragraph('BUG-08', cell_center), Paragraph('MEDIO', severity_styles['MEDIO']),
     Paragraph('Loop Over Items1', cell_bold), Paragraph('Batch size 50 eccessivo per 41 scene - overhead non necessario', cell)],
]

avail_w = A4[0] - 2*inch
col_widths = [0.08*avail_w, 0.12*avail_w, 0.18*avail_w, 0.62*avail_w]
t = Table(bugs_data, colWidths=col_widths, hAlign='CENTER')
sev_colors = {'CRITICO': RED_CRIT, 'ALTO': ORANGE_HIGH, 'MEDIO': YELLOW_MED}
style_cmds = [
    ('BACKGROUND', (0, 0), (-1, 0), ACCENT),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
    ('GRID', (0, 0), (-1, -1), 0.5, TEXT_MUTED),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ('TOPPADDING', (0, 0), (-1, -1), 5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
]
for i in range(1, len(bugs_data)):
    bg = colors.white if i % 2 == 1 else BG_SURFACE
    style_cmds.append(('BACKGROUND', (0, i), (-1, i), bg))
    # Color the severity cell
    desc_map = {1: 'CRITICO', 2: 'CRITICO', 3: 'CRITICO', 4: 'ALTO', 5: 'ALTO', 6: 'ALTO', 7: 'MEDIO', 8: 'MEDIO'}
    if i in desc_map:
        style_cmds.append(('BACKGROUND', (1, i), (1, i), sev_colors[desc_map[i]]))
t.setStyle(TableStyle(style_cmds))
story.append(t)
story.append(Paragraph('<b>Tabella 1.</b> Riepilogo completo dei 8 problemi identificati nella validazione', caption_style))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 4. DETTAGLIO BUG CRITICI
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>4. Dettaglio Bug Critici</b>', h1))

# BUG-01
story.append(Paragraph('<b>4.1 BUG-01: Autenticazione Kie.ai Mancante nel nodo "wait for all"</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> wait for all (Code node)', h3))
story.append(Paragraph(
    'Il nodo "wait for all" esegue il polling dello stato dei task Kie.ai per verificare se i video sono stati generati. '
    'Per effettuare le chiamate API GET a "https://api.kie.ai/api/v1/jobs/recordInfo", il codice utilizza la seguente riga per '
    'recuperare l\'header di autorizzazione:',
    body))
story.append(Paragraph(
    'this.getWorkflowStaticData(\'global\').kie_auth || \'\'', code_style))
story.append(Paragraph(
    'Il problema fondamentale e che il valore "kie_auth" non viene mai impostato in nessun punto del workflow. Il metodo '
    'getWorkflowStaticData(\'global\') restituisce un oggetto vuoto perche nessun nodo esegue un\'operazione di scrittura su di esso. '
    'Di conseguenza, l\'espressione restituisce sempre una stringa vuota, e tutte le chiamate API di polling a Kie.ai verranno '
    'effettuate senza header Authorization, causando un errore 401 Unauthorized per ogni task.',
    body))
story.append(Paragraph(
    'Inoltre, c\'e un secondo tentativo di recupero autenticazione nella riga precedente del codice che tenta di leggere '
    'il parametro headerParametersJson dal nodo "Generate video". Questo approccio non funziona per due motivi: il valore '
    'headerParametersJson e impostato a "{}" (stringa JSON vuota), e l\'autenticazione HTTP in n8n viene gestita tramite il '
    'sistema di credenziali (genericCredentialType), non tramite parametri JSON leggibili a runtime. Non esiste alcun modo '
    'per estrarre il valore della credenziale Header Auth configurata nel nodo "Generate video" dal codice di un altro nodo.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Utilizzare this.helpers.httpRequestWithAuthentication o configurare una credenziale '
    'Header Auth dedicata nel nodo "wait for all" e referenziarla tramite this.getCredentials(\'httpHeaderAuth\'). In alternativa, '
    'memorizzare la chiave API Kie.ai in una variabile d\'ambiente o in this.getWorkflowStaticData(\'global\').kie_auth impostandola '
    'in un nodo precedente (ad esempio nel nodo "Generate video" subito dopo la prima chiamata API riuscita).', body))
story.append(Spacer(1, 12))

# BUG-02
story.append(Paragraph('<b>4.2 BUG-02: Riferimento a Foglio Google Errato nel nodo "nuove idee"</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> nuove idee (Google Sheets node)', h3))
story.append(Paragraph(
    'Il nodo "nuove idee" e responsabile della scrittura delle nuove idee video generate dal ciclo 1 sul Google Sheet "studio ghibli". '
    'L\'analisi della configurazione rivela una discrepanza critica tra il documentId e il sheetName. Il documentId punta correttamente '
    'al foglio "studio ghibli" con ID "1tuxeK9o-SzgCUWEAaM0VfRyr0Hrz6iOrGgVd8lmqOtI", ma il campo sheetName contiene un URL cachedResultUrl '
    'che riferimento a un documento completamente diverso con ID "1eIkDfvFPLDWMy_3PmJKDmX3eZpKpjJWhObCZoSMCWVQ".',
    body))
story.append(Paragraph(
    'In n8n, il campo sheetName con "__rl": true e "mode": "list" utilizza il cachedResultUrl come riferimento interno per il Resource Locator. '
    'Quando il workflow viene importato su una nuova istanza n8n, il sistema tentera di risolvere il sheetName utilizzando questo URL, '
    'che punta a un documento diverso da quello specificato nel documentId. Questo mismatch causera un errore di scrittura quando il nodo '
    'tentera di aggiungere la nuova riga al foglio, con un messaggio di errore simile a "Sheet not found" o "Permission denied" a seconda '
    'della configurazione dei permessi.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Aggiornare il campo sheetName del nodo "nuove idee" per assicurare che il cachedResultUrl '
    'corrisponda allo stesso documentId. Il valore corretto dovrebbe essere '
    '"https://docs.google.com/spreadsheets/d/1tuxeK9o-SzgCUWEAaM0VfRyr0Hrz6iOrGgVd8lmqOtI/edit#gid=0" con cachedResultName "Foglio1", '
    'coerente con tutti gli altri nodi Google Sheets del workflow.', body))
story.append(Spacer(1, 12))

# BUG-03
story.append(Paragraph('<b>4.3 BUG-03: Prompt Troncato nel nodo "idea generator"</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> idea generator (AI Agent node)', h3))
story.append(Paragraph(
    'Il nodo "idea generator" contiene il prompt principale che istruisce GPT-4.1 su come generare nuove idee video ASMR Ghibli. '
    'L\'analisi rivela che il campo "text" del prompt e troncato a meta di una frase, terminando con le parole '
    '"1. **OVERRIDE CHECK:** If USER OVERRIDE is not empty..." senza nessuna istruzione successiva. Questo suggerisce che il prompt '
    'originale e stato perso durante il processo di copia-incolla o esportazione del workflow.',
    body))
story.append(Paragraph(
    'Senza le istruzioni complete, l\'agente GPT-4.1 non potra generare idee video coerenti con il formato richiesto. Le istruzioni '
    'mancanti dovrebbero includere: le regole di override quando custom_idea non e vuoto (probabilmente per usare l\'idea personalizzata '
    'invece di generarne una nuova), i criteri di varieta rispetto ai lavori precedenti (evitare ripetizioni), le specifiche del formato '
    'di output (Title, Caption, Thumbnail_Prompt, GLOBAL_INSTRUCTIONS con CHARACTER DNA), e le regole per la creazione dei personaggi '
    'coerenti con lo stile ASMR Ghibli. Senza queste istruzioni, l\'output dell\'agente sara imprevedibile e probabilmente non rispettera '
    'il formato atteso dal resto del workflow.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Ripristinare il prompt completo del nodo "idea generator". Il prompt dovrebbe includere '
    'tutte le istruzioni per l\'override check, la varieta creativa, il formato di output strutturato, e le regole per il CHARACTER DNA. '
    'Riferirsi al nodo "ASMR GHIBLI" come esempio di prompt ben strutturato presente nello stesso workflow.', body))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 5. DETTAGLIO BUG ALTI
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>5. Dettaglio Bug di Severita Alta</b>', h1))

# BUG-04
story.append(Paragraph('<b>5.1 BUG-04: Nomi DNA Placeholder Incoerenti</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> DNA placeholders (Code node)', h3))
story.append(Paragraph(
    'Il nodo "DNA placeholders" effettua la sostituzione dei placeholder nei prompt dello storyboard con le descrizioni complete dei '
    'personaggi. Il codice definisce una mappa dnaMap con tre chiavi: "__SUSPECT_DNA__", "__OFFICER_DNA__" e "__WITNESS_DNA__". '
    'Questi nomi fanno riferimento a un contesto di genere poliziesco/detective (sospettato, ufficiale, testimone), che e chiaramente '
    'incoerente con il contesto ASMR Ghibli del workflow.',
    body))
story.append(Paragraph(
    'Il nodo tenta di leggere i valori corrispondenti dalla riga del Google Sheet recuperata dal nodo "Idea", cercando colonne chiamate '
    '"Suspect_DNA", "Officer_DNA" e "Witness_DNA". Se il Google Sheet non contiene queste colonne esatte, i valori saranno undefined, '
    'e nessuna sostituzione verra effettuata. Inoltre, la funzione extractName rimuove prefissi come "Primary Officer", "Secondary Officer", '
    '"Subject S1", "Witness" ecc., confermando che il codice e stato adattato da un workflow poliziesco senza aggiornare completamente '
    'i nomi dei placeholder. Per un contesto ASMR Ghibli, i nomi dovrebbero riferirsi a personaggi come Main_Character_DNA, Friend_DNA, '
    'o corrispondere ai nomi definiti nel campo GLOBAL_INSTRUCTIONS del Google Sheet.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Aggiornare la dnaMap nel nodo "DNA placeholders" per utilizzare nomi coerenti con il '
    'contesto ASMR Ghibli. Verificare i nomi delle colonne nel Google Sheet e assicurarsi che corrispondano. In alternativa, leggere i nomi '
    'dei personaggi dinamicamente dal campo GLOBAL_INSTRUCTIONS della riga selezionata, estrarre i DNA definiti nel CHARACTER LIST, e costruire '
    'la mappa dei placeholder in modo dinamico anziche hardcoded.', body))
story.append(Spacer(1, 12))

# BUG-05
story.append(Paragraph('<b>5.2 BUG-05: Assenza di Retry per Task Kie.ai Falliti</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> wait for all (Code node)', h3))
story.append(Paragraph(
    'Il nodo "wait for all" implementa il polling dello stato dei task Kie.ai. Quando uno stato viene rilevato come "fail", il codice '
    'registra il messaggio di errore nella proprieta "it.error" e contrassegna il task come fallito, poi continua a iterare sugli altri '
    'task. Non esiste alcun meccanismo di retry per i task falliti: un task che fallisce rimane nello stato "fail" permanentemente e il suo '
    'campo video_url rimane null.',
    body))
story.append(Paragraph(
    'Il flag allDone viene impostato a true solo quando tutti i task hanno raggiunto lo stato "success" o "fail", il che significa che il '
    'workflow prosegue anche se alcuni video non sono stati generati. Il nodo successivo "prepara per merge" filtra gli elementi che hanno '
    'un video_url valido, quindi i task falliti vengono semplicemente esclusi dal video finale. Questo comporta che il video unito avra meno '
    'di 41 scene, potenzialmente creando salti narrativi o una durata inferiore a quella prevista. Inoltre, il nodo "crea video" di Fal.ai '
    'potrebbe fallire se riceve un array di URL vuoto o con troppe scene mancanti.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Implementare un contatore di retry per ogni task (massimo 3 tentativi). Se un task fallisce, '
    're-inviare la richiesta a Kie.ai per la rigenerazione. Se dopo 3 tentativi il task fallisce ancora, opzionalmente utilizzare un prompt '
    'semplificato come fallback. Aggiungere anche un controllo sul numero minimo di scene richieste per procedere con il merge (es. almeno '
    '35 scene su 41).', body))
story.append(Spacer(1, 12))

# BUG-06
story.append(Paragraph('<b>5.3 BUG-06: Nodi Wait senza Durata Configurata</b>', h2))
story.append(Paragraph('<b>Nodi interessati:</b> Wait (id: ed13c0cc), Wait3 (id: b67cd03f)', h3))
story.append(Paragraph(
    'Entrambi i nodi Wait presenti nel workflow hanno il campo "options" impostato a un oggetto vuoto "{}", senza specificare alcuna durata '
    'di attesa. In n8n, il nodo Wait v1.1 con opzioni vuote ha un comportamento che varia a seconda della versione: in alcune versioni '
    'procede immediatamente senza alcuna attesa, in altre potrebbe generare un errore di configurazione.',
    body))
story.append(Paragraph(
    'Il nodo "Wait" viene utilizzato nel ciclo di polling dello stato Fal.ai (merge video), mentre il nodo "Wait3" viene utilizzato nel ciclo '
    'di polling dello stato Kie.ai (generazione video singoli). Senza una durata di attesa configurata, il polling loop potrebbe eseguire '
    'richieste API in rapida successione, causando potenzialmente il blocco per rate limiting da parte delle API di Kie.ai e Fal.ai. '
    'Considerando che la generazione di un singolo video tramite Kie.ai richiede tipicamente da 30 secondi a diversi minuti, e il merge '
    'tramite Fal.ai puo richiedere da 1 a 5 minuti, un intervallo di polling di 60-120 secondi sarebbe appropriato per evitare di '
    'sprecare risorse API e ridurre il rischio di blocco.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Configurare il nodo "Wait3" (Kie.ai polling) con un\'attesa di 60 secondi e il nodo '
    '"Wait" (Fal.ai polling) con un\'attesa di 120 secondi. In n8n Wait v1.1, questo si configura impostando options.amount e '
    'options.unit (es. "seconds").', body))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 6. DETTAGLIO BUG MEDI
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>6. Dettaglio Bug di Severita Media</b>', h1))

# BUG-07
story.append(Paragraph('<b>6.1 BUG-07: Variabile authHeader Non Utilizzata</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> wait for all (Code node)', h3))
story.append(Paragraph(
    'All\'interno del nodo "wait for all", la riga di codice che calcola authHeader tenta di estrarre il valore di autenticazione '
    'dal nodo "Generate video" tramite l\'espressione $("Generate video").item?.matchingExecution?.node?.parameters?.headerParametersJson. '
    'Questa variabile viene calcolata ma non viene mai utilizzata nel resto del codice: l\'autenticazione effettiva per le chiamate API '
    'utilizza invece this.getWorkflowStaticData(\'global\').kie_auth (che come descritto nel BUG-01 restituisce sempre una stringa vuota).',
    body))
story.append(Paragraph(
    'Questo rappresenta codice morto che potrebbe confondere chiunque tenti di fare debugging del workflow. La variabile authHeader non puo '
    'comunque funzionare perche i parametri HTTP in n8n non espongono il valore reale delle credenziali configurate. La rimozione di questa '
    'riga migliorerebbe la leggibilita del codice senza alcun impatto funzionale.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Rimuovere la riga authHeader e sostituire l\'intero meccanismo di autenticazione con '
    'un approccio funzionante come descritto nella soluzione del BUG-01.', body))
story.append(Spacer(1, 12))

# BUG-08
story.append(Paragraph('<b>6.2 BUG-08: Batch Size Eccessivo per il Volume di Scene</b>', h2))
story.append(Paragraph('<b>Nodo interessato:</b> Loop Over Items1 (SplitInBatches node)', h3))
story.append(Paragraph(
    'Il nodo "Loop Over Items1" utilizza SplitInBatches con un batch size di 50 elementi. Considerando che il workflow genera esattamente '
    '41 scene (come specificato nel prompt del nodo "ASMR GHIBLI"), tutte le scene vengono elaborate in un unico batch. Questo significa '
    'che il meccanismo di batching non aggiunge alcun valore in termini di gestione della memoria o limitazione delle richieste simultanee.',
    body))
story.append(Paragraph(
    'Tuttavia, questo non e un bug bloccante perche il workflow funziona correttamente con un singolo batch. Il problema e che tutti i 41 '
    'task Kie.ai vengono inviati contemporaneamente senza alcun limitatore, il che potrebbe saturare i limiti di concorrenza dell\'API Kie.ai '
    'e causare il fallimento di alcune richieste. Un batch size piu piccolo (es. 10-15) consentirebbe di inviare i task in gruppi, '
    'riducendo la pressione sull\'API e facilitando il monitoraggio dei singoli batch. Inoltre, in caso di fallimento di un batch, '
    'sarebbe possibile ripetere solo quel gruppo specifico di scene anziche tutte 41.',
    body))
story.append(Paragraph('<b>Soluzione suggerita:</b> Ridurre il batch size a 10-15 elementi. Questo richiederebbe di rivedere il meccanismo '
    'di loop per gestire correttamente il passaggio dei dati tra i batch (ad esempio utilizzando workflowStaticData per accumulare i risultati '
    'di tutti i batch prima di procedere al merge).', body))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 7. VERIFICHE POSITIVE
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>7. Verifiche Positive (Cosa Funziona Correttamente)</b>', h1))

ok_data = [
    [Paragraph('<b>Componente</b>', header_cell), Paragraph('<b>Stato</b>', header_cell),
     Paragraph('<b>Note</b>', header_cell)],
    [Paragraph('Architettura a 2 cicli', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Separazione corretta tra generazione idee e produzione video', cell)],
    [Paragraph('SplitInBatches loop logic', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Loop-back tramite Unpack Batch funziona correttamente', cell)],
    [Paragraph('Switch3 polling pattern', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Pattern waiting/success per polling asincrono implementato bene', cell)],
    [Paragraph('ASMR GHIBLI prompt', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Prompt engineering eccellente: 41 scene, DNA protocol, audio rules', cell)],
    [Paragraph('Kie.ai API endpoint', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('URL e payload JSON corretti per text-to-video', cell)],
    [Paragraph('Fal.ai merge endpoint', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('URL e payload corretti per merge-videos', cell)],
    [Paragraph('Google Sheets "Idea" read', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Filter "for production" + returnFirstMatch corretto', cell)],
    [Paragraph('Google Sheets "URL NOSTRO"', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('appendOrUpdate con matching su "id" implementato bene', cell)],
    [Paragraph('prepara per merge sorting', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Ordinamento per order_id + filtro video_url validi corretto', cell)],
    [Paragraph('split_out extraction', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('$input.item.json.output.scenes estrae correttamente l\'array scene', cell)],
    [Paragraph('Merge and Rebuild packing', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Ricostruisce correttamente l\'array items con taskIds da Kie.ai', cell)],
    [Paragraph('If1 status check', cell_bold), Paragraph('OK', severity_styles['OK']),
     Paragraph('Controllo status === "COMPLETED" con loop su Wait corretto', cell)],
]

col_widths_ok = [0.28*avail_w, 0.10*avail_w, 0.62*avail_w]
t2 = Table(ok_data, colWidths=col_widths_ok, hAlign='CENTER')
style_cmds2 = [
    ('BACKGROUND', (0, 0), (-1, 0), GREEN_OK),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
    ('GRID', (0, 0), (-1, -1), 0.5, TEXT_MUTED),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ('TOPPADDING', (0, 0), (-1, -1), 5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
]
for i in range(1, len(ok_data)):
    bg = colors.white if i % 2 == 1 else BG_SURFACE
    style_cmds2.append(('BACKGROUND', (0, i), (-1, i), bg))
    style_cmds2.append(('BACKGROUND', (1, i), (1, i), GREEN_OK))
t2.setStyle(TableStyle(style_cmds2))
story.append(t2)
story.append(Paragraph('<b>Tabella 2.</b> Componenti verificati e funzionanti correttamente', caption_style))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 8. CONFIGURAZIONE RICHIESTA
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>8. Configurazione Richiesta Prima dell\'Esecuzione</b>', h1))

story.append(Paragraph(
    'Prima di eseguire il workflow su un\'istanza n8n, e necessario configurare le seguenti credenziali e risorse. Queste configurazioni '
    'non sono incluse nel file JSON del workflow per motivi di sicurezza e devono essere impostate manualmente nella UI di n8n.',
    body))

config_data = [
    [Paragraph('<b>Risorsa</b>', header_cell), Paragraph('<b>Tipo</b>', header_cell),
     Paragraph('<b>Nodo/i</b>', header_cell), Paragraph('<b>Note</b>', header_cell)],
    [Paragraph('Google Sheets OAuth2', cell_bold), Paragraph('Credenziale', cell_center),
     Paragraph('Idea, URL NOSTRO, lavori precedenti, nuove idee', cell),
     Paragraph('Account Google con accesso al foglio "studio ghibli"', cell)],
    [Paragraph('OpenAI API Key', cell_bold), Paragraph('Credenziale', cell_center),
     Paragraph('OpenAI Chat Model1, OpenAI Chat Model4', cell),
     Paragraph('Chiave API OpenAI con accesso a GPT-4.1', cell)],
    [Paragraph('Kie.ai Header Auth', cell_bold), Paragraph('Credenziale', cell_center),
     Paragraph('Generate video', cell),
     Paragraph('Header Authorization per api.kie.ai (anche per wait for all dopo fix BUG-01)', cell)],
    [Paragraph('Fal.ai Header Auth', cell_bold), Paragraph('Credenziale', cell_center),
     Paragraph('crea video, Get status3, GET videos', cell),
     Paragraph('Header Authorization per queue.fal.run', cell)],
    [Paragraph('Google Sheet "studio ghibli"', cell_bold), Paragraph('Risorsa esterna', cell_center),
     Paragraph('Tutti i nodi Google Sheets', cell),
     Paragraph('Foglio con colonne: id, Title, GLOBAL_INSTRUCTIONS, production_status, Video_url', cell)],
    [Paragraph('Colonne DNA nel Sheet', cell_bold), Paragraph('Risorsa esterna', cell_center),
     Paragraph('DNA placeholders', cell),
     Paragraph('Dopo fix BUG-04: colonne con DNA dei personaggi coerenti', cell)],
]

col_widths_cfg = [0.20*avail_w, 0.12*avail_w, 0.30*avail_w, 0.38*avail_w]
t3 = Table(config_data, colWidths=col_widths_cfg, hAlign='CENTER')
style_cmds3 = [
    ('BACKGROUND', (0, 0), (-1, 0), ACCENT),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
    ('GRID', (0, 0), (-1, -1), 0.5, TEXT_MUTED),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ('TOPPADDING', (0, 0), (-1, -1), 5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
]
for i in range(1, len(config_data)):
    bg = colors.white if i % 2 == 1 else BG_SURFACE
    style_cmds3.append(('BACKGROUND', (0, i), (-1, i), bg))
t3.setStyle(TableStyle(style_cmds3))
story.append(t3)
story.append(Paragraph('<b>Tabella 3.</b> Configurazioni necessarie prima dell\'esecuzione', caption_style))
story.append(Spacer(1, 18))

# ═══════════════════════════════════════════════════
# 9. PRIORITA DI CORREZIONE
# ═══════════════════════════════════════════════════
story.append(Paragraph('<b>9. Piano di Correzione Prioritario</b>', h1))

story.append(Paragraph(
    'Si raccomanda di affrontare i problemi nell\'ordine seguente, partendo dai bug critici che bloccano completamente '
    'l\'esecuzione del workflow, poi procedendo con quelli di severita alta che causano malfunzionamenti parziali, '
    'e infine quelli di severita media che rappresentano ottimizzazioni.',
    body))

priority_data = [
    [Paragraph('<b>Priorita</b>', header_cell), Paragraph('<b>BUG</b>', header_cell),
     Paragraph('<b>Azione</b>', header_cell), Paragraph('<b>Impatto</b>', header_cell)],
    [Paragraph('1', cell_center), Paragraph('BUG-01', cell_center),
     Paragraph('Fix auth in "wait for all" - usare this.helpers.httpRequestWithAuthentication o staticData', cell),
     Paragraph('Abilita il polling Kie.ai (fondamentale)', cell)],
    [Paragraph('2', cell_center), Paragraph('BUG-02', cell_center),
     Paragraph('Correggere sheetName URL nel nodo "nuove idee"', cell),
     Paragraph('Abilita la scrittura delle idee (fondamentale)', cell)],
    [Paragraph('3', cell_center), Paragraph('BUG-03', cell_center),
     Paragraph('Ripristinare il prompt completo nel nodo "idea generator"', cell),
     Paragraph('Abilita la generazione idee coerenti', cell)],
    [Paragraph('4', cell_center), Paragraph('BUG-04', cell_center),
     Paragraph('Aggiornare i nomi DNA placeholder per contesto ASMR Ghibli', cell),
     Paragraph('Abilita la coerenza dei personaggi', cell)],
    [Paragraph('5', cell_center), Paragraph('BUG-06', cell_center),
     Paragraph('Configurare Wait=60s e Wait3=120s', cell),
     Paragraph('Previene rate limiting API', cell)],
    [Paragraph('6', cell_center), Paragraph('BUG-05', cell_center),
     Paragraph('Implementare retry (max 3) per task Kie.ai falliti', cell),
     Paragraph('Migliora affidabilita generazione', cell)],
    [Paragraph('7', cell_center), Paragraph('BUG-07', cell_center),
     Paragraph('Rimuovere variabile authHeader non utilizzata', cell),
     Paragraph('Pulizia codice', cell)],
    [Paragraph('8', cell_center), Paragraph('BUG-08', cell_center),
     Paragraph('Ridurre batch size da 50 a 10-15', cell),
     Paragraph('Ottimizzazione concorrenza API', cell)],
]

col_widths_p = [0.08*avail_w, 0.10*avail_w, 0.50*avail_w, 0.32*avail_w]
t4 = Table(priority_data, colWidths=col_widths_p, hAlign='CENTER')
style_cmds4 = [
    ('BACKGROUND', (0, 0), (-1, 0), TEXT_PRIMARY),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
    ('GRID', (0, 0), (-1, -1), 0.5, TEXT_MUTED),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ('TOPPADDING', (0, 0), (-1, -1), 5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
]
for i in range(1, len(priority_data)):
    bg = colors.white if i % 2 == 1 else BG_SURFACE
    style_cmds4.append(('BACKGROUND', (0, i), (-1, i), bg))
t4.setStyle(TableStyle(style_cmds4))
story.append(t4)
story.append(Paragraph('<b>Tabella 4.</b> Piano di correzione prioritario', caption_style))
story.append(Spacer(1, 18))

# ─── Build ───
doc.build(story)
print(f"PDF generated: {output_path}")
