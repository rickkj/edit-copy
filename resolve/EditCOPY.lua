local SCRIPT_DIR = debug.getinfo(1, "S").source:sub(2)

local separator = package.config:sub(1, 1)

SCRIPT_DIR = SCRIPT_DIR:match("^(.*)" .. separator .. "[^" .. separator .. "]+$") or "."

package.path =
    SCRIPT_DIR
    .. separator
    .. "?.lua;"
    .. SCRIPT_DIR
    .. separator
    .. "?/init.lua;"
    .. package.path

local MODULE_DIR = SCRIPT_DIR .. separator .. "modules"

package.path =
    MODULE_DIR
    .. separator
    .. "?.lua;"
    .. package.path

local DEPS_DIR =
    SCRIPT_DIR .. separator .. "deps"

package.path =
    DEPS_DIR .. separator .. "?.lua;"
    .. package.path

print("[EditCOPY Lua] Iniciando...")

local ok, EditCopy = pcall(require, "editcopy_core")

if not ok then
    print("[EditCOPY Lua] ERRO ao carregar editcopy_core:")
    print(tostring(EditCopy))
    return
end

local ok_start, err = pcall(function()
    EditCopy.start_server(56002)
end)

if not ok_start then
    print("[EditCOPY Lua] ERRO ao iniciar servidor:")
    print(tostring(err))
    return
end

print("[EditCOPY Lua] Servidor iniciado em 127.0.0.1:56002")

EditCopy.run()
