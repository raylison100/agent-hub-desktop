# agent-hub-desktop

App de desktop do Agent Hub em Tauri 2, para Windows e Linux. E uma janela
nativa com bandeja em volta da mesma interface do
[agent-hub-web](https://github.com/raylison100/agent-hub-web): fechar a janela
esconde o app, e o menu da bandeja tem Abrir e Sair.

- **Linux**: quando nao ha daemon respondendo em `127.0.0.1:47311`, o app sobe
  o daemon como sidecar.
- **Windows**: nao ha sidecar. O app conecta no daemon que roda no WSL, que o
  WSL2 expoe em `127.0.0.1:47311` no Windows. A conexao e automatica.

## Gerar os instaladores

Os builds rodam em Docker, sem precisar de Rust na maquina. Da raiz do
[agent-hub](https://github.com/raylison100/agent-hub):

```bash
make windows
make linux
```

Saem em `dist-bundle/`: instalador NSIS e executavel portatil para Windows
(compilado com `cargo-xwin`), `.deb` e `.rpm` para Linux. Os binarios nao sao
assinados.

Para instalar no Windows, copie o instalador para uma pasta do proprio Windows
antes de rodar: executado direto de `\\wsl.localhost\...` ele falha.

## Estrutura

```
docker/                    imagens de build para Linux e Windows
scripts/
  build-windows-docker.sh  instalador NSIS
  build-linux-docker.sh    deb e rpm
  make-sidecar.sh          empacota o daemon como binario unico para o Linux
src-tauri/
  tauri.conf.json          janela, sidecar e bundle
  tauri.windows.conf.json  tira o sidecar no Windows
  capabilities/            permissoes: links, sidecar e dialogo de pasta
  src/lib.rs               bandeja, esconder ao fechar, subir e parar o sidecar
```

## Parte do Agent Hub

Este repositorio e uma das partes do [Agent Hub](https://github.com/raylison100/agent-hub),
um gerenciador de modelos de IA que roda na sua maquina. A documentacao geral
esta na [wiki](https://github.com/raylison100/agent-hub/wiki).

| Repositorio | Papel |
|---|---|
| [agent-hub](https://github.com/raylison100/agent-hub) | ponto de partida, Makefile, scripts e wiki |
| [agent-hub-core](https://github.com/raylison100/agent-hub-core) | biblioteca TypeScript: adaptadores, laco do agente, custo, roteamento, ferramentas, protocolo |
| [agent-hub-daemon](https://github.com/raylison100/agent-hub-daemon) | servico local: sessoes, runs, aprovacoes, automacao, conectores, API WebSocket |
| [agent-hub-web](https://github.com/raylison100/agent-hub-web) | interface Vue 3 como PWA, a mesma no navegador, no celular e no desktop |
| [agent-hub-agents](https://github.com/raylison100/agent-hub-agents) | perfis, papeis, skills, workflows, precos, roteamento e politicas, em texto |
| [agent-hub-desktop](https://github.com/raylison100/agent-hub-desktop) | app Tauri 2 para Windows e Linux |
| [agent-hub-relay](https://github.com/raylison100/agent-hub-relay) | retransmissor sem estado para acesso remoto |
| [agent-hub-channels](https://github.com/raylison100/agent-hub-channels) | clientes em plataformas de mensagem, hoje Telegram |
| [agent-hub-docs](https://github.com/raylison100/agent-hub-docs) | planejamento, arquitetura, ADRs e a fonte das paginas da wiki |

## Licenca

[PolyForm Noncommercial 1.0.0](LICENSE). Pode ler, estudar, modificar e usar
para fins pessoais, de pesquisa, ensino ou em organizacao sem fins lucrativos.
Uso comercial nao e permitido sem autorizacao do autor.

Required Notice: Copyright (c) 2026 Raylison Nunes (https://github.com/raylison100)
