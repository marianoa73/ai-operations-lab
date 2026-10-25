"""Enrutador de tareas entre tres asistentes de IA.

Esta función RECOMIENDA un destino a partir de etiquetas que asigna una persona o el coordinador.
No detecta secretos, no anonimiza datos y no pide aprobaciones: esas son prácticas externas (ver docs/limitations.md).

Regla central: el riesgo del dato define el destino, no la dificultad de la tarea.
  - coordinator: toca algo sensible o no está clasificado; lo resuelve quien tiene el acceso real y la confirmación humana.
  - builder:     código y pruebas, sólo con datos ficticios; también las consultas públicas largas.
  - auxiliary:   preguntas públicas y cortas (modelo económico).
  - queue:       tarea sin clasificar con la reserva de cupo agotada; espera a la persona.
"""
from dataclasses import dataclass

SENSITIVE_TAGS = {"credentials", "finance", "personal-data", "production", "infra"}
CODE_TAGS = {"code", "tests", "refactor", "review-code"}
PUBLIC_TAGS = {"research", "second-opinion", "naming", "translation"}

# Una consulta pública de más de LONG_PROMPT_CHARS caracteres no va al auxiliar (agotaba el tiempo en las pruebas).
LONG_PROMPT_CHARS = 2000

# Reserva de cupo del coordinador (porcentaje semanal). Es lo único del consumo que esta función aplica.
# Los umbrales de 60 % (ahorro) y 85 % (crítico) son política operativa de la persona y NO están implementados aquí.
RESERVE_AT = 90


@dataclass(frozen=True)
class Task:
    title: str
    tags: frozenset
    prompt_chars: int = 0
    urgent: bool = False


@dataclass(frozen=True)
class Route:
    assistant: str  # "coordinator" | "builder" | "auxiliary" | "queue"
    reason: str
    needs_fictional_data: bool = False


def route(task: Task, usage_pct: float = 0.0) -> Route:
    tags = set(task.tags)

    if tags & SENSITIVE_TAGS:
        if tags & CODE_TAGS:
            # Se puede programar lo sensible si el builder sólo ve datos inventados.
            return Route("builder", "código sobre un tema sensible: sólo con datos ficticios", True)
        return Route("coordinator", "toca algo sensible: lo ejecuta quien tiene el acceso real")

    if tags & CODE_TAGS:
        return Route("builder", "código o pruebas sin datos reales")

    if tags & PUBLIC_TAGS:
        if task.prompt_chars > LONG_PROMPT_CHARS:
            return Route("builder", "consulta pública larga: el auxiliar suele agotar el tiempo")
        return Route("auxiliary", "pregunta pública y corta")

    # Sin etiquetas conocidas: nunca sale del coordinador (no se sabe si es público).
    if usage_pct >= RESERVE_AT and not task.urgent:
        return Route("queue", "sin clasificar y con la reserva de cupo agotada: espera a la persona")
    return Route("coordinator", "sin clasificar: se queda donde hay revisión humana")
