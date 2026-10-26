# Manual de instalación: todo en una Raspberry Pi 4B

Guía para que otra persona arme el mismo laboratorio **en una sola Raspberry Pi 4B de 8 GB** (más un equipo aparte si
quiere el modelo propio). Los pasos marcados con 🧑 **los hace una persona** porque requieren una cuenta, un pago, un
inicio de sesión en el navegador o una decisión; el resto se puede ejecutar o automatizar.

> Los comandos de instalación de cada herramienta cambian con el tiempo: usá siempre la documentación oficial de
> cada una y tomá esta guía como el orden y la configuración. Ver en el punto 1 qué se probó y qué no.

## 1. Requisitos previos

### Revisalos antes de empezar
Antes de instalar nada, ejecutá el chequeo de prerrequisitos. **No cambia nada en el sistema**: sólo lee y te dice qué
falta (`FALTA`) y qué conviene mirar (`aviso`). Si hay algún `FALTA`, resolvelo y volvé a ejecutarlo; recién con
"Listo para instalar" seguí con el paso 2.

```bash
git clone <URL> ~/ai-operations-lab        # o descargá el repositorio como .zip
bash ~/ai-operations-lab/src/preflight.sh
```

Para correrlo hacen falta `bash`, `git` (o el .zip), `curl` y `python3`, que vienen con los sistemas de abajo. El resto de
lo que revisa se instala en el paso 2.

### Lista de prerrequisitos

| # | Requisito | Mínimo | Qué lo revisa | Cómo se resuelve |
|---|---|---|---|---|
| 1 | Placa | Raspberry Pi 4B de **8 GB** | memoria ≥ 7000 MB | no hay alternativa con menos memoria |
| 2 | Arquitectura | **64 bits** (`aarch64`/`arm64`) | `uname -m` | grabar el sistema de 64 bits |
| 3 | Sistema operativo | **Raspberry Pi OS Lite 64 bits** (Debian 12 o 13) o **Ubuntu Server 24.04 LTS arm64** | `/etc/os-release` | Imager oficial 🧑 |
| 4 | Disco libre | **20 GB** en `/` (recomendado: 32 GB o más; ver abajo) | `df` | SSD por USB 3 o tarjeta de 64 GB |
| 5 | Usuario | normal, con `sudo` y SSH (no root) | `id`, `sudo` | paso 2.1 |
| 6 | Herramientas base | `tmux`, `git`, `curl`, `python3` 3.9 o superior | `command -v` | paso 2.3 |
| 7 | Node.js | 20 o superior (LTS) | `node -v` | paso 2.4 |
| 8 | Red | salida a Internet y resolución de nombres | `getent hosts` | cable de red |
| 9 | Hora | sincronizada (HTTPS la necesita) | `timedatectl` | `sudo timedatectl set-ntp true` |
| 10 | Puertos 80 y 443 | libres en la placa | `ss -ltn` | detener el otro servicio que los use |
| 11 | Cuentas 🧑 | Claude Code, Codex y OpenRouter (con **tope de gasto** y privacidad revisada) | no se puede automatizar | suscripciones propias |
| 12 | Dominio 🧑 | un dominio o subdominio (sirve un DNS dinámico gratuito) y, para acceder desde fuera, **puertos 80 y 443 redirigidos** en el router | no se puede automatizar | proveedor de DNS y router |
| 13 | Modelo propio (opcional) | equipo aparte con 32 GB de RAM o más, en la misma red | no se puede automatizar | ver [`local-model.md`](local-model.md) |

Los puntos 11 y 12 no los puede verificar el script: son decisiones y trámites tuyos.

### Con qué versiones se escribió esta guía
Salen del equipo real del autor (Raspberry Pi 4B, Raspberry Pi OS basado en **Debian 13 "trixie"**, arm64, kernel 6.x):
**Node.js 24.19**, **tmux 3.5a**, **Python 3.13**, **k3s v1.35**. Caddy se usa desde su repositorio oficial; fijá la
versión que instales y anotala. Con versiones muy distintas los pasos pueden variar: la documentación oficial manda.

### Espacio en disco
- **Medido** en una de las placas del autor (tarjeta de 58 GB, sistema y k3s con Open WebUI): 25 GB usados en total; los datos
  de k3s ocupaban unos 225 MB, sin contar las imágenes de contenedores.
- **Estimado** para esta guía: sistema 3–5 GB, k3s y la imagen de Open WebUI 3–5 GB, herramientas de IA y Node 1–2 GB,
  repositorio y bitácoras 1–2 GB. Por eso el mínimo es 20 GB y se recomiendan 32 GB o más. Si además guardás copias de seguridad
  o documentos en la placa, sumalos.

> Esta guía describe una instalación **todo en una placa**, pero el autor hoy la tiene repartida en dos Raspberry. El chequeo,
> los scripts y las pruebas sí se ejecutaron; lo que **no** se hizo es una instalación completa de punta a punta en una sola
> placa con todo corriendo junto. Si la hacés, medí la memoria y contanos qué ajustar (ver [`limitations.md`](limitations.md)).

## 2. Preparar la placa

1. 🧑 Grabar el sistema en el SSD (o la tarjeta) con el Imager oficial; habilitar SSH y crear el usuario.
2. Actualizar: `sudo apt update && sudo apt full-upgrade -y`.
3. Instalar lo base: `sudo apt install -y tmux git python3 curl ufw`.
4. Instalar Node.js (versión LTS) desde el repositorio oficial de Node, porque las herramientas de IA lo necesitan.
5. Firewall: `sudo ufw default deny incoming && sudo ufw allow ssh && sudo ufw allow 80,443/tcp && sudo ufw enable`.
6. Clonar este repositorio: `git clone <URL> ~/ai-operations-lab`.
7. Copiar la configuración: `mkdir -p ~/.config/ai-lab && cp ~/ai-operations-lab/examples/ai-lab.env.example ~/.config/ai-lab/ai-lab.env` y editarla (usuario, dominio, sesiones).

## 3. Instalar los tres asistentes

1. Instalar cada herramienta siguiendo su documentación oficial.
2. 🧑 Iniciar sesión en cada una (abre el navegador o pide un código). **Las claves las guarda cada herramienta; no las pongas en `ai-lab.env`.**
3. Recomendado: crear un usuario de Linux por asistente (`sudo adduser --disabled-password svc-builder`) e iniciar
   sesión en cada herramienta con el usuario que corresponda, para que no compartan archivos ni credenciales.
4. Levantar las consolas en `tmux`:
   ```bash
   set -a; . ~/.config/ai-lab/ai-lab.env; set +a
   ~/ai-operations-lab/src/consoles.sh start
   tmux attach -t claude     # para salir sin cerrar: Ctrl+B, luego D
   ```
5. Que arranquen solas: copiar [`examples/systemd/ai-consoles.service`](../examples/systemd/ai-consoles.service) a
   `~/.config/systemd/user/`, ejecutar `systemctl --user enable --now ai-consoles` y `sudo loginctl enable-linger $USER`.
6. Probar la delegación con [`src/delegate.sh`](../src/delegate.sh) (ver [`getting-started.md`](getting-started.md)); hay que ajustar `IDLE_PATTERN` a la herramienta.

## 4. Publicar con HTTPS (Caddy)

1. Instalar Caddy desde su repositorio oficial (paquete para Debian/Ubuntu).
2. Generar el hash de la contraseña del monitoreo: `caddy hash-password` y pegarlo en `ai-lab.env` (`MONITOR_PASS_HASH`).
3. Copiar [`examples/caddy/Caddyfile`](../examples/caddy/Caddyfile) a `/etc/caddy/Caddyfile` y hacer que el servicio lea las
   variables (`sudo systemctl edit caddy` → `[Service]` / `EnvironmentFile=/home/USUARIO/.config/ai-lab/ai-lab.env`).
4. `sudo caddy validate --config /etc/caddy/Caddyfile && sudo systemctl reload caddy`.
5. Caddy obtiene y renueva solo el **certificado HTTPS** de Let's Encrypt. Requiere que el dominio apunte a tu IP y que
   los puertos 80/443 lleguen a la placa. **Sólo en la red local:** usá un nombre interno y la CA interna de Caddy
   (`tls internal`), y confiá en ese certificado en tus dispositivos.

## 5. Monitoreo web

1. Crear la carpeta de salida: `sudo mkdir -p /var/lib/ai-lab/monitor && sudo chown $USER /var/lib/ai-lab/monitor`.
2. Copiar [`ai-monitor.service`](../examples/systemd/ai-monitor.service) y [`ai-monitor.timer`](../examples/systemd/ai-monitor.timer) a
   `~/.config/systemd/user/` y ejecutar `systemctl --user enable --now ai-monitor.timer`.
3. 🧑 Abrir `https://TU_DOMINIO/monitor/`, entrar con el usuario y la contraseña y comprobar que se ven las consolas.
4. Pausa de emergencia: `touch ~/.config/ai-lab/monitor.pause`. Detalles en [`monitoring.md`](monitoring.md).

## 6. Open WebUI en k3s

1. Instalar k3s con el instalador oficial (una sola máquina) y comprobar `sudo k3s kubectl get nodes`.
2. Editar [`examples/k8s/open-webui.yaml`](../examples/k8s/open-webui.yaml): la dirección de Ollama (`OLLAMA_BASE_URL`) y **fijar la versión de la imagen**.
3. `sudo k3s kubectl apply -f examples/k8s/open-webui.yaml`. Queda en el puerto 30080 de la propia placa y Caddy lo publica.
4. 🧑 La primera cuenta que se registra es la administradora: crearla y dejar el registro cerrado (el manifiesto ya lo desactiva).

## 7. Modelo propio (opcional, en el otro equipo) 🧑

1. Instalar Ollama y bajar los modelos (ver [`local-model.md`](local-model.md)). Hacer que escuche en la red local.
2. **Firewall del equipo del modelo:** permitir su puerto (11434) sólo desde la IP de la Raspberry. Nunca publicarlo a Internet.
3. Poner esa dirección en `OLLAMA_BASE_URL` y comprobar desde Open WebUI que lista los modelos.

## 8. Verificación final

```bash
python3 -m unittest discover -s tests -v   # 21 pruebas: enrutador y monitoreo
bash tests/test_delegate.sh                # delegación con un tmux simulado
bash tests/test_consoles.sh                # lanzador de consolas con un tmux simulado
bash tests/test_preflight.sh               # chequeo de prerrequisitos con datos simulados
```

Y a mano: las tres consolas visibles en `tmux ls`, la página `/monitor/` actualizándose con contraseña, HTTPS válido y
Open WebUI respondiendo. Medí la memoria (`free -h`) con todo en marcha y comparala con [`hardware.md`](hardware.md).

## 9. Qué sigue siendo manual (y debe serlo)

- Iniciar sesión en cada asistente y mantener las suscripciones.
- Decidir qué se delega a cada uno: la regla es por riesgo del dato (ver [`architecture.md`](architecture.md)).
- Aprobar todo lo que se publica hacia afuera y cambiar los modelos.
- Renovar o revisar claves, y las copias de seguridad.
