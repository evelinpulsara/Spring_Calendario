#!/usr/bin/env bash
# Instala Flutter en Vercel (Vercel no lo trae). Misma versión que en desarrollo.
set -euo pipefail
FLUTTER_VERSION="3.50.0"
if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git --branch "$FLUTTER_VERSION" --depth 1
fi
./flutter/bin/flutter config --enable-web --no-analytics
./flutter/bin/flutter pub get
