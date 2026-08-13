# EditCOPY MVP Plan

Este plano descreve a implementação do MVP do EditCOPY, um aplicativo desktop para integrar o clipboard do Windows com a timeline do DaVinci Resolve via Tauri 2 e Rust.

## 🏗️ Arquitetura
1.  **Frontend**: React (TanStack Start) + Tailwind (Professional Dark UI).
2.  **Desktop Runtime**: Tauri 2 (Rust).
3.  **Bridge**: Rust (`reqwest`) intermediando comunicação HTTP com o Resolve.
4.  **Integration**: Scripts Lua executados no DaVinci Resolve (Servidor HTTP local na porta 56002).

## 📋 Fases de Implementação

### Fase 1: Fundação & UI Profissional
- Criar a interface principal `EditCOPY` com estética "Premium Dark".
- Implementar `src/api/resolve-api.ts` para centralizar chamadas ao bridge Rust.
- Componentes: Header (Status), Image Queue (Thumbnails), Settings (Duration, Track), Footer (Apply).

### Fase 2: Rust Bridge (Tauri Commands)
- Implementar o comando Tauri `resolve_bridge` no Rust.
- Configurar `reqwest` para POSTs em `127.0.0.1:56002`.
- Tratamento rigoroso de erros (Connection Refused, Timeout).

### Fase 3: DaVinci Resolve Integration (Lua)
- Criar `resolve/EditCOPY.lua` (Launcher).
- Criar `resolve/modules/editcopy_core.lua` (Lógica do Servidor e Integração API Resolve).
- Implementar handlers: `Ping`, `GetResolveInfo`, `GetTimelineInfo`, `ImportImages`, `ApplyImages`.

### Fase 4: Clipboard & Fila de Imagens
- Implementar listener de CTRL+V no frontend.
- Captura de imagem do clipboard e salvamento em pasta temporária local.
- Gerenciamento da fila de imagens com thumbnails e remoção individual.

### Fase 5: Integração de Timeline
- Lógica de importação para o Media Pool via Scripting API.
- Inserção na timeline na track selecionada, respeitando o playhead e frame rate real.
- Conversão de duração (segundos -> frames) baseada nos dados reais da timeline.

## 🛡️ Segurança e Robustez
- Comunicação exclusiva via `127.0.0.1`.
- Whitelist de funções no servidor Lua.
- Feedback visual claro para todos os estados de erro.
