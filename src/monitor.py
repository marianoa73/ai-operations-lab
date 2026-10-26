#!/usr/bin/env python3
"""Genera una página HTML con las últimas líneas de las consolas tmux, para mirarlas desde el navegador.

La página se refresca sola (<meta refresh>), no tiene JavaScript y no acepta entradas: sólo muestra. Antes de
escribirla se quitan los códigos de color y se tapan patrones típicos de secretos. Tapar es un esfuerzo razonable y
no una garantía: la página debe servirse detrás de una contraseña y de HTTPS (ver docs/monitoring.md).

Configuración por variables de entorno (ver examples/ai-lab.env.example):
  MONITOR_SESSIONS  sesiones tmux separadas por coma          (claude,codex,opencode)
  MONITOR_LINES     últimas líneas visibles por sesión        (24)
  MONITOR_REFRESH   segundos entre refrescos del navegador    (30)
  MONITOR_OUT       archivo HTML de salida                    (./site/index.html)
  MONITOR_PAUSE     si este archivo existe, no se muestra nada (./monitor.pause)
"""
import html
import os
import re
import subprocess
import tempfile
import time
from pathlib import Path

ANSI = re.compile(r"\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b\][^\x07]*\x07")
SECRETS = [
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----.*", re.S),
    re.compile(r"\bsk-[A-Za-z0-9_\-]{16,}"),
    re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}"),
    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    re.compile(r"\beyJ[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}"),
]
ASSIGNED = re.compile(r"(?i)\b(api[_-]?key|token|secret|password|passwd|authorization)(\s*[:=]\s*|\s+bearer\s+)\S+")
MASK = "***"


def clean(text):
    """Quita colores y tapa patrones típicos de secretos."""
    text = ANSI.sub("", text)
    for pattern in SECRETS:
        text = pattern.sub(MASK, text)
    return ASSIGNED.sub(lambda m: m.group(1) + m.group(2) + MASK, text)


def capture(session, lines, run=subprocess.run):
    """Últimas líneas de una sesión tmux, o None si la sesión no existe."""
    result = run(["tmux", "capture-pane", "-p", "-t", session, "-S", f"-{lines * 3}"],
                 capture_output=True, text=True)
    if result.returncode != 0:
        return None
    visible = [line.rstrip() for line in result.stdout.splitlines() if line.strip()]
    return clean("\n".join(visible[-lines:]))


def render(panes, refresh, now, paused=False):
    blocks = []
    for name, text in panes.items():
        if paused:
            body = "En pausa."
        elif text is None:
            body = "La sesión no está corriendo."
        else:
            body = text or "(sin salida)"
        blocks.append(f"<section><h2>{html.escape(name)}</h2><pre>{html.escape(body)}</pre></section>")
    stamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(now))
    return (
        '<!doctype html><html lang="es"><head><meta charset="utf-8">'
        f'<meta http-equiv="refresh" content="{int(refresh)}">'
        '<meta name="viewport" content="width=device-width,initial-scale=1"><title>Consolas</title>'
        "<style>body{font:14px system-ui;margin:1rem;background:#f6f7f8;color:#1b1f23}"
        "pre{background:#10151a;color:#d7dde3;padding:.8rem;border-radius:6px;overflow:auto;white-space:pre-wrap}"
        "h2{font-size:1rem;margin:1rem 0 .3rem}small{color:#667}"
        "@media(prefers-color-scheme:dark){body{background:#0d1114;color:#d7dde3}}</style></head><body>"
        f"<h1>Consolas</h1><small>Solo lectura · actualizado {stamp} · se refresca cada {int(refresh)} s</small>"
        + "".join(blocks) + "</body></html>"
    )


def write_atomic(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, suffix=".tmp")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(content)
    os.chmod(tmp, 0o644)
    os.replace(tmp, path)


def main():
    sessions = [s.strip() for s in os.environ.get("MONITOR_SESSIONS", "claude,codex,opencode").split(",") if s.strip()]
    lines = int(os.environ.get("MONITOR_LINES", "24"))
    refresh = int(os.environ.get("MONITOR_REFRESH", "30"))
    out = os.environ.get("MONITOR_OUT", "./site/index.html")
    paused = Path(os.environ.get("MONITOR_PAUSE", "./monitor.pause")).exists()
    panes = {s: (None if paused else capture(s, lines)) for s in sessions}
    write_atomic(out, render(panes, refresh, time.time(), paused))


if __name__ == "__main__":
    main()
