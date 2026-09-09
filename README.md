# agent-hub-desktop

Casca Tauri 2. Janela nativa, bandeja, inicio automatico e sidecar do daemon.
Embute o build de `../web`.

Estado: fase 0, sem codigo. Entra na fase 2. Ver
`../docs/adr/0002-tauri-com-daemon-sidecar.md`.

Estrutura prevista:

```
src-tauri/
  src/main.rs       janela, bandeja, sidecar
  tauri.conf.json   instaladores e permissoes
  binaries/         daemon empacotado por plataforma
```
