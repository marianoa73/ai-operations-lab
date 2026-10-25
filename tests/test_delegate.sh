#!/usr/bin/env bash
# Prueba de src/delegate.sh con un `tmux` falso: no necesita tmux ni ninguna IA.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin"

cat > "$WORK/bin/tmux" <<'STUB'
#!/usr/bin/env bash
# MODE: ok | busy | permission | silent | partial
case "$1" in
  has-session) exit 0 ;;
  capture-pane)
    case "$MODE" in
      busy) echo "Working (esc to interrupt)" ;;
      permission) [ -f "$STATE/sent" ] && echo "Allow this command? (y)" || echo "> LIBRE" ;;
      *) echo "> LIBRE" ;;
    esac ;;
  send-keys)
    if [ "$2" = "-t" ] && [ "$4" = "-l" ]; then
      out="$(sed -E 's/.* en (\S+\.md),.*/\1/' <<<"$5")"; touch "$STATE/sent"
      case "$MODE" in
        ok) printf 'respuesta de prueba\n<<FIN>>\n' > "$out" ;;
        partial) printf 'respuesta incompleta\n' > "$out" ;;
      esac
    fi ;;
esac
STUB
chmod +x "$WORK/bin/tmux"
export PATH="$WORK/bin:$PATH" STATE="$WORK" IDLE_PATTERN="> LIBRE" OUT_DIR="$WORK/out" POLL_SECONDS=1
fail=0
check() { # nombre esperado_codigo modo
  rm -f "$WORK/sent"; MODE="$3" bash "$ROOT/src/delegate.sh" s "pedido" 3 >"$WORK/stdout" 2>&1; local rc=$?
  if [ "$rc" -eq "$2" ]; then echo "ok   $1 (salida $rc)"; else echo "FALLA $1: esperado $2, salió $rc"; fail=1; fi
}
check "respuesta completa"            0 ok
check "asistente ocupado"             2 busy
check "pide permiso"                  3 permission
check "archivo sin marca de fin"      4 partial
check "sin respuesta (tiempo agotado)" 4 silent
exit $fail
