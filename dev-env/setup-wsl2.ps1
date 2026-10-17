# Prepara um PC Windows 10/11 com WSL2 + Ubuntu + Podman para compilar o app.
# Execute no PowerShell como administrador:  powershell -ExecutionPolicy Bypass -File setup-wsl2.ps1
# Reinicie o Windows se for pedido e rode de novo.

$ErrorActionPreference = "Stop"

Write-Host "== Instalando WSL2 com Ubuntu"
wsl --install -d Ubuntu-24.04 --no-launch
wsl --set-default-version 2

Write-Host "== Configurando Podman dentro do Ubuntu"
$script = @'
set -e
sudo apt-get update
sudo apt-get install -y podman uidmap slirp4netns fuse-overlayfs git
# usbip para o adb enxergar o celular pelo USB (opcional; precisa do usbipd-win no Windows)
sudo apt-get install -y linux-tools-generic hwdata || true
echo
echo "Podman instalado: $(podman --version)"
'@
wsl -d Ubuntu-24.04 -- bash -c $script

Write-Host ""
Write-Host "Pronto. Abra o Ubuntu (menu Iniciar > Ubuntu 24.04) e, na pasta do projeto:"
Write-Host "  podman build -t arraial-build -f dev-env/Containerfile dev-env"
Write-Host "  podman run --rm -it -v `"`$PWD:/work`" -v arraial-gradle:/root/.gradle arraial-build"
Write-Host ""
Write-Host "Dica: copie o projeto para dentro do WSL (ex.: ~/projetos) em vez de usar /mnt/c; o Gradle fica varias vezes mais rapido."
Write-Host "Para instalar no celular por USB a partir do WSL, instale o usbipd-win: winget install usbipd"
