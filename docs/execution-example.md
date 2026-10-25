# Ejemplos de ejecución (ficticios)

Tres recorridos inventados para este repositorio, que muestran qué decide cada participante. No son registros de un
sistema real.

## 1. Caso exitoso: pruebas para una función de redondeo

| Paso | Quién | Qué pasa |
|---|---|---|
| 1 | Persona | "Agregá pruebas a la función de redondeo." |
| 2 | Coordinador | Etiqueta `code`, `tests` → el enrutador recomienda **builder**; la consigna no incluye datos reales |
| 3 | Builder | Escribe 8 pruebas y un `RESUMEN.md` de 20 líneas |
| 4 | Coordinador | Corre las pruebas: 8 en verde; revisa que no haya datos reales en el código |
| 5 | Persona | Aprueba. El coordinador publica y anota "hecho por: builder; revisado por: coordinador" |

## 2. Caso fallido: el builder se traba

| Paso | Quién | Qué pasa |
|---|---|---|
| 1 | Coordinador | Envía una consigna; el script devuelve salida **2** ("ocupado") |
| 2 | Coordinador | Comprueba la pantalla: sigue trabajando. No lo da por fallido todavía |
| 3 | Coordinador | Pasan 10 minutos sin archivo con `<<FIN>>`: salida **4** (tiempo agotado) |
| 4 | Persona | Autoriza reiniciar la sesión (permiso ya otorgado para este caso) |
| 5 | Coordinador | Reenvía la consigna; esta vez termina |

Lección registrada en [`decisions.md`](decisions.md): una salida de error no siempre significa que el trabajo falló.

## 3. Aprobación: la herramienta pide un permiso

| Paso | Quién | Qué pasa |
|---|---|---|
| 1 | Builder | Pide permiso para ejecutar un comando |
| 2 | Script | Detecta el pedido y sale con **3**: "lo decide una persona" |
| 3 | Coordinador | **No** aprueba ni elige opciones de un menú; avisa a la persona |
| 4 | Persona | Revisa el comando y decide |
