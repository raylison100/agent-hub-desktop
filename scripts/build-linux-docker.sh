#!/usr/bin/env bash
# Compila o desktop para Linux dentro de um container com Rust e as
# dependencias do Tauri. Saida em desktop/dist-bundle.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IMAGE="agent-hub-tauri"

if [ ! -d "$ROOT/web/dist" ]; then
  echo "web/dist ausente; rode pnpm build em web/ antes" >&2
  exit 1
fi

docker build -t "$IMAGE" "$ROOT/desktop/docker"
"$ROOT/desktop/scripts/make-sidecar.sh" x86_64-unknown-linux-gnu

docker run --rm \
  -v "$ROOT":/work \
  -v agent-hub-cargo-registry:/usr/local/cargo/registry \
  -v agent-hub-cargo-target:/work/desktop/src-tauri/target \
  -w /work/desktop \
  "$IMAGE" bash -c '
    set -e
    tauri icon ../web/public/icon.svg
    tauri build --config "{\"build\":{\"beforeBuildCommand\":\"\"}}"
    rm -rf dist-bundle && mkdir -p dist-bundle
    find src-tauri/target/release/bundle -maxdepth 2 -type f \( -name "*.deb" -o -name "*.rpm" -o -name "*.AppImage" \) -exec cp {} dist-bundle/ \;
    ls -la dist-bundle
  '
echo "AppImage exige FUSE no host do build; sem ele ficam apenas deb e rpm."
