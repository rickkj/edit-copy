# EditCOPY - DaVinci Resolve Integration

Este aplicativo especializado permite capturar imagens do clipboard do Windows e inseri-las automaticamente na timeline do DaVinci Resolve via uma ponte segura em Rust e um servidor local em Lua.

---

## 🛠️ Comandos do Desenvolvedor (NPM)

Para facilitar o desenvolvimento e build do aplicativo desktop, utilize os seguintes comandos no terminal:

- `npm run tauri:dev`: Inicia o aplicativo em modo de desenvolvimento (Hot Reload).
- `npm run tauri:build`: Gera o executável de produção (.exe) para Windows.
- `npm run tauri:clean`: Limpa os arquivos temporários de build do Rust/Cargo.

---

## 🚀 Guia de Instalação e Configuração

Para que a integração funcione, você precisa configurar o DaVinci Resolve para aceitar comandos do EditCOPY.

### 1. Requisitos Prévios
- **DaVinci Resolve** instalado.
- **Python** (opcional, mas recomendado para algumas APIs do Resolve).
- No DaVinci Resolve, vá em `Preferences` -> `System` -> `General` e certifique-se de que **"External scripting using"** está definido como **"Local"** ou **"Network"**.

### 2. Instalação dos Scripts Lua
Copie o conteúdo da pasta `resolve/` deste projeto para a pasta de scripts do DaVinci Resolve:

**Caminho no Windows:**
`%AppData%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp\`

**Estrutura de arquivos correta:**
```text
Comp/
├── EditCOPY.lua             (O lançador do script)
├── modules/
│   └── editcopy_core.lua    (O motor do servidor HTTP)
└── deps/
    └── dkjson.lua           (Dependência para JSON)
```

### 3. Como Iniciar a Integração
1. Abra o **DaVinci Resolve**.
2. No menu superior, vá em: **Workspace** -> **Scripts** -> **EditCOPY**.
3. Verifique o Console do DaVinci (ou a janela que abrir) para a mensagem: `[EditCOPY Lua] Listening on 127.0.0.1:56002`.
4. Com o servidor Lua rodando, abra o aplicativo **EditCOPY**.
5. No EditCOPY, o status de conexão deve mudar para **"Connected"**.

---

## 🏗️ Arquitetura Técnica (4 Camadas)

1.  **Interface (React/TS):** Gerencia a fila de imagens e o estado da conexão.
2.  **Ponte (Tauri/IPC):** Canal de comunicação seguro entre o frontend e o sistema operacional.
3.  **Backend (Rust):** Proxy transparente que envia requisições HTTP POST para o servidor Lua local.
4.  **Integração (Lua Server):** Script rodando dentro do DaVinci Resolve que executa comandos via **Scripting API**.

---

## 📝 Notas Importantes
- O servidor Lua utiliza a porta **56002**. Certifique-se de que não há firewalls bloqueando conexões locais nesta porta.
- Se o status no app for "Disconnected", certifique-se de que o script `EditCOPY` foi iniciado dentro do DaVinci Resolve.
