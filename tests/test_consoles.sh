#!/usr/bin/env bash
# Prueba de src/consoles.sh con un `tmux` falso que registra las llamadas: no necesita tmux real.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin"
cat > "$WORK/bin/tmux" <<'STUB'
#!/usr/bin/env bash
echo "$*" >> "$STATE/calls"
case "$1" in
  has-session) grep -q "^new-session -d -s $3 " "$STATE/calls" ;;   # existe si ya se creó
  new-session|kill-session) exit 0 ;;
esac
STUB
chmod +x "$WORK/bin/tmux"
export PATH="$WORK/bin:$PATH" STATE="$WORK" WORKDIR="$WORK" CONSOLES='uno:cmd-uno;dos:sudo -u aux -H cmd-dos'
fail=0
expect() { if grep -qF -- "$2" <<<"$3"; then echo "ok   $1"; else echo "FALLA $1: falta '$2' en: $3"; fail=1; fi; }

expect "inicia ambas sesiones" "iniciada: dos" "$(bash "$ROOT/src/consoles.sh" start)"
expect "pasa el comando completo" "new-session -d -s dos -c $WORK sudo -u aux -H cmd-dos" "$(cat "$WORK/calls")"
expect "no repite una sesión existente" "ya corre: uno" "$(bash "$ROOT/src/consoles.sh" start)"
expect "estado" "corre:   uno" "$(bash "$ROOT/src/consoles.sh" status)"
bash "$ROOT/src/consoles.sh" bad >/dev/null 2>&1; [ $? -eq 64 ] && echo "ok   acción inválida (64)" || { echo "FALLA acción inválida"; fail=1; }
exit $fail
