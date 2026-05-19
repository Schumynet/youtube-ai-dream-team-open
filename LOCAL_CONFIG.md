# LOCAL CONFIG — GitHub Safety System v2.0

> **ATTENZIONE:** Questo file NON deve mai essere eliminato. E il sistema di sicurezza che previene la disconnessione da GitHub.

---

## Token GitHub — 3 Locazioni Fallback

| # | Percorso | Priorita | Scopo |
|---|----------|----------|-------|
| 1 | `.secrets/github_token` | Primario | Lettura/scrittura repo |
| 2 | `.secrets/github_token.bak` | Backup | Ripristino emergenza |
| 3 | `.env` (GITHUB_TOKEN=) | Env fallback | Auto-load sessione |

---

## Comandi Rapidi (Copia-Incolla)

### Inizializzare il sistema in ogni nuova chat:
```bash
source .github_safety.sh
```

### Verificare che tutto funzioni:
```bash
source .github_safety.sh && status
```

### Leggere un file dal repo:
```bash
source .github_safety.sh
github_read dream_team_index.md
```

### Leggere un SOP di un agente:
```bash
source .github_safety.sh
github_read sops/quality/agent_32_sop_n8n_workflow_validator.md
```

### Scrivere un file sul repo:
```bash
source .github_safety.sh
github_write "percorso/file.md" "contenuto del file" "Messaggio commit"
```

### Aggiornare il token (se scade o viene rigenerato):
```bash
source .github_safety.sh
save_token "nuovo_token_qui"
```

### Health check rapido:
```bash
source .github_safety.sh && health_check
```

---

## Cosa Farsi se la Connessione Cadre

1. **Verifica con:** `source .github_safety.sh && status`
2. **Se TOKEN_EXPIRED:** Vai su github.com/settings/tokens e rigenera il token, poi: `save_token <NUOVO_TOKEN>`
3. **Se RATE_LIMITED:** Attendi 60 secondi e riprova
4. **Se REPO_NOT_FOUND:** Il repo potrebbe essere stato rinominato, controlla su GitHub

---

## Repo Info

```
Repository: YOUR_USERNAME/youtube-ai-dream-team
URL: https://github.com/YOUR_USERNAME/youtube-ai-dream-team
Visibilita: Privato
Branch: main
```

---

*Ultimo aggiornamento: 20 Maggio 2026*
*Versione: 2.0*
