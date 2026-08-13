local json = require("dkjson")
local socket = require("ljsocket")
local ffi = require("ffi")

ffi.cdef[[
    void Sleep(unsigned int ms);
]]

local function sleep(seconds)
    ffi.C.Sleep(math.floor(seconds * 1000))
end

local EditCopy = {}
local handlers = {}
local server = nil
local HOST = "127.0.0.1"
local PORT = 56003

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
    local info = assert(socket.find_first_address(HOST, actual_port))
    print("[EditCOPY Lua] find_first_address OK")
    local srv = assert(socket.create(info.family, info.socket_type, info.protocol))
    print("[EditCOPY Lua] socket.create OK")

    assert(srv:set_blocking(false))
    assert(srv:set_option("nodelay", true, "tcp"))
    assert(srv:set_option("reuseaddr", true))
    assert(srv:bind(info))
    assert(srv:listen())

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
        local client, err = server:accept()

        if client then
            print("[EditCOPY HTTP] Client accepted")
            
            local peername, peer_err = client:get_peer_name()
            if peername then
                assert(client:set_blocking(false))

                local request = ""
                local receive_err = nil
                
                -- Loop de leitura da requisição HTTP (estilo AutoSubs)
                while true do
                    local sep_start, sep_end = string.find(request, "\r\n\r\n", 1, true)

                    if sep_end then
                        print("[EditCOPY HTTP] Headers received")
                        local headers = string.sub(request, 1, sep_start - 1)
                        local body_start_idx = sep_end + 1
                        local content_length = string.match(headers, "[Cc]ontent%-[Ll]ength:%s*(%d+)")

                        if content_length then
                            local needed = tonumber(content_length)
                            print("[EditCOPY HTTP] Content-Length: " .. tostring(needed))
                            local current = #request - (body_start_idx - 1)

                            if current >= needed then
                                print("[EditCOPY HTTP] Body received")
                                break
                            end
                        else
                            break
                        end
                    end

                    local chunk, recv_err, partial = client:receive(1024)
                    
                    if chunk and #chunk > 0 then
                        if request == "" then print("[EditCOPY HTTP] Received raw request") end
                        request = request .. chunk
                    elseif partial and #partial > 0 then
                        if request == "" then print("[EditCOPY HTTP] Received raw request") end
                        request = request .. partial
                    else
                        -- Se não recebeu nada e não deu erro de timeout, ou se deu outro erro, sai do loop
                        if recv_err ~= "timeout" then
                            break
                        end
                        -- Se deu timeout, esperamos um pouco e tentamos ler mais no próximo loop do client:receive
                        sleep(0.01)
                    end
                end

                -- Processamento da requisição completa
                local _, sep_end = string.find(request, "\r\n\r\n", 1, true)
                if sep_end then
                    local body = string.sub(request, sep_end + 1)
                    print("[EditCOPY HTTP] Body:", tostring(body))

                    local ok, data = pcall(json.decode, body, 1, nil)
                    
                    if ok and data then
                        print("[EditCOPY HTTP] JSON decoded")
                        local func = data.func
                        print("[EditCOPY HTTP] Function: " .. tostring(func))
                        
                        local handler = handlers[func]
                        if handler then
                            local success, result = pcall(handler, data)
                            if success then
                                print("[EditCOPY HTTP] Handler completed")
                                local response_body = json.encode(result)
                                print("[EditCOPY HTTP] Sending response")
                                local sent, send_error = client:send(create_response(response_body))
                                if sent then
                                    print("[EditCOPY HTTP] Response sent")
                                else
                                    print("[EditCOPY HTTP] Send failed:", send_error or "unknown")
                                end
                            else
                                print("[EditCOPY HTTP] Handler error:", tostring(result))
                            end
                        else
                            print("[EditCOPY HTTP] No handler for:", tostring(func))
                        end
                    else
                        print("[EditCOPY HTTP] JSON decode failed")
                    end
                end
                
                client:close()
            end
        elseif err ~= "timeout" then
            print("[EditCOPY HTTP] Accept error:", err)
        end

        sleep(0.1)
    end
end

return EditCopy

