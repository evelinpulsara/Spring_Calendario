#!/usr/bin/env bash
# Compila la app web. API_URL es la dirección del backend (variable de entorno en Vercel).
set -euo pipefail
if [ -z "${API_URL:-}" ]; then
  echo "Falta la variable API_URL en Vercel (ej: https://spring-backend.onrender.com)" >&2
  exit 1
fi
./flutter/bin/flutter build web --release --dart-define=API_URL="$API_URL"
