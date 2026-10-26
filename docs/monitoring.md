# Monitoreo de las consolas por web

Todas las consolas de IA se lanzan dentro de **sesiones `tmux`** (una por asistente). Eso permite dos cosas: mirarlas en
vivo desde una terminal (`tmux attach -t claude`) y mirarlas **desde el navegador** a través de una página que se
refresca sola.

## Cómo funciona

```
tmux (claude, codex, opencode) ──► src/monitor.py (cada 30 s) ──► index.html ──► Caddy (HTTPS + contraseña) ──► navegador
```

1. [`src/consoles.sh`](../src/consoles.sh) levanta cada asistente en su sesión `tmux` (si ya existe, no la toca).
2. [`src/monitor.py`](../src/monitor.py) lee las últimas líneas de cada sesión con `tmux capture-pane`, quita los códigos
   de color, **tapa patrones de secretos** y escribe una página HTML de forma atómica.
3. Un temporizador de systemd ([`ai-monitor.timer`](../examples/systemd/ai-monitor.timer)) lo repite cada 30 s.
4. Caddy sirve el archivo en `/monitor/` con HTTPS y contraseña ([`Caddyfile`](../examples/caddy/Caddyfile)).
5. La página usa `<meta http-equiv="refresh">`: el navegador la recarga solo. No tiene JavaScript ni formularios.

Es de **sólo lectura**: desde la web no se puede escribirle a una consola. Las respuestas largas no se leen de la
pantalla sino de archivos (ver [`architecture.md`](architecture.md)); la página sirve para *ver qué está pasando*.

## Seguridad

- **Tapar secretos es un esfuerzo razonable, no una garantía.** Cubre claves con prefijos conocidos (`sk-…`, `ghp_…`,
  `AKIA…`), JWT, bloques de clave privada y asignaciones como `token=…` o `password: …`. No detecta datos personales,
  montos ni secretos con otro formato. Por eso la página va **siempre** detrás de HTTPS y contraseña, y no se publica sin ellas.
- **Pausa de emergencia:** si existe el archivo indicado en `MONITOR_PAUSE`, la página deja de mostrar el contenido de
  las consolas (`touch ~/.config/ai-lab/monitor.pause`; para reanudar, borrarlo).
- La sesión web nunca recibe entradas: no hay forma de enviar comandos desde la página.
- Las pruebas ([`tests/test_monitor.py`](../tests/test_monitor.py)) cubren el tapado de secretos, el escapado de HTML, la
  pausa y la escritura atómica.

## Límites

- Muestra las últimas líneas, no un historial; si algo se desplaza de la pantalla, no se ve.
- Depende de que `tmux` conserve las sesiones: si una sesión no existe, la página lo dice.
- La detección de secretos es por patrones: ante la duda, usar la pausa.
