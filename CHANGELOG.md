# Cambios

## 0.3.0
- Diagramas rehechos a mano (SVG y PNG de alta resolución en `docs/assets/`), con el flujo de arriba hacia abajo: servicios de terceros, persona y red propia.
- Se agrega el certificado HTTPS con Caddy entre la persona y Kubernetes, y el ciclo de verificación por modelos externos
  (funcionamiento, visibilidad y seguridad) antes de aprobar.

## 0.2.0
- Enrutador: las consultas públicas largas van al builder también con la reserva agotada; lo sin clasificar nunca va
  al auxiliar (se queda con el coordinador o espera); se quitaron del código los umbrales 60/85 que no se usaban.
- Pruebas del enrutador ampliadas a 11 (bordes de longitud, reserva y etiquetas vacías).
- Script de delegación: ruta absoluta, identificador único, marca explícita de fin (`<<FIN>>`) y prueba con un `tmux` simulado.
- Documentación: coordinador/auxiliar en vez de "local/free", alcance real de las garantías de privacidad, política de
  skills unificada, cifras de modelos con fecha y método, modelo propio, ejemplos de ejecución.

## 0.1.0
- Primera versión pública.
