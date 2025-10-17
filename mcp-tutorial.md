# Tutorial práctico: aprender a usar e interactuar con MCP (Model Context Protocol)

Este tutorial está pensado para que, paso a paso, entiendas qué es MCP, cómo funciona en el ecosistema Copilot, y cómo experimentar con peticiones reales usando el proxy local que configuraste.

Contenido:
- Conceptos claves
- Estructura típica de requests/responses MCP
- Ejemplos prácticos con `curl` a través del proxy local
- Cómo activar logging seguro en el proxy (opcional)
- Capturar una petición real desde VS Code Copilot
- Ejercicios recomendados
- Seguridad y limpieza

---

## Conceptos claves

- MCP (Model Context Protocol) no es la API REST de GitHub. Es el protocolo que usan clientes (p. ej. VS Code + Copilot extension) y el servidor del modelo (Copilot) para intercambiar contexto y mensajes.
- MCP se implementa sobre HTTP(S): el cliente POSTea JSON con el tipo de petición y el contexto; el servidor responde con JSON que contiene la salida del modelo.
- Tu proxy local (`/mcp`) actúa como intermediario entre VS Code y el servidor de Copilot, permitiéndote inspeccionar o modificar peticiones.

## Estructura típica de una petición MCP

Las implementaciones concretas pueden variar, pero una petición de ejemplo (tipo chat/completion) tiene forma similar a:

```json
{
  "type": "chat.completions",
  "messages": [
    {"role": "user", "content": "Escribe una función en Python que invierta una cadena"}
  ],
  "metadata": {
    "editor": "vscode",
    "filePath": "src/main.py",
    "cursor": 123
  }
}
```

Respuesta de ejemplo:

```json
{
  "id": "abc123",
  "object": "chat.completion",
  "choices": [
    {"index": 0, "message": {"role": "assistant", "content": "def reverse(s):\n    return s[::-1]"}}
  ],
  "usage": {"prompt_tokens": 10, "completion_tokens": 20}
}
```

> Nota: el formato exacto (nombres de campos) depende de la implementación del servidor MCP. Lo anterior es una plantilla ilustrativa.

## Ejemplos prácticos: `curl` a través del proxy local

1) Health (ya disponible):

```bash
curl -sS http://localhost:8080/health | jq .
```

2) Petición de ejemplo (chat/completion) a través del proxy local (reemplaza el JSON según la estructura esperada):

```bash
curl -sS -X POST \
  -H "Content-Type: application/json" \
  --data '{"type":"chat.completions","messages":[{"role":"user","content":"Genera un README corto para un proyecto Node.js"}]}' \
  http://localhost:8080/mcp/
```

3) Si el backend espera otro campo (por ejemplo `model`, `prompt`), usa la estructura que corresponda. El proxy simplemente reenvía la petición y añade `Authorization: Bearer $GITHUB_PAT`.

## Habilitar logging seguro en el proxy (opcional)

Si quieres capturar bodies y headers de las peticiones MCP (útil para aprender exactamente qué envía Copilot), vamos a cambiar `mcp-proxy/index.js` para que, cuando `LOG_MCP_BODIES=true` esté en el entorno, el proxy haga `console.log` del body (o lo guarde en un archivo).

Importantísimo: los bodies pueden contener código, TODOs, credenciales o secretos. No actives este logging en entornos públicos ni dejes logs en repos públicos.

Si quieres, implemento esto ahora como:
- Lectura de `LOG_MCP_BODIES` desde `.env`.
- Si true, un middleware que captura req body (usando `express.json()` y un wrapper) y lo escribe a `mcp-proxy/mcp-bodies.log` con timestamp y headers selectos.

¿Quieres que lo implemente? (Responde "sí, implementa logging" o "no")

## Capturar una petición real desde VS Code Copilot

Pasos (asumiendo logging activado):
1. Habilita logging: en `mcp-proxy/.env` añade `LOG_MCP_BODIES=true` y reinicia el proxy.
2. Abre VS Code, asegúrate de que la MCP server config esté en `local` (`.vscode/mcp.json` apunta a `http://localhost:8080/mcp/`).
3. En VS Code, activa Copilot Chat o genera una sugerencia que haga una petición (p. ej. pide un fragmento de código que incluya el path del archivo abierto).
4. Revisa `mcp-proxy/mcp-bodies.log` para ver la petición completa y la respuesta.

## Ejercicios recomendados (para aprender)

1. Enviar una petición simple de completion por `curl` y comparar la respuesta con la que obtienes desde VS Code.
2. Capturar una petición real desde Copilot (con logging), analiza el JSON y reproduce la misma petición con `curl` directamente contra el backend a través del proxy.
3. Modifica el `metadata` en una petición manual para ver cómo cambia la respuesta (p. ej. cambia `filePath` o `cursor`).
4. Implementa un filtro en el proxy que redireccione ciertas peticiones a un stub local para ver diferencias.

## Seguridad y limpieza

- Cuando termines, deshabilita `LOG_MCP_BODIES` y borra `mcp-proxy/mcp-bodies.log` si contiene datos sensibles.
- Usa rotación de logs o permisos de archivo restringidos.
- Evita exponer el proxy a la red sin autenticación.

## Siguientes pasos que puedo hacer por ti

- Implementar el logging seguro en `mcp-proxy` (y un script para limpiar logs).
- Capturar una petición real y añadir un ejemplo real al `mcp-wtfisthat.md`.
- Añadir scripts que conviertan peticiones MCP capturadas a `curl`/`jq` reproducibles.

---

He creado `mcp-tutorial.md` en la raíz del proyecto. ¿Quieres que implemente ahora el logging seguro para que puedas capturar peticiones reales desde VS Code? (recuerda la advertencia de seguridad).