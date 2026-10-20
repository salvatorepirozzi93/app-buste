#!/bin/bash
# Deploy di App Buste su GitHub Pages (funziona anche senza git installato).
# Uso:  ./deploy.sh
#
# Richiede: gh CLI autenticato (gh auth login) + perl + curl (presenti di default su macOS).
# In alternativa, se hai git: git add -A && git commit -m "..." && git push

set -euo pipefail

GH="${GH_BIN:-$HOME/.local/bin/gh}"
REPO="${REPO:-salvatorepirozzi93/app-buste}"
BRANCH="main"
API="https://api.github.com/repos/$REPO/contents"

cd "$(dirname "$0")"

command -v "$GH" >/dev/null 2>&1 || { echo "GitHub CLI non trovato. Installalo: https://cli.github.com"; exit 1; }
TOKEN="$("$GH" auth token)"

build_payload() {
  perl -MMIME::Base64 -MJSON::PP -e '
    my ($f, $m, $b, $sha) = @ARGV;
    open(my $fh, "<:raw", $f) or die "open $f: $!";
    local $/; my $c = <$fh>; close $fh;
    my %p = (
      message => $m,
      content => MIME::Base64::encode_base64($c, ""),
      branch  => $b
    );
    $p{sha} = $sha if $sha;   # serve per aggiornare un file esistente
    open(my $o, ">:raw", "/tmp/_gh_payload.json") or die $!;
    print $o JSON::PP->new->canonical->encode(\%p);
    close $o;
  ' "$1" "$2" "$3" "$4"
}

# sha del file già presente su GitHub (vuoto se non esiste)
remote_sha() {
  curl -sS -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "$API/$1" \
  | perl -MJSON::PP -0777 -ne '
      my $d = JSON::PP->new->decode($_);
      print($d->{sha} // "");
    '
}

upload() {
  local file="$1" msg="$2"
  [ -f "$file" ] || { echo "  skip $file (assente)"; return 0; }

  build_payload "$file" "$msg" "$BRANCH" "$(remote_sha "$file")"

  curl -sS -X PUT \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    --data @/tmp/_gh_payload.json \
    "$API/$file" \
  | perl -MJSON::PP -0777 -ne '
      my $d = JSON::PP->new->decode($_);
      if ($d->{content}) { print "  OK   $d->{content}{path}\n" }
      else { print "  ERR  ", ($d->{message} // "errore sconosciuto"), "\n"; exit 1 }
    '
}

echo "Deploy su $REPO (branch $BRANCH)…"
upload "index.html" "Aggiorna index.html"
upload "README.md"  "Aggiorna README.md"
upload ".gitignore" "Aggiorna .gitignore"
upload ".nojekyll"  "Aggiorna .nojekyll"
upload "deploy.sh"   "Aggiorna deploy.sh"

echo
echo "Fatto. GitHub Pages ripubblica in 30-60 secondi:"
echo "https://salvatorepirozzi93.github.io/app-buste/"
