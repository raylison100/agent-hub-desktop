#!/usr/bin/env bash
# Cruza-compila o desktop para Windows (instalador NSIS) dentro de um container
# Linux com cargo-xwin. No Windows nao ha sidecar: o app conecta no daemon que
# ja roda no WSL (tauri.windows.conf.json zera o externalBin).
# Com a chave de assinatura em ~/.tauri/agent-hub-atualizacao.key (ou em CHAVE_DE_ATUALIZACAO),
# gera tambem a assinatura que o app confere antes de instalar uma versao nova.
# CONFIG_EXTRA recebe um JSON mesclado na configuracao do Tauri.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IMAGE="agent-hub-tauri-windows"
CHAVE="${CHAVE_DE_ATUALIZACAO:-$HOME/.tauri/agent-hub-atualizacao.key}"
[ -n "${CONFIG_EXTRA:-}" ] || CONFIG_EXTRA='{}'

if [ ! -d "$ROOT/web/dist" ]; then
  echo "web/dist ausente; rode pnpm build em web/ antes" >&2
  exit 1
fi

docker build -t agent-hub-tauri "$ROOT/desktop/docker"
docker build -t "$IMAGE" -f "$ROOT/desktop/docker/Dockerfile.windows" "$ROOT/desktop/docker"

ASSINATURA=()
ARTEFATOS='{"bundle":{"createUpdaterArtifacts":false}}'
if [ -f "$CHAVE" ]; then
  ASSINATURA=(-v "$CHAVE":/chave/atualizacao.key:ro -e TAURI_SIGNING_PRIVATE_KEY=/chave/atualizacao.key -e TAURI_SIGNING_PRIVATE_KEY_PASSWORD=)
  ARTEFATOS='{"bundle":{"createUpdaterArtifacts":true}}'
else
  echo "sem chave de assinatura em $CHAVE: o instalador sai sem assinatura de atualizacao" >&2
fi

docker run --rm \
  -v "$ROOT":/work \
  -v agent-hub-cargo-registry:/usr/local/cargo/registry \
  -v agent-hub-cargo-target:/work/desktop/src-tauri/target \
  -v agent-hub-xwin-cache:/root/.cache/cargo-xwin \
  "${ASSINATURA[@]}" \
  -e ARTEFATOS="$ARTEFATOS" \
  -e CONFIG_EXTRA="$CONFIG_EXTRA" \
  -w /work/desktop \
  "$IMAGE" bash -c '
    set -e
    tauri icon ../web/public/icon.svg
    rm -rf src-tauri/target/x86_64-pc-windows-msvc/release/bundle/nsis
    tauri build --runner cargo-xwin --target x86_64-pc-windows-msvc --bundles nsis \
      --config "{\"build\":{\"beforeBuildCommand\":\"\"}}" --config "$ARTEFATOS" --config "$CONFIG_EXTRA"
    rm -rf dist-bundle
    mkdir -p dist-bundle
    find src-tauri/target/x86_64-pc-windows-msvc/release/bundle -type f \( -name "*.exe" -o -name "*.msi" -o -name "*.sig" \) -exec cp {} dist-bundle/ \;
    cp src-tauri/target/x86_64-pc-windows-msvc/release/agent-hub-desktop.exe dist-bundle/ 2>/dev/null || true
    ls -la dist-bundle
  '
