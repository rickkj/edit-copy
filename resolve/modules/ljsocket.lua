local ffi = require("ffi")

ffi.cdef[[
    typedef unsigned short WORD;
    typedef unsigned int DWORD;
    typedef void* HANDLE;
    typedef HANDLE HWND;
    typedef unsigned long long SOCKET;
    typedef int socklen_t;

    typedef struct {
        WORD wVersion;
        WORD wHighVersion;
        char szDescription[257];
        char szSystemStatus[129];
        unsigned short iMaxSockets;
        unsigned short iMaxUdpDg;
        char *lpVendorInfo;
    } WSADATA;

    typedef struct {
        short sin_family;
        unsigned short sin_port;
        struct {
            unsigned char s_b1, s_b2, s_b3, s_b4;
        } sin_addr;
        char sin_zero[8];
    } sockaddr_in;

    typedef struct {
        int ai_flags;
        int ai_family;
        int ai_socktype;
        int ai_protocol;
        size_t ai_addrlen;
        char *ai_canonname;
        struct sockaddr *ai_addr;
        struct addrinfo *ai_next;
    } addrinfo;

    int WSAStartup(WORD wVersionRequested, WSADATA *lpWSAData);
    SOCKET socket(int af, int type, int protocol);
    int bind(SOCKET s, const struct sockaddr *name, int namelen);
    int listen(SOCKET s, int backlog);
    SOCKET accept(SOCKET s, struct sockaddr *addr, int *addrlen);
    int closesocket(SOCKET s);
    int send(SOCKET s, const char *buf, int len, int flags);
    int recv(SOCKET s, char *buf, int len, int flags);
    int ioctlsocket(SOCKET s, long cmd, unsigned long *argp);
    int setsockopt(SOCKET s, int level, int optname, const char *optval, int optlen);
    int getsockname(SOCKET s, struct sockaddr *name, int *namelen);
    int getpeername(SOCKET s, struct sockaddr *name, int *namelen);

    int getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res);
    void freeaddrinfo(struct addrinfo *res);

    int WSAGetLastError();
]]

local ws2 = ffi.load("ws2_32")

-- WSADATA setup
local wsaData = ffi.new("WSADATA")
ws2.WSAStartup(0x0202, wsaData)

local M = {}
local Socket = {}
Socket.__index = Socket

-- Constants (Windows specific)
local AF_INET = 2
local SOCK_STREAM = 1
local IPPROTO_TCP = 6
local SOL_SOCKET = 0xffff
local SO_REUSEADDR = 0x0004
local TCP_NODELAY = 0x0001
local IPPROTO_TCP_LEVEL = 6
local FIONBIO = 0x8004667E

function M.find_first_address(host, service, options)
    local hints = ffi.new("addrinfo")
    hints.ai_family = AF_INET
    hints.ai_socktype = SOCK_STREAM
    hints.ai_protocol = IPPROTO_TCP
    
    local res = ffi.new("addrinfo*[1]")
    local status = ws2.getaddrinfo(host, tostring(service), hints, res)
    
    if status ~= 0 then
        return nil, "getaddrinfo failed: " .. status
    end
    
    local info = res[0]
    local result = {
        family = info.ai_family,
        socket_type = info.ai_socktype,
        protocol = info.ai_protocol,
        addrlen = info.ai_addrlen,
        addr = ffi.new("char[?]", info.ai_addrlen)
    }
    ffi.copy(result.addr, info.ai_addr, info.ai_addrlen)
    
    ws2.freeaddrinfo(info)
    return result
end

function M.create(family, socket_type, protocol)
    local s = ws2.socket(family, socket_type, protocol)
    if s == -1 or s == 18446744073709551615 then
        return nil, "Socket creation failed"
    end
    return setmetatable({s = s}, Socket)
end

function Socket:set_blocking(block)
    local mode = ffi.new("unsigned long[1]", block and 0 or 1)
    if ws2.ioctlsocket(self.s, FIONBIO, mode) ~= 0 then
        return nil, "ioctlsocket failed"
    end
    return true
end

function Socket:set_option(name, value, level_name)
    local level = SOL_SOCKET
    local optname = 0
    
    if level_name == "tcp" then
        level = IPPROTO_TCP_LEVEL
        if name == "nodelay" then optname = TCP_NODELAY end
    elseif name == "reuseaddr" then
        optname = SO_REUSEADDR
    end
    
    local optval = ffi.new("int[1]", value and 1 or 0)
    if ws2.setsockopt(self.s, level, optname, ffi.cast("const char*", optval), ffi.sizeof("int")) ~= 0 then
        return nil, "setsockopt failed"
    end
    return true
end

function Socket:bind(info)
    if ws2.bind(self.s, ffi.cast("const struct sockaddr*", info.addr), info.addrlen) ~= 0 then
        return nil, "Bind failed: " .. ws2.WSAGetLastError()
    end
    return true
end

function Socket:listen(backlog)
    if ws2.listen(self.s, backlog or 5) ~= 0 then
        return nil, "Listen failed"
    end
    return true
end

function Socket:accept()
    local addr = ffi.new("sockaddr_in")
    local addrlen = ffi.new("int[1]", ffi.sizeof(addr))
    local client_s = ws2.accept(self.s, ffi.cast("struct sockaddr*", addr), addrlen)
    
    if client_s == -1 or client_s == 18446744073709551615 then 
        return nil, "timeout" -- Simplified for ljsocket pattern
    end

    return setmetatable({s = client_s}, Socket)
end

function Socket:get_peer_name()
    local addr = ffi.new("sockaddr_in")
    local addrlen = ffi.new("int[1]", ffi.sizeof(addr))
    if ws2.getpeername(self.s, ffi.cast("struct sockaddr*", addr), addrlen) == 0 then
        return string.format("%d.%d.%d.%d", addr.sin_addr.s_b1, addr.sin_addr.s_b2, addr.sin_addr.s_b3, addr.sin_addr.s_b4)
    end
    return nil, "getpeername failed"
end

function Socket:receive(len)
    local buffer = ffi.new("char[?]", len or 4096)
    local bytes = ws2.recv(self.s, buffer, len or 4096, 0)
    if bytes > 0 then
        return ffi.string(buffer, bytes)
    elseif bytes == 0 then
        return nil, "closed"
    else
        local err = ws2.WSAGetLastError()
        if err == 10035 then -- WSAEWOULDBLOCK
            return nil, "timeout"
        end
        return nil, "error: " .. err
    end
end

function Socket:send(data)
    local bytes = ws2.send(self.s, data, #data, 0)
    if bytes >= 0 then
        return bytes
    else
        return nil, "send failed: " .. ws2.WSAGetLastError()
    end
end

function Socket:close()
    ws2.closesocket(self.s)
end

-- Compat check
M.bind = function(...) error("Use find_first_address and create instead") end

return M
