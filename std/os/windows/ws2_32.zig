use @import("index.zig");

pub const BASEERR = 10000;
pub const DESCRIPTION_LEN = 256;
pub const EACCES = c_long(10013);
pub const EADDRINUSE = c_long(10048);
pub const EADDRNOTAVAIL = c_long(10049);
pub const EAFNOSUPPORT = c_long(10047);
pub const EALREADY = c_long(10037);
pub const EBADF = c_long(10009);
pub const ECANCELLED = c_long(10103);
pub const ECONNABORTED = c_long(10053);
pub const ECONNREFUSED = c_long(10061);
pub const ECONNRESET = c_long(10054);
pub const EDESTADDRREQ = c_long(10039);
pub const EDISCON = c_long(10101);
pub const EDQUOT = c_long(10069);
pub const EFAULT = c_long(10014);
pub const EHOSTDOWN = c_long(10064);
pub const EHOSTUNREACH = c_long(10065);
pub const EINPROGRESS = c_long(10036);
pub const EINTR = c_long(10004);
pub const EINVAL = c_long(10022);
pub const EINVALIDPROCTABLE = c_long(10104);
pub const EINVALIDPROVIDER = c_long(10105);
pub const EISCONN = c_long(10056);
pub const ELOOP = c_long(10062);
pub const EMFILE = c_long(10024);
pub const EMSGSIZE = c_long(10040);
pub const ENAMETOOLONG = c_long(10063);
pub const ENETDOWN = c_long(10050);
pub const ENETRESET = c_long(10052);
pub const ENETUNREACH = c_long(10051);
pub const ENOBUFS = c_long(10055);
pub const ENOMORE = c_long(10102);
pub const ENOPROTOOPT = c_long(10042);
pub const ENOTCONN = c_long(10057);
pub const ENOTEMPTY = c_long(10066);
pub const ENOTSOCK = c_long(10038);
pub const EOPNOTSUPP = c_long(10045);
pub const EPFNOSUPPORT = c_long(10046);
pub const EPROCLIM = c_long(10067);
pub const EPROTONOSUPPORT = c_long(10043);
pub const EPROTOTYPE = c_long(10041);
pub const EPROVIDERFAILEDINIT = c_long(10106);
pub const EREFUSED = c_long(10112);
pub const EREMOTE = c_long(10071);
pub const ESHUTDOWN = c_long(10058);
pub const ESOCKTNOSUPPORT = c_long(10044);
pub const ESTALE = c_long(10070);
pub const ETIMEDOUT = c_long(10060);
pub const ETOOMANYREFS = c_long(10059);
pub const EUSERS = c_long(10068);
pub const EWOULDBLOCK = c_long(10035);
pub const HOST_NOT_FOUND = c_long(11001);
pub const NOTINITIALISED = c_long(10093);
pub const NO_ADDRESS = WSANO_DATA;
pub const NO_DATA = c_long(11004);
pub const NO_RECOVERY = c_long(11003);
pub const SERVICE_NOT_FOUND = c_long(10108);
pub const SYSCALLFAILURE = c_long(10107);
pub const SYSNOTREADY = c_long(10091);
pub const SYS_STATUS_LEN = 128;
pub const TRY_AGAIN = c_long(11002);
pub const TYPE_NOT_FOUND = c_long(10109);
pub const VERNOTSUPPORTED = c_long(10092);
pub const ERROR_IO_PENDING = c_long(997);
pub const ERROR_NETNAME_DELETED = c_long(64);
pub const STATUS_PENDING = c_long(259);

pub const SOCKET = usize;

pub const OVERLAPPED_COMPLETION_ROUTINE = stdcallcc fn(
    dwError: u16,
    cbTransferred: u16,
    lpOverlapped: LPOVERLAPPED,
    dwFlags: u16
) void;

pub const in_port_t = c_ushort;
pub const sa_family_t = c_ushort;
pub const socklen_t = c_ulong;

pub const sockaddr = extern union {
    in: sockaddr_in,
    in6: sockaddr_in6,
};

pub const sockaddr_in = extern struct {
    family: sa_family_t,
    port: in_port_t,
    addr: [2]u16,
    zero: [8]u8,
};

pub const sockaddr_in6 = extern struct {
    family: sa_family_t,
    port: in_port_t,
    flowinfo: c_ulong,
    addr: [16]u8,
    scope_id: c_ulong,
};

pub const addrinfo = extern struct {
    ai_flags: c_int,
    ai_family: c_int,
    ai_socktype: c_int,
    ai_protocol: c_int,
    ai_addrlen: usize,
    ai_canonname: [*]u8,
    ai_addr: *sockaddr,
    ai_next: *addrinfo,
};

pub const WSABuf = extern struct {
    len: c_ulong,
    buf: [*]u8
};

pub extern "ws2_32" stdcallcc fn getnameinfo(
    pSockaddr: *const sockaddr,
    SockaddrLength: socklen_t,
    pNodeBuffer: [*]u8,
    NodeBufferSize: u32,
    pServiceBuffer: [*]u8,
    ServiceBufferSize: u32,
    Flags: c_int,
) c_int;
pub extern "ws2_32" stdcallcc fn getaddrinfo(
  pNodeName: [*]u8,
  pServiceName: [*]u8,
  pHints: *addrinfo,
  ppResult: **addrinfo,
) c_int;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetProtoByName(hWnd: HWND, wMsg: u_int, name: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetProtoByNumber(hWnd: HWND, wMsg: u_int, number: c_int, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetServByName(hWnd: HWND, wMsg: u_int, name: ?[*]const u8, proto: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetServByPort(hWnd: HWND, wMsg: u_int, port: c_int, proto: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSACancelAsyncRequest(hAsyncTaskHandle: HANDLE) c_int;
pub extern "ws2_32" stdcallcc fn WSACancelBlockingCall() c_int;
pub extern "ws2_32" stdcallcc fn WSACleanup() c_int;
pub extern "ws2_32" stdcallcc fn WSAGetLastError() c_int;
pub extern "ws2_32" stdcallcc fn WSAIsBlocking() BOOL;
pub extern "ws2_32" stdcallcc fn WSASetLastError(iError: c_int) void;
pub extern "ws2_32" stdcallcc fn WSAStartup(wVersionRequired: WORD, lpWSAData: LPWSADATA) c_int;
pub extern "ws2_32" stdcallcc fn WSAUnhookBlockingHook() c_int;
pub extern "ws2_32" stdcallcc fn WSARecv(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: u32,
    lpNumberOfBytesSent: *u32,
    lpFlags: *u32,
    lpOverlapped: *OVERLAPPED,
    lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
) c_int;
pub extern "ws2_32" stdcallcc fn WSARecvFrom(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: u32,
    lpNumberOfBytesSent: *u32,
    lpFlags: *u32,
    lpFrom: *sockaddr,
    lpFromlen: *c_int,
    lpOverlapped: *OVERLAPPED,
    lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
) c_int;
pub extern "ws2_32" stdcallcc fn WSASend(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: u32,
    lpNumberOfBytesSent: *u32,
    dwFlags: u32,
    lpOverlapped: *OVERLAPPED,
    lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
) c_int;
pub extern "ws2_32" stdcallcc fn WSASendTo(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: u32,
    lpNumberOfBytesSent: *u32,
    dwFlags: u32, lpTo: *const sockaddr,
    iTolen: c_int, lpOverlapped: *OVERLAPPED,
    lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
) c_int;
pub extern "ws2_32" stdcallcc fn accept(s: SOCKET, addr: ?*struct_sockaddr, addrlen: ?*c_int) SOCKET;
pub extern "ws2_32" stdcallcc fn bind(s: SOCKET, addr: ?*const struct_sockaddr, namelen: c_int) c_int;
pub extern "ws2_32" stdcallcc fn closesocket(s: SOCKET) c_int;
pub extern "ws2_32" stdcallcc fn connect(s: SOCKET, name: ?*const struct_sockaddr, namelen: c_int) c_int;
pub extern "ws2_32" stdcallcc fn gethostname(name: ?[*]u8, namelen: c_int) c_int;
pub extern "ws2_32" stdcallcc fn getpeername(s: SOCKET, name: ?*struct_sockaddr, namelen: ?*c_int) c_int;
pub extern "ws2_32" stdcallcc fn getprotobyname(name: ?[*]const u8) ?*struct_protoent;
pub extern "ws2_32" stdcallcc fn getprotobynumber(proto: c_int) ?*struct_protoent;
pub extern "ws2_32" stdcallcc fn getservbyname(name: ?[*]const u8, proto: ?[*]const u8) ?*struct_servent;
pub extern "ws2_32" stdcallcc fn getservbyport(port: c_int, proto: ?[*]const u8) ?*struct_servent;
pub extern "ws2_32" stdcallcc fn getsockname(s: SOCKET, name: ?*struct_sockaddr, namelen: ?*c_int) c_int;
pub extern "ws2_32" stdcallcc fn getsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]u8, optlen: ?*c_int) c_int;
pub extern "ws2_32" stdcallcc fn htonl(hostlong: u_long) u_long;
pub extern "ws2_32" stdcallcc fn htons(hostshort: u_short) u_short;
pub extern "ws2_32" stdcallcc fn inet_addr(cp: ?[*]const u8) c_ulong;
pub extern "ws2_32" stdcallcc fn inet_ntoa(in: struct_in_addr) ?[*]u8;
pub extern "ws2_32" stdcallcc fn ioctlsocket(s: SOCKET, cmd: c_long, argp: ?*u_long) c_int;
pub extern "ws2_32" stdcallcc fn listen(s: SOCKET, backlog: c_int) c_int;
pub extern "ws2_32" stdcallcc fn ntohl(netlong: u_long) u_long;
pub extern "ws2_32" stdcallcc fn ntohs(netshort: u_short) u_short;
pub extern "ws2_32" stdcallcc fn recv(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int) c_int;
pub extern "ws2_32" stdcallcc fn recvfrom(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int, from: ?*struct_sockaddr, fromlen: ?*c_int) c_int;
pub extern "ws2_32" stdcallcc fn select(nfds: c_int, readfds: ?*fd_set, writefds: ?*fd_set, exceptfds: ?*fd_set, timeout: ?*const struct_timeval) c_int;
pub extern "ws2_32" stdcallcc fn send(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int) c_int;
pub extern "ws2_32" stdcallcc fn sendto(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int, to: ?*const struct_sockaddr, tolen: c_int) c_int;
pub extern "ws2_32" stdcallcc fn setsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]const u8, optlen: c_int) c_int;
pub extern "ws2_32" stdcallcc fn shutdown(s: SOCKET, how: c_int) c_int;
pub extern "ws2_32" stdcallcc fn socket(af: c_int, type_0: c_int, protocol: c_int) SOCKET;
