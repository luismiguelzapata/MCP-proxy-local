#!/usr/bin/env bash
set -euo pipefail

# Lista todos los repositorios de la cuenta autenticada y guarda repos-list.csv en la raíz del proyecto.
# Requiere: GITHUB_PAT en el entorno con permisos repo (si quieres incluir privados) o al menos 'repo:public_repo' para públicos.

OUT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/repos-list.csv"
TOKEN="${GITHUB_PAT:-}"
if [[ -z "$TOKEN" ]]; then
  echo "Error: variable GITHUB_PAT no definida. Exporta tu token y vuelve a intentar."
  exit 1
fi

# CSV header
printf 'id,name,full_name,private,html_url,description,language,stargazers_count,forks_count,created_at,updated_at\n' > "$OUT_FILE"

page=1
per_page=100
while true; do
  echo "Fetching page $page..."
  resp=$(curl -sS -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/user/repos?per_page=$per_page&page=$page")

  # Check empty
  repo_count=$(echo "$resp" | jq 'length')
  if [[ "$repo_count" -eq 0 ]]; then
    break
  fi

  echo "$resp" | jq -r '.[] | [ .id, .name, .full_name, (.private|tostring), .html_url, (.description // ""), (.language // ""), (.stargazers_count|tostring), (.forks_count|tostring), .created_at, .updated_at ] | @csv' >> "$OUT_FILE"

  # If less than per_page, finished
  if [[ "$repo_count" -lt $per_page ]]; then
    break
  fi

  page=$((page+1))
  sleep 0.2
done

echo "Saved repos to $OUT_FILE"
