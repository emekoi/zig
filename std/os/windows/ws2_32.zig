use @import("index.zig");

pub const ENOMEM = 8;

pub const EACCES = 10013;

pub const EADDRINUSE = 10048;

pub const EADDRNOTAVAIL = 10049;

pub const EAFNOSUPPORT = 10047;

pub const EALREADY = 10037;

pub const EBADF = 10009;

pub const ECANCELLED = 10103;

pub const ECONNABORTED = 10053;

pub const ECONNREFUSED = 10061;

pub const ECONNRESET = 10054;

pub const EDESTADDRREQ = 10039;

pub const EDISCON = 10101;

pub const EDQUOT = 10069;

pub const EFAULT = 10014;

pub const EHOSTDOWN = 10064;

pub const EHOSTUNREACH = 10065;

pub const EINPROGRESS = 10036;

pub const EINTR = 10004;

pub const EINVAL = 10022;

pub const EINVALIDPROCTABLE = 10104;

pub const EINVALIDPROVIDER = 10105;

pub const EISCONN = 10056;

pub const ELOOP = 10062;

// TODO
pub const ENOTDIR = 20;

pub const ENFILE = 10023;

pub const EMFILE = 10024;

pub const EMSGSIZE = 10040;

pub const ENAMETOOLONG = 10063;

// TODO: WSAENETDOWN
pub const ENOENT = 10050;

pub const ENETRESET = 10052;

pub const ENETUNREACH = 10051;

pub const ENOBUFS = 10055;

pub const ENOMORE = 10102;

pub const ENOPROTOOPT = 10042;

pub const ENOTCONN = 10057;

pub const ENOTEMPTY = 10066;

pub const ENOTSOCK = 10038;

pub const EOPNOTSUPP = 10045;

pub const EPFNOSUPPORT = 10046;

pub const EPROCLIM = 10067;

pub const EPROTONOSUPPORT = 10043;

// TODO: WSAEPROTOTYPE
pub const EPROTO = 10041;

pub const EPROVIDERFAILEDINIT = 10106;

pub const EREFUSED = 10112;

pub const EREMOTE = 10071;

pub const ESHUTDOWN = 10058;

pub const ESOCKTNOSUPPORT = 10044;

pub const ESTALE = 10070;

pub const ETIMEDOUT = 10060;

pub const ETOOMANYREFS = 10059;

pub const EUSERS = 10068;

pub const EWOULDBLOCK = 10035;

pub const EROFS = ~u32(0);

// pub const WSAHOST_NOT_FOUND = 11001;

// pub const WSANOTINITIALISED = 10093;

// pub const WSANO_ADDRESS = WSANO_DATA;

// pub const WSANO_DATA = 11004;

// pub const WSANO_RECOVERY = 11003;

// pub const WSASERVICE_NOT_FOUND = 10108;

// pub const WSASYSCALLFAILURE = 10107;

// pub const WSASYSNOTREADY = 10091;

// pub const WSASYS_STATUS_LEN = 128;

// pub const WSATRY_AGAIN = 11002;

// pub const WSATYPE_NOT_FOUND = 10109;

// pub const WSAVERNOTSUPPORTED = 10092;

// pub const WSA_E_CANCELLED = 10111;

// pub const WSA_E_NO_MORE = 10110;

// pub const WSA_IPSEC_NAME_POLICY_ERROR = 11033;

// pub const WSA_QOS_ADMISSION_FAILURE = 11010;

// pub const WSA_QOS_BAD_OBJECT = 11013;

// pub const WSA_QOS_BAD_STYLE = 11012;

// pub const WSA_QOS_EFILTERCOUNT = 11021;

// pub const WSA_QOS_EFILTERSTYLE = 11019;

// pub const WSA_QOS_EFILTERTYPE = 11020;

// pub const WSA_QOS_EFLOWCOUNT = 11023;

// pub const WSA_QOS_EFLOWDESC = 11026;

// pub const WSA_QOS_EFLOWSPEC = 11017;

// pub const WSA_QOS_EOBJLENGTH = 11022;

// pub const WSA_QOS_EPOLICYOBJ = 11025;

// pub const WSA_QOS_EPROVSPECBUF = 11018;

// pub const WSA_QOS_EPSFILTERSPEC = 11028;

// pub const WSA_QOS_EPSFLOWSPEC = 11027;

// pub const WSA_QOS_ESDMODEOBJ = 11029;

// pub const WSA_QOS_ESERVICETYPE = 11016;

// pub const WSA_QOS_ESHAPERATEOBJ = 11030;

// pub const WSA_QOS_EUNKOWNPSOBJ = 11024;

// pub const WSA_QOS_GENERIC_ERROR = 11015;

// pub const WSA_QOS_NO_RECEIVERS = 11008;

// pub const WSA_QOS_NO_SENDERS = 11007;

// pub const WSA_QOS_POLICY_FAILURE = 11011;

// pub const WSA_QOS_RECEIVERS = 11005;

// pub const WSA_QOS_REQUEST_CONFIRMED = 11009;

// pub const WSA_QOS_RESERVED_PETYPE = 11031;

// pub const WSA_QOS_SENDERS = 11006;

// pub const WSA_QOS_TRAFFIC_CTRL_ERROR = 11014;

// pub const WSA_SECURE_HOST_NOT_FOUND = 11032;

pub const AF_UNSPEC = 0;

pub const AF_INET = 2;

pub const AF_INET6 = 23;

pub const SD_RECEIVE = 0;

pub const SD_SEND = 1;

pub const SD_BOTH = 2;

pub const SOCK_STREAM = 1;

pub const SOCK_DGRAM = 2;

pub const SOCK_RAW = 3;

pub const SOCK_RDM = 4;

pub const SOCK_SEQPACKET = 5;

pub const SOCK_NONBLOCK = 0x8004667e;

// WSA_FLAG_NO_HANDLE_INHERIT
pub const SOCK_CLOEXEC = 0x80;

pub const SOL_SOCKET = 0xffff;

pub const SOMAXCONN = 0x7fffffff;

pub const SO_RCVTIMEO = 0x1006;

pub const SO_SNDTIMEO = 0x1005;

pub const SO_REUSEADDR = 0x0004;

pub const PROTO_tcp = 6;

pub const PROTO_udp = 17;

pub const PROTO_rm = 113;

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

// pub const NI_MAXSERV = 32;

// pub const NI_MAXHOST = 1025;

// pub const ERROR_IO_PENDING = c_long(997);

// pub const ERROR_NETNAME_DELETED = c_long(64);

// pub const STATUS_PENDING = c_long(259);

pub const INVALID_SOCKET = ~SOCKET(0);

pub const WSA_FLAG_OVERLAPPED = 0x01;

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

pub const WSABuf = extern struct {
    len: usize,
    buf: [*]u8,
};

pub const WSABufConst = extern struct {
    len: usize,
    buf: [*]const u8,
};

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

pub extern "ws2_32" stdcallcc fn WSARecv(
    s: SOCKET,
    lpBuffers: [*]io_vec,
    dwBufferCount: u32,
    lpNumberOfBytesRecvd: *u32,
    lpFlags: *u32,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

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

pub extern "ws2_32" stdcallcc fn WSASend(
    s: SOCKET,
    lpBuffers: [*]iovec_const,
    dwBufferCount: u32,
    lpNumberOfBytesSent: *u32,
    dwFlags: u32,
    lpOverlapped: ?*OVERLAPPED,
    lpCompletionRoutine: ?OVERLAPPED_COMPLETION_ROUTINE
) c_int;

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

pub extern "ws2_32" stdcallcc fn connect(s: SOCKET, name: ?*const sockaddr, namelen: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn gethostname(name: ?[*]u8, namelen: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn getpeername(s: SOCKET, name: ?*sockaddr, namelen: ?*c_int) c_int;

// pub extern "ws2_32" stdcallcc fn getprotobyname(name: ?[*]const u8) ?*struct_protoent;

// pub extern "ws2_32" stdcallcc fn getprotobynumber(proto: c_int) ?*struct_protoent;

// pub extern "ws2_32" stdcallcc fn getservbyname(name: ?[*]const u8, proto: ?[*]const u8) ?*struct_servent;

// pub extern "ws2_32" stdcallcc fn getservbyport(port: c_int, proto: ?[*]const u8) ?*struct_servent;

pub extern "ws2_32" stdcallcc fn getsockname(s: SOCKET, name: ?*sockaddr, namelen: ?*c_int) c_int;

pub extern "ws2_32" stdcallcc fn getsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]u8, optlen: ?*c_int) c_int;

// pub extern "ws2_32" stdcallcc fn htonl(hostlong: u_long) u_long;

// pub extern "ws2_32" stdcallcc fn htons(hostshort: u_short) u_short;

// pub extern "ws2_32" stdcallcc fn inet_addr(cp: ?[*]const u8) c_ulong;

// pub extern "ws2_32" stdcallcc fn inet_ntoa(in: struct_in_addr) ?[*]u8;

// pub extern "ws2_32" stdcallcc fn inet_ntop(Family: c_int, pAddr: *const c_void, pStringBuf: [*]u8, StringBufSize: c_ulong) ?[*]u8;

pub extern "ws2_32" stdcallcc fn ioctlsocket(s: SOCKET, cmd: c_ulong, argp: ?*c_ulong) c_int;

pub extern "ws2_32" stdcallcc fn listen(s: SOCKET, backlog: u32) c_int;

// pub extern "ws2_32" stdcallcc fn ntohl(netlong: u_long) u_long;

// pub extern "ws2_32" stdcallcc fn ntohs(netshort: u_short) u_short;

// pub extern "ws2_32" stdcallcc fn recv(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn recvfrom(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int, from: ?*sockaddr, fromlen: ?*c_int) c_int;

// pub extern "ws2_32" stdcallcc fn select(nfds: c_int, readfds: ?*fd_set, writefds: ?*fd_set, exceptfds: ?*fd_set, timeout: ?*const struct_timeval) c_int;

pub extern "ws2_32" stdcallcc fn send(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn sendto(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int, to: ?*const sockaddr, tolen: c_int) c_int;

pub extern "ws2_32" stdcallcc fn setsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]const u8, optlen: c_int) c_int;

pub extern "ws2_32" stdcallcc fn shutdown(s: SOCKET, how: c_int) c_int;

pub extern "ws2_32" stdcallcc fn WSASocketW(af: u32, sockType: u32, protocol: u32, lpProtocolInfo: ?*c_void, g: c_uint, dwFlags: u32) SOCKET;

pub stdcallcc fn socket(af: u32, sockType: u32, protocol: u32) SOCKET {
    return WSASocketW(af, sockType, protocol, null, 0, WSA_FLAG_OVERLAPPED);
}
