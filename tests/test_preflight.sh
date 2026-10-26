#!/usr/bin/env bash
# Prueba de src/preflight.sh con datos del sistema sustituidos (arquitectura, memoria, sistema, disco, herramientas).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
printf 'ID=debian\nVERSION_ID="13"\nPRETTY_NAME="Debian GNU/Linux 13 (trixie)"\n' > "$WORK/os-debian"
printf 'ID=fedora\nVERSION_ID="40"\nPRETTY_NAME="Fedora 40"\n' > "$WORK/os-otro"
printf 'MemTotal:        7900000 kB\n' > "$WORK/mem-8gb"
printf 'MemTotal:        3900000 kB\n' > "$WORK/mem-4gb"
# PATH acotado: sólo las herramientas que el script necesita, para poder quitar tmux
mkdir -p "$WORK/bin"
for t in awk sort head sed df id uname getent ss timedatectl python3 node git curl sudo grep cat dirname printf; do
  p="$(command -v "$t" 2>/dev/null)" && ln -s "$p" "$WORK/bin/$t"
done
ln -s "$(command -v tmux)" "$WORK/bin/tmux" 2>/dev/null
fail=0
corre() { env PATH="$WORK/bin" OS_RELEASE="$WORK/os-debian" MEMINFO="$WORK/mem-8gb" MIN_DISK_GB=0 "$@" /usr/bin/bash "$ROOT/src/preflight.sh" 2>&1; }
expect() { if grep -qF -- "$2" <<<"$3"; then echo "ok   $1"; else echo "FALLA $1: falta '$2' en: $3"; fail=1; fi; }
codigo() { [ "$2" = "$3" ] && echo "ok   $1" || { echo "FALLA $1: código $3, esperado $2"; fail=1; }; }

out=$(corre ARCH=aarch64); cod=$?
if grep -q '^FALTA' <<<"$out"; then echo "(entorno de prueba sin DNS o sin herramientas: se omite el caso base)"; else
  codigo "todo en orden sale con 0" 0 "$cod"; fi
out=$(corre ARCH=armv7l); cod=$?
expect "rechaza 32 bits" "FALTA  arquitectura armv7l" "$out"; codigo "32 bits sale con 1" 1 "$cod"
out=$(corre ARCH=aarch64 MEMINFO="$WORK/mem-4gb")
expect "rechaza poca memoria" "FALTA  memoria 3808 MB" "$out"
out=$(corre ARCH=aarch64 MIN_DISK_GB=999999)
expect "rechaza poco disco" "FALTA  disco libre" "$out"
out=$(corre ARCH=aarch64 OS_RELEASE="$WORK/os-otro")
expect "avisa un sistema no previsto" "aviso  sistema Fedora 40" "$out"
out=$(corre ARCH=aarch64 MIN_NODE=999)
expect "rechaza node viejo" "hace falta la versión 999" "$out"
rm -f "$WORK/bin/tmux"
out=$(corre ARCH=aarch64)
expect "detecta tmux ausente" "FALTA  tmux no está instalado" "$out"
exit $fail
