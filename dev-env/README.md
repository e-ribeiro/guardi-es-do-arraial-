# Ambiente de build

Três formas de compilar o APK e rodar outros projetos Capacitor ou Android, sem instalar o Android Studio. Escolha pelo aparelho que você tem em mãos.

| Onde | Como | Arquivo |
|---|---|---|
| No próprio celular Android | Termux + Ubuntu (proot-distro) | `termux-setup.sh` |
| PC com Windows | WSL2 + Podman rodando o contêiner | `setup-wsl2.ps1` + `Containerfile` |
| Linux ou macOS | Podman ou Docker rodando o contêiner | `Containerfile` |

Em todos os casos o resultado é o mesmo: `android/app/build/outputs/apk/debug/app-debug.apk`.

## 1. No celular (Termux)

Instale o Termux pelo F-Droid ou pelo GitHub (a versão da Play Store está abandonada). Copie `termux-setup.sh` para a pasta Downloads do celular e, no Termux:

```
bash ~/storage/downloads/termux-setup.sh
```

O script instala Ubuntu dentro do Termux, JDK 21, Node, o SDK Android de linha de comando e um `aapt2` compilado para arm64 (o do Google só existe para x86_64; o Gradle passa a usar o arm64 pela propriedade `android.aapt2FromMavenOverride`). Depois:

```
ubuntu-build ~/storage/downloads/arraial-app
termux-open ~/storage/downloads/arraial-app/android/app/build/outputs/apk/debug/app-debug.apk
```

O primeiro build baixa Gradle e dependências (uns 500 MB) e leva alguns minutos; os seguintes levam menos de um minuto. Feche outros apps durante o build. Serve para qualquer projeto Gradle Android, não só este.

Limites: sem emulador (o APK instala direto no aparelho, que é o que interessa num dobrável) e sem Android Studio. Para editar código no celular, Acode ou o editor do Termux (nano, vim).

## 2. Windows (WSL2 + Podman)

No PowerShell como administrador:

```
powershell -ExecutionPolicy Bypass -File dev-env\setup-wsl2.ps1
```

Reinicie se for pedido. Abra o Ubuntu do menu Iniciar, copie o projeto para dentro do WSL (ex.: `~/projetos/arraial-app`; evite `/mnt/c`, é muito mais lento) e siga a seção 3.

Para instalar no celular por USB a partir do WSL: `winget install usbipd`, depois `usbipd list`, `usbipd bind --busid <id>` e `usbipd attach --wsl --busid <id>`. No Ubuntu, `adb devices` passa a ver o aparelho.

## 3. Contêiner (Podman ou Docker)

Dentro da pasta do projeto:

```
podman build -t arraial-build -f dev-env/Containerfile dev-env
podman run --rm -it -v "$PWD:/work" -v arraial-gradle:/root/.gradle arraial-build
```

(Com Docker, troque `podman` por `docker`. No SELinux, acrescente `:Z` ao fim de `"$PWD:/work"`.)

A imagem tem Ubuntu 24.04, JDK 21, Node 22, platform-tools, android-36 e build-tools 36.0.0, e pesa perto de 2 GB. O volume `arraial-gradle` guarda o cache do Gradle entre builds. O comando padrão compila o debug; para release:

```
podman run --rm -it -v "$PWD:/work" -v arraial-gradle:/root/.gradle arraial-build build-apk release
```

Para usar o contêiner com outro projeto, monte a pasta dele em `/work`. Para abrir um shell e rodar qualquer outra coisa (gradle, adb, npm):

```
podman run --rm -it -v "$PWD:/work" -v arraial-gradle:/root/.gradle arraial-build bash
```

## Versões fixadas

- cmdline-tools 15859902 (Google)
- platforms;android-36, build-tools;36.0.0 (as mesmas do `android/variables.gradle`)
- aapt2 arm64: lzhiyong/android-sdk-tools, release mais recente

Se o Capacitor subir a versão de `compileSdkVersion` em `variables.gradle`, ajuste `PLATFORM` e `BUILD_TOOLS` nos dois scripts.
