local json =
    require("dkjson")

local socket =
    require("socket")

local EditCopy = {}

local handlers = {}

local server = nil

local HOST =
    "127.0.0.1"

local PORT =
    56003


local function send_response(
    client,
    status,
    body
)

    local status_text =
        status == 200
        and "OK"
        or status == 400
        and "Bad Request"
        or status == 404
        and "Not Found"
        or "Internal Server Error"

    local response =
        "HTTP/1.1 "
        .. tostring(status)
        .. " "
        .. status_text
        .. "\r\n"
        .. "Content-Type: application/json\r\n"
        .. "Content-Length: "
        .. tostring(#body)
        .. "\r\n"
        .. "Connection: close\r\n"
        .. "\r\n"
        .. body

    client:send(response)
end


local function read_headers(
    client
)

    local headers = {}

    while true do

        local line, err =
            client:receive("*l")

        if not line then
            return nil, err
        end

        if line == "" then
            break
        end

        local name, value =
            line:match(
                "^([^:]+):%s*(.*)$"
            )

        if name then

            headers[
                string.lower(name)
            ] = value
        end
    end

    return headers
end


local function read_request(
    client
)

    local request_line, err =
        client:receive("*l")

    if not request_line then
        return nil, err
    end

    local method, path =
        request_line:match(
            "^(%S+)%s+(%S+)"
        )

    if not method then
        return nil,
            "HTTP request line inválida"
    end

    local headers, header_error =
        read_headers(client)

    if not headers then
        return nil, header_error
    end

    local length =
        tonumber(
            headers["content-length"]
                or "0"
        )

    local body = ""

    if length > 0 then

        body, err =
            client:receive(length)

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


function EditCopy.start_server(
    port
)

    if server then

        print(
            "[EditCOPY Lua] Server já iniciado."
        )

        return server
    end

    local srv, err =
        socket.bind(
            HOST,
            port or PORT
        )

    if not srv then

        error(
            "Falha ao abrir "
            .. HOST
            .. ":"
            .. tostring(port or PORT)
            .. " -> "
            .. tostring(err)
        )
    end

    server = srv

    server:settimeout(0)

    return server
end


function EditCopy.handle_request(
    body
)

    local data, _, decode_error =
        json.decode(body)

    if not data then
        -- Tentar limpar caracteres extras (espaços, tabs, quebras de linha) se falhar
        local clean_body = body:match("^%s*(.-)%s*$")
        data, _, decode_error = json.decode(clean_body)
    end

    if not data then
        return {
            ok = false,
            error = "JSON inválido.",
            detail = tostring(decode_error)
        }
    end

    local func =
        data.func

    if type(func) ~= "string" then

        return {
            ok = false,
            error =
                "Campo 'func' não informado."
        }
    end

    local handler =
        handlers[func]

    if not handler then

        return {
            ok = false,
            func = func,
            error =
                "Função não permitida: "
                .. func
        }
    end

    print(
        "[EditCOPY Lua] Executando: "
        .. func
    )

    local success, result =
        pcall(
            handler,
            data
        )

    if not success then

        return {
            ok = false,
            func = func,
            error =
                "Erro no handler.",
            detail =
                tostring(result)
        }
    end

    result =
        result
        or {}

    if result.ok == nil then
        result.ok = true
    end

    result.func =
        func

    return result
end


handlers["Ping"] =
    function(data)

        return {
            ok = true,
            data = {
                message =
                    "EditCOPY Lua server is alive"
            }
        }
    end


handlers["GetResolveInfo"] =
    function(data)

        local resolve =
            Resolve()

        if not resolve then
            error(
                "Resolve() retornou nil."
            )
        end

        return {
            ok = true,
            data = {
                product =
                    resolve:GetProductName(),

                version =
                    resolve:GetVersionString()
            }
        }
    end


handlers["GetTimelineInfo"] =
    function(data)

        local resolve =
            Resolve()

        if not resolve then
            error(
                "Resolve() retornou nil."
            )
        end

        local project_manager =
            resolve:GetProjectManager()

        if not project_manager then
            error(
                "GetProjectManager() retornou nil."
            )
        end

        local project =
            project_manager:GetCurrentProject()

        if not project then

            return {
                ok = false,
                error =
                    "Nenhum projeto está aberto."
            }
        end

        local timeline =
            project:GetCurrentTimeline()

        if not timeline then

            return {
                ok = false,
                error =
                    "Nenhuma timeline está aberta."
            }
        end

        local fps =
            tonumber(
                timeline:GetSetting(
                    "timelineFrameRate"
                )
            )

        return {
            ok = true,
            data = {
                name =
                    timeline:GetName(),

                frameRate = fps,

                currentTimecode =
                    timeline:GetCurrentTimecode(),

                duration =
                    tostring(
                        timeline:GetEndFrame()
                    ),

                videoTrackCount =
                    timeline:GetTrackCount(
                        "video"
                    )
            }
        }
    end


function EditCopy.run()

    if not server then

        error(
            "Servidor não iniciado."
        )
    end

    while true do

        local client =
            server:accept()

        if client then

            client:settimeout(10)

            local request,
                request_error =
                read_request(client)

            if not request then

                send_response(
                    client,
                    400,
                    json.encode({
                        ok = false,
                        error =
                            "HTTP request inválida.",
                        detail =
                            tostring(
                                request_error
                            )
                    })
                )

            else

                if request.method ~= "POST" then

                    send_response(
                        client,
                        404,
                        json.encode({
                            ok = false,
                            error =
                                "Somente POST é suportado."
                        })
                    )

                elseif request.path ~= "/" then

                    send_response(
                        client,
                        404,
                        json.encode({
                            ok = false,
                            error =
                                "Endpoint inexistente."
                        })
                    )

                else

                    local response =
                        EditCopy.handle_request(
                            request.body
                        )

                    local status =
                        response.ok
                        and 200
                        or 400

                    send_response(
                        client,
                        status,
                        json.encode(response)
                    )
                end
            end

            client:close()
        end

        socket.sleep(0.01)
    end
end


return EditCopy
