# EditCOPY - DaVinci Resolve Integration

Este guia explica como configurar e rodar o EditCOPY para integrar o clipboard do Windows diretamente com a timeline do DaVinci Resolve.

---

## ✅ Checklist de Pré-Execução

Antes de rodar `npm run tauri:dev`, certifique-se de cumprir estas etapas:

- [ ] **Node.js instalado:** Versão 18 ou superior.
- [ ] **Rust instalado:** `rustc` e `cargo` configurados no PATH.
- [ ] **DaVinci Resolve configurado:** `Preferences` -> `System` -> `General` -> `External scripting using` definido como **Local**.
- [ ] **Scripts instalados:** Executou `npm run resolve:install` com sucesso.
- [ ] **Dependências do projeto:** Executou `npm install` na raiz.
- [ ] **DaVinci Resolve aberto:** O software deve estar em execução.
- [ ] **Servidor Lua ativo:** Clicou em `Workspace` -> `Scripts` -> `EditCOPY` dentro do Resolve.

---

## 🛠️ Guia Rápido de Comandos (Terminal)

Siga esta ordem exata para configurar e rodar o projeto pela primeira vez:

### 1. Instalação de Dependências
Instale as bibliotecas necessárias para o frontend e o motor Tauri:
```bash
npm install
```

### 2. Instalação do Plugin no DaVinci Resolve
Este comando copia automaticamente os scripts Lua necessários para a pasta de scripts do DaVinci Resolve no seu Windows:
```bash
npm run resolve:install
```

### 3. Iniciar o Aplicativo (Modo Desenvolvimento)
Compila e abre a interface do EditCOPY. Na primeira execução, o Rust fará o download das dependências e compilará o core (isso pode levar alguns minutos):
```bash
npm run tauri:dev
```

### 4. Testar Conexão com o Resolve
Após iniciar o script dentro do DaVinci Resolve (veja seção abaixo), você pode testar a comunicação HTTP via terminal:
```bash
npm run resolve:test
```

---

## 🚀 Passo a Passo: Configuração do DaVinci Resolve

Para que a integração funcione, você deve ativar o servidor Lua dentro do Resolve:

1.  **Configuração de Scripting:**
    - Abra o DaVinci Resolve.
    - Vá em `Preferences` -> `System` -> `General`.
    - Defina **"External scripting using"** como **"Local"**.
    - Salve e reinicie o Resolve se necessário.

2.  **Ativar o Servidor EditCOPY:**
    - Com o Resolve aberto, vá no menu superior: `Workspace` -> `Scripts` -> `EditCOPY`.
    - **Dica:** O console do Resolve (que abre automaticamente ou via `Workspace` -> `Console`) mostrará a mensagem: `[EditCOPY Lua] Listening on 127.0.0.1:56002`.

3.  **Uso:**
    - Com o script rodando no Resolve e o App EditCOPY aberto, qualquer imagem copiada (PrintScreen, Snipping Tool, Copiar Imagem no Navegador) aparecerá na fila do app e poderá ser inserida na timeline.

---

## 📋 Lista Completa de Comandos

| Comando | Descrição |
| :--- | :--- |
| `npm install` | Instala dependências do Node.js. |
| `npm run tauri:dev` | Inicia o app em modo de desenvolvimento. |
| `npm run tauri:build` | Gera o instalador `.exe` de produção. |
| `npm run tauri:clean` | Limpa o cache de build do Rust (útil se houver erros de compilação). |
| `npm run resolve:install` | Instala os scripts Lua no diretório do Resolve. |
| `npm run resolve:test` | Valida se o servidor Lua está ativo e respondendo. |

---

## 🏗️ Estrutura Técnica
- **Frontend:** React + Tailwind + TanStack Router.
- **Desktop:** Tauri 2 (Rust).
- **Integração:** Servidor HTTP em Lua rodando via DaVinci Scripting API na porta `56002`.

---

## ⚠️ Solução de Problemas
- **Erro de Build (Ícones):** Se o build falhar reclamando de `icon.ico`, certifique-se de que a pasta `src-tauri/icons` contém os arquivos gerados.
- **"Failed to connect":** O erro `curl: (7)` no `resolve:test` significa que o script `EditCOPY` não foi iniciado dentro do menu `Workspace -> Scripts` do DaVinci Resolve.
