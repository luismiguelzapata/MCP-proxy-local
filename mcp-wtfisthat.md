# MCP Proxy Local

Este proyecto es un proxy local para el Model Context Protocol (MCP) de GitHub Copilot. Permite experimentar, aprender y depurar cómo interactúa Copilot (o cualquier cliente MCP) con el backend de GitHub, usando tu propio token personal (GITHUB_PAT).

## ¿Qué es MCP?

MCP es el protocolo que usa Copilot para enviar contexto del editor (archivos, cursor, historial de chat) y recibir respuestas generadas por el modelo (completions, explicaciones, documentación, etc).

## ¿Para qué sirve este proxy?

- Reenvía peticiones MCP desde tu editor a GitHub, añadiendo tu token de autenticación.
- Permite inspeccionar, modificar y registrar las peticiones/respuestas MCP.
- Facilita el aprendizaje y debugging de cómo funciona Copilot internamente.

---

## Instalación

1. Clona el repositorio y entra en la carpeta:

   ```zsh
   git clone https://github.com/luismiguelzapata/MCP-proxy-local.git
   cd MCP-proxy-local/mcp-proxy
   ```

2. Instala las dependencias:

   ```zsh
   npm install
   ```

3. Copia el archivo de ejemplo de entorno y agrega tu token:

   ```zsh
   cp .env.example .env
   # Edita .env y pon tu GITHUB_PAT
   ```

---

## Uso básico

1. Arranca el proxy en segundo plano:

   ```zsh
   nohup npm start > mcp-proxy.log 2>&1 & echo $! > mcp-proxy.pid
   ```

2. Verifica que está funcionando:

   ```zsh
   curl http://localhost:8080/health
   # Respuesta esperada: {"ok":true,"target":"https://api.githubcopilot.com/mcp"}
   ```

3. Configura tu editor (VS Code) para usar el MCP local:

   - En `.vscode/mcp.json` pon:
     ```jsonc
     {
       "servers": {
         "local": { "type": "http", "url": "http://localhost:8080/mcp/" }
       }
     }
     ```
   - Reinicia VS Code si es necesario.

---

## Ejemplo de petición MCP manual

Puedes enviar peticiones MCP directamente usando `curl`:

```zsh
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"type":"chat.completions","messages":[{"role":"user","content":"Explica qué es una función en Python"}]}' \
  http://localhost:8080/mcp/
```

La respuesta será un JSON generado por el modelo de Copilot.

---

## Logging avanzado (opcional)

Si quieres registrar los cuerpos de las peticiones MCP para análisis:

1. En `.env` agrega:
   ```
   LOG_MCP_BODIES=true
   ```
2. Reinicia el proxy.
3. Revisa el archivo `mcp-bodies.log` para ver los detalles de cada petición.

**Advertencia:** No actives este logging en entornos públicos ni compartas logs con datos sensibles.

---

## Parar el proxy

```zsh
kill $(cat mcp-proxy.pid)
rm mcp-proxy.pid
```

---

## Ejercicios recomendados

- Envía peticiones manuales y analiza las respuestas.
- Captura una petición real desde Copilot y compárala con una manual.
- Modifica el contexto (por ejemplo, el path del archivo) y observa cómo cambia la respuesta.

---

## Preguntas frecuentes

- **¿Puedo listar archivos de un repositorio usando MCP?**  
  No, MCP está diseñado para autocompletado, chat y análisis de código, no para operaciones CRUD sobre repositorios.

- **¿Es seguro usar mi GITHUB_PAT aquí?**  
  Sí, siempre que no compartas tu `.env` ni los logs generados.

---

¿Dudas o sugerencias? Abre un issue en el repositorio.
