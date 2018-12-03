use @import("index.zig");

pub const AF_UNSPEC = 0;
pub const AF_INET = 2;
pub const AF_IPX = 6;
pub const AF_APPLETALK = 16;
pub const AF_NETBIOS = 17;
pub const AF_INET6 = 23;
pub const AF_IRDA = 26;
pub const AF_BTH = 32;

pub const SD_RECEIVE = 0;
pub const SD_SEND = 1;
pub const SD_BOTH = 2;

pub const SOCK_STREAM = 1;
pub const SOCK_DGRAM = 2;
pub const SOCK_RAW = 3;
pub const SOCK_RDM = 4;
pub const SOCK_SEQPACKET = 5;

pub const FIONBIO = 0x8004667e;
pub const WSA_FLAG_NO_HANDLE_INHERIT = 0x80;

pub const SOL_SOCKET = 0xffff;
pub const SOMAXCONN = 0x7fffffff;

pub const SO_BROADCAST = 0x0020;

pub const SO_RCVTIMEO = 0x1006;
pub const SO_SNDTIMEO = 0x1005;
pub const SO_REUSEADDR = 0x0004;
pub const SO_ERROR = 0x1007;

pub const IPPROTO_ICMP = 1;
pub const IPPROTO_IGMP = 2;
pub const BTHPROTO_RFCOMM = 3;
pub const IPPROTO_TCP = 6;
pub const IPPROTO_UDP = 17;
pub const IPPROTO_ICMPV6 = 58;
pub const IPPROTO_RM = 113;

pub const TCP_NODELAY = 0x0001;

// pub const IP_TTL = 4;

// pub const IP_MULTICAST_TTL = 10;
// pub const IP_MULTICAST_LOOP = 11;
// pub const IP_ADD_MEMBERSHIP = 12;
// pub const IP_DROP_MEMBERSHIP = 13;

// pub const IPV6_MULTICAST_TTL = 10;
// pub const IPV6_MULTICAST_LOOP = 11;
// pub const IPV6_ADD_MEMBERSHIP = 12;
// pub const IPV6_DROP_MEMBERSHIP = 13;

// pub const MSG_PEEK: c_int = 0x2;
// pub const NI_MAXSERV = 32;
// pub const NI_MAXHOST = 1025;

// pub const ERROR_IO_PENDING = c_long(997);
// pub const ERROR_NETNAME_DELETED = c_long(64);
// pub const STATUS_PENDING = c_long(259);

pub const INVALID_SOCKET = ~SOCKET(0);

pub const SOCKET = usize;

pub const OVERLAPPED_COMPLETION_ROUTINE = stdcallcc fn(
    dwError: u16,
    cbTransferred: u16,
    lpOverlapped: *OVERLAPPED,
    dwFlags: u16
) void;

pub const in_port_t = c_ushort;
pub const sa_family_t = c_ushort;
pub const socklen_t = c_int;

pub const sockaddr = extern union {
    in: sockaddr_in,
    in6: sockaddr_in6,
};

pub const sockaddr_in = extern struct {
    family: sa_family_t,
    port: in_port_t,
    addr: DWORD,
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
    ai_next: ?*addrinfo,
};

pub const WSAData = extern struct {
    wVersion: WORD,
    wHighVersion: WORD,
    iMaxSockets: c_ushort,
    iMaxUdpDg: c_ushort,
    lpVendorInfo: ?[*]u8,
    szDescription: [257]u8,
    szSystemStatus: [129]u8,
};

pub const WSABuf = extern struct {
    len: usize,
    buf: [*]u8,
};

pub const WSABufConst = extern struct {
    len: usize,
    buf: [*]const u8,
};

pub const WSAMSG = extern struct {
    name: *sockaddr,
    namelen: INT,
    lpBuffers: *WSABuf,
    dwBufferCount: ULONG,
    Control: WSABuf,
    dwFlags: ULONG,
};

// TODO use GetNameInfoW?
pub extern "ws2_32" stdcallcc fn getnameinfo(
    pSockaddr: *const sockaddr,
    SockaddrLength: socklen_t,
    pNodeBuffer: [*]u8,
    NodeBufferSize: DWORD,
    pServiceBuffer: [*]u8,
    ServiceBufferSize: DWORD,
    Flags: c_int,
) c_int;

// TODO use GetAddrInfoW?
pub extern "ws2_32" stdcallcc fn getaddrinfo(
  pNodeName: ?[*]const u8,
  pServiceName: [*]const u8,
  pHints: *const addrinfo,
  ppResult: **addrinfo,
) c_int;

pub extern "ws2_32" stdcallcc fn freeaddrinfo(pAddrInfo: *addrinfo) void;

// TODO use these?
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetProtoByName(hWnd: HWND, wMsg: u_int, name: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetProtoByNumber(hWnd: HWND, wMsg: u_int, number: c_int, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetServByName(hWnd: HWND, wMsg: u_int, name: ?[*]const u8, proto: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetServByPort(hWnd: HWND, wMsg: u_int, port: c_int, proto: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSACancelAsyncRequest(hAsyncTaskHandle: HANDLE) c_int;

pub extern "ws2_32" stdcallcc fn WSACleanup() c_int;

pub extern "ws2_32" stdcallcc fn WSAGetLastError() c_int;

pub extern "ws2_32" stdcallcc fn WSAStartup(wVersionRequired: WORD, lpWSAData: *WSAData) c_int;

pub extern "ws2_32" stdcallcc fn getsockname(s: SOCKET, name: ?*sockaddr, namelen: ?*socklen_t) c_int;

pub extern "ws2_32" stdcallcc fn getpeername(s: SOCKET, name: ?*sockaddr, namelen: ?*socklen_t) c_int;

pub extern "ws2_32" stdcallcc fn socket(af: c_int, @"type": c_int, protocol: c_int) SOCKET;

pub extern "ws2_32" stdcallcc fn setsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]const u8, optlen: c_int) c_int;

pub extern "ws2_32" stdcallcc fn getsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]u8, optlen: ?*c_int) c_int;

pub extern "ws2_32" stdcallcc fn connect(s: SOCKET, name: ?*const sockaddr, namelen: socklen_t) c_int;

pub extern "ws2_32" stdcallcc fn recvfrom(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int, from: ?*sockaddr, fromlen: ?*c_int) c_int;

pub extern "ws2_32" stdcallcc fn shutdown(s: SOCKET, how: c_int) c_int;

pub extern "ws2_32" stdcallcc fn bind(s: SOCKET, addr: *const sockaddr, namelen: socklen_t) c_int;

pub extern "ws2_32" stdcallcc fn listen(s: SOCKET, backlog: c_int) c_int;

pub extern "ws2_32" stdcallcc fn sendto(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int, to: ?*const sockaddr, tolen: c_int) c_int;

pub extern "ws2_32" stdcallcc fn accept(s: SOCKET, addr: ?*sockaddr, addrlen: ?*c_int) SOCKET;

pub extern "ws2_32" stdcallcc fn closesocket(s: SOCKET) c_int;

pub extern "ws2_32" stdcallcc fn ioctlsocket(s: SOCKET, cmd: c_ulong, argp: ?*c_ulong) c_int;

pub extern "ws2_32" stdcallcc fn send(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int) c_int;

pub extern "ws2_32" stdcallcc fn recv(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int) c_int;

// TODO delete these?
// pub extern "ws2_32" stdcallcc fn gethostname(name: ?[*]u8, namelen: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn getprotobyname(name: ?[*]const u8) ?*struct_protoent;
// pub extern "ws2_32" stdcallcc fn getprotobynumber(proto: c_int) ?*struct_protoent;
// pub extern "ws2_32" stdcallcc fn getservbyname(name: ?[*]const u8, proto: ?[*]const u8) ?*struct_servent;
// pub extern "ws2_32" stdcallcc fn getservbyport(port: c_int, proto: ?[*]const u8) ?*struct_servent;
// pub extern "ws2_32" stdcallcc fn inet_ntop(Family: c_int, pAddr: *const c_void, pStringBuf: [*]u8, StringBufSize: c_ulong) ?[*]u8;
// pub extern "ws2_32" stdcallcc fn select(nfds: c_int, readfds: ?*fd_set, writefds: ?*fd_set, exceptfds: ?*fd_set, timeout: ?*const struct_timeval) c_int;

// pub extern "ws2_32" stdcallcc fn WSASocketW(
//     af: c_int,
//     @"type": c_int,
//     protocol: c_int,
//     lpProtocolInfo: ?*c_void,
//     g: c_uint,
//     dwFlags: DWORD,
// ) SOCKET;

pub extern "ws2_32" stdcallcc fn WSASendMsg(
    s: SOCKET,
    lpMsg: *WSAMSG,
    dwFlags: DWORD,
    lpNumberOfBytesSent: *DWORD,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

pub extern "ws2_32" stdcallcc fn WSARecvMsg(
    s: SOCKET,
    lpMsg: *WSAMSG,
    lpdwNumberOfBytesRecvd: *DWORD,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE,
) c_int;

pub extern "ws2_32" stdcallcc fn WSARecvFrom(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: DWORD,
    lpNumberOfBytesSent: *DWORD,
    lpFlags: *DWORD,
    lpFrom: *sockaddr,
    lpFromlen: *c_int,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

pub extern "ws2_32" stdcallcc fn WSASendTo(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: DWORD,
    lpNumberOfBytesSent: *DWORD,
    dwFlags: DWORD, lpTo: *const sockaddr,
    iTolen: c_int, lpOverlapped: *OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

pub extern "ws2_32" stdcallcc fn WSASend(
    s: SOCKET,
    lpBuffers: [*]WSABufConst,
    dwBufferCount: DWORD,
    lpNumberOfBytesSent: *DWORD,
    dwFlags: DWORD,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

pub extern "ws2_32" stdcallcc fn WSARecv(
    s: SOCKET,
    lpBuffers: [*]WSABuf,
    dwBufferCount: DWORD,
    lpNumberOfBytesRecvd: *DWORD,
    lpFlags: *DWORD,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

