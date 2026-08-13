local json = require("dkjson") -- Assume-se que o usuário tenha o módulo json ou usaremos um helper
local socket = require("socket")

local EditCopy = {}
local handlers = {}

function EditCopy.start_server(port)
    local server = assert(socket.bind("127.0.0.1", port))
    server:settimeout(0)
    print("[Lua Server] Escutando em 127.0.0.1:" .. port)
    
    return server
end

function EditCopy.handle_request(request_json)
    local success, data = pcall(json.decode, request_json)
    if not success or not data or not data.func then
        return json.encode({ ok = false, error = "JSON inválido ou função não especificada" })
    end

    local func = data.func
    if handlers[func] then
        print("[Lua Server] Executando: " .. func)
        local ok, result = pcall(handlers[func], data)
        if ok then
            result.ok = true
            result.func = func
            return json.encode(result)
        else
            return json.encode({ ok = false, error = "Erro interno na função Lua", detail = tostring(result), func = func })
        end
    else
        return json.encode({ ok = false, error = "Função não permitida ou inexistente", func = func })
    end
end

-- Handlers OBRIGATÓRIOS
handlers["Ping"] = function(data)
    return { ok = true }
end

handlers["GetResolveInfo"] = function(data)
    local resolve = Resolve()
    return {
        product = resolve:GetProductName(),
        version = resolve:GetVersionString()
    }
end

handlers["GetTimelineInfo"] = function(data)
    local resolve = Resolve()
    local projectManager = resolve:GetProjectManager()
    local project = projectManager:GetCurrentProject()
    if not project then return { error = "Nenhum projeto aberto" } end
    
    local timeline = project:GetCurrentTimeline()
    if not timeline then return { error = "Nenhuma timeline aberta" } end
    
    return {
        timeline = {
            name = timeline:GetName(),
            frameRate = timeline:GetSetting("timelineFrameRate"),
            currentTimecode = timeline:GetCurrentTimecode(),
            duration = tostring(timeline:GetEndFrame()),
            videoTrackCount = timeline:GetTrackCount("video")
        }
    }
end

return EditCopy
