-- EditCOPY Core para DaVinci Resolve
-- Módulo com handlers e lógica de servidor HTTP real

local json = require("deps.dkjson")
local socket = require("socket")

local EditCopyCore = {}
local handlers = {}

-- Utilitário para formatar resposta HTTP
local function http_response(content_json, status_code)
    status_code = status_code or 200
    local status_text = status_code == 200 and "OK" or "Internal Server Error"
    
    return string.format(
        "HTTP/1.1 %d %s\r\n" ..
        "Content-Type: application/json\r\n" ..
        "Content-Length: %d\r\n" ..
        "Connection: close\r\n" ..
        "\r\n" ..
        "%s",
        status_code, status_text, #content_json, content_json
    )
end

-- Handlers OBRIGATÓRIOS
handlers["Ping"] = function(data)
    return { ok = true, func = "Ping", data = { message = "EditCOPY Lua server is alive" } }
end

handlers["GetResolveInfo"] = function(data)
    local resolve = Resolve()
    if not resolve then
        return { ok = false, func = "GetResolveInfo", error = "Não foi possível acessar a API do Resolve." }
    end
    
    return {
        ok = true,
        func = "GetResolveInfo",
        data = {
            product = resolve:GetProductName(),
            version = resolve:GetVersionString()
        }
    }
end

handlers["GetTimelineInfo"] = function(data)
    local resolve = Resolve()
    if not resolve then
        return { ok = false, func = "GetTimelineInfo", error = "Não foi possível acessar a API do Resolve." }
    end
    
    local projectManager = resolve:GetProjectManager()
    local project = projectManager:GetCurrentProject()
    if not project then 
        return { ok = false, func = "GetTimelineInfo", error = "Nenhum projeto está aberto no DaVinci Resolve." } 
    end
    
    local timeline = project:GetCurrentTimeline()
    if not timeline then 
        return { ok = false, func = "GetTimelineInfo", error = "Nenhuma timeline está aberta." } 
    end
    
    return {
        ok = true,
        func = "GetTimelineInfo",
        data = {
            name = timeline:GetName(),
            frameRate = timeline:GetSetting("timelineFrameRate"),
            currentTimecode = timeline:GetCurrentTimecode(),
            duration = tostring(timeline:GetEndFrame()),
            videoTrackCount = timeline:GetTrackCount("video")
        }
    }
end

function EditCopyCore.handle_request(client)
    client:settimeout(5)
    local line, err = client:receive()
    if err then return end

    -- Parsing básico de POST /
    local method, path = line:match("^(%u+)%s+(%S+)%s+HTTP/%d%.%d$")
    if method ~= "POST" then
        client:send(http_response(json.encode({ ok = false, error = "Apenas POST é permitido" }), 405))
        return
    end

    -- Ler headers para achar Content-Length
    local content_length = 0
    while true do
        local h_line, h_err = client:receive()
        if not h_line or h_line == "" then break end
        local name, value = h_line:match("^(.-):%s*(.*)$")
        if name and name:lower() == "content-length" then
            content_length = tonumber(value)
        end
    end

    -- Ler body
    local body = ""
    if content_length > 0 then
        body, err = client:receive(content_length)
    end

    print("[EditCOPY Lua] Received request body: " .. (body or "empty"))

    local success, request_data = pcall(json.decode, body)
    if not success or not request_data or not request_data.func then
        client:send(http_response(json.encode({ ok = false, error = "JSON inválido ou campo 'func' ausente" })))
        return
    end

    local func = request_data.func
    local response_data
    
    if handlers[func] then
        print("[EditCOPY Lua] Executing function: " .. func)
        local ok, result = pcall(handlers[func], request_data)
        if ok then
            response_data = result
        else
            response_data = { ok = false, func = func, error = "Erro interno no script Lua", detail = tostring(result) }
        end
    else
        response_data = { ok = false, func = func, error = "Função desconhecida ou não implementada" }
    end

    local resp_json = json.encode(response_data)
    client:send(http_response(resp_json))
    print("[EditCOPY Lua] " .. func .. " successful")
end

return EditCopyCore
