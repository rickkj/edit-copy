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

local ok, core =
    pcall(
        require,
        "editcopy_core"
    )

if not ok then

    print(
        "[EditCOPY Lua] ERRO ao carregar editcopy_core:"
    )

    print(
        tostring(core)
    )

    return
end

local ok_start, start_error =
    pcall(
        core.start_server,
        56002
    )

if not ok_start then

    print(
        "[EditCOPY Lua] ERRO ao iniciar servidor:"
    )

    print(
        tostring(start_error)
    )

    return
end

print(
    "[EditCOPY Lua] Listening on 127.0.0.1:56002"
)

local ok_run, run_error =
    pcall(
        core.run
    )

if not ok_run then

    print(
        "[EditCOPY Lua] ERRO no servidor:"
    )

    print(
        tostring(run_error)
    )
end
