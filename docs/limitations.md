# Límites

- Es **una persona** operando su propio laboratorio: no hay equipo, SLA ni carga de producción de clientes.
- La muestra de código es pequeña a propósito. El sistema completo no se publica.
- `route()` recomienda un destino a partir de etiquetas: no detecta secretos, no anonimiza y no pide aprobaciones. Si una
  etiqueta es incorrecta, la recomendación también.
- El coordinador y los otros asistentes son servicios de terceros. La separación de datos depende de procedimientos y
  de la revisión humana; sólo el modelo propio procesa sin enviar datos fuera de la red.
- No hay métricas de productividad ni ahorro medido. Las cifras de cupo son umbrales de configuración y los costos son
  estimaciones a partir del precio por consulta.
- Las comparaciones de modelos son de octubre de 2026, con muestras pequeñas y sin repeticiones. Los modelos y los
  planes de cada proveedor cambian.
- El modelo propio se evaluó con la velocidad de cinco modelos y un único caso de diagnóstico; no hay una batería de
  calidad. Faltan registrar cuantizaciones y versiones exactas.
- `delegate.sh` depende de dos señales heurísticas de pantalla (caja libre y pedido de permiso); si la herramienta
  cambia su interfaz, hay que ajustar `IDLE_PATTERN` y las expresiones. Se probó con un `tmux` simulado, no con cada herramienta real.
- La instalación completa en **una sola Raspberry Pi 4B de 8 GB** es el objetivo de diseño: el presupuesto de memoria es
  una estimación y falta medirlo con todo en marcha en una sola placa. [`install.md`](install.md) es una guía de orden y
  configuración, no un instalador probado de punta a punta; el manifiesto de Kubernetes sólo se validó como YAML.
- La página de monitoreo tapa secretos por patrones; no detecta datos personales ni secretos con formato desconocido.
  Debe ir detrás de HTTPS y contraseña.
- Política de skills: se prefieren las oficiales; una propia se construye para un uso puntual; las de terceros se
  evitan y sólo se instalan tras un control exhaustivo.
- El esquema depende de que la persona revise. Sin esa revisión, no es un esquema seguro.
