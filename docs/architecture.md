# Arquitectura

## Diagrama general

```mermaid
flowchart TB
    P([Persona<br/>aprueba y decide modelos])

    subgraph NUBE["Servicios de terceros (nube)"]
        direction LR
        C["Coordinador<br/>Claude<br/><i>acceso real + revisión</i>"]
        B["Builder<br/>Codex<br/><i>sólo datos ficticios</i>"]
        A["Auxiliar<br/>OpenRouter / OpenCode<br/><i>sólo contenido público</i>"]
    end

    subgraph LAN["Red propia"]
        direction LR
        subgraph K8S["Clúster Kubernetes (k3s)"]
            W["Open WebUI<br/><i>interfaz de chat y documentos</i>"]
        end
        subgraph MS["Servidor de modelos"]
            O["Ollama"]
            M1["Gemma 4 26B-A4B<br/><i>respuestas</i>"]
            M2["Modelo de embeddings<br/><i>búsqueda en documentos</i>"]
        end
        FW{{"Firewall<br/>puerto del modelo sólo para la interfaz"}}
        SYS[("Sistemas reales<br/>servidores · paneles · bases")]
        W --> FW --> O
        O --- M1
        O --- M2
    end

    P -->|pide| C
    C -->|"consigna con datos ficticios (tmux)"| B
    C -->|"pregunta pública corta (tmux)"| A
    B -->|"código + resumen (archivo)"| C
    A -->|"respuesta (archivo)"| C
    C -->|"prueba y opera con acceso real"| SYS
    C -->|"qué hizo cada IA"| P
    P -->|"chat y consulta de documentos"| W

    classDef cloud fill:#EAF0FB,stroke:#3B5BA9,color:#091430;
    classDef local fill:#E8F5EE,stroke:#2E7D5B,color:#0B2A1D;
    classDef person fill:#FFF4DC,stroke:#9C6300,color:#3A2600;
    class C,B,A cloud;
    class W,O,M1,M2,FW,SYS local;
    class P person;
```

Azul: servicios de terceros. Verde: dentro de la red propia. Amarillo: la persona.

## Piezas

1. **Coordinador.** Lo usa la persona todos los días. Tiene acceso a los sistemas reales. Por regla, es el único que
   toca credenciales, finanzas, datos personales o infraestructura de producción. Es un servicio de terceros: "acceso
   real" no significa que lo que procesa se quede en la red propia.
2. **Builder.** Corre en su propia sesión `tmux`. Recibe consignas con datos inventados y devuelve código y un resumen
   de hasta 60 líneas.
3. **Auxiliar.** Otra sesión `tmux` con un modelo económico. Sólo preguntas públicas y cortas.
4. **Modelo propio.** Ollama sirve el modelo dentro de la red; Open WebUI, desplegado en Kubernetes, es el frente de
   chat y de consulta de documentos. Es el único camino donde el contenido no sale de la red.
5. **Persona.** Mira cualquier sesión en vivo, aprueba lo que se publica y es la única que cambia el modelo de un asistente.

## Flujo de una tarea

```mermaid
sequenceDiagram
    participant P as Persona
    participant C as Coordinador
    participant B as Builder
    P->>C: pedido
    C->>C: enrutar (src/route.py recomienda)
    C->>B: consigna con datos ficticios (tmux)
    B-->>C: código + RESUMEN.md
    C->>C: revisar y probar con datos reales aislados
    C->>P: resultado y qué hizo cada IA
    P->>C: aprobar
    C->>C: publicar y anotar en bitácora
```

## Límites de confianza

- Por regla, el builder y el auxiliar no ven credenciales ni datos reales. Esa regla se cumple con procedimiento
  (cómo se escribe cada consigna y la revisión humana); `route.py` sólo recomienda un destino.
- Los modelos gratuitos pueden conservar lo que reciben: por eso sólo reciben contenido público.
- Publicar es una acción del coordinador, siempre después de que la persona aprueba.

## Por qué archivos y no la pantalla

Una sesión de terminal corta los textos largos. Se le pide al asistente que escriba la respuesta completa en un
archivo que termina con una marca explícita (`<<FIN>>`) y se lee ese archivo. La pantalla se consulta sólo para dos
señales heurísticas: si la caja de entrada está libre y si hay un pedido de permiso.
