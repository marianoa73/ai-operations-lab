#!/usr/bin/env bash
# Referencia: levanta cada asistente en su propia sesión tmux, para poder mirarlos con `tmux attach` o desde la
# página de monitoreo. Idempotente: no toca las sesiones que ya existen.
#
# Uso: CONSOLES='claude:claude;codex:codex;opencode:opencode' consoles.sh start|stop|status
# Cada elemento es <sesión>:<comando>, separados por ';'. Para aislar un asistente en otro usuario de Linux:
#   CONSOLES='opencode:sudo -u svc-aux -H opencode'
set -uo pipefail
ACTION="${1:?uso: consoles.sh start|stop|status}"
WORKDIR="${WORKDIR:-$HOME}"
IFS=';' read -r -a ITEMS <<<"${CONSOLES:?definí CONSOLES, por ejemplo 'claude:claude;codex:codex'}"

for item in "${ITEMS[@]}"; do
  name="${item%%:*}"; cmd="${item#*:}"
  case "$ACTION" in
    start)  tmux has-session -t "$name" 2>/dev/null && echo "ya corre: $name" \
              || { tmux new-session -d -s "$name" -c "$WORKDIR" "$cmd" && echo "iniciada: $name"; } ;;
    stop)   tmux kill-session -t "$name" 2>/dev/null && echo "detenida: $name" || echo "no corría: $name" ;;
    status) tmux has-session -t "$name" 2>/dev/null && echo "corre:   $name" || echo "parada:  $name" ;;
    *) echo "acción desconocida: $ACTION"; exit 64 ;;
  esac
done
