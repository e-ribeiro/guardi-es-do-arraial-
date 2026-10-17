#!/usr/bin/env bash
# Compila o APK de um projeto Capacitor montado em /work (ou no diretorio atual).
# Uso: build-apk [debug|release]
set -euo pipefail
TIPO="${1:-debug}"
cd "${PROJETO:-$PWD}"

if [ ! -f package.json ] || [ ! -d android ]; then
  echo "Monte a pasta do projeto (com package.json e android/) em /work." >&2
  exit 1
fi

echo "== npm install"
npm install --no-audit --no-fund

echo "== cap sync android"
npx cap sync android

echo "== gradle assemble${TIPO^}"
cd android
chmod +x ./gradlew
./gradlew "assemble${TIPO^}" --no-daemon --console=plain

SAIDA="app/build/outputs/apk/${TIPO}"
echo
echo "APK pronto em android/${SAIDA}/:"
ls -la "${SAIDA}"/*.apk
echo
echo "Instalar num aparelho conectado por USB (adb precisa enxergar o aparelho):"
echo "  adb install -r android/${SAIDA}/app-${TIPO}.apk"
