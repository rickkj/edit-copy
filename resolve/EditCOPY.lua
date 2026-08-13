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
    "[EditCOPY Lua] ljsocket carregado com sucesso."
)

-- Validação de ljsocket concluída.
-- (Removido teste de bind manual aqui para evitar conflito com o core)
print(
    "[EditCOPY Lua] ljsocket validado e pronto."
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
    "[EditCOPY Lua] HTTP server listening on 127.0.0.1:56003"
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
