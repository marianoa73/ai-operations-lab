# Decisiones y errores

## Decisiones

| Decisión | Alternativa descartada | Motivo |
|---|---|---|
| Enrutar por riesgo del dato | Enrutar por dificultad | Lo difícil se puede delegar con datos inventados; lo sensible no se delega aunque sea fácil |
| Lo sin clasificar se queda con el coordinador (o espera) | Mandarlo al auxiliar por defecto | Si no se sabe que es público, no sale |
| Respuesta a un archivo con marca de fin | Leer la pantalla del terminal | Los textos largos se cortan, y un archivo a medio escribir no debe leerse como completo |
| Reinicio permitido si el asistente está trabado | Esperar siempre | Es una sesión de herramienta, no un sistema crítico; la persona lo autorizó |
| La persona elige el modelo | Que el asistente lo cambie | Un cambio automático rompe la confianza en el costo y la calidad |
| Modelo según el uso; el más alto sólo si hace falta | Un único modelo potente para todo | Cuida el cupo y el costo sin perder calidad donde importa (ver models.md) |
| Elegir el modelo propio midiendo en el equipo | Quedarse con la recomendación de la investigación | La medición eligió un modelo grande y más rápido que lo esperado (ver local-model.md) |
| Preferir skills oficiales; propias sólo para un uso puntual y documentado; evitar las de terceros (sólo tras un control exhaustivo) | Instalar skills de terceros libremente | Reduce el riesgo de código no revisado y mantiene el esquema fácil de explicar y auditar |
| Umbrales de consumo 60/85/90 % como política de la persona | Sin umbrales | Evita quedarse sin cupo a mitad de semana; el ejemplo sólo implementa la reserva (90 %) |
| Resumen de hasta 60 líneas | Resumen mínimo | Lo complejo necesita explicación |

## Qué falló y cómo se corrigió

1. **Una tecla perdida cambió el modelo.** Un mensaje corto de prueba llegó a un menú de selección de modelo y lo
   respondió. Regla nueva: el coordinador nunca elige opciones de un menú ni aprueba permisos.
2. **Falsas alarmas.** Códigos de salida de "ocupado" o "tiempo agotado" aparecían aunque el builder seguía trabajando.
   Ahora se comprueba la pantalla antes de dar una tarea por fallida.
3. **El auxiliar con consignas largas.** Los modelos gratuitos fallaban con timeouts. Los pedidos públicos largos van al builder.
4. **No enterarse de que un trabajo había terminado.** Se lanzaba en segundo plano sin un mecanismo de espera. Ahora
   cada trabajo largo se lanza con una espera que avisa al terminar.
5. **Tareas programadas sin variables de entorno de usuario.** Un script de cron no encontraba el bus de `systemd --user`
   y el reinicio nocturno fallaba en silencio. Se agregaron las dos variables que faltaban.
6. **Hallazgos de una revisión externa del propio repositorio** (hecha por otro asistente de IA y corregida en la versión 0.2.0):
   una consulta pública larga con la reserva agotada se enrutaba al auxiliar, lo no clasificado salía al auxiliar,
   dos umbrales declarados no se usaban, el script de delegación usaba rutas relativas y consideraba "terminado" a
   cualquier archivo no vacío, y varias frases de privacidad prometían más de lo que el código garantiza.
