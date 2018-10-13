const std = @import("../index.zig");
const builtin = @import("builtin");
const os = std.os;

pub const sys = switch (builtin.os) {
    builtin.Os.windows => std.os.windows,
    builtin.Os.linux, builtin.Os.macosx => std.os.posix,
    else => @compileError("unsupported os"),
};

const unexpectedError = switch (builtin.os) {
    builtin.Os.windows => os.unexpectedErrorWindows,
    builtin.Os.linux, builtin.Os.macosx => os.unexpectedErrorPosix,
    else => @compileError("unsupported os"),
};

fn winGetErrno(_: usize) u32 {
    return @intCast(u32, sys.WSAGetLastError());
}

pub const getErrno = switch (builtin.os) {
    builtin.Os.windows => winGetErrno,
    builtin.Os.linux, builtin.Os.macosx => sys.getErrno,
    else => @compileError("unsupported os"),
};

pub const Socket = switch (builtin.os) {
    builtin.Os.windows => sys.SOCKET,
    builtin.Os.linux, builtin.Os.macosx => i32,
    else => @compileError("unsupported os"),
};

pub const SocketError = error{
    /// Permission to create a socket of the specified type and/or
    /// pro‐tocol is denied.
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

pub fn socket(domain: u32, socket_type: u32, protocol: u32) !Socket {
    const rc = sys.socket(domain, socket_type, protocol);
    const err = getErrno(rc);
    switch (err) {
        0 => return @intCast(Socket, rc),
        sys.EACCES => return SocketError.PermissionDenied,
        sys.EAFNOSUPPORT => return SocketError.AddressFamilyNotSupported,
        sys.EINVAL => return SocketError.ProtocolFamilyNotAvailable,
        sys.EMFILE => return SocketError.ProcessFdQuotaExceeded,
        sys.ENFILE => return SocketError.SystemFdQuotaExceeded,
        sys.ENOBUFS, sys.ENOMEM => return SocketError.SystemResources,
        sys.EPROTONOSUPPORT => return SocketError.ProtocolNotSupported,
        else => return unexpectedError(err),
    }
}

pub const BindError = error{
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

/// addr is `*const T` where T is one of the sockaddr
pub fn bind(socketfd: Socket, addr: *const sys.sockaddr) BindError!void {
    const rc = sys.bind(socketfd, addr, @sizeOf(sys.sockaddr));
    const err = getErrno(@intCast(usize, rc));
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
}

const ListenError = error{
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

pub fn listen(socketfd: Socket, backlog: u32) ListenError!void {
    const rc = sys.listen(socketfd, backlog);
    const err = getErrno(@intCast(usize, rc));
    switch (err) {
        0 => return,
        sys.EADDRINUSE => return ListenError.AddressInUse,
        sys.EBADF => unreachable,
        sys.ENOTSOCK => return ListenError.FileDescriptorNotASocket,
        sys.EOPNOTSUPP => return ListenError.OperationNotSupported,
        else => return unexpectedError(err),
    }
}

pub const AcceptError = error{
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

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub fn accept(socketfd: Socket, addr: *sys.sockaddr, flags: u32) AcceptError!Socket {
    while (true) {
        var sockaddr_size = u32(@sizeOf(sys.sockaddr));
        const rc = sys.accept4(socketfd, addr, &sockaddr_size, flags);
        const err = getErrno(rc);
        switch (err) {
            0 => return @intCast(Socket, rc),
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
}

/// Returns -1 if would block.
pub fn asyncAccept(socketfd: Socket, addr: *sys.sockaddr, flags: u32) AcceptError!Socket {
    while (true) {
        var sockaddr_size = u32(@sizeOf(sys.sockaddr));
        const rc = sys.accept4(socketfd, addr, &sockaddr_size, flags);
        const err = getErrno(rc);
        switch (err) {
            0 => return @intCast(Socket, rc),
            sys.EINTR => continue,
            else => return unexpectedError(err),

            sys.EAGAIN => return -1,
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
}

pub const GetSockNameError = error{
    /// Insufficient resources were available in the system to perform the operation.
    SystemResources,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub fn getSockName(socketfd: Socket) GetSockNameError!sys.sockaddr {
    var addr: sys.sockaddr = undefined;
    var addrlen: sys.socklen_t = @sizeOf(sys.sockaddr);
    const rc = sys.getsockname(socketfd, &addr, &addrlen);
    const err = getErrno(rc);
    switch (err) {
        0 => return addr,
        else => return unexpectedError(err),

        sys.EBADF => unreachable,
        sys.EFAULT => unreachable,
        sys.EINVAL => unreachable,
        sys.ENOTSOCK => unreachable,
        sys.ENOBUFS => return GetSockNameError.SystemResources,
    }
}

pub const ConnectError = error{
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

pub fn connect(socketfd: Socket, sockaddr: *const sys.sockaddr) ConnectError!void {
    while (true) {
        const rc = sys.connect(socketfd, sockaddr, @sizeOf(sys.sockaddr));
        const err = getErrno(rc);
        switch (err) {
            0 => return,
            else => return unexpectedError(err),

            sys.EACCES => return ConnectError.PermissionDenied,
            sys.EPERM => return ConnectError.PermissionDenied,
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
        }
    }
}

/// Same as connect except it is for blocking socket file descriptors.
/// It expects to receive EINPROGRESS.
pub fn connectAsync(socketfd: Socket, sockaddr: *const c_void, len: u32) ConnectError!void {
    while (true) {
        const rc = sys.connect(socketfd, sockaddr, len);
        const err = getErrno(rc);
        switch (err) {
            0, sys.EINPROGRESS => return,
            else => return unexpectedError(err),

            sys.EACCES => return ConnectError.PermissionDenied,
            sys.EPERM => return ConnectError.PermissionDenied,
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
        }
    }
}

pub fn getSockOptConnectError(socketfd: Socket) ConnectError!void {
    var err_code: i32 = undefined;
    var size: u32 = @sizeOf(i32);
    const rc = sys.getsockopt(socketfd, sys.SOL_SOCKET, sys.SO_ERROR, @ptrCast([*]u8, &err_code), &size);
    assert(size == 4);
    const err = getErrno(rc);
    switch (err) {
        0 => switch (err_code) {
            0 => return,
            else => return unexpectedError(err),

            sys.EACCES => return ConnectError.PermissionDenied,
            sys.EPERM => return ConnectError.PermissionDenied,
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
        },
        else => return unexpectedError(err),
        sys.EBADF => unreachable, // The argument socket is not a valid file descriptor.
        sys.EFAULT => unreachable, // The address pointed to by optval or optlen is not in a valid part of the process address space.
        sys.EINVAL => unreachable,
        sys.ENOPROTOOPT => unreachable, // The option is unknown at the level indicated.
        sys.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
    }
}


pub fn close(socketfd: Socket) void {
    switch (builtin.os) {
        builtin.Os.windows => sys.closesocket(socketfd),
        builtin.Os.linux, builtin.Os.macosx => os.close(socketfd),
        else => @compileError("unsupported os"),
    }
}
