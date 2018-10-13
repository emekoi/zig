use @import("../index.zig");
pub use @import("error.zig");

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

// aparrently zig can't cast from an unsigned int to a signed int so..
// unsigned: 
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

// pub const WSABuf = extern struct {
//     len: c_ulong,
//     buf: [*]u8
// };

pub const iovec = extern struct {
    iov_len: usize,
    iov_base: [*]u8,
};

pub const iovec_const = extern struct {
    iov_len: usize,
    iov_base: [*]const u8,
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

// TODO: support other ioctl commands. see [this](https://www.winsocketdotnetworkprogramming.com/winsock2programming/winsock2advancedsocketoptionioctl7b.html).
pub stdcallcc fn accept4(s: SOCKET, addr: ?*sockaddr, addrlen: ?*u32, flags: u32) SOCKET {
    const result = accept(s, addr, @ptrCast(*c_int, addrlen));

    var mode: c_ulong = 0;
    if ((@intCast(c_long, flags) & SOCK_NONBLOCK) == SOCK_NONBLOCK) {
        mode = 1;
    } else {
        mode = 0;
    }

    if (ioctlsocket(result, SOCK_NONBLOCK, &mode) != 0) {
        return INVALID_SOCKET;
    } else {
        return result;
    }
}

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

pub extern "ws2_32" stdcallcc fn ioctlsocket(s: SOCKET, cmd: c_long, argp: ?*c_ulong) c_int;

pub extern "ws2_32" stdcallcc fn listen(s: SOCKET, backlog: u32) c_int;

// pub extern "ws2_32" stdcallcc fn ntohl(netlong: u_long) u_long;

// pub extern "ws2_32" stdcallcc fn ntohs(netshort: u_short) u_short;

// pub extern "ws2_32" stdcallcc fn recv(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn recvfrom(s: SOCKET, buf: ?[*]u8, len: c_int, flags: c_int, from: ?*sockaddr, fromlen: ?*c_int) c_int;

// pub extern "ws2_32" stdcallcc fn select(nfds: c_int, readfds: ?*fd_set, writefds: ?*fd_set, exceptfds: ?*fd_set, timeout: ?*const struct_timeval) c_int;

pub extern "ws2_32" stdcallcc fn send(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn sendto(s: SOCKET, buf: ?[*]const u8, len: c_int, flags: c_int, to: ?*const sockaddr, tolen: c_int) c_int;

// pub extern "ws2_32" stdcallcc fn setsockopt(s: SOCKET, level: c_int, optname: c_int, optval: ?[*]const u8, optlen: c_int) c_int;

pub extern "ws2_32" stdcallcc fn shutdown(s: SOCKET, how: c_int) c_int;

extern "ws2_32" stdcallcc fn WSASocketW(af: u32, sockType: u32, protocol: u32, lpProtocolInfo: ?*c_void, g: c_uint, dwFlags: u32) SOCKET;

pub stdcallcc fn socket(af: u32, sockType: u32, protocol: u32) SOCKET {
    return WSASocketW(af, sockType, protocol, null, 0, WSA_FLAG_OVERLAPPED);
}

// pub stdcallcc fn read(s: SOCKET, buf: [*]u8, count: usize) usize {
//     return syscall3(SYS_read, @intCast(usize, fd), @ptrToInt(buf), count);
// }

pub stdcallcc fn readv(s: SOCKET, iov: [*]const iovec, count: usize) usize {
    var read: u32 = 0;
    var flags: u32 = 0;
    return WSARecv(s, iov, count, &read, &flags, null, null);
}

// pub fn write(s: SOCKET, buf: [*]const u8, count: usize) usize {
//     return syscall3(SYS_write, @intCast(usize, fd), @ptrToInt(buf), count);
// }


pub stdcallcc fn writev(s: SOCKET, iov: [*]const iovec_const, count: usize) usize {
    var sent: u32 = 0;
    return WSASend(s, iov, count, &sent, 0, null, null);
}
