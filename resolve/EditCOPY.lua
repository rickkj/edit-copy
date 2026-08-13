-- EditCOPY Launcher para DaVinci Resolve
-- Configura caminhos e inicia o servidor HTTP

local PORT = 56002

-- 1. Determinar diretório real do script
local function get_script_path()
    local info = debug.getinfo(1, "S")
    local path = info.source:sub(2) -- Remove o '@' inicial
    return path:match("(.*[/\\])") or ""
end

local script_dir = get_script_path()
print("[EditCOPY Lua] Script directory: " .. script_dir)

-- 2. Configurar package.path para incluir subdiretórios
package.path = package.path .. ";" .. script_dir .. "?.lua"
package.path = package.path .. ";" .. script_dir .. "modules/?.lua"
package.path = package.path .. ";" .. script_dir .. "deps/?.lua"

-- 3. Carregar dependências e core
local status_json, json = pcall(require, "dkjson")
if not status_json then
    -- Fallback se dkjson estiver na pasta deps
    status_json, json = pcall(require, "deps.dkjson")
end

local status_socket, socket = pcall(require, "socket")
if not status_socket then
    print("[EditCOPY Lua] ERRO CRÍTICO: LuaSocket não encontrado. Certifique-se que o plugin foi instalado corretamente.")
    return
end

local status_core, core = pcall(require, "modules.editcopy_core")
if not status_core then
    print("[EditCOPY Lua] ERRO CRÍTICO ao carregar editcopy_core: " .. tostring(core))
    return
end

-- 4. Iniciar Servidor (evitando múltiplos servidores)
local server, err = socket.bind("127.0.0.1", PORT)
if not server then
    -- Tenta verificar se já existe um servidor EditCOPY rodando
    local client = socket.tcp()
    client:settimeout(1)
    if client:connect("127.0.0.1", PORT) then
        print("[EditCOPY Lua] Servidor já está rodando na porta " .. PORT .. ". Reutilizando conexão.")
        client:close()
        return
    else
        print("[EditCOPY Lua] Erro ao iniciar servidor: " .. tostring(err))
        return
    end
end

server:settimeout(0.1)
print("[EditCOPY Lua] Servidor HTTP iniciado em 127.0.0.1:" .. PORT)

-- Loop principal (o Resolve executa scripts de forma síncrona, 
-- mas podemos rodar um loop com timeout se necessário para o MVP)
-- NOTA: Em ambiente Resolve, scripts de UI costumam ter um loop próprio.
-- Para o MVP funcional, vamos rodar um loop que processa requisições.

local running = true
while running do
    local client, accept_err = server:accept()
    if client then
        core.handle_request(client)
        client:close()
    elseif accept_err ~= "timeout" then
        print("[EditCOPY Lua] Accept error: " .. tostring(accept_err))
    end
    
    -- Pequena pausa para não consumir 100% da CPU se o Resolve permitir
    socket.sleep(0.01)
end
