#!/usr/bin/env bash
# Referencia (no es un instalador): envía un pedido a un asistente que corre en una sesión tmux
# y espera a que escriba la respuesta en un archivo. Se puede mirar la sesión en vivo con `tmux attach`.
#
# La respuesta se lee de un ARCHIVO, no de la pantalla. La pantalla sólo se consulta para dos señales heurísticas:
# si la caja de entrada está libre (IDLE_PATTERN) y si hay un pedido de permiso. Si la herramienta cambia su
# interfaz, esas dos señales pueden fallar; por eso el límite de tiempo y los códigos de salida.
#
# Uso: IDLE_PATTERN='texto de la caja vacía' [OUT_DIR=/ruta/absoluta] delegate.sh <sesion_tmux> "pedido" [timeout_s]
# Códigos de salida: 0 ok, 1 sin sesión, 2 ocupado, 3 pide un permiso (lo decide una persona), 4 tiempo agotado.
set -uo pipefail
SESSION="${1:?falta la sesión tmux}"
REQUEST="${2:?falta el pedido}"
TIMEOUT="${3:-600}"
: "${IDLE_PATTERN:?definí IDLE_PATTERN con el texto de la caja de entrada vacía}"
OUT_DIR="$(mkdir -p "${OUT_DIR:-./responses}" && cd "${OUT_DIR:-./responses}" && pwd)"   # ruta absoluta
END_MARK="<<FIN>>"
ID="$(date +%Y%m%d-%H%M%S)-$$-$RANDOM"                                                  # único aunque haya dos pedidos por segundo
OUT="$OUT_DIR/$ID.md"

screen() { tmux capture-pane -p -t "$SESSION" | grep -v '^\s*$' | tail -6; }
idle()   { local s; s="$(screen)"; grep -q "$IDLE_PATTERN" <<<"$s" && ! grep -qiE 'working|interrupt' <<<"$s"; }
asks_permission() { screen | grep -qiE 'allow|approve|\(y\)|yes, '; }
finished() { [ -s "$OUT" ] && [ "$(tail -n 1 "$OUT")" = "$END_MARK" ]; }                # señal explícita de fin

tmux has-session -t "$SESSION" 2>/dev/null || { echo "no existe la sesión '$SESSION'"; exit 1; }
idle || { echo "el asistente está ocupado"; exit 2; }

tmux send-keys -t "$SESSION" -l "[delegado] ${REQUEST//$'\n'/ } — escribí la respuesta completa en $OUT, terminá el archivo con una última línea que diga $END_MARK y respondé sólo 'listo'."
sleep 2; tmux send-keys -t "$SESSION" Enter

elapsed=0
while [ "$elapsed" -lt "$TIMEOUT" ]; do
  sleep "${POLL_SECONDS:-5}"; elapsed=$((elapsed + ${POLL_SECONDS:-5}))
  if finished; then sed '$d' "$OUT"; exit 0; fi
  if asks_permission && ! idle; then echo "pide un permiso; lo decide una persona"; screen; exit 3; fi
done
echo "tiempo agotado"; screen; exit 4
