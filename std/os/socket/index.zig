pub use @import("errors.zig");
use @import("errors.zig");

const std = @import("../index.zig");
const builtin = @import("builtin");
const net = std.net;
const os = std.os;

const sys = switch (builtin.os) {
    builtin.Os.windows => std.os.windows,
    else => std.os.posix,
};

const is_windows = builtin.os == Os.windows;

const is_posix = switch (builtin.os) {
    builtin.Os.linux, builtin.Os.macosx, builtin.Os.freebsd => true,
    else => false,
};

const unexpectedError = switch (builtin.os) {
    builtin.Os.windows => os.unexpectedErrorWindows,
    else => os.unexpectedErrorPosix,
};

pub const SocketFd = switch (builtin.os) {
    builtin.Os.windows => sys.SOCKET,
    else => i32,
};

pub const InvalidSocketFd: SocketFd = switch (builtin.os) {
    builtin.Os.windows => sys.INVALID_SOCKET,
    else => -1,
};

pub const Domain = enum {
    Unspecified,
    Unix,
    Inet,
    Inet6,

    fn toInt(self: Domain, comptime T: type) T {
        return @intCast(T, switch (self) {
            Domain.Unspecified => sys.AF_UNSPEC,
            Domain.Unix => sys.AF_UNIX,
            Domain.Inet => sys.AF_INET,
            Domain.Inet6 => sys.AF_INET6,
        });
    }
};

pub const SocketType = enum {
    Stream,
    DataGram,
    Raw,
    SeqPacket,

    fn toInt(self: SocketType, comptime T: type) T {
        return @intCast(T, switch (self) {
            SocketType.Stream => sys.SOCK_STREAM,
            SocketType.DataGram => sys.SOCK_DGRAM,
            SocketType.Raw => sys.SOCK_RAW,
            SocketType.SeqPacket => sys.SOCK_SEQPACKET,
        });
    }
};

pub const Protocol = enum {
    Unix,
    TCP,
    UDP,
    IP,
    IPV6,
    RAW,
    ICMP,

    fn toInt(self: Protocol, comptime T: type) !T {
        return @intCast(T, switch (self) {
            Protocol.Unix => if (is_posix) 0 else return SocketError.ProtocolNotSupported,
            Protocol.TCP => if (is_posix) sys.PROTO_tcp else sys.IPPROTO_TCP,
            Protocol.UDP => if (is_posix) sys.PROTO_udp else sys.IPPROTO_UDP,
            Protocol.IP => if (is_posix) sys.PROTO_ip else sys.IPPROTO_IP,
            Protocol.IPV6 => if (is_posix) sys.PROTO_ipv6 else sys.IPPROTO_IPV6,
            Protocol.RAW => if (is_posix) sys.PROTO_raw else sys.IPPROTO_RAW,
            Protocol.ICMP => if (is_posix) sys.PROTO_icmp else sys.IPPROTO_ICMP,

        });
    }
};

pub const Shutdown = enum {
    Read = if (is_posix) sys.SHUT_RD else sys.SD_RECEIVE,
    Write = if (is_posix) sys.SHUT_WR else sys.SD_SEND,
    Both = if (is_posix) sys.SHUT_RDWR else sys.SD_BOTH,

    fn toInt(self: Shutdown, comptime T: type) T {
        return @intCast(T, switch (self) {
            Shutdown.Read => if (is_posix) sys.SHUT_RD else sys.SD_RECEIVE,
            Shutdown.Write => if (is_posix) sys.SHUT_WR else sys.SD_SEND,
            Shutdown.Both => if (is_posix) sys.SHUT_RDWR else sys.SD_BOTH,
        });
    }
};

// pub const Level = enum(u32) {
//     IP = if (is_posix) sys.SOL_IP ,
//     IPV6 = if (is_posix) sys.SOL_IPV6 ,
//     RM = if (is_posix) sys. ,
//     TCP = if (is_posix) sys. ,
//     UDP = if (is_posix) sys. ,
//     IPX = if (is_posix) sys. ,
//     AppleTalk = if (is_posix) sys. ,
//     IRLMP = if (is_posix) sys. ,
//     Socket = if (is_posix) sys. ,
// };

fn accept4Windows(fd: SocketFd, addr: ?*net.OsAddress, addrlen: ?*sys.socklen_t, flags: u32) SocketFd {
    const result = sys.accept(fd, addr, @ptrCast(*c_int, addrlen));
    const ioctl_mode = @boolToInt((@intCast(c_ulong, flags) & sys.FIONBIO) == sys.FIONBIO);
    const no_inherit = (flags & sys.WSA_FLAG_NO_HANDLE_INHERIT);

    if (sys.ioctlsocket(result, sys.FIONBIO, &@intCast(c_ulong, ioctl_mode)) != 0) {
        return InvalidSocketFd;
    }

    if (no_inherit == sys.WSA_FLAG_NO_HANDLE_INHERIT) {
        const handle = @intToPtr(sys.HANDLE, result);
        if (sys.SetHandleInformation(handle, sys.HANDLE_FLAG_INHERIT, 0) == sys.FALSE) {
            return InvalidSocketFd;
        }
    }

    return result;
}

// add timeouts

pub const Socket = struct {
    fd: SocketFd,
    domain: Domain,
    socket_type: SocketType,
    protocol: Protocol,

    fn initSocket(fd: SocketFd, domain: Domain, socket_type: SocketType, protocol: Protocol) Socket {
        return Socket {
            .fd = @intCast(SocketFd, rc),
            .domain = domain,
            .socket_type = socket_type,
            .protocol = protocol,
        };
    }

    pub fn new(domain: Domain, socket_type: SocketType, protocol: Protocol) SocketError!Socket {
        if (is_posix) {
            const rc = sys.socket(domain.toInt(u32), socket_type.toInt(u32), try protocol.toInt(u32));
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return initSocket(@intCast(SocketFd, rc), domain, socket_type, protocol),
                sys.EACCES => return SocketError.PermissionDenied,
                sys.EAFNOSUPPORT => return SocketError.AddressFamilyNotSupported,
                sys.EINVAL => return SocketError.ProtocolFamilyNotAvailable,
                sys.EMFILE => return SocketError.ProcessFdQuotaExceeded,
                sys.ENFILE => return SocketError.SystemFdQuotaExceeded,
                sys.ENOBUFS, sys.ENOMEM => return SocketError.SystemResources,
                sys.EPROTONOSUPPORT => return SocketError.ProtocolNotSupported,
                else => return unexpectedError(err),
            }
        } else {
            const rc = sys.socket(domain.toInt(c_int), sock_type.toInt(c_int), try protocol.toInt(c_int));
            const err = sys.WSAGetLastError();
            // TODO check for TOO_MANY_OPEN_FILES?
            switch (err) {
                0 => return initSocket(rc, domain, socket_type, protocol),
                sys.ERROR.WSAEACCES => return SocketError.PermissionDenied,
                sys.ERROR.WSAEAFNOSUPPORT => return SocketError.AddressFamilyNotSupported,
                sys.ERROR.WSAEINVAL => return SocketError.ProtocolFamilyNotAvailable,
                sys.ERROR.WSAEMFILE => return SocketError.ProcessFdQuotaExceeded,
                sys.ERROR.WSAENOBUFS => return SocketError.SystemResources,
                sys.ERROR.WSAEPROTONOSUPPORT, sys.ERROR.WSAEPROTOTYPE, sys.ERROR.WSAESOCKTNOSUPPORT => return SocketError.ProtocolNotSupported,
                else => return unexpectedError(@intCast(u32, err)),
            }
        }
    }

    pub fn tcp(domain: Domain) SocketError!Socket {
        return Socket.new(domain, SocketType.Stream, Protocol.TCP);
    }

    pub fn udp(domain: Domain) SocketError!Socket {
        return Socket.new(domain, SocketType.DataGram, Protocol.UDP);
    }

    pub fn unix(socket_type: SocketType) SocketError!Socket {
        return Socket.new(Domain.Unix, socket_type, Protocol.Unix);
    }

    /// addr is `*const T` where T is one of the sockaddr
    pub fn bind(self: Socket, addr: *const net.Address) BindError!void {
        const rc = sys.bind(self.fd, &addr.os_addr, @sizeOf(net.OsAddress));

        if (is_posix) {
            const err = sys.getErrno(@intCast(usize, rc));
            switch (err) {
                0 => return,
                sys.EACCES => return BindError.AccessDenied,
                sys.EADDRINUSE => return BindError.AddressInUse,
                sys.EBADF => unreachable, // always a race condition if this error is returned
                sys.EINVAL => unreachable,
                sys.ENOTSOCK => unreachable,
                sys.EADDRNOTAVAIL => return BindError.AddressNotAvailable,
                sys.EFAULT => unreachable,
                sys.ELOOP => return BindError.SymLinkLoop,
                sys.ENAMETOOLONG => return BindError.NameTooLong,
                sys.ENOENT => return BindError.FileNotFound,
                sys.ENOMEM => return BindError.SystemResources,
                sys.ENOTDIR => return BindError.NotDir,
                sys.EROFS => return BindError.ReadOnlyFileSystem,
                else => return unexpectedError(err),
            }
        } else {
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => return,
                sys.ERROR.WSAEACCES => return BindError.AccessDenied,
                sys.ERROR.WSAEADDRINUSE => return BindError.AddressInUse,
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAENOTSOCK => unreachable,
                sys.ERROR.WSAEADDRNOTAVAIL => return BindError.AddressNotAvailable,
                sys.ERROR.WSAEFAULT => unreachable,
                else => return unexpectedError(@intCast(u32, err)),
            }
        }
    }

    pub fn listen(self: Socket, backlog: u32) ListenError!void {
        if (is_posix) {
            const rc = sys.listen(self.fd, backlog);
            const err = sys.getErrno(@intCast(usize, rc));
            switch (err) {
                0 => return,
                sys.EADDRINUSE => return ListenError.AddressInUse,
                sys.EBADF => unreachable,
                sys.ENOTSOCK => return ListenError.FileDescriptorNotASocket,
                sys.EOPNOTSUPP => return ListenError.OperationNotSupported,
                else => return unexpectedError(err),
            }
        } else {
            const rc = sys.listen(self.fd, @intCast(c_int, backlog));
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => return,
                sys.ERROR.WSAEADDRINUSE => return ListenError.AddressInUse,
                sys.ERROR.WSAENOTSOCK => return ListenError.FileDescriptorNotASocket,
                // these are technically protocol/domain errors
                sys.ERROR.WSAEPROTOTYPE, sys.ERROR.WSAEPROTONOSUPPORT, sys.ERROR.WSAESOCKTNOSUPPORT => return ListenError.OperationNotSupported,
                sys.ERROR.WSAENOBUFS, sys.ERROR.WSAEMFILE => unreachable, // return error for this? (system resources)
                sys.ERROR.WSAEISCONN => unreachable, // return error for this? (already connected)
                sys.ERROR.WSAEINVAL => unreachable, // return error for this? (not bound)
                else => return unexpectedError(@intCast(u32, err)),
            }
        }
    }

    pub fn accept(self: Socket, addr: *net.Address, flags: u32) AcceptError!Socket {
        if (is_posix) {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(net.OsAddress));
                const rc = sys.accept4(self.fd, &addr.os_addr, &sockaddr_size, flags);
                const err = sys.getErrno(rc);
                switch (err) {
                    0 => return initSocket(@intCast(SocketFd, rc), self.domain, self.socket_type, self.protocol),
                    sys.EINTR => continue,
                    else => return unexpectedError(err),
                    sys.EAGAIN => unreachable, // use asyncAccept for non-blocking
                    sys.EBADF => unreachable, // always a race condition
                    sys.ECONNABORTED => return AcceptError.ConnectionAborted,
                    sys.EFAULT => unreachable,
                    sys.EINVAL => unreachable,
                    sys.EMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.ENFILE => return AcceptError.SystemFdQuotaExceeded,
                    sys.ENOBUFS => return AcceptError.SystemResources,
                    sys.ENOMEM => return AcceptError.SystemResources,
                    sys.ENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.EOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.EPROTO => return AcceptError.ProtocolFailure,
                    sys.EPERM => return AcceptError.BlockedByFirewall,
                }
            }
        } else {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(net.OsAddress));
                // port accept4
                const rc = accept4Windows(self.fd, &addr.os_addr, &sockaddr_size, flags);
                const err = sys.WSAGetLastError();
                switch (err) {
                    0 => {
                        if (rc == InvalidSocketFd) {
                            return unexpectedError(@intCast(u32, sys.GetLastError()));
                        } else {
                            return initSocket(rc, self.domain, self.socket_type, self.protocol);
                        }
                    },
                    sys.ERROR.WSAEINTR => continue,
                    else => return unexpectedError(@intCast(u32, err)),
                    // TODO check for TOO_MANY_OPEN_FILES?
                    sys.ERROR.WSAEWOULDBLOCK => unreachable, // use asyncAccept for non-blocking
                    sys.ERROR.WSAECONNRESET => return AcceptError.ConnectionAborted,
                    sys.ERROR.WSAEFAULT => unreachable,
                    sys.ERROR.WSAEINVAL => unreachable,
                    sys.ERROR.WSAEMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.ERROR.WSAENOBUFS => return AcceptError.SystemResources,
                    sys.ERROR.WSAENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.ERROR.WSAEOPNOTSUPP => return AcceptError.OperationNotSupported,
                }
            }
        }
    }

    /// Returns InvalidSocketFd if would block.
    pub fn asyncAccept(self: Socket, addr: *net.Address, flags: u32) AcceptError!Socket {
        if (is_posix) {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(net.OsAddress));
                const rc = sys.accept4(self.fd, &addr.os_addr, &sockaddr_size, flags);
                const err = sys.getErrno(rc);
                switch (err) {
                    0 => return initSocket(@intCast(SocketFd, rc), self.domain, self.socket_type, self.protocol),
                    sys.EINTR => continue,
                    else => return unexpectedError(err),
                    sys.EAGAIN  => return InvalidSocketFd,
                    sys.EBADF => unreachable, // always a race condition
                    sys.ECONNABORTED => return AcceptError.ConnectionAborted,
                    sys.EFAULT => unreachable,
                    sys.EINVAL => unreachable,
                    sys.EMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.ENFILE => return AcceptError.SystemFdQuotaExceeded,
                    sys.ENOBUFS => return AcceptError.SystemResources,
                    sys.ENOMEM => return AcceptError.SystemResources,
                    sys.ENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.EOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.EPROTO => return AcceptError.ProtocolFailure,
                    sys.EPERM => return AcceptError.BlockedByFirewall,
                }
            }
        } else {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(net.OsAddress));
                const rc = accept4Windows(self.fd, &addr.os_addr, &sockaddr_size, flags);
                const err = sys.WSAGetLastError();
                // TODO check for TOO_MANY_OPEN_FILES?
                switch (err) {
                    0 => return initSocket(rc, self.domain, self.socket_type, self.protocol),
                    sys.ERROR.WSAEINTR => continue,
                    else => return unexpectedError(@intCast(u32, err)),
                    sys.ERROR.WSAEWOULDBLOCK  => return InvalidSocketFd,
                    sys.ERROR.WSAECONNRESET => return AcceptError.ConnectionAborted,
                    sys.ERROR.WSAEFAULT => unreachable,
                    sys.ERROR.WSAEINVAL => unreachable,
                    sys.ERROR.WSAEMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.ERROR.WSAENOBUFS => return AcceptError.SystemResources,
                    sys.ERROR.WSAENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.ERROR.WSAEOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.ERROR.WSAEACCES => return AcceptError.BlockedByFirewall,
                }
            }
        }
    }

    pub fn connect(self: Socket, addr: *const net.Address) ConnectError!void {
        if (is_posix) {
            while (true) {
                const rc = sys.connect(self.fd, &addr.os_addr, @sizeOf(net.OsAddress));
                const err = sys.getErrno(rc);
                switch (err) {
                    0 => return,
                    sys.EPERM => return AcceptError.BlockedByFirewall,
                    sys.EACCES => return ConnectError.PermissionDenied,
                    sys.EADDRINUSE => return ConnectError.AddressInUse,
                    sys.EADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.EAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.EAGAIN => return ConnectError.SystemResources,
                    sys.EALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.EBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.ECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.EFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.EINPROGRESS => unreachable, // The socket is nonblocking and the connection cannot be completed immediately.
                    sys.EINTR => continue,
                    sys.EISCONN => unreachable, // The socket is already connected.
                    sys.ENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.EPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.ETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(err),
                }
            }
        } else {
            while (true) {
                const rc = sys.connect(self.fd, &addr.os_addr, @sizeOf(net.OsAddress));
                const err = sys.WSAGetLastError();
                switch (err) {
                    0 => return,
                    sys.ERROR.WSAEACCES => return ConnectError.PermissionDenied,
                    sys.ERROR.WSAEADDRINUSE => return ConnectError.AddressInUse,
                    sys.ERROR.WSAEADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.ERROR.WSAEAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.ERROR.WSAEWOULDBLOCK => return ConnectError.SystemResources,
                    sys.ERROR.WSAEALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.ERROR.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.ERROR.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.ERROR.WSAEINPROGRESS => unreachable, // The socket is nonblocking and the connection cannot be completed immediately.
                    sys.ERROR.WSAEINTR => continue,
                    sys.ERROR.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.ERROR.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ERROR.WSAEHOSTUNREACH => unreachable, // return error for this? (unreachable host)
                    sys.ERROR.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.ERROR.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    sys.ERROR.WSAENOBUFS => ConnectError.SystemResources,
                    else => return unexpectedError(@intCast(u32, err)),
                }
            }
        }
    }

    /// Same as connect except it is for blocking socket file descriptors.
    /// It expects to receive EINPROGRESS.
    pub fn connectAsync(self: Sokcet, addr: *const net.Address) ConnectError!void {
        if (is_posix) {
            while (true) {
                const rc = sys.connect(self.fd, &addr.os_addr, @sizeOf(net.OsAddress));
                const err = sys.getErrno(rc);
                switch (err) {
                    0, sys.EINPROGRESS => return,
                    sys.EPERM => return AcceptError.BlockedByFirewall,
                    sys.EACCES => return ConnectError.PermissionDenied,
                    sys.EADDRINUSE => return ConnectError.AddressInUse,
                    sys.EADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.EAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.EAGAIN => return ConnectError.SystemResources,
                    sys.EALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.EBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.ECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.EFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.EINTR => continue,
                    sys.EISCONN => unreachable, // The socket is already connected.
                    sys.ENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.EPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.ETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(err),
                }
            }
        } else {
            while (true) {
                const rc = sys.connect(self.fd, &addr.os_addr, @sizeOf(net.OsAddress));
                const err = sys.WSAGetLastError();
                switch (err) {
                    0, sys.ERROR.WSAEINPROGRESS => return,
                    sys.ERROR.WSAEACCES => return ConnectError.PermissionDenied,
                    sys.ERROR.WSAEADDRINUSE => return ConnectError.AddressInUse,
                    sys.ERROR.WSAEADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.ERROR.WSAEAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.ERROR.WSAEWOULDBLOCK => return ConnectError.SystemResources,
                    sys.ERROR.WSAEALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.ERROR.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.ERROR.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.ERROR.WSAEINTR => continue,
                    sys.ERROR.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.ERROR.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ERROR.WSAEHOSTUNREACH => unreachable, // return error for this? (unreachable host)
                    sys.ERROR.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.ERROR.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    sys.ERROR.WSAENOBUFS => ConnectError.SystemResources,
                    else => return unexpectedError(@intCast(u32, err)),
                }
            }
        }
    }

    pub fn getSockOptConnectError(self: Socket) ConnectError!void {
        var err_code: i32 = undefined;
        var size: u32 = @sizeOf(i32);
        const rc = sys.getsockopt(self.fd, sys.SOL_SOCKET, sys.SO_ERROR, @ptrCast([*]u8, &err_code), &size);
        assert(size == 4);
        if (is_posix) {
            const err = sys.getErrno(rc);
            switch (err) {
                0 => switch (err_code) {
                    0 => return,
                    sys.EPERM => return AcceptError.BlockedByFirewall,
                    sys.EACCES => return ConnectError.PermissionDenied,
                    sys.EADDRINUSE => return ConnectError.AddressInUse,
                    sys.EADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.EAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.EAGAIN => return ConnectError.SystemResources,
                    sys.EALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.EBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.ECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.EFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.EISCONN => unreachable, // The socket is already connected.
                    sys.ENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.EPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.ETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(err),
                },
                else => return unexpectedError(err),
                sys.EBADF => unreachable, // The argument socket is not a valid file descriptor.
                sys.EFAULT => unreachable, // The address pointed to by optval or optlen is not in a valid part of the process address space.
                sys.EINVAL => unreachable,
                sys.ENOPROTOOPT => unreachable, // The option is unknown at the level indicated.
                sys.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
            }
        } else {
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => switch (err_code) {
                    0 => return,
                    sys.ERROR.WSAEACCES => return ConnectError.PermissionDenied,
                    sys.ERROR.WSAEADDRINUSE => return ConnectError.AddressInUse,
                    sys.ERROR.WSAEADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.ERROR.WSAEAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.ERROR.WSAEWOULDBLOCK => return ConnectError.SystemResources,
                    sys.ERROR.WSAEALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.ERROR.WSAEBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.ERROR.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.ERROR.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.ERROR.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.ERROR.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ERROR.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.ERROR.WSAEPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.ERROR.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(@intCast(u32, err)),
                },
                else => return unexpectedError(@intCast(u32, err)),
                sys.ERROR.WSAEBADF => unreachable, // The argument socket is not a valid file descriptor.
                sys.ERROR.WSAEFAULT => unreachable, // The address pointed to by optval or optlen is not in a valid part of the process address space.
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAENOPROTOOPT => unreachable, // The option is unknown at the level indicated.
                sys.ERROR.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
            }
        }
    }

    pub fn getSockName(self: Socket) GetSockNameError!net.Address {
        var addr: net.OsAddress = undefined;
        var addrlen: sys.socklen_t = @sizeOf(net.OsAddress);
        const rc = sys.getsockname(self.fd, &addr, &addrlen);

        if (is_posix) {
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return net.Address.init(addr),
                else => return unexpectedError(err),
                sys.EBADF => unreachable,
                sys.EFAULT => unreachable,
                sys.EINVAL => unreachable,
                sys.ENOTSOCK => return GetSockNameError.FileDescriptorNotASocket,
                sys.ENOBUFS => return GetSockNameError.SystemResources,
            }
        } else {
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => return net.Address.init(addr),
                else => return unexpectedError(@intCast(u32, err)),
                sys.ERROR.WSAEFAULT => unreachable,
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAENOTSOCK => return GetSockNameError.FileDescriptorNotASocket,
            }
        }
    }

    pub fn getPeerName(self: Socket) GetPeerNameError!net.Address {
        var addr: net.OsAddress = undefined;
        var addrlen: sys.socklen_t = @sizeOf(net.OsAddress);
        const rc = sys.getpeername(self.fd, &addr, &addrlen);

        if (is_posix) {
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return net.Address.init(addr),
                else => return unexpectedError(err),
                sys.EBADF => unreachable,
                sys.EFAULT => unreachable,
                sys.EINVAL => unreachable,
                sys.ENOTSOCK => return GetPeerNameError.FileDescriptorNotASocket,
                sys.ENOTCONN => return GetPeerNameError.NotConnected,
                sys.ENOBUFS => return GetPeerNameError.SystemResources,
            }
        } else {
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => return net.Address.init(addr),
                else => return unexpectedError(@intCast(u32, err)),
                sys.ERROR.WSAEFAULT => unreachable,
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAENOTSOCK => return GetPeerNameError.FileDescriptorNotASocket,
                sys.ERROR.WSAENOTCONN => return GetPeerNameError.NotConnected,
                sys.ERROR.WSAENOBUFS => return GetPeerNameError.SystemResources,
            }
        }
    }
    
    pub fn shutdown(self: Socket, how: Shutdown) ShutdownError!void {
        if (is_posix) {
            const rc = sys.shutdown(self.fd, how.toInt(u32));
            const err = sys.getErrno(rc);
            switch (err) {
                0 => {},
                else => return unexpectedError(err),
                sys.EBADF => unreachable,
                sys.EINVAL => unreachable,
                sys.ENOTCONN => return ShutdownError.NotConnected,
                sys.ENOTSOCK => return ShutdownError.FileDescriptorNotASocket,
            }
        } else {
            const rc = sys.shutdown(self.fd, how.toInt(c_int));
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => {},
                else => return unexpectedError(@intCast(u32, err)),
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAEINPROGRESS => unreachable,
                sys.ERROR.WSAENOTCONN => return ShutdownError.NotConnected,
                sys.ERROR.WSAENOTSOCK => return ShutdownError.FileDescriptorNotASocket,
            }
        }
    }

    pub fn close(self: Socket) void {
        if (is_posix) {
            os.close(self.fd);
        } else {
            _ = sys.closesocket(self.fd);
        }
    }

    // pub fn getSockOpt(self: Socket) {
    // }

    // pub fn setSockOpt(self: Socket) {
    // }

    // pub fn send(self: Socket, buf: []const u8) {
    // }

    // pub fn recv(self: Socket, buf: []u8) {
    // }

    // pub fn sendTo(self: Socket) {
    // }

    // pub fn recvFrom(self: Socket) {
    // }

    pub fn setBlocking(self: Self, blocking: bool) SocketAttributeError!void {
        if (is_posix) {
            const flags = sys.fcntl(self.fd, sys.F_GETFL, 0);
            var err = sys.getErrno(flags);
            switch (err) {
                0 => {
                    const mode = if (blocking) flags & ~sys.O_NONBLOCK else flags | sys.O_NONBLOCK;
                    const rc = sys.fcntl(self.fd, sys.F_SETFL, mode);
                    err = sys.getErrno(flags);
                    switch (err) {
                        0 => {},
                        else => return unexpectedError(err),
                    }
                },
                else => return unexpectedError(err),
            }
        } else {
            const mode = @intCast(c_ulong, @boolToInt(!blocking));
            const rc = sys.ioctlsocket(self.fd, sys.FIONBIO, &mode);
            const err = sys.WSAGetLastError();

            switch (err) {
                0 => {},
                else => return unexpectedError(@intCast(u32, err)),
                sys.ERROR.WSAENOTSOCK => return SocketAttributeError.FileDescriptorNotASocket,
                sys.ERROR.WSAEINPROGRESS => unreachable,
                sys.ERROR.WSAEFAULT => unreachable,
            }
        }
    }
};
