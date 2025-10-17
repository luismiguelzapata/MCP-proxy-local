# ¿Qué es el MCP (Model Context Protocol) y qué puedes hacer con él?

Este documento resume de forma práctica qué es el MCP (Model Context Protocol) que usa GitHub Copilot / Copilot Chat, qué capacidades ofrece, límites y ejemplos concretos para experimentar con tu proxy local.

## Resumen corto

MCP es un protocolo HTTP para que el editor (cliente) y un servicio de modelo (servidor de Copilot) intercambien "contexto" y mensajes del usuario para obtener respuestas generadas por un modelo. Piensa en MCP como la API que permite a Copilot pedir y recibir sugerencias, completar código, o mantener un chat con contexto del repositorio y del editor.

## ¿Qué tipo de cosas puedes hacer con MCP?

- Solicitar completions y sugerencias de código usando el contexto del archivo y del repositorio.
- Usar conversación tipo chat (turnos) donde el servidor mantiene o recibe el contexto del estado del editor.
- Enviar datos de telemetría o metadatos que el servidor pueda usar para priorizar o filtrar sugerencias.
- En algunos escenarios, enviar archivos o fragmentos de repositorio para que el modelo los use como contexto (limitados por políticas del proveedor).

Nota: GitHub administra qué features están disponibles y qué scopes del token necesitas. MCP es la capa de transporte; las capacidades reales dependen del servidor de backend (Copilot).

## Contrato mínimo (inputs/outputs)

- Input: peticiones HTTP POST con JSON que describen el tipo de request (p. ej. `complete`, `chat`, `annotation`), contexto (texto, path, repo metadata) y encabezados de autenticación.
- Output: JSON con la respuesta del modelo, incluyendo fragmentos de texto, tokens, metadatos y a veces instrucciones para el cliente.
- Errores: respuestas HTTP estándar (4xx/5xx) con JSON de error.

## Casos de uso prácticos (ejemplos)

1) Completado simple
- El cliente envía el contenido del archivo y la posición del cursor.
- El servidor responde con una sugerencia de código (posible multiple choices, rango y metadatos).

2) Chat / multi-turn
- El cliente incluye el historial de mensajes y el servidor produce el siguiente mensaje del asistente.

3) Análisis de repositorio
- El cliente puede enviar un resumen del repo o archivos específicos. El servidor puede devolver sugerencias que requieran comprensión del proyecto.

## Limitaciones y privacidad

- Tu PAT (token) autoriza solicitudes contra el servicio de GitHub; evita compartirlo.
- No todo el contenido que envies queda "privado": depende de la política del servicio. Evita enviar secretos o credenciales en texto plano.
- Hay límites de tamaño y rate limits; el servidor puede rechazar peticiones muy grandes.

## Ejemplos y comandos para experimentar con tu proxy local

Suponiendo que tienes el proxy corriendo en `http://localhost:8080/mcp/` (como lo configuramos):

1. Health (ya lo probaste):

```bash
curl -sS http://localhost:8080/health | jq .
```

2. Hacer una petición MCP de ejemplo (plantilla genérica)

```bash
curl -sS -X POST \
  -H "Content-Type: application/json" \
  --data '{"type":"chat.completions","messages":[{"role":"user","content":"Escribe una función en Python que invierta una cadena"}]}' \
  http://localhost:8080/mcp/
```

Nota: el body exacto depende del servidor MCP real; la estructura anterior es ilustrativa. Si el backend espera campos distintos, ajusta los nombres.

3. Inspeccionar logs del proxy para ver headers y requests

```bash
# ver los últimos logs
tail -n 200 mcp-proxy.log

# si ejecutas con npm start en primer plano, verás los logs en la terminal
```

## Cómo integrar con VS Code

- En `.vscode/mcp.json` añade o selecciona el servidor local: `http://localhost:8080/mcp/`.
- Reinicia la extensión (o VS Code) para que tome la nueva configuración.
- Usa Copilot / Copilot Chat normalmente; las peticiones saldrán por el proxy y podrás inspeccionarlas en `mcp-proxy.log`.

## Buenas prácticas

- Mantén el PAT en la variable de entorno del sistema o en un gestor de secretos. No lo pongas en `.env` versionado.
- Limita la exposición de tu proxy (por defecto escucha localhost). Si necesitas acceso remoto, agrega TLS y auth.
- Para debugging, aumenta el logging solo temporalmente.

## ¿Qué más puedo probar si quiero aprender?

- Añadir logging de bodies (cuidado con datos sensibles) para ver exactamente qué envía la extensión.
- Construir pequeñas peticiones desde curl o un script para ver respuestas del modelo.
- Crear un wrapper que convierta eventos del editor (archivo abierto, selección) en peticiones MCP para ver cómo cambia el comportamiento.

---

Si quieres, puedo:
- Añadir a este archivo ejemplos reales del body que envía Copilot (si conseguimos capturar uno) — yo puedo modificar el proxy para loguear bodies (opcional, con advertencias de seguridad).
- Añadir una sección con referencias a la spec MCP si quieres profundizar en los campos.


---

Documento generado automáticamente: `mcp-wtfisthat.md` en la raíz del proyecto.
