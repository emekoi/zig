use @import("index.zig");

// pub const WSABASEERR = 10000;
// pub const WSADESCRIPTION_LEN = 256;
// pub const WSAEACCES = c_long(10013);
// pub const WSAEADDRINUSE = c_long(10048);
// pub const WSAEADDRNOTAVAIL = c_long(10049);
// pub const WSAEAFNOSUPPORT = c_long(10047);
// pub const WSAEALREADY = c_long(10037);
// pub const WSAEBADF = c_long(10009);
// pub const WSAECANCELLED = c_long(10103);
// pub const WSAECONNABORTED = c_long(10053);
// pub const WSAECONNREFUSED = c_long(10061);
// pub const WSAECONNRESET = c_long(10054);
// pub const WSAEDESTADDRREQ = c_long(10039);
// pub const WSAEDISCON = c_long(10101);
// pub const WSAEDQUOT = c_long(10069);
// pub const WSAEFAULT = c_long(10014);
// pub const WSAEHOSTDOWN = c_long(10064);
// pub const WSAEHOSTUNREACH = c_long(10065);
// pub const WSAEINPROGRESS = c_long(10036);
// pub const WSAEINTR = c_long(10004);
// pub const WSAEINVAL = c_long(10022);
// pub const WSAEINVALIDPROCTABLE = c_long(10104);
// pub const WSAEINVALIDPROVIDER = c_long(10105);
// pub const WSAEISCONN = c_long(10056);
// pub const WSAELOOP = c_long(10062);
// pub const WSAEMFILE = c_long(10024);
// pub const WSAEMSGSIZE = c_long(10040);
// pub const WSAENAMETOOLONG = c_long(10063);
// pub const WSAENETDOWN = c_long(10050);
// pub const WSAENETRESET = c_long(10052);
// pub const WSAENETUNREACH = c_long(10051);
// pub const WSAENOBUFS = c_long(10055);
// pub const WSAENOMORE = c_long(10102);
// pub const WSAENOPROTOOPT = c_long(10042);
// pub const WSAENOTCONN = c_long(10057);
// pub const WSAENOTEMPTY = c_long(10066);
// pub const WSAENOTSOCK = c_long(10038);
// pub const WSAEOPNOTSUPP = c_long(10045);
// pub const WSAEPFNOSUPPORT = c_long(10046);
// pub const WSAEPROCLIM = c_long(10067);
// pub const WSAEPROTONOSUPPORT = c_long(10043);
// pub const WSAEPROTOTYPE = c_long(10041);
// pub const WSAEPROVIDERFAILEDINIT = c_long(10106);
// pub const WSAEREFUSED = c_long(10112);
// pub const WSAEREMOTE = c_long(10071);
// pub const WSAESHUTDOWN = c_long(10058);
// pub const WSAESOCKTNOSUPPORT = c_long(10044);
// pub const WSAESTALE = c_long(10070);
// pub const WSAETIMEDOUT = c_long(10060);
// pub const WSAETOOMANYREFS = c_long(10059);
// pub const WSAEUSERS = c_long(10068);
// pub const WSAEWOULDBLOCK = c_long(10035);
// pub const WSAHOST_NOT_FOUND = c_long(11001);
// pub const WSANOTINITIALISED = c_long(10093);
// pub const WSANO_ADDRESS = WSANO_DATA;
// pub const WSANO_DATA = c_long(11004);
// pub const WSANO_RECOVERY = c_long(11003);
// pub const WSASERVICE_NOT_FOUND = c_long(10108);
// pub const WSASYSCALLFAILURE = c_long(10107);
// pub const WSASYSNOTREADY = c_long(10091);
// pub const WSASYS_STATUS_LEN = 128;
// pub const WSATRY_AGAIN = c_long(11002);
// pub const WSATYPE_NOT_FOUND = c_long(10109);
// pub const WSAVERNOTSUPPORTED = c_long(10092);

pub const AF_UNSPEC = 0;
pub const AF_INET = 2;
pub const AF_INET6 = 23;
// pub const SD_BOTH = 2;
// pub const SD_RECEIVE = 0;
// pub const SD_SEND = 1;
pub const SOCK_STREAM = 1;
pub const SOCK_DGRAM = 2;
pub const SOCK_RAW = 3;
pub const SOCK_RDM = 4;
pub const SOCK_SEQPACKET = 5;
// pub const SOL_SOCKET = 0xffff;
pub const SOMAXCONN = 0x7fffffff;
// pub const SO_RCVTIMEO = 0x1006;
// pub const SO_SNDTIMEO = 0x1005;
// pub const SO_REUSEADDR = 0x0004;
pub const IPPROTO_TCP = 6;
pub const IPPROTO_UDP = 17;
pub const IPPROTO_RM = 113;
// pub const TCP_NODELAY = 0x0001;
// pub const IP_TTL = 4;
// pub const IPV6_V6ONLY = 27;
// pub const SO_ERROR = 0x1007;
// pub const SO_BROADCAST = 0x0020;
// pub const IP_MULTICAST_LOOP = 11;
// pub const IPV6_MULTICAST_LOOP = 11;
// pub const IP_MULTICAST_TTL = 10;
// pub const IP_ADD_MEMBERSHIP = 12;
// pub const IP_DROP_MEMBERSHIP = 13;
// pub const IPV6_ADD_MEMBERSHIP = 12;
// pub const IPV6_DROP_MEMBERSHIP = 13;
// pub const MSG_PEEK: c_int = 0x2;

pub const NI_MAXSERV = 32;
pub const NI_MAXHOST = 1025;

// pub const ERROR_IO_PENDING = c_long(997);
// pub const ERROR_NETNAME_DELETED = c_long(64);
// pub const STATUS_PENDING = c_long(259);

pub const SOCKET = usize;
pub const INVALID_SOCKET = ~SOCKET(0);

// pub const OVERLAPPED_COMPLETION_ROUTINE = stdcallcc fn(
//     dwError: u16,
//     cbTransferred: u16,
//     lpOverlapped: LPOVERLAPPED,
//     dwFlags: u16
// ) void;

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
    addr: u32,
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

// pub const WSABuf = extern struct {
//     len: c_ulong,
//     buf: [*]u8
// };

// pub extern "ws2_32" stdcallcc fn getnameinfo(
//     pSockaddr: *const sockaddr,
//     SockaddrLength: socklen_t,
//     pNodeBuffer: [*]u8,
//     NodeBufferSize: u32,
//     pServiceBuffer: [*]u8,
//     ServiceBufferSize: u32,
//     Flags: c_int,
// ) c_int;
pub extern "ws2_32" stdcallcc fn freeaddrinfo(pAddrInfo: *addrinfo) void;
pub extern "ws2_32" stdcallcc fn getaddrinfo(
  pNodeName: ?[*]const u8,
  pServiceName: [*]const u8,
  pHints: *const addrinfo,
  ppResult: **addrinfo,
) c_int;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetProtoByName(hWnd: HWND, wMsg: u_int, name: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetProtoByNumber(hWnd: HWND, wMsg: u_int, number: c_int, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetServByName(hWnd: HWND, wMsg: u_int, name: ?[*]const u8, proto: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSAAsyncGetServByPort(hWnd: HWND, wMsg: u_int, port: c_int, proto: ?[*]const u8, buf: ?[*]u8, buflen: c_int) HANDLE;
// pub extern "ws2_32" stdcallcc fn WSACancelAsyncRequest(hAsyncTaskHandle: HANDLE) c_int;
// pub extern "ws2_32" stdcallcc fn WSACancelBlockingCall() c_int;
pub extern "ws2_32" stdcallcc fn WSACleanup() c_int;
pub extern "ws2_32" stdcallcc fn WSAGetLastError() c_int;
// pub extern "ws2_32" stdcallcc fn WSAIsBlocking() BOOL;
// pub extern "ws2_32" stdcallcc fn WSASetLastError(iError: c_int) void;
pub extern "ws2_32" stdcallcc fn WSAStartup(wVersionRequired: WORD, lpWSAData: *WSAData) c_int;
// pub extern "ws2_32" stdcallcc fn WSAUnhookBlockingHook() c_int;
// pub extern "ws2_32" stdcallcc fn WSARecv(
//     s: SOCKET,
//     lpBuffers: [*]WSABuf,
//     dwBufferCount: u32,
//     lpNumberOfBytesSent: *u32,
//     lpFlags: *u32,
//     lpOverlapped: *OVERLAPPED,
//     lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
// ) c_int;
// pub extern "ws2_32" stdcallcc fn WSARecvFrom(
//     s: SOCKET,
//     lpBuffers: [*]WSABuf,
//     dwBufferCount: u32,
//     lpNumberOfBytesSent: *u32,
//     lpFlags: *u32,
//     lpFrom: *sockaddr,
//     lpFromlen: *c_int,
//     lpOverlapped: *OVERLAPPED,
//     lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
// ) c_int;
// pub extern "ws2_32" stdcallcc fn WSASend(
//     s: SOCKET,
//     lpBuffers: [*]WSABuf,
//     dwBufferCount: u32,
//     lpNumberOfBytesSent: *u32,
//     dwFlags: u32,
//     lpOverlapped: *OVERLAPPED,
//     lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
// ) c_int;
// pub extern "ws2_32" stdcallcc fn WSASendTo(
//     s: SOCKET,
//     lpBuffers: [*]WSABuf,
//     dwBufferCount: u32,
//     lpNumberOfBytesSent: *u32,
//     dwFlags: u32, lpTo: *const sockaddr,
//     iTolen: c_int, lpOverlapped: *OVERLAPPED,
//     lpCompletionRoutine: OVERLAPPED_COMPLETION_ROUTINE
// ) c_int;
pub extern "ws2_32" stdcallcc fn accept(s: SOCKET, addr: ?*sockaddr, addrlen: ?*c_int) SOCKET;
pub extern "ws2_32" stdcallcc fn bind(s: SOCKET, addr: *const sockaddr, namelen: c_int) c_int;
pub extern "ws2_32" stdcallcc fn closesocket(s: SOCKET) c_int;
// pub extern "ws2_32" stdcallcc fn connect(s: SOCKET, name: ?*const sockaddr, namelen: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn gethostname(name: ?[*]u8, namelen: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn getpeername(s: SOCKET, name: ?*sockaddr, namelen: ?*c_int) c_int;
// pub extern "ws2_32" stdcallcc fn getprotobyname(name: ?[*]const u8) ?*struct_protoent;
// pub extern "ws2_32" stdcallcc fn getprotobynumber(proto: c_int) ?*struct_protoent;
// pub extern "ws2_32" stdcallcc fn getservbyname(name: ?[*]const u8, proto: ?[*]const u8) ?*struct_servent;
// pub extern "ws2_32" stdcallcc fn getservbyport(port: c_int, proto: ?[*]const u8) ?*struct_servent;
// pub extern "ws2_32" stdcallcc fn getsockname(s: SOCKET, name: ?*sockaddr, namelen: ?*c_int) c_int;
// pub extern "ws2_32" stdcallcc fn getsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]u8, optlen: ?*c_int) c_int;
// pub extern "ws2_32" stdcallcc fn htonl(hostlong: u_long) u_long;
// pub extern "ws2_32" stdcallcc fn htons(hostshort: u_short) u_short;
// pub extern "ws2_32" stdcallcc fn inet_addr(cp: ?[*]const u8) c_ulong;
// pub extern "ws2_32" stdcallcc fn inet_ntoa(in: struct_in_addr) ?[*]u8;
// pub extern "ws2_32" stdcallcc fn inet_ntop(Family: c_int, pAddr: *const c_void, pStringBuf: [*]u8, StringBufSize: c_ulong) ?[*]u8;
// pub extern "ws2_32" stdcallcc fn ioctlsocket(s: SOCKET, cmd: c_long, argp: ?*u_long) c_int;
pub extern "ws2_32" stdcallcc fn listen(s: SOCKET, backlog: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn ntohl(netlong: u_long) u_long;
// pub extern "ws2_32" stdcallcc fn ntohs(netshort: u_short) u_short;
// pub extern "ws2_32" stdcallcc fn recv(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn recvfrom(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int, from: ?*sockaddr, fromlen: ?*c_int) c_int;
// pub extern "ws2_32" stdcallcc fn select(nfds: c_int, readfds: ?*fd_set, writefds: ?*fd_set, exceptfds: ?*fd_set, timeout: ?*const struct_timeval) c_int;
pub extern "ws2_32" stdcallcc fn send(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn sendto(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int, to: ?*const sockaddr, tolen: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn setsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]const u8, optlen: c_int) c_int;
// pub extern "ws2_32" stdcallcc fn shutdown(s: SOCKET, how: c_int) c_int;
pub extern "ws2_32" stdcallcc fn socket(af: c_int, type_0: c_int, protocol: c_int) SOCKET;
