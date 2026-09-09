#!/usr/bin/env bash
# Gera o sidecar do daemon para a plataforma indicada. Em Linux e macOS e um
# script que chama o Node instalado; empacotar como binario unico fica para
# quando o daemon virar SEA.
set -euo pipefail
TRIPLE="${1:-x86_64-unknown-linux-gnu}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/desktop/src-tauri/binaries/agent-hub-daemon-$TRIPLE"
mkdir -p "$(dirname "$OUT")"
cat > "$OUT" <<EOS
#!/usr/bin/env bash
exec node "$ROOT/daemon/dist/cli.js" "\$@"
EOS
chmod +x "$OUT"
echo "sidecar gerado em $OUT"
