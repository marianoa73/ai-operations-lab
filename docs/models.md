# Modelos: cuál se usa y por qué

Principio: **el modelo se ajusta al tipo de uso**. Se arranca con el más económico que resuelve bien la tarea del día
y se sube a uno más potente sólo cuando la complejidad o la habilidad requerida lo justifican. Los cambios de modelo
los decide la persona, no el propio asistente.

Los nombres de modelos y planes cambian con frecuencia: lo que sigue describe la configuración de **octubre de 2026**.

## Claude (coordinador)

| Uso | Modelo | Motivo |
|---|---|---|
| Trabajo diario, coordinación, revisión y publicación | Intermedio (Sonnet) | Equilibrio entre calidad y consumo de cupo para las tareas habituales |
| Tareas programadas livianas (chequeos previos) | Pequeño (Haiku) | No necesitan razonar mucho; ahorran cupo |
| Tareas programadas de resumen y operación | Intermedio | Suficiente y predecible |
| Diseño complejo, decisiones con dinero o con brokers | Más alto (Opus), a pedido | Aquí un error cuesta más que el consumo extra |

Hay umbrales de consumo semanal que la persona usa como política operativa: **60 %** (ahorro), **85 %** (crítico) y
**90 %** (reserva). El ejemplo de `src/route.py` sólo implementa la reserva; los otros dos no están en el código.

## Codex (builder)

- Corre con esfuerzo de razonamiento **medio**. Se había probado en alto y se bajó para cuidar el cupo semanal del plan.
- El modelo y el esfuerzo los cambia **sólo la persona**. Un cambio no autorizado (una tecla que cayó en un menú) ya
  ocurrió una vez y por eso es una regla.
- Se usa para escribir código y pruebas y para investigaciones con fuentes. Si un trabajo sale mal, se revisa con la
  persona y ella decide si se rehace y con qué modelo.

## OpenRouter / OpenCode (auxiliar económico)

### Por qué OpenRouter

- Un solo punto de acceso a muchos modelos: cambiar de modelo es cambiar una línea de configuración.
- Permite empezar con modelos gratuitos y pasar a pago por consumo sin cambiar de herramienta.
- Se cargaron **USD 10** de crédito. Según su documentación (consultada en octubre de 2026), haber comprado esos
  USD 10 sube el límite diario de los modelos **gratuitos** de 50 a 1.000 pedidos, aunque el saldo se gaste después.

### Cómo se eligió el modelo

Pruebas del 24/10/2026, con las mismas consignas, **muestra pequeña y sin repeticiones estadísticas**. El tiempo es el
de pared medido en la herramienta; el costo, el de la lista de precios del proveedor.

1. **Modelos gratuitos primero.** Se probaron varios. Los mejores respondían bien en unos 20 segundos, pero
   **fallaban con consignas largas** (errores 504 y tiempos agotados de 15 a 30 minutos).
2. **Dos modelos de pago por consumo:**

| Modelo | Costo aproximado por consulta | Tiempo de respuesta | Observación |
|---|---|---|---|
| DeepSeek V4 Flash | USD 0,00005 | 6 a 8 s | Respuestas directas |
| Qwen3.7 Flash | USD 0,00028 (unas 5,6 veces más) | 19 a 33 s | Gasta casi todo en "pensar" |

3. **Decisión:** DeepSeek V4 Flash: unas 5,6 veces más barato y, según los rangos medidos, entre 2,4 y 5,5 veces más
   rápido. No se evaluó la precisión con un puntaje numérico: se compararon respuestas a las mismas consignas.
4. **Escala de costo:** a USD 0,00005 por consulta, 1.000 consultas serían unos USD 0,05 (alrededor de USD 1,50 por
   30 días). Es un **techo teórico** si se usara ese volumen todos los días, no un uso medido, y los 1.000 pedidos
   del plan corresponden a los modelos gratuitos, no a este modelo de pago.
5. **Uso acotado:** sólo preguntas cortas y segunda opinión. No se le envía nada que identifique a alguien.

El modelo auxiliar liviano de la herramienta (para títulos y tareas mínimas) sigue siendo gratuito.

## A quién se delega cada cosa y por qué

| Participante | Recibe | Por qué |
|---|---|---|
| **Coordinador** | Datos reales, claves, infraestructura, revisión, pruebas y publicación | Tiene el acceso real y la confirmación humana |
| **Builder** | Código, pruebas e investigaciones con fuentes, con datos ficticios | Rinde mejor programando y cuida el cupo del coordinador |
| **Auxiliar** | Preguntas cortas, segunda opinión, pruebas como usuario externo | Muy barato y rápido para lo corto y público; no es confiable con textos largos |
| **Modelo propio** | Tareas cortas con documentos internos | Privacidad: el contenido no sale de la red; sin cargo por consulta |

Regla de desempate: **decide el riesgo del dato, no la dificultad**. Ver [`architecture.md`](architecture.md).
