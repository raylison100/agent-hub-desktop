#!/usr/bin/env bash
# Gera o sidecar do daemon para Linux: usa o repositorio de desenvolvimento quando existe e, fora dele, o comando agent-hub do pacote.
set -euo pipefail
TRIPLE="${1:-x86_64-unknown-linux-gnu}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/desktop/src-tauri/binaries/agent-hub-daemon-$TRIPLE"
mkdir -p "$(dirname "$OUT")"
cat > "$OUT" <<EOS
#!/usr/bin/env bash
REPO_CLI="$ROOT/daemon/dist/cli.js"
if [ -f "\$REPO_CLI" ] && command -v node >/dev/null 2>&1; then
  exec node "\$REPO_CLI" "\$@"
fi
if command -v agent-hub >/dev/null 2>&1; then
  exec agent-hub "\$@"
fi
for candidato in "\$HOME"/.nvm/versions/node/*/bin/agent-hub "\$HOME"/.npm-global/bin/agent-hub /usr/local/bin/agent-hub /usr/bin/agent-hub; do
  [ -x "\$candidato" ] && exec "\$candidato" "\$@"
done
echo "agent-hub nao encontrado: instale o pacote com npm install -g e rode agent-hub instalar" >&2
exit 1
EOS
chmod +x "$OUT"
echo "sidecar gerado em $OUT"
