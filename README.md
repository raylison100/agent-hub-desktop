# agent-hub-desktop

Casca Tauri 2. Janela nativa, bandeja com Abrir e Sair, fechar a janela
esconde em vez de encerrar, e o daemon sobe como sidecar quando nao ha um
respondendo em `127.0.0.1:47311`. Embute o build de `../web`.

Estado: fase 2, esqueleto escrito e nao compilado. A maquina de
desenvolvimento nao tinha Rust no WSL. Ver
`../docs/adr/0002-tauri-com-daemon-sidecar.md`.

## Requisitos

- Rust estavel e as dependencias do Tauri 2 para o sistema
  (`https://tauri.app/start/prerequisites/`).
- `pnpm add -D @tauri-apps/cli` neste repositorio.
- `../web` instalado. O `beforeBuildCommand` gera `../web/dist`.
- O daemon empacotado como binario unico em
  `src-tauri/binaries/agent-hub-daemon-<target-triple>` (por exemplo
  `agent-hub-daemon-x86_64-pc-windows-msvc.exe`). Gere com
  `node --experimental-sea-config` ou `pkg` a partir de `../daemon/dist`.
- Icones em `src-tauri/icons/` gerados com `pnpm tauri icon ../web/public/icon.svg`.

## Comandos

```bash
pnpm install
pnpm tauri icon ../web/public/icon.svg
pnpm dev
pnpm build
```

`pnpm build` gera MSI e NSIS no Windows, DMG no macOS, AppImage e deb no
Linux.

## Estrutura

```
src-tauri/
  Cargo.toml
  tauri.conf.json          janela, sidecar externo, bundle
  capabilities/default.json permissoes: abrir links, executar o sidecar
  src/main.rs
  src/lib.rs               bandeja, esconder ao fechar, subir e parar o sidecar
```

Se o sidecar nao subir em alguma plataforma, instale o daemon como servico
do sistema. A interface conecta em `127.0.0.1:47311` de qualquer forma.
