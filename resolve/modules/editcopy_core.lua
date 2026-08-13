local json = require("dkjson")
local socket = require("socket")

local EditCopy = {}
local server = nil

local handlers = {}

local HOST = "127.0.0.1"
local PORT = 56002

local function json_response(payload)
    return json.encode(payload)
end

local function send_http_response(client, status_code, body)

    local status_text = {
        [200] = "OK",
        [400] = "Bad Request",
        [404] = "Not Found",
        [500] = "Internal Server Error"
    }

    local text = status_text[status_code] or "OK"

    local response =
        "HTTP/1.1 "
        .. tostring(status_code)
        .. " "
        .. text
        .. "\r\n"
        .. "Content-Type: application/json\r\n"
        .. "Content-Length: "
        .. tostring(#body)
        .. "\r\n"
        .. "Connection: close\r\n"
        .. "\r\n"
        .. body

    local ok, err = client:send(response)

    if not ok and err then
        print("[EditCOPY HTTP] erro ao enviar resposta: " .. tostring(err))
    end
end

local function read_headers(client)

    local headers = {}

    while true do

        local line, err = client:receive("*l")

        if not line then
            return nil, err
        end

        if line == "" then
            break
        end

        local key, value =
            line:match("^([^:]+):%s*(.*)$")

        if key and value then
            headers[string.lower(key)] = value
        end
    end

    return headers
end

local function read_request(client)

    local request_line, err =
        client:receive("*l")

    if not request_line then
        return nil, err
    end

    local method, path =
        request_line:match("^(%S+)%s+(%S+)")

    if not method or not path then
        return nil, "HTTP request line inválida"
    end

    local headers, header_err =
        read_headers(client)

    if not headers then
        return nil, header_err
    end

    local content_length =
        tonumber(headers["content-length"] or "0")

    local body = ""

    if content_length > 0 then

        body, err =
            client:receive(content_length)

        if not body then
            return nil, err
        end
    end

    return {
        method = method,
        path = path,
        headers = headers,
        body = body
    }
end

function EditCopy.start_server(port)

    if server then
        print("[EditCOPY Lua] servidor já está iniciado")
        return server
    end

    local srv, err =
        socket.bind(HOST, port or PORT)

    if not srv then
        error(
            "Não foi possível abrir "
            .. HOST
            .. ":"
            .. tostring(port or PORT)
            .. " - "
            .. tostring(err)
        )
    end

    server = srv

    server:settimeout(0)

    print(
        "[EditCOPY Lua] Listening on "
        .. HOST
        .. ":"
        .. tostring(port or PORT)
    )

    return server
end

function EditCopy.handle_request(body)

    local decoded, _, decode_err =
        json.decode(body)

    if not decoded then

        return {
            ok = false,
            error = "JSON inválido",
            detail = tostring(decode_err)
        }
    end

    local func = decoded.func

    if type(func) ~= "string" then

        return {
            ok = false,
            error = "Campo 'func' não informado"
        }
    end

    local handler = handlers[func]

    if not handler then

        return {
            ok = false,
            func = func,
            error = "Função não permitida: " .. func
        }
    end

    print(
        "[EditCOPY Lua] Executando: "
        .. func
    )

    local ok, result =
        pcall(handler, decoded)

    if not ok then

        return {
            ok = false,
            func = func,
            error = "Erro interno no handler",
            detail = tostring(result)
        }
    end

    result = result or {}

    result.ok = true
    result.func = func

    return result
end

handlers["Ping"] = function(data)

    return {
        data = {
            message = "EditCOPY Lua server is alive"
        }
    }
end

handlers["GetResolveInfo"] = function(data)

    local resolve = Resolve()

    if not resolve then
        error("Resolve() retornou nil")
    end

    local product =
        resolve:GetProductName()

    local version =
        resolve:GetVersionString()

    return {
        data = {
            product = product,
            version = version
        }
    }
end

handlers["GetTimelineInfo"] = function(data)

    local resolve = Resolve()

    if not resolve then
        error("Resolve() retornou nil")
    end

    local project_manager =
        resolve:GetProjectManager()

    if not project_manager then
        error("GetProjectManager() retornou nil")
    end

    local project =
        project_manager:GetCurrentProject()

    if not project then

        return {
            ok = false,
            error = "Nenhum projeto está aberto."
        }
    end

    local timeline =
        project:GetCurrentTimeline()

    if not timeline then

        return {
            ok = false,
            error = "Nenhuma timeline está aberta."
        }
    end

    local frame_rate =
        tonumber(
            timeline:GetSetting("timelineFrameRate")
        )

    local current_timecode =
        timeline:GetCurrentTimecode()

    local end_frame =
        timeline:GetEndFrame()

    local track_count =
        timeline:GetTrackCount("video")

    return {
        data = {
            name = timeline:GetName(),
            frameRate = frame_rate,
            currentTimecode = current_timecode,
            duration = tostring(end_frame),
            videoTrackCount = track_count
        }
    }
end

function EditCopy.run()

    assert(server, "Servidor não iniciado")

    while true do

        local client =
            server:accept()

        if client then

            client:settimeout(10)

            local request, err =
                read_request(client)

            if not request then

                send_http_response(
                    client,
                    400,
                    json_response({
                        ok = false,
                        error = "HTTP request inválida",
                        detail = tostring(err)
                    })
                )

                client:close()

            else

                if request.method ~= "POST" then

                    send_http_response(
                        client,
                        404,
                        json_response({
                            ok = false,
                            error = "Somente POST é suportado."
                        })
                    )

                    client:close()

                elseif request.path ~= "/" then

                    send_http_response(
                        client,
                        404,
                        json_response({
                            ok = false,
                            error = "Endpoint inexistente."
                        })
                    )

                    client:close()

                else

                    local result

                    local ok, response =
                        pcall(
                            EditCopy.handle_request,
                            request.body
                        )

                    if ok then
                        result = response
                    else

                        result = {
                            ok = false,
                            error = "Erro processando requisição.",
                            detail = tostring(response)
                        }
                    end

                    local status_code =
                        result.ok and 200 or 400

                    send_http_response(
                        client,
                        status_code,
                        json_response(result)
                    )

                    client:close()
                end
            end
        end

        socket.sleep(0.01)
    end
end

return EditCopy
