# Cómo probarlo

## Recorrido 1: el enrutador (sin instalar nada)

Requisitos: Python 3.9 o más nuevo.

```bash
git clone <URL de este repositorio>
cd ai-operations-lab
python3 -m unittest discover -s tests -v
```

Resultado esperado: 11 pruebas en verde. Las tareas de `demo/fixtures/tasks.json` están inventadas para este repositorio.

Para explorar:
- Cambiá una etiqueta en `demo/fixtures/tasks.json` y corré las pruebas: el enrutador debería mandar la tarea a otro participante.
- Probá `route(Task("x", frozenset()), usage_pct=90)` en una consola de Python: una tarea sin clasificar con la reserva
  agotada devuelve `queue`.

## Recorrido 2: el script de delegación

Requisitos: Bash.

```bash
bash tests/test_delegate.sh
```

Resultado esperado: 5 casos "ok" (respuesta completa, ocupado, pide permiso, archivo sin marca de fin, tiempo agotado). Usa un `tmux` simulado.

Para usarlo con una herramienta real necesitás además `tmux` y una IA de línea de comandos corriendo en una sesión:

```bash
IDLE_PATTERN='texto que muestra la caja de entrada vacía' \
OUT_DIR=/ruta/absoluta/para/respuestas \
src/delegate.sh <sesion_tmux> "pedido en una línea" 600
```

- `IDLE_PATTERN`: el texto que la herramienta muestra cuando está esperando un pedido; cambia de una herramienta a otra.
- `OUT_DIR`: dónde se escriben las respuestas (por defecto `./responses`, que se convierte a ruta absoluta).
- Límites: es una referencia; la detección de "libre" y de "pide permiso" es heurística. Ver [`limitations.md`](limitations.md).
