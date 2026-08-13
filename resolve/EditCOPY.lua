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

package.path =
    MODULES_DIR
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

-- Validação de ljsocket
local ok_socket, socket_lib =
    pcall(
        require,
        "ljsocket"
    )

if not ok_socket then
    print(
        "[EditCOPY Lua] ERRO: ljsocket não carregou.\nDetalhes: "
        .. tostring(socket_lib)
    )
    return
end
print(
    "[EditCOPY Lua] ljsocket carregado."
)

print(
    "[EditCOPY Lua] ljsocket.find_first_address:",
    type(socket_lib.find_first_address)
)

print(
    "[EditCOPY Lua] ljsocket.create:",
    type(socket_lib.create)
)

-- Teste find_first_address isoladamente
local test_info, test_err =
    socket_lib.find_first_address(
        "127.0.0.1",
        56003
    )

if not test_info then
    error(
        "[EditCOPY Lua] find_first_address falhou: "
        .. tostring(test_err)
    )
end

print("[EditCOPY Lua] find_first_address OK")

-- Teste socket.create
local test_server, test_create_err =
    socket_lib.create(
        test_info.family,
        test_info.socket_type,
        test_info.protocol
    )

if not test_server then
    error(
        "[EditCOPY Lua] socket.create falhou: "
        .. tostring(test_create_err)
    )
end

print("[EditCOPY Lua] socket.create OK")

-- MUDANÇA V14: REMOVER set_blocking(false) para evitar erro ioctlsocket
-- assert(test_server:set_blocking(false))

assert(test_server:set_option("nodelay", true, "tcp"))
assert(test_server:set_option("reuseaddr", true))
assert(test_server:bind(test_info))
assert(test_server:listen())

print("[EditCOPY Lua] TCP server pronto em 127.0.0.1:56003")

test_server:close()


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

-- Rodar servidor (core.run agora contém o loop blocking)
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
