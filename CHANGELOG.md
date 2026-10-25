# Cambios

## 0.2.0 (borrador, sin publicar)
- Enrutador: las consultas públicas largas van al builder también con la reserva agotada; lo sin clasificar nunca va
  al auxiliar (se queda con el coordinador o espera); se quitaron del código los umbrales 60/85 que no se usaban.
- Pruebas del enrutador ampliadas a 11 (bordes de longitud, reserva y etiquetas vacías).
- Script de delegación: ruta absoluta, identificador único, marca explícita de fin (`<<FIN>>`) y prueba con un `tmux` simulado.
- Documentación: coordinador/auxiliar en vez de "local/free", alcance real de las garantías de privacidad, política de
  skills unificada, cifras de modelos con fecha y método, diagrama con modelo propio, Kubernetes y Ollama, ejemplos de ejecución.

## 0.1.0 (borrador, sin publicar)
- Primera versión.
