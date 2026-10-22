# App Buste — La caja de ToTri

Una web app single-page (HTML + CSS + JS puro, senza build step) per creare e
raccontare "buste" digitali: lettere, playlist, ricette, desideri, ritratti.

## Struttura

```
.
├── index.html      # l'intera app
├── README.md
└── deploy.sh       # script di pubblicazione su GitHub Pages
```

## Deploy

Il sito è pubblicato tramite **GitHub Pages**:
Settings → Pages → Source: *Deploy from a branch* → branch `main`, cartella `/ (root)`.

URL pubblico: `https://salvatorepirozzi93.github.io/app-buste/`

Per ripubblicare dopo una modifica:

```bash
./deploy.sh
```

---

# Sincronizzazione in tempo reale (Firebase)

✅ **Attiva.** Il progetto Firebase `caja-de-totri` è già creato e configurato:

| Cosa | Stato |
|---|---|
| Progetto Firebase | `caja-de-totri` |
| Database Firestore | creato (regione `nam5`) |
| App Web | "App Buste" (config già in `index.html`) |
| Accesso | **Accedi con Google** (gratuito, niente carta di credito) |
| Domini autorizzati | `salvatorepirozzi93.github.io` |
| Regole di sicurezza | pubblicate (ogni utente vede solo le sue buste) |

L'accesso avviene con un popup Google: su iPhone viene usato il reindirizzamento
(più affidabile su Safari mobile).

## Come funziona per l'utente

1. Apri la app → compare "Accedi con Google"
2. Scegli l'account → le buste si sincronizzano **in tempo reale** su tutti i
   dispositivi (telefono, computer, tablet)
3. Il badge in alto a destra mostra lo stato: "Sincronizzato" / "Solo su questo dispositivo"
4. "Esci" ti riporta alla modalità solo-locale

Nessun account → l'app funziona comunque, ma i dati restano solo su quel
dispositivo (e "Continua senza account" lo dice).

## Note tecniche

- **Regole Firestore** (già pubblicate): ogni utente può leggere/scrivere
  **solo** il proprio documento `vaults/{uid}`.
- **Offline**: Firestore accoda le scritture e le sincronizza al ritorno della rete.
- **Conflitti**: last-write-wins sul timestamp; le modifiche fatte offline non
  vengono perse (viene confrontato il timestamp locale con quello del cloud).
- **Persistenza locale**: `localStorage` come cache, così l'app apre subito
  anche senza rete.
- La configurazione `firebaseConfig` in `index.html` **è pensata per essere
  pubblica**: la sicurezza dipende dalle regole Firestore, non dalla API key.

## Se un giorno vuoi rifare il setup

<details>
<summary>Procedura completa</summary>

1. <https://console.firebase.google.com> → **Add project**
2. **Build → Firestore Database** → **Create database** (Production mode)
3. **Build → Authentication** → attiva il provider **Google**
   (l'Email/Password richiede il piano Blaze a pagamento: non serve qui)
4. **Impostazioni progetto → Le tue app** → icona `</>` (Web) → registra l'app
   → **Usa un tag `<script>`** → copia `firebaseConfig` nel blocco
   `FIREBASE_CONFIG` in `index.html`
5. **Authentication → Impostazioni → Domini autorizzati** → aggiungi il tuo dominio
   (es. `salvatorepirozzi93.github.io`)
6. **Authentication → Metodo di accesso** → imposta l'email di assistenza
   (obbligatoria per attivare Google) e clicca **Salva**
7. **Firestore → Regole** → incolla le regole qui sotto e clicca **Pubblica**:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /vaults/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

</details>


./deploy.sh
```

Al primo avvio comparirà il login: crea un account (email + password, minimo 6
caratteri) e le buste si sincronizzeranno subito su tutti i dispositivi.

## Come funziona

| Aspetto | Dettaglio |
|---|---|
| **Real-time** | `onSnapshot` di Firestore: push via WebSocket, nessun polling |
| **Offline** | Firestore accoda le scritture e le sincronizza al ritorno della rete |
| **Conflitti** | last-write-wins sul timestamp; le modifiche offline non vengono perse |
| **Dati locali** | `localStorage` come cache: l'app apre subito, anche senza rete |
| **Sicurezza** | un documento per utente in `/vaults/{uid}`, regole Firestore |

---

# Backup manuale (Export / Import)

Indipendentemente dalla sincronizzazione, il pulsante 📦 in alto a destra permette:

- **Esporta** — scarica un file `buste-caja-totri.json` con tutte le buste.
  Mandamelo pure e lo incorporo nell'app.
- **Importa** — carica un file `.json` (o incolla il JSON nel campo di testo)
  per ripristinare le buste su un altro dispositivo.

---

# Note

- Per modificare e ripubblicare: modifica `index.html`, poi `./deploy.sh`.
  GitHub Pages ricostruisce il sito in automatico (30–60 secondi).
- Con la sincronizzazione attiva i dati stanno **sia** in locale (cache, per
  l'apertura offline) **sia** nel cloud Firestore. Senza accesso restano solo
  in locale.
- Ogni account Google vede **solo le proprie** buste (regole Firestore).
- Il gioco della moneta (busta "decisione") usa Web Audio: su iPhone va sbloccato
  con un tocco. Se non senti nulla, controlla il **silenzioso** dell'iPhone e il
  pulsante 🔊 in alto a destra.
