const std = @import("../index.zig");
const builtin = @import("builtin");
const os = std.os;
const net = std.net;

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

pub const Domain = enum(u32) {
    Unspecified = sys.AF_UNSPEC,
    Unix = sys.AF_UNIX,
    Inet = sys.AF_INET,
    Inet6 = sys.AF_INET6,
};

pub const SocketType = enum(u32) {
    Stream = sys.SOCK_STREAM,
    DataGram = sys.SOCK_DGRAM,
    Raw = sys.SOCK_RAW,
    SeqPacket = sys.SOCK_SEQPACKET,
};

pub const Protocol = enum(u32) {
    Unix,
    TCP = if (is_posix) sys.PROTO_tcp else sys.IPPROTO_TCP,
    UDP = if (is_posix) sys.PROTO_udp else sys.IPPROTO_UDP,
    IP = if (is_posix) sys.PROTO_ip else sys.IPPROTO_IP,
    IPV6 = if (is_posix) sys.PROTO_ipv6 else sys.IPPROTO_IPV6,
    RAW = if (is_posix) sys.PROTO_raw else sys.IPPROTO_RAW,
    ICMP = if (is_posix) sys.PROTO_icmp else sys.IPPROTO_ICMP,
};

pub const Shutdown = enum {
    Read,
    Write,
    Both,
};

pub const SocketError = error {
    /// Permission to create a socket of the specified type and/or
    /// protocol is denied.
    PermissionDenied,

    /// The implementation does not support the specified address family.
    AddressFamilyNotSupported,

    /// Unknown protocol, or protocol family not available.
    ProtocolFamilyNotAvailable,

    /// The per-process limit on the number of open file descriptors has been reached.
    ProcessFdQuotaExceeded,

    /// The system-wide limit on the total number of open files has been reached.
    SystemFdQuotaExceeded,

    /// Insufficient memory is available. The socket cannot be created until sufficient
    /// resources are freed.
    SystemResources,

    /// The protocol type or the specified protocol is not supported within this domain.
    ProtocolNotSupported,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub const BindError = error {
    /// The address is protected, and the user is not the superuser.
    /// For UNIX domain sockets: Search permission is denied on  a  component
    /// of  the  path  prefix.
    AccessDenied,

    /// The given address is already in use, or in the case of Internet domain sockets,
    /// The  port number was specified as zero in the socket
    /// address structure, but, upon attempting to bind to  an  ephemeral  port,  it  was
    /// determined  that  all  port  numbers in the ephemeral port range are currently in
    /// use.  See the discussion of /proc/sys/net/ipv4/ip_local_port_range ip(7).
    AddressInUse,

    /// A nonexistent interface was requested or the requested address was not local.
    AddressNotAvailable,

    /// Too many symbolic links were encountered in resolving addr.
    SymLinkLoop,

    /// addr is too long.
    NameTooLong,

    /// A component in the directory prefix of the socket pathname does not exist.
    FileNotFound,

    /// Insufficient kernel memory was available.
    SystemResources,

    /// A component of the path prefix is not a directory.
    NotDir,

    /// The socket inode would reside on a read-only filesystem.
    ReadOnlyFileSystem,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub const ListenError = error {
    /// Another socket is already listening on the same port.
    /// For Internet domain sockets, the  socket referred to by socket had not previously
    /// been bound to an address and, upon attempting to bind it to an ephemeral port, it
    /// was determined that all port numbers in the ephemeral port range are currently in
    /// use.  See the discussion of /proc/sys/net/ipv4/ip_local_port_range in ip(7).
    AddressInUse,

    /// The file descriptor socket does not refer to a socket.
    FileDescriptorNotASocket,

    /// The socket is not of a type that supports the listen() operation.
    OperationNotSupported,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub const AcceptError = error {
    ConnectionAborted,

    /// The per-process limit on the number of open file descriptors has been reached.
    ProcessFdQuotaExceeded,

    /// The system-wide limit on the total number of open files has been reached.
    SystemFdQuotaExceeded,

    /// Not enough free memory.  This often means that the memory allocation  is  limited
    /// by the socket buffer limits, not by the system memory.
    SystemResources,

    /// The file descriptor socket does not refer to a socket.
    FileDescriptorNotASocket,

    /// The referenced socket is not of type SOCK_STREAM.
    OperationNotSupported,

    ProtocolFailure,

    /// Firewall rules forbid connection.
    BlockedByFirewall,

    /// Accepting would block.
    WouldBlock,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub const GetSockNameError = error {
    /// Insufficient resources were available in the system to perform the operation.
    SystemResources,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub const ConnectError = error {
    /// For UNIX domain sockets, which are identified by pathname: Write permission is denied on  the  socket
    /// file,  or  search  permission  is  denied  for  one of the directories in the path prefix.
    /// or
    /// The user tried to connect to a broadcast address without having the socket broadcast flag enabled  or
    /// the connection request failed because of a local firewall rule.
    PermissionDenied,

    /// Local address is already in use.
    AddressInUse,

    /// (Internet  domain  sockets)  The  socket  referred  to  by socket had not previously been bound to an
    /// address and, upon attempting to bind it to an ephemeral port, it was determined that all port numbers
    /// in    the    ephemeral    port    range    are   currently   in   use.    See   the   discussion   of
    /// /proc/sys/net/ipv4/ip_local_port_range in ip(7).
    AddressNotAvailable,

    /// The passed address didn't have the correct address family in its sa_family field.
    AddressFamilyNotSupported,

    /// Insufficient entries in the routing cache.
    SystemResources,

    /// A connect() on a stream socket found no one listening on the remote address.
    ConnectionRefused,

    /// Network is unreachable.
    NetworkUnreachable,

    /// Timeout  while  attempting  connection.   The server may be too busy to accept new connections.  Note
    /// that for IP sockets the timeout may be very long when syncookies are enabled on the server.
    ConnectionTimedOut,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

// pub const ShutdownError = error {
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

pub const Socket = struct {
    fd: SocketFd,

    pub fn new(domain: Domain, socket_type: SocketType, protocol: Protocol) SocketError!Socket {
        if (is_posix) {
            const rc = sys.socket(domain, socket_type, protocol);
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return Socket { .fd = @intCast(SocketFd, rc) },
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
            const rc = blk: {
                const _domain = @intCast(c_int, @enumToInt(domain));
                const _sock_type = @intCast(c_int, @enumToInt(socket_type));
                const _protocol = @intCast(c_int, @enumToInt(protocol));
                break :blk sys.socket(_domain, _sock_type, _protocol);
            };
            const err = sys.WSAGetLastError();
            // TODO check for TOO_MANY_OPEN_FILES?
            switch (err) {
                0 => return  Socket { .fd = rc },
                sys.ERROR.WSAEACCES => return SocketError.PermissionDenied,
                sys.ERROR.WSAEAFNOSUPPORT => return SocketError.AddressFamilyNotSupported,
                sys.ERROR.WSAEINVAL => return SocketError.ProtocolFamilyNotAvailable,
                sys.ERROR.WSAEMFILE => return SocketError.ProcessFdQuotaExceeded,
                sys.ERROR.WSAENOBUFS, sys.ERROR.WSA_NOT_ENOUGH_MEMORY => return SocketError.SystemResources,
                sys.ERROR.WSAEPROTONOSUPPORT => return SocketError.ProtocolNotSupported,
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
                sys.ERROR.WSAEBADF => unreachable, // always a race condition if this error is returned
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAENOTSOCK => unreachable,
                sys.ERROR.WSAEADDRNOTAVAIL => return BindError.AddressNotAvailable,
                sys.ERROR.WSAEFAULT => unreachable,
                sys.ERROR.WSAELOOP => return BindError.SymLinkLoop,
                sys.ERROR.WSAENAMETOOLONG => return BindError.NameTooLong,
                sys.ERROR.WSA_NOT_ENOUGH_MEMORY => return BindError.SystemResources,
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
                sys.ERROR.WSAEBADF => unreachable,
                sys.ERROR.WSAENOTSOCK => return ListenError.FileDescriptorNotASocket,
                sys.ERROR.WSAEOPNOTSUPP => return ListenError.OperationNotSupported,
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
                    0 => return Socket { .fd = @intCast(SocketFd, rc) },
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
                            return Socket { .fd = rc };
                        }
                    },
                    sys.ERROR.WSAEINTR => continue,
                    else => return unexpectedError(@intCast(u32, err)),
                    // TODO check for TOO_MANY_OPEN_FILES?
                    sys.ERROR.WSAEWOULDBLOCK => unreachable, // use asyncAccept for non-blocking
                    sys.ERROR.WSAEBADF => unreachable, // always a race condition
                    sys.ERROR.WSAECONNABORTED => return AcceptError.ConnectionAborted,
                    sys.ERROR.WSAEFAULT => unreachable,
                    sys.ERROR.WSAEINVAL => unreachable,
                    sys.ERROR.WSAEMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.ERROR.WSAENOBUFS => return AcceptError.SystemResources,
                    sys.ERROR.WSA_NOT_ENOUGH_MEMORY => return AcceptError.SystemResources,
                    sys.ERROR.WSAENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.ERROR.WSAEOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.ERROR.WSAEACCES => return AcceptError.BlockedByFirewall,
                }
            }
        }
    }

    /// Returns InvalidSocketFd if would block.
    pub fn asyncAccept(self: Socket, addr: *net.OsAddress, flags: u32) AcceptError!Socket {
        if (is_posix) {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(net.OsAddress));
                const rc = sys.accept4(self.fd, &addr.os_addr, &sockaddr_size, flags);
                const err = sys.getErrno(rc);
                switch (err) {
                    0 => return Socket { .fd = @intCast(SocketFd, rc) },
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
                    0 => return Socket { .fd = rc },
                    sys.ERROR.WSAEINTR => continue,
                    else => return unexpectedError(@intCast(u32, err)),
                    sys.ERROR.WSAEWOULDBLOCK  => return InvalidSocketFd,
                    sys.ERROR.WSAEBADF => unreachable, // always a race condition
                    sys.ERROR.WSAECONNABORTED => return AcceptError.ConnectionAborted,
                    sys.ERROR.WSAEFAULT => unreachable,
                    sys.ERROR.WSAEINVAL => unreachable,
                    sys.ERROR.WSAEMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.ERROR.WSAENOBUFS => return AcceptError.SystemResources,
                    sys.ERROR.WSA_NOT_ENOUGH_MEMORY => return AcceptError.SystemResources,
                    sys.ERROR.WSAENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.ERROR.WSAEOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.ERROR.WSAEACCES => return AcceptError.BlockedByFirewall,
                }
            }
        }
    }

    pub fn getSockName(self: Socket) GetSockNameError!net.OsAddress {
        var addr: net.OsAddress = undefined;
        var addrlen: sys.socklen_t = @sizeOf(net.OsAddress);
        const rc = sys.getsockname(self.fd, &addr, &addrlen);

        if (is_posix) {
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return net.OsAddress.init(addr),
                else => return unexpectedError(err),
                sys.EBADF => unreachable,
                sys.EFAULT => unreachable,
                sys.EINVAL => unreachable,
                sys.ENOTSOCK => unreachable,
                sys.ENOBUFS => return GetSockNameError.SystemResources,
            }
        } else {
            const err = sys.WSAGetLastError();
            switch (err) {
                0 => return net.OsAddress.init(addr),
                else => return unexpectedError(@intCast(u32, err)),
                sys.ERROR.WSAEBADF => unreachable,
                sys.ERROR.WSAEFAULT => unreachable,
                sys.ERROR.WSAEINVAL => unreachable,
                sys.ERROR.WSAENOTSOCK => unreachable,
                sys.ERROR.WSAENOBUFS => return GetSockNameError.SystemResources,
            }
        }
    }

    pub fn connect(self: Socket, addr: *const net.OsAddress) ConnectError!void {
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
                    sys.ERROR.WSAEBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.ERROR.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.ERROR.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.ERROR.WSAEINPROGRESS => unreachable, // The socket is nonblocking and the connection cannot be completed immediately.
                    sys.ERROR.WSAEINTR => continue,
                    sys.ERROR.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.ERROR.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ERROR.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.ERROR.WSAEPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.ERROR.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(@intCast(u32, err)),
                }
            }
        }
    }

    /// Same as connect except it is for blocking socket file descriptors.
    /// It expects to receive EINPROGRESS.
    pub fn connectAsync(self: Sokcet, addr: *const net.OsAddress) ConnectError!void {
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
                    sys.ERROR.WSAEBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.ERROR.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.ERROR.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.ERROR.WSAEINTR => continue,
                    sys.ERROR.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.ERROR.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.ERROR.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.ERROR.WSAEPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.ERROR.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
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

    // pub fn shutdown(self: Socket) !void {
    // }

    // pub fn getSockOpt() {
    // }

    // pub fn setSockOpt() {
    // }

    // pub fn send(self: Socket, buf: []const u8) {
    // }

    // pub fn recv(self: Socket, buf: []u8) {
    // }

    pub fn close(self: Socket) void {
        if (is_posix) {
            os.close(self.fd);
        } else {
            _ = sys.closesocket(self.fd);
        }
    }
};
