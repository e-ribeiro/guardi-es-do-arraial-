#!/data/data/com.termux/files/usr/bin/bash
# Build do APK direto no celular Android, dentro do Termux + Ubuntu (proot-distro).
# Nao precisa de PC. Funciona em aparelhos arm64 (todos os dobraveis atuais).
#
# 1. Instale o Termux pelo F-Droid ou pelo GitHub (a versao da Play Store e antiga e nao serve).
# 2. No Termux:  curl -fsSL <url deste arquivo> -o termux-setup.sh && bash termux-setup.sh
#    (ou copie o arquivo para a pasta Downloads e rode: bash ~/storage/downloads/termux-setup.sh)
# 3. Depois, para compilar:  ubuntu-build /caminho/do/projeto
#
# O que faz: instala Ubuntu via proot-distro, JDK 21, Node, o Android SDK de linha de comando
# e um aapt2 compilado para arm64 (o do Google e so x86_64). Gradle, sdkmanager, d8 e apksigner
# sao Java e rodam em arm64 sem ajuste.
set -euo pipefail

PLATFORM=36
BUILD_TOOLS=36.0.0
CMDLINE_TOOLS=15859902

echo "== Termux: pacotes basicos"
pkg update -y
pkg install -y proot-distro curl unzip git android-tools
termux-setup-storage || true

if ! proot-distro list | grep -q "ubuntu.*installed"; then
  echo "== Instalando Ubuntu (proot-distro)"
  proot-distro install ubuntu
fi

echo "== Dentro do Ubuntu: JDK, Node, Android SDK"
proot-distro login ubuntu -- bash -euo pipefail -c "
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl unzip zip git openjdk-21-jdk-headless nodejs npm
export ANDROID_HOME=/opt/android-sdk
mkdir -p \$ANDROID_HOME/cmdline-tools
if [ ! -d \$ANDROID_HOME/cmdline-tools/latest ]; then
  cd \$ANDROID_HOME/cmdline-tools
  curl -fsSL -o tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS}_latest.zip
  unzip -q tools.zip && rm tools.zip && mv cmdline-tools latest
fi
export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin
yes | sdkmanager --licenses >/dev/null
sdkmanager 'platform-tools' 'platforms;android-${PLATFORM}' 'build-tools;${BUILD_TOOLS}'

# aapt2 para arm64 (projeto lzhiyong/android-sdk-tools)
mkdir -p /opt/arm64-tools && cd /opt/arm64-tools
if [ ! -x aapt2 ]; then
  curl -fsSL -o tools.zip https://github.com/lzhiyong/android-sdk-tools/releases/latest/download/android-sdk-tools-static-aarch64.zip
  unzip -qo tools.zip && rm tools.zip
  cp \$(find . -name aapt2 -type f | head -1) ./aapt2 && chmod +x ./aapt2
fi

cat > /etc/profile.d/android.sh <<'EOF'
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools
export GRADLE_OPTS='-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs=-Xmx2g'
EOF
"

echo "== Comando ubuntu-build"
cat > "$PREFIX/bin/ubuntu-build" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Uso: ubuntu-build /caminho/do/projeto [debug|release]
set -e
PROJ="$(realpath "${1:?informe a pasta do projeto}")"
TIPO="${2:-debug}"
proot-distro login ubuntu --bind "$PROJ:/work" -- bash -lc "
cd /work
grep -q aapt2FromMavenOverride android/gradle.properties 2>/dev/null || echo 'android.aapt2FromMavenOverride=/opt/arm64-tools/aapt2' >> android/gradle.properties
npm install --no-audit --no-fund
npx cap sync android
cd android && chmod +x gradlew && ./gradlew assemble${TIPO^} --no-daemon --console=plain
ls -la app/build/outputs/apk/${TIPO}/*.apk
"
echo
echo "Para instalar aqui mesmo: termux-open \"$PROJ/android/app/build/outputs/apk/$TIPO/app-$TIPO.apk\""
EOF
chmod +x "$PREFIX/bin/ubuntu-build"

echo
echo "Pronto. Exemplo:"
echo "  ubuntu-build ~/storage/downloads/arraial-app"
echo "O primeiro build baixa o Gradle e as dependencias (uns 500 MB); os seguintes sao rapidos."
echo "Memoria: feche outros apps durante o build; 2 GB de heap ja bastam para este projeto."
