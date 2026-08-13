# EditCOPY - DaVinci Resolve Integration MVP

Este é o MVP do EditCOPY, uma ferramenta desktop para acelerar o workflow de editores no DaVinci Resolve.

## 🚀 Como usar

1.  **Instalação do Script no DaVinci Resolve**:
    - Copie o conteúdo de `resolve/EditCOPY.lua` e a pasta `resolve/modules` para a pasta de scripts do DaVinci Resolve:
      `%AppData%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp\EditCOPY.lua`
2.  **Iniciar Integração**:
    - No DaVinci Resolve, vá em `Workspace` -> `Scripts` -> `EditCOPY`.
    - Isso iniciará o servidor local na porta `56002`.
3.  **Usar o App**:
    - Abra o aplicativo EditCOPY.
    - O status deve mudar para `Connected`.
    - Copie qualquer imagem (CTRL+C) e pressione `CTRL+V` no EditCOPY para adicionar à fila.
    - Configure a duração e a track.
    - Clique em `APPLY TO TIMELINE`.

## 🏗️ Arquitetura
- **Frontend**: React 19 + TanStack Start.
- **Desktop**: Tauri 2 + Rust.
- **Comunicação**: Rust Bridge -> Local HTTP Server (Lua) -> Resolve Scripting API.
