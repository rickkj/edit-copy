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

    int WSAStartup(WORD wVersionRequested, WSADATA *lpWSAData);
    SOCKET socket(int af, int type, int protocol);
    int bind(SOCKET s, const struct sockaddr *name, int namelen);
    int listen(SOCKET s, int backlog);
    SOCKET accept(SOCKET s, struct sockaddr *addr, int *addrlen);
    int closesocket(SOCKET s);
    int send(SOCKET s, const char *buf, int len, int flags);
    int recv(SOCKET s, char *buf, int len, int flags);
    int ioctlsocket(SOCKET s, long cmd, unsigned long *argp);
    int select(int nfds, void *readfds, void *writefds, void *exceptfds, const struct timeval *timeout);
    int WSAGetLastError();
]]

local ws2 = ffi.load("ws2_32")

-- WSADATA setup
local wsaData = ffi.new("WSADATA")
ws2.WSAStartup(0x0202, wsaData)

local ljsocket = {}
local Socket = {}
Socket.__index = Socket

function ljsocket.bind(host, port)
    local s = ws2.socket(2, 1, 6) -- AF_INET, SOCK_STREAM, IPPROTO_TCP
    if s == -1 then return nil, "Socket creation failed" end

    -- Set non-blocking
    local mode = ffi.new("unsigned long[1]", 1)
    ws2.ioctlsocket(s, 0x8004667E, mode) -- FIONBIO

    local addr = ffi.new("sockaddr_in")
    addr.sin_family = 2
    addr.sin_port = tonumber(ffi.cast("unsigned short", (port % 256) * 256 + math.floor(port / 256)))
    
    -- 127.0.0.1
    addr.sin_addr.s_b1 = 127
    addr.sin_addr.s_b2 = 0
    addr.sin_addr.s_b3 = 0
    addr.sin_addr.s_b4 = 1

    if ws2.bind(s, ffi.cast("const struct sockaddr*", addr), ffi.sizeof(addr)) ~= 0 then
        ws2.closesocket(s)
        return nil, "Bind failed"
    end

    if ws2.listen(s, 5) ~= 0 then
        ws2.closesocket(s)
        return nil, "Listen failed"
    end

    return setmetatable({s = s}, Socket)
end

function Socket:accept()
    local addr = ffi.new("sockaddr_in")
    local addrlen = ffi.new("int[1]", ffi.sizeof(addr))
    local client_s = ws2.accept(self.s, ffi.cast("struct sockaddr*", addr), addrlen)
    
    if client_s == -1 or client_s == 18446744073709551615 then 
        return nil 
    end

    return setmetatable({s = client_s}, Socket)
end

function Socket:receive(pattern)
    local buffer = ffi.new("char[4096]")
    local bytes = ws2.recv(self.s, buffer, 4096, 0)
    if bytes > 0 then
        local data = ffi.string(buffer, bytes)
        if pattern == "*l" then
            local line = data:match("([^\r\n]*)")
            return line
        end
        return data
    end
    return nil, "No data"
end

function Socket:send(data)
    ws2.send(self.s, data, #data, 0)
end

function Socket:close()
    ws2.closesocket(self.s)
end

function Socket:settimeout(t)
    -- Mock for compat
end

function ljsocket.sleep(t)
    local start = os.clock()
    while os.clock() - start < t do end
end

return ljsocket
