const std = @import("../index.zig");
const builtin = @import("builtin");
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

pub const InvalidSocket: SocketFd = switch (builtin.os) {
    builtin.Os.windows => sys.INVALID_SOCKET,
    else => -1,
};

pub const Domain = enum {
    Unspecified = sys.AF_UNSPEC,
    Unix = if (is_posix) sys.AF_UNIX else -1,
    Inet = sys.AF_INET,
    Inet6 = sys.AF_INET6,
};

pub const SocketType = enum {
    Stream = sys.SOCK_STREAM,
    DataGram = sys.SOCK_DGRAM,
    Raw = sys.SOCK_RAW,
    SeqPacket = sys.SOCK_SEQPACKET,
};

pub const Protocol = enum {
    TCP = if (is_posix) sys.PROTO_tcp else sys.IPPROTO_TCP,
    UDP = if (is_posix) sys.PROTO_udp else sys.IPPROTO_UDP,
    IP = if (is_posix) sys.PROTO_ip else sys.IPPROTO_IP,
    IPV6 = if (is_posix) sys.PROTO_ipv6 else sys.IPPROTO_IPV6,
    RAW = if (is_posix) sys.PROTO_raw else sys.IPPROTO_RAW,
    ICMP = if (is_posix) sys.PROTO_icmp else sys.IPPROTO_ICMP,
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

fn accept4Windows(fd: SocketFd, addr: ?*sys.sockaddr, addrlen: ?*sys.socklen_t, flags: u32) SocketFd {
    // TODO: support other ioctl commands
    // https://www.winsocketdotnetworkprogramming.com/winsock2programming/winsock2advancedsocketoptionioctl7b.html
    // https://docs.microsoft.com/en-us/windows/desktop/winsock/summary-of-socket-ioctl-opcodes-2
    // https://docs.microsoft.com/en-us/windows/desktop/winsock/winsock-ioctls
    
    const result = sys.accept(fd, addr, @ptrCast(*c_int, addrlen));
    const mode = @boolToInt((@intCast(c_ulong, flags) & sys.FIONBIO) == sys.FIONBIO);

    if (sys.ioctlsocket(result, sys.FIONBIO, &@intCast(c_int, mode)) != 0) {
        return InvalidSocket;
    }

    // WSA_FLAG_NO_HANDLE_INHERIT

    return result;
}

pub const Socket = struct {
    fd: SocketFd,

    pub fn new(domain: Domain, socket_type: SocketType, protocol: Protocol) {
        const rc = sys.socket(@enumToInt(domain), @enumToInt(socket_type), @enumToInt(protocol));

        if (is_posix) {
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return @intCast(SocketFd, rc),
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
            const err = sys.WSAGetLastError();
            // TODO check for TOO_MANY_OPEN_FILES?
            switch (err) {
                0 => return rc,
                sys.WSAEACCES => return SocketError.PermissionDenied,
                sys.WSAEAFNOSUPPORT => return SocketError.AddressFamilyNotSupported,
                sys.WSAEINVAL => return SocketError.ProtocolFamilyNotAvailable,
                sys.WSAEMFILE => return SocketError.ProcessFdQuotaExceeded,
                sys.WSAENOBUFS, sys.WSA_NOT_ENOUGH_MEMORY => return SocketError.SystemResources,
                sys.WSAEPROTONOSUPPORT => return SocketError.ProtocolNotSupported,
                else => return unexpectedError(err),
            }
        }
    }

    /// addr is `*const T` where T is one of the sockaddr
    pub fn bind(self: Self, addr: *const sys.sockaddr) BindError!void {
        const rc = sys.bind(self.fd, addr, @sizeOf(sys.sockaddr));

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
                sys.WSAEACCES => return BindError.AccessDenied,
                sys.WSAEADDRINUSE => return BindError.AddressInUse,
                sys.WSAEBADF => unreachable, // always a race condition if this error is returned
                sys.WSAEINVAL => unreachable,
                sys.WSAENOTSOCK => unreachable,
                sys.WSAEADDRNOTAVAIL => return BindError.AddressNotAvailable,
                sys.WSAEFAULT => unreachable,
                sys.WSAELOOP => return BindError.SymLinkLoop,
                sys.WSAENAMETOOLONG => return BindError.NameTooLong,
                sys.WSAENOMEM => return BindError.SystemResources,
                else => return unexpectedError(err),
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
                sys.WSAEADDRINUSE => return ListenError.AddressInUse,
                sys.WSAEBADF => unreachable,
                sys.WSAENOTSOCK => return ListenError.FileDescriptorNotASocket,
                sys.WSAEOPNOTSUPP => return ListenError.OperationNotSupported,
                else => return unexpectedError(err),
            }
        }
        
    }

    pub fn accept(fd: SocketFd, addr: *sys.sockaddr, flags: u32) AcceptError!Socket {
        if (is_posix) {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(sys.sockaddr));
                const rc = sys.accept4(fd, addr, &sockaddr_size, flags);
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
                var sockaddr_size = sys.socklen_t(@sizeOf(sys.sockaddr));
                // port accept4
                const rc = accept4Windows(fd, addr, &sockaddr_size, flags);
                const err = sys.WSAGetLastError();
                switch (err) {
                    0 => return Socket { .fd = rc },
                    sys.EINTR => continue,
                    else => return unexpectedError(err),
                    // TODO check for TOO_MANY_OPEN_FILES?
                    sys.WSAEWOULDBLOCK => unreachable, // use asyncAccept for non-blocking
                    sys.WSAEBADF => unreachable, // always a race condition
                    sys.WSAECONNABORTED => return AcceptError.ConnectionAborted,
                    sys.WSAEFAULT => unreachable,
                    sys.WSAEINVAL => unreachable,
                    sys.WSAEMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.WSAENOBUFS => return AcceptError.SystemResources,
                    sys.WSAENOMEM => return AcceptError.SystemResources,
                    sys.WSAENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.WSAEOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.WSAEPROTO => return AcceptError.ProtocolFailure,
                    sys.WSAEACCES => return AcceptError.BlockedByFirewall,
                }
            }
        }
    }

    /// Returns InvalidSocket if would block.
    pub fn asyncAccept(self: Self, addr: *sys.sockaddr, flags: u32) AcceptError!Socket {
        if (is_posix) {
            while (true) {
                var sockaddr_size = sys.socklen_t(@sizeOf(sys.sockaddr));
                const rc = sys.accept4(self.fd, addr, &sockaddr_size, flags);
                const err = sys.getErrno(rc);
                switch (err) {
                    0 => return Socket { .fd = @intCast(SocketFd, rc) },
                    sys.EINTR => continue,
                    else => return unexpectedError(err),
                    sys.EAGAIN  => return InvalidSocket,
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
                var sockaddr_size = sys.socklen_t(@sizeOf(sys.sockaddr));
                const rc = accept4Windows(self.fd, addr, &sockaddr_size, flags);
                const err = sys.WSAGetLastError();
                // TODO check for TOO_MANY_OPEN_FILES?
                switch (err) {
                    0 => return Socket { .fd = rc },
                    sys.WSAEINTR => continue,
                    else => return unexpectedError(err),
                    sys.WSAEWOULDBLOCK  => return InvalidSocket,
                    sys.WSAEBADF => unreachable, // always a race condition
                    sys.WSAECONNABORTED => return AcceptError.ConnectionAborted,
                    sys.WSAEFAULT => unreachable,
                    sys.WSAEINVAL => unreachable,
                    sys.WSAEMFILE => return AcceptError.ProcessFdQuotaExceeded,
                    sys.WSAENOBUFS => return AcceptError.SystemResources,
                    sys.WSAENOMEM => return AcceptError.SystemResources,
                    sys.WSAENOTSOCK => return AcceptError.FileDescriptorNotASocket,
                    sys.WSAEOPNOTSUPP => return AcceptError.OperationNotSupported,
                    sys.WSAEPROTO => return AcceptError.ProtocolFailure,
                    sys.WSAEACCES => return AcceptError.BlockedByFirewall,
                }
            }
        }
    }

    pub fn getSockName(self: Socket) GetSockNameError!sys.sockaddr {
        var addr: sys.sockaddr = undefined;
        var addrlen: sys.socklen_t = @sizeOf(sys.sockaddr);
        const rc = sys.getsockname(self.fd, &addr, &addrlen);

        if (is_posix) {
            const err = sys.getErrno(rc);
            switch (err) {
                0 => return addr,
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
                0 => return addr,
                else => return unexpectedError(err),
                sys.WSAEBADF => unreachable,
                sys.WSAEFAULT => unreachable,
                sys.WSAEINVAL => unreachable,
                sys.WSAENOTSOCK => unreachable,
                sys.WSAENOBUFS => return GetSockNameError.SystemResources,
            }
        }
    }

    pub fn connect(self: Socket, sockaddr: *const sys.sockaddr) ConnectError!void {
        if (is_posix) {
            while (true) {
                const rc = sys.connect(self.fd, sockaddr, @sizeOf(sys.sockaddr));
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
                const rc = sys.connect(self.fd, sockaddr, @sizeOf(sys.sockaddr));
                const err = sys.WSAGetLastError();
                switch (err) {
                    0 => return,
                    sys.WSAEACCES => return ConnectError.PermissionDenied,
                    sys.WSAEADDRINUSE => return ConnectError.AddressInUse,
                    sys.WSAEADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.WSAEAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.WSAEWOULDBLOCK => return ConnectError.SystemResources,
                    sys.WSAEALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.WSAEBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.WSAEINPROGRESS => unreachable, // The socket is nonblocking and the connection cannot be completed immediately.
                    sys.WSAEINTR => continue,
                    sys.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.WSAEPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(err),
                }
            }
        }
    }

    /// Same as connect except it is for blocking socket file descriptors.
    /// It expects to receive EINPROGRESS.
    pub fn connectAsync(self: Sokcet, sockaddr: *const sys.sockaddr) ConnectError!void {
        if (is_posix) {
            while (true) {
                const rc = sys.connect(self.fd, sockaddr, @sizeOf(sys.sockaddr));
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
                const rc = sys.connect(self.fd, sockaddr, @sizeOf(sys.sockaddr));
                const err = sys.WSAGetLastError();
                switch (err) {
                    0, sys.WSAEINPROGRESS => return,
                    sys.WSAEACCES => return ConnectError.PermissionDenied,
                    sys.WSAEADDRINUSE => return ConnectError.AddressInUse,
                    sys.WSAEADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.WSAEAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.WSAEWOULDBLOCK => return ConnectError.SystemResources,
                    sys.WSAEALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.WSAEBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.WSAEINTR => continue,
                    sys.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.WSAEPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(err),
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
                    sys.WSAEACCES => return ConnectError.PermissionDenied,
                    sys.WSAEADDRINUSE => return ConnectError.AddressInUse,
                    sys.WSAEADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
                    sys.WSAEAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
                    sys.WSAEWOULDBLOCK => return ConnectError.SystemResources,
                    sys.WSAEALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
                    sys.WSAEBADF => unreachable, // socket is not a valid open file descriptor.
                    sys.WSAECONNREFUSED => return ConnectError.ConnectionRefused,
                    sys.WSAEFAULT => unreachable, // The socket structure address is outside the user's address space.
                    sys.WSAEISCONN => unreachable, // The socket is already connected.
                    sys.WSAENETUNREACH => return ConnectError.NetworkUnreachable,
                    sys.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
                    sys.WSAEPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
                    sys.WSAETIMEDOUT => return ConnectError.ConnectionTimedOut,
                    else => return unexpectedError(err),
                },
                else => return unexpectedError(err),
                sys.WSAEBADF => unreachable, // The argument socket is not a valid file descriptor.
                sys.WSAEFAULT => unreachable, // The address pointed to by optval or optlen is not in a valid part of the process address space.
                sys.WSAEINVAL => unreachable,
                sys.WSAENOPROTOOPT => unreachable, // The option is unknown at the level indicated.
                sys.WSAENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
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
};
