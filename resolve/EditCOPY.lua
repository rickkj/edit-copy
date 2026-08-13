local source =
    debug.getinfo(1, "S").source

local SCRIPT_PATH =
    source:sub(2)

local SEPARATOR =
    package.config:sub(1, 1)

local SCRIPT_DIR =
    SCRIPT_PATH:match(
        "^(.*)"
        .. SEPARATOR
        .. "[^"
        .. SEPARATOR
        .. "]+$"
    )

if not SCRIPT_DIR then
    error(
        "[EditCOPY Lua] Não foi possível determinar o diretório do script."
    )
end

local MODULES_DIR =
    SCRIPT_DIR
    .. SEPARATOR
    .. "modules"

local DEPS_DIR =
    SCRIPT_DIR
    .. SEPARATOR
    .. "deps"

package.path =
    MODULES_DIR
    .. SEPARATOR
    .. "?.lua;"
    .. DEPS_DIR
    .. SEPARATOR
    .. "?.lua;"
    .. package.path

print(
    "[EditCOPY Lua] Iniciando..."
)

-- Validação de dkjson
local ok_dkjson, dkjson_lib =
    pcall(
        require,
        "dkjson"
    )

if not ok_dkjson then
    print(
        "[EditCOPY Lua] ERRO: dkjson não encontrado.\nDetalhes: "
        .. tostring(dkjson_lib)
    )
    return
end
print(
    "[EditCOPY Lua] dkjson carregado."
)

-- Validação de LuaSocket
local ok_socket, socket_lib =
    pcall(
        require,
        "socket"
    )

if not ok_socket then
    print(
        "[EditCOPY Lua] ERRO: dependência LuaSocket não encontrada.\nDetalhes: "
        .. tostring(socket_lib)
    )
    return
end
print(
    "[EditCOPY Lua] LuaSocket carregado."
)

-- Teste de bind do LuaSocket
local testSocket, err =
    socket_lib.bind("127.0.0.1", 56003)

if not testSocket then
    print(
        "[EditCOPY Lua] ERRO: Falha ao abrir 127.0.0.1:56003: "
        .. tostring(err)
    )
    return
end
testSocket:close()
print(
    "[EditCOPY Lua] Teste de bind do LuaSocket: PASS."
)

-- Carregamento do core do EditCOPY
local ok_core, core =
    pcall(
        require,
        "editcopy_core"
    )

if not ok_core then
    print(
        "[EditCOPY Lua] ERRO ao carregar editcopy_core:\nDetalhes: "
        .. tostring(core)
    )
    return
end

-- Iniciar servidor
local ok_start, start_error =
    pcall(
        core.start_server,
        56003
    )

if not ok_start then
    print(
        "[EditCOPY Lua] ERRO ao iniciar servidor:\nDetalhes: "
        .. tostring(start_error)
    )
    return
end

print(
    "[EditCOPY Lua] Listening on 127.0.0.1:56003"
)

-- Rodar servidor
local ok_run, run_error =
    pcall(
        core.run
    )

if not ok_run then
    print(
        "[EditCOPY Lua] ERRO no servidor:\nDetalhes: "
        .. tostring(run_error)
    )
end
