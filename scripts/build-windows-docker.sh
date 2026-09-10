#!/usr/bin/env bash
# Cruza-compila o desktop para Windows (instalador NSIS) dentro de um container
# Linux com cargo-xwin. No Windows nao ha sidecar: o app conecta no daemon que
# ja roda no WSL (tauri.windows.conf.json zera o externalBin).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IMAGE="agent-hub-tauri-windows"

if [ ! -d "$ROOT/web/dist" ]; then
  echo "web/dist ausente; rode pnpm build em web/ antes" >&2
  exit 1
fi

docker build -t agent-hub-tauri "$ROOT/desktop/docker"
docker build -t "$IMAGE" -f "$ROOT/desktop/docker/Dockerfile.windows" "$ROOT/desktop/docker"

docker run --rm \
  -v "$ROOT":/work \
  -v agent-hub-cargo-registry:/usr/local/cargo/registry \
  -v agent-hub-cargo-target:/work/desktop/src-tauri/target \
  -v agent-hub-xwin-cache:/root/.cache/cargo-xwin \
  -w /work/desktop \
  "$IMAGE" bash -c '
    set -e
    tauri icon ../web/public/icon.svg
    tauri build --runner cargo-xwin --target x86_64-pc-windows-msvc --bundles nsis --config "{\"build\":{\"beforeBuildCommand\":\"\"}}"
    mkdir -p dist-bundle
    find src-tauri/target/x86_64-pc-windows-msvc/release/bundle -type f \( -name "*.exe" -o -name "*.msi" \) -exec cp {} dist-bundle/ \;
    cp src-tauri/target/x86_64-pc-windows-msvc/release/agent-hub-desktop.exe dist-bundle/ 2>/dev/null || true
    ls -la dist-bundle
  '
