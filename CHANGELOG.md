# Cambios

## 0.4.0
- `src/preflight.sh`: chequeo de prerrequisitos antes de instalar (arquitectura, sistema, memoria, disco, herramientas, red, hora, puertos), con pruebas; `docs/install.md` con la tabla de prerrequisitos, versiones usadas y espacio en disco (medido y estimado).
- Hardware objetivo: todo el laboratorio en una Raspberry Pi 4B de 8 GB (`docs/hardware.md`, diagrama 05), con el modelo
  propio en un equipo aparte.
- Monitoreo web de las consolas: `src/consoles.sh` (sesiones `tmux`) y `src/monitor.py` (página de sólo lectura que se
  refresca sola, con secretos tapados y pausa de emergencia), con pruebas.
- `docs/install.md`: manual de instalación para terceros (requisitos, pasos manuales y automáticos, HTTPS con Caddy,
  k3s, modelo propio) y `examples/` con la configuración general.

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
