# EditCOPY - DaVinci Resolve Integration MVP

Este é o MVP do EditCOPY, uma ferramenta desktop para acelerar o workflow de editores no DaVinci Resolve, permitindo a inserção instantânea de imagens do clipboard na timeline.

## 🚀 Como usar

### 1. Instalação do Script no DaVinci Resolve
- Localize a pasta de scripts do DaVinci Resolve no seu sistema:
  - **Windows**: `%AppData%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp\`
  - **macOS**: `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Comp/`
- Copie o arquivo `resolve/EditCOPY.lua` e as pastas `resolve/modules` e `resolve/deps` para este diretório.

### 2. Iniciar a Integração
- No DaVinci Resolve, vá em `Workspace` -> `Scripts` -> `EditCOPY`.
- O console do Resolve mostrará `[EditCOPY Lua] Servidor HTTP iniciado em 127.0.0.1:56002`.
- **Nota**: Mantenha o console/janela do script aberta enquanto utiliza o EditCOPY.

### 3. Conectar o Aplicativo
- Abra o aplicativo EditCOPY.
- Clique em `TEST CONNECTION` para validar a comunicação.
- O status mudará para `Connected` quando o servidor Lua responder.

### 4. Workflow de Trabalho
- Copie qualquer imagem no Windows (ex: Snipping Tool, Navegador) com `CTRL+C`.
- No EditCOPY, pressione `CTRL+V` para adicionar a imagem à fila.
- Clique em `APPLY TO TIMELINE` para enviar todas as imagens da fila diretamente para a track selecionada no Resolve.

## 🔧 DaVinci Resolve Integration

A comunicação entre o EditCOPY e o DaVinci Resolve utiliza uma arquitetura de quatro camadas:
1. **Frontend (React)**: Interface do usuário que gerencia a fila e configurações.
2. **Bridge (Rust/Tauri)**: Ponte segura que realiza requisições HTTP locais.
3. **Server (Lua)**: Servidor HTTP rodando dentro do processo do DaVinci Resolve.
4. **API (Resolve Scripting)**: Comandos finais que manipulam a Media Pool e a Timeline.

### Configurações de Rede
- **Host**: `127.0.0.1` (Apenas conexões locais)
- **Porta**: `56002`

## 🛠️ Troubleshooting

- **Porta Ocupada**: Se o servidor não iniciar, verifique se não há outra instância do EditCOPY ou outro serviço usando a porta 56002.
- **Script não aparece**: Certifique-se de que os arquivos foram copiados para a pasta `Comp` e não apenas `Scripts`.
- **Timeout**: Se receber erro de tempo limite, verifique se o DaVinci Resolve não está travado ou processando uma tarefa pesada.
- **Timeline inexistente**: O Resolve exige que exista pelo menos uma timeline ativa para que as informações possam ser lidas.

## 🏗️ Arquitetura Técnica
- **Frontend**: React 19 + TanStack Start + Tailwind CSS 4.
- **Desktop**: Tauri 2 (Rust bridge via `reqwest`).
- **Resolve**: Lua 5.1 (ambiente interno do Resolve) + LuaSocket + dkjson.

