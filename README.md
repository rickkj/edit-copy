# EditCOPY - DaVinci Resolve Integration

Este aplicativo permite copiar imagens do clipboard e inseri-las na timeline do DaVinci Resolve.

## Instalação no DaVinci Resolve

Para que o EditCOPY funcione, você deve instalar os scripts Lua no DaVinci Resolve.

### Estrutura de Pastas

Copie os arquivos da pasta `resolve/` deste repositório para a seguinte localização no seu computador:

**Windows:**
`%AppData%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp\`

A estrutura final deve ser:
```text
Comp/
├── EditCOPY.lua
├── modules/
│   └── editcopy_core.lua
└── deps/
    ├── dkjson.lua
    └── (outras dependências)
```

### Como Executar

1. Abra o DaVinci Resolve.
2. Abra um projeto e uma timeline.
3. Vá em **Workspace** → **Scripts** → **EditCOPY**.
4. O console do Resolve mostrará `[EditCOPY Lua] Listening on 127.0.0.1:56002`.
5. Abra o aplicativo EditCOPY e clique em **TEST CONNECTION**.

## Arquitetura

- **Frontend:** React + Tailwind
- **Desktop Bridge:** Tauri (Rust) usando `reqwest` para comunicação local.
- **Resolve Integration:** Servidor HTTP em Lua (LuaSocket) rodando dentro do DaVinci Resolve.
