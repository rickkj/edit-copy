local json = require("dkjson")
local socket = require("ljsocket")
local ffi = require("ffi")

local EditCopy = {}
local handlers = {}
local server = nil
local HOST = "127.0.0.1"
local PORT = 56005

local function create_response(body)
    local header =
        "HTTP/1.1 200 OK\r\n"
        .. "Server: EditCOPY/0.1\r\n"
        .. "Content-Type: application/json\r\n"
        .. "Content-Length: "
        .. tostring(#body)
        .. "\r\n"
        .. "Connection: close\r\n"
        .. "\r\n"

    return header .. body
end

function EditCopy.start_server(port)
    if server then
        print("[EditCOPY Lua] Server já iniciado.")
        return server
    end

    local actual_port = port or PORT
    
    local info, err = socket.find_first_address(HOST, actual_port)
    if not info then
        error("[EditCOPY Lua] find_first_address falhou: " .. tostring(err))
    end
    print("[EditCOPY Lua] find_first_address OK")
    
    local srv, create_err = socket.create(info.family, info.socket_type, info.protocol)
    if not srv then
        error("[EditCOPY Lua] socket.create falhou: " .. tostring(create_err))
    end
    print("[EditCOPY Lua] socket.create OK")

    -- MUDANÇA V14: NUNCA usar set_blocking(false)
    -- O socket permanece no modo padrão blocking.

    assert(srv:set_option("nodelay", true, "tcp"))
    assert(srv:set_option("reuseaddr", true))
    
    local bind_ok, bind_err = srv:bind(info)
    if not bind_ok then
        error("[EditCOPY Lua] server.bind falhou: " .. tostring(bind_err))
    end
    print("[EditCOPY Lua] server.bind OK")

    local listen_ok, listen_err = srv:listen()
    if not listen_ok then
        error("[EditCOPY Lua] server.listen falhou: " .. tostring(listen_err))
    end
    print("[EditCOPY Lua] server.listen OK")

    server = srv
    return server
end

handlers["Ping"] = function(data)
    return {
        ok = true,
        func = "Ping",
        data = {
            message = "EditCOPY Lua server is alive"
        }
    }
end

function EditCopy.run()
    if not server then
        error("Servidor não iniciado.")
    end

    while true do
        print("[EditCOPY HTTP] Aguardando conexão...")
        
        -- server:accept() vai bloquear aqui até receber uma conexão (intencional)
        local client, err = server:accept()

        if client then
            print("[EditCOPY HTTP] Cliente conectado.")
            
            -- O cliente também permanece em modo BLOCKING.
            
            -- Leitura da requisição HTTP de forma blocking
            local request = ""
            local body_received = false
            
            -- Recebe o primeiro chunk
            local first_chunk, recv_err = client:receive()
            if first_chunk then
                request = first_chunk
                print("[EditCOPY HTTP] Request recebida.")
                
                -- Procura o fim dos headers
                while true do
                    local sep_start, sep_end = string.find(request, "\r\n\r\n", 1, true)
                    if sep_end then
                        local headers = string.sub(request, 1, sep_start - 1)
                        local body_start_idx = sep_end + 1
                        local content_length = string.match(headers, "[Cc]ontent%-[Ll]ength:%s*(%d+)")
                        
                        if content_length then
                            local needed = tonumber(content_length)
                            local current = #request - (body_start_idx - 1)
                            
                            if current >= needed then
                                request = string.sub(request, 1, body_start_idx + needed - 1)
                                body_received = true
                                break
                            else
                                -- Recebe mais dados se o body estiver incompleto
                                local chunk, next_err = client:receive()
                                if chunk then
                                    request = request .. chunk
                                else
                                    break
                                end
                            end
                        else
                            -- Se não tem Content-Length, assume que não tem body ou terminou nos headers
                            body_received = true
                            break
                        end
                    else
                        -- Continua recebendo headers
                        local chunk, next_err = client:receive()
                        if chunk then
                            request = request .. chunk
                        else
                            break
                        end
                    end
                end
            end

            if body_received then
                local _, sep_end = string.find(request, "\r\n\r\n", 1, true)
                local body = string.sub(request, sep_end + 1)
                print("[EditCOPY HTTP] Body recebido.")

                local ok, data = pcall(json.decode, body, 1, nil)
                if ok and data then
                    local func = data.func
                    print("[EditCOPY HTTP] Function: " .. tostring(func))
                    
                    local handler = handlers[func]
                    if handler then
                        local success, result = pcall(handler, data)
                        if success then
                            local response_body = json.encode(result)
                            client:send(create_response(response_body))
                            print("[EditCOPY HTTP] Response enviada.")
                        end
                    end
                end
            end
            
            client:close()
            print("[EditCOPY HTTP] Cliente desconectado.")
        else
            print("[EditCOPY HTTP] Accept error:", tostring(err))
            break
        end
    end
end

return EditCopy
