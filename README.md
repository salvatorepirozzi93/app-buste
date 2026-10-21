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

L'app funziona **subito** senza configurazione: i dati vengono salvati nel
`localStorage` del browser, quindi restano **solo su quel dispositivo**.

Per avere gli stessi dati su telefono, computer e tablet in tempo reale serve
un piccolo setup su Firebase (gratis, ~10 minuti, una volta sola).

## 1. Crea il progetto Firebase

1. Apri <https://console.firebase.google.com> e accedi con Google
2. **Add project** → dai un nome (es. `caja-de-totri`) → continua
3. **Build → Firestore Database** → **Create database**
   - modalità *Production mode*
   - location: scegli quello più vicino (es. `europe-west1`)
4. **Build → Authentication** → *Get started* → attiva **Email/Password**
   (nella sezione *Sign-in method*)
5. **Project settings** (icona ingranaggio) → **Your apps** → icona `</>` (Web)
   → registra l'app → **copia il blocco `firebaseConfig`**

## 2. Incolla la configurazione

Incolla il blocco copiato in `index.html`, all'inizio dello `<script>`:

```js
const FIREBASE_CONFIG = {
  apiKey: "AIza...",
  authDomain: "caja-de-totri.firebaseapp.com",
  projectId: "caja-de-totri",
  storageBucket: "caja-de-totri.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

> I valori di `firebaseConfig` **sono pensati per essere pubblici**: chiunque
> può leggerli. La sicurezza dei dati dipende dalle regole Firestore (punto 3).

## 3. Regole di sicurezza Firestore

**Firestore → Rules** → incolla e pubblica:

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

Così ogni utente vede e modifica **solo le proprie** buste.

## 4. Pubblica

```bash
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
- I dati salvati sono locali al browser/dispositivo: cancellare i dati di navigazione
  li perde. Se attivi la sincronizzazione, i dati restano anche nel cloud.
- Il gioco della moneta (busta "decisione") usa Web Audio: su iPhone va sbloccato
  con un tocco. Se non senti nulla, controlla il **silenzioso** dell'iPhone e il
  pulsante 🔊 in alto a destra.
