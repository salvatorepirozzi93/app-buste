# App Buste — La caja de ToTri

Una web app single-page (HTML + CSS + JS puro, senza build step) per creare e
raccontare "buste" digitali: lettere, playlist, ricette, desideri, ritratti.

## Come funziona

- Tutto sta in **un solo file** `index.html`.
- I dati vengono salvati nel **localStorage** del browser (nessun server, nessun account).
- Le dipendenze esterne arrivano da CDN: Tailwind CSS, Font Awesome, Google Fonts, canvas-confetti.

## Struttura

```
.
├── index.html   # l'intera app
└── README.md
```

## Deploy

Il sito è pubblicato tramite **GitHub Pages**:
Settings → Pages → Source: *Deploy from a branch* → branch `main`, cartella `/ (root)`.

URL pubblico: `https://<username>.github.io/<nome-repo>/`

## Uso locale

```bash
open index.html
```

Oppure un server statico:

```bash
python3 -m http.server 8000
# poi apri http://localhost:8000
```

## Note

- Per modificare e ripubblicare: modifica `index.html`, poi `git commit` + `git push`.
  GitHub Pages ricostruisce il sito in automatico (30–60 secondi).
- I dati salvati sono locali al browser/dispositivo: cancellare i dati di navigazione
  li perde. Non viene inviato nulla in rete.
