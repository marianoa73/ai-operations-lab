#!/usr/bin/env bash
# Revisa los prerrequisitos ANTES de instalar nada. No cambia nada en el sistema: sólo lee y avisa.
# Sale con 0 si no hay faltantes obligatorios, 1 si falta alguno. Las advertencias no cortan.
#
# Uso: preflight.sh [--con-modelo-propio]
# Los umbrales se pueden ajustar por variables (MIN_MEM_MB, MIN_DISK_GB, MIN_NODE, MIN_PY) y los datos del sistema
# se pueden sustituir para probar (OS_RELEASE, MEMINFO, ARCH, DISK_PATH).
set -uo pipefail
MIN_MEM_MB="${MIN_MEM_MB:-7000}"     # una placa de 8 GB informa cerca de 7,6 GB utilizables
MIN_DISK_GB="${MIN_DISK_GB:-20}"     # libres en la partición del sistema (ver docs/hardware.md)
MIN_NODE="${MIN_NODE:-20}"
MIN_PY="${MIN_PY:-3.9}"
OS_RELEASE="${OS_RELEASE:-/etc/os-release}"
MEMINFO="${MEMINFO:-/proc/meminfo}"
ARCH="${ARCH:-$(uname -m)}"
DISK_PATH="${DISK_PATH:-/}"

falta=0; aviso=0
ok()   { echo "ok     $1"; }
mal()  { echo "FALTA  $1"; falta=$((falta + 1)); }
avisa() { echo "aviso  $1"; aviso=$((aviso + 1)); }
tiene() { command -v "$1" >/dev/null 2>&1; }
# versión >= mínima (comparación numérica por partes)
al_menos() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

# 1. Arquitectura y sistema operativo
case "$ARCH" in
  aarch64|arm64) ok "arquitectura de 64 bits ($ARCH)" ;;
  *) mal "arquitectura $ARCH: hace falta arm64 (sistema de 64 bits)" ;;
esac
if [ -r "$OS_RELEASE" ]; then
  # shellcheck disable=SC1090
  . "$OS_RELEASE"
  case "${ID:-}:${VERSION_ID:-}" in
    debian:12|debian:13|ubuntu:24.04|ubuntu:26.04) ok "sistema operativo ${PRETTY_NAME:-$ID $VERSION_ID}" ;;
    *) avisa "sistema ${PRETTY_NAME:-desconocido}: la guía se escribió para Debian 12/13 (Raspberry Pi OS) o Ubuntu 24.04" ;;
  esac
else
  avisa "no se pudo leer $OS_RELEASE"
fi

# 2. Memoria y disco
mem_mb=$(awk '/^MemTotal:/ {print int($2 / 1024)}' "$MEMINFO" 2>/dev/null)
if [ "${mem_mb:-0}" -ge "$MIN_MEM_MB" ]; then ok "memoria ${mem_mb} MB"; else mal "memoria ${mem_mb:-?} MB: hacen falta al menos $MIN_MEM_MB MB (placa de 8 GB)"; fi
libre_gb=$(df -Pk "$DISK_PATH" 2>/dev/null | awk 'NR==2 {print int($4 / 1024 / 1024)}')
if [ "${libre_gb:-0}" -ge "$MIN_DISK_GB" ]; then ok "disco libre ${libre_gb} GB"; else mal "disco libre ${libre_gb:-?} GB: hacen falta al menos $MIN_DISK_GB GB"; fi

# 3. Herramientas imprescindibles
for h in tmux git curl python3 sudo; do
  if tiene "$h"; then ok "$h instalado"; else mal "$h no está instalado"; fi
done
if tiene python3; then
  py=$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')
  if al_menos "$py" "$MIN_PY"; then ok "python $py"; else mal "python $py: hace falta $MIN_PY o superior"; fi
fi
if tiene node; then
  nv=$(node -v | sed 's/^v//; s/\..*//')
  if [ "${nv:-0}" -ge "$MIN_NODE" ]; then ok "node $(node -v)"; else mal "node $(node -v): hace falta la versión $MIN_NODE o superior"; fi
else
  mal "node no está instalado (las herramientas de IA lo necesitan; paso 2.4 de install.md)"
fi

# 4. Red, hora y puertos
if tiene getent && getent hosts example.com >/dev/null 2>&1; then ok "resolución de nombres (DNS)"; else mal "no resuelve nombres: sin salida a Internet no se instalan las herramientas"; fi
if tiene timedatectl; then
  case "$(timedatectl show -p NTPSynchronized --value 2>/dev/null)" in
    yes) ok "hora sincronizada" ;;
    *) avisa "hora sin sincronizar: HTTPS puede fallar" ;;
  esac
fi
if tiene ss; then
  for p in 80 443; do
    if ss -ltn "sport = :$p" 2>/dev/null | grep -q LISTEN; then avisa "el puerto $p ya está en uso (Caddy lo necesita; sólo importa si ya hay otro servicio)"; else ok "puerto $p libre"; fi
  done
fi

# 5. Opcionales
tiene ufw && ok "ufw instalado" || avisa "ufw no está instalado (se instala en el paso 2.3)"
[ "$(id -u)" -eq 0 ] && avisa "estás como root: usá un usuario normal con sudo"
if [ "${1:-}" = "--con-modelo-propio" ]; then
  echo "nota   el modelo propio se revisa en el otro equipo: 32 GB de RAM y Ollama (ver docs/local-model.md)"
fi

echo "---"
if [ "$falta" -eq 0 ]; then echo "Listo para instalar ($aviso aviso(s))."; exit 0; fi
echo "Faltan $falta requisito(s) obligatorio(s): resolvelos y volvé a ejecutar."; exit 1
