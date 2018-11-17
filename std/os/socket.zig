const std = @import("../index.zig");
const builtin = @import("builtin");
const os = std.os;

const impl = switch (builtin.os) {
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
    return @intCast(u32, impl.WSAGetLastError());
}

pub const getErrno = switch (builtin.os) {
    builtin.Os.windows => winGetErrno,
    builtin.Os.linux, builtin.Os.macosx => impl.getErrno,
    else => @compileError("unsupported os"),
};

pub const Socket = switch (builtin.os) {
    builtin.Os.windows => impl.SOCKET,
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
    const rc = impl.socket(domain, socket_type, protocol);
    const err = getErrno(rc);
    switch (err) {
        0 => return @intCast(Socket, rc),
        impl.EACCES => return SocketError.PermissionDenied,
        impl.EAFNOSUPPORT => return SocketError.AddressFamilyNotSupported,
        impl.EINVAL => return SocketError.ProtocolFamilyNotAvailable,
        impl.EMFILE => return SocketError.ProcessFdQuotaExceeded,
        impl.ENFILE => return SocketError.SystemFdQuotaExceeded,
        impl.ENOBUFS, impl.ENOMEM => return SocketError.SystemResources,
        impl.EPROTONOSUPPORT => return SocketError.ProtocolNotSupported,
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
    /// use.  See the discussion of /proc/impl/net/ipv4/ip_local_port_range ip(7).
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
pub fn bind(fd: Socket, addr: *const impl.sockaddr) BindError!void {
    const rc = impl.bind(fd, addr, @sizeOf(impl.sockaddr));
    const err = getErrno(@intCast(usize, rc));
    switch (err) {
        0 => return,
        impl.EACCES => return BindError.AccessDenied,
        impl.EADDRINUSE => return BindError.AddressInUse,
        impl.EBADF => unreachable, // always a race condition if this error is returned
        impl.EINVAL => unreachable,
        impl.ENOTSOCK => unreachable,
        impl.EADDRNOTAVAIL => return BindError.AddressNotAvailable,
        impl.EFAULT => unreachable,
        impl.ELOOP => return BindError.SymLinkLoop,
        impl.ENAMETOOLONG => return BindError.NameTooLong,
        impl.ENOENT => return BindError.FileNotFound,
        impl.ENOMEM => return BindError.SystemResources,
        impl.ENOTDIR => return BindError.NotDir,
        impl.EROFS => return BindError.ReadOnlyFileSystem,
        else => return unexpectedError(err),
    }
}

const ListenError = error{
    /// Another socket is already listening on the same port.
    /// For Internet domain sockets, the  socket referred to by socket had not previously
    /// been bound to an address and, upon attempting to bind it to an ephemeral port, it
    /// was determined that all port numbers in the ephemeral port range are currently in
    /// use.  See the discussion of /proc/impl/net/ipv4/ip_local_port_range in ip(7).
    AddressInUse,

    /// The file descriptor socket does not refer to a socket.
    FileDescriptorNotASocket,

    /// The socket is not of a type that supports the listen() operation.
    OperationNotSupported,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub fn listen(fd: Socket, backlog: u32) ListenError!void {
    const rc = impl.listen(fd, backlog);
    const err = getErrno(@intCast(usize, rc));
    switch (err) {
        0 => return,
        impl.EADDRINUSE => return ListenError.AddressInUse,
        impl.EBADF => unreachable,
        impl.ENOTSOCK => return ListenError.FileDescriptorNotASocket,
        impl.EOPNOTSUPP => return ListenError.OperationNotSupported,
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

pub fn accept(fd: Socket, addr: *impl.sockaddr, flags: u32) AcceptError!Socket {
    while (true) {
        var sockaddr_size = u32(@sizeOf(impl.sockaddr));
        const rc = impl.accept4(fd, addr, &sockaddr_size, flags);
        const err = getErrno(rc);
        switch (err) {
            0 => return @intCast(Socket, rc),
            impl.EINTR => continue,
            else => return unexpectedError(err),

            impl.EAGAIN => unreachable, // use asyncAccept for non-blocking
            impl.EBADF => unreachable, // always a race condition
            impl.ECONNABORTED => return AcceptError.ConnectionAborted,
            impl.EFAULT => unreachable,
            impl.EINVAL => unreachable,
            impl.EMFILE => return AcceptError.ProcessFdQuotaExceeded,
            impl.ENFILE => return AcceptError.SystemFdQuotaExceeded,
            impl.ENOBUFS => return AcceptError.SystemResources,
            impl.ENOMEM => return AcceptError.SystemResources,
            impl.ENOTSOCK => return AcceptError.FileDescriptorNotASocket,
            impl.EOPNOTSUPP => return AcceptError.OperationNotSupported,
            impl.EPROTO => return AcceptError.ProtocolFailure,
            impl.EPERM => return AcceptError.BlockedByFirewall,
        }
    }
}

/// Returns -1 if would block.
pub fn asyncAccept(fd: Socket, addr: *impl.sockaddr, flags: u32) AcceptError!Socket {
    while (true) {
        var sockaddr_size = u32(@sizeOf(impl.sockaddr));
        const rc = impl.accept4(fd, addr, &sockaddr_size, flags);
        const err = getErrno(rc);
        switch (err) {
            0 => return @intCast(Socket, rc),
            impl.EINTR => continue,
            else => return unexpectedError(err),

            impl.EAGAIN => return -1,
            impl.EBADF => unreachable, // always a race condition
            impl.ECONNABORTED => return AcceptError.ConnectionAborted,
            impl.EFAULT => unreachable,
            impl.EINVAL => unreachable,
            impl.EMFILE => return AcceptError.ProcessFdQuotaExceeded,
            impl.ENFILE => return AcceptError.SystemFdQuotaExceeded,
            impl.ENOBUFS => return AcceptError.SystemResources,
            impl.ENOMEM => return AcceptError.SystemResources,
            impl.ENOTSOCK => return AcceptError.FileDescriptorNotASocket,
            impl.EOPNOTSUPP => return AcceptError.OperationNotSupported,
            impl.EPROTO => return AcceptError.ProtocolFailure,
            impl.EPERM => return AcceptError.BlockedByFirewall,
        }
    }
}

pub const GetSockNameError = error{
    /// Insufficient resources were available in the system to perform the operation.
    SystemResources,

    /// See https://github.com/ziglang/zig/issues/1396
    Unexpected,
};

pub fn getSockName(fd: Socket) GetSockNameError!impl.sockaddr {
    var addr: impl.sockaddr = undefined;
    var addrlen: impl.socklen_t = @sizeOf(impl.sockaddr);
    const rc = impl.getsockname(fd, &addr, &addrlen);
    const err = getErrno(rc);
    switch (err) {
        0 => return addr,
        else => return unexpectedError(err),

        impl.EBADF => unreachable,
        impl.EFAULT => unreachable,
        impl.EINVAL => unreachable,
        impl.ENOTSOCK => unreachable,
        impl.ENOBUFS => return GetSockNameError.SystemResources,
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
    /// /proc/impl/net/ipv4/ip_local_port_range in ip(7).
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

pub fn connect(fd: Socket, sockaddr: *const impl.sockaddr) ConnectError!void {
    while (true) {
        const rc = impl.connect(fd, sockaddr, @sizeOf(impl.sockaddr));
        const err = getErrno(rc);
        switch (err) {
            0 => return,
            else => return unexpectedError(err),

            impl.EACCES => return ConnectError.PermissionDenied,
            impl.EPERM => return ConnectError.PermissionDenied,
            impl.EADDRINUSE => return ConnectError.AddressInUse,
            impl.EADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
            impl.EAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
            impl.EAGAIN => return ConnectError.SystemResources,
            impl.EALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
            impl.EBADF => unreachable, // socket is not a valid open file descriptor.
            impl.ECONNREFUSED => return ConnectError.ConnectionRefused,
            impl.EFAULT => unreachable, // The socket structure address is outside the user's address space.
            impl.EINPROGRESS => unreachable, // The socket is nonblocking and the connection cannot be completed immediately.
            impl.EINTR => continue,
            impl.EISCONN => unreachable, // The socket is already connected.
            impl.ENETUNREACH => return ConnectError.NetworkUnreachable,
            impl.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
            impl.EPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
            impl.ETIMEDOUT => return ConnectError.ConnectionTimedOut,
        }
    }
}

/// Same as connect except it is for blocking socket file descriptors.
/// It expects to receive EINPROGRESS.
pub fn connectAsync(fd: Socket, sockaddr: *const c_void, len: u32) ConnectError!void {
    while (true) {
        const rc = impl.connect(fd, sockaddr, len);
        const err = getErrno(rc);
        switch (err) {
            0, impl.EINPROGRESS => return,
            else => return unexpectedError(err),

            impl.EACCES => return ConnectError.PermissionDenied,
            impl.EPERM => return ConnectError.PermissionDenied,
            impl.EADDRINUSE => return ConnectError.AddressInUse,
            impl.EADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
            impl.EAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
            impl.EAGAIN => return ConnectError.SystemResources,
            impl.EALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
            impl.EBADF => unreachable, // socket is not a valid open file descriptor.
            impl.ECONNREFUSED => return ConnectError.ConnectionRefused,
            impl.EFAULT => unreachable, // The socket structure address is outside the user's address space.
            impl.EINTR => continue,
            impl.EISCONN => unreachable, // The socket is already connected.
            impl.ENETUNREACH => return ConnectError.NetworkUnreachable,
            impl.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
            impl.EPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
            impl.ETIMEDOUT => return ConnectError.ConnectionTimedOut,
        }
    }
}

pub fn getSockOptConnectError(fd: Socket) ConnectError!void {
    var err_code: i32 = undefined;
    var size: u32 = @sizeOf(i32);
    const rc = impl.getsockopt(fd, impl.SOL_SOCKET, impl.SO_ERROR, @ptrCast([*]u8, &err_code), &size);
    assert(size == 4);
    const err = getErrno(rc);
    switch (err) {
        0 => switch (err_code) {
            0 => return,
            else => return unexpectedError(err),

            impl.EACCES => return ConnectError.PermissionDenied,
            impl.EPERM => return ConnectError.PermissionDenied,
            impl.EADDRINUSE => return ConnectError.AddressInUse,
            impl.EADDRNOTAVAIL => return ConnectError.AddressNotAvailable,
            impl.EAFNOSUPPORT => return ConnectError.AddressFamilyNotSupported,
            impl.EAGAIN => return ConnectError.SystemResources,
            impl.EALREADY => unreachable, // The socket is nonblocking and a previous connection attempt has not yet been completed.
            impl.EBADF => unreachable, // socket is not a valid open file descriptor.
            impl.ECONNREFUSED => return ConnectError.ConnectionRefused,
            impl.EFAULT => unreachable, // The socket structure address is outside the user's address space.
            impl.EISCONN => unreachable, // The socket is already connected.
            impl.ENETUNREACH => return ConnectError.NetworkUnreachable,
            impl.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
            impl.EPROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
            impl.ETIMEDOUT => return ConnectError.ConnectionTimedOut,
        },
        else => return unexpectedError(err),
        impl.EBADF => unreachable, // The argument socket is not a valid file descriptor.
        impl.EFAULT => unreachable, // The address pointed to by optval or optlen is not in a valid part of the process address space.
        impl.EINVAL => unreachable,
        impl.ENOPROTOOPT => unreachable, // The option is unknown at the level indicated.
        impl.ENOTSOCK => unreachable, // The file descriptor socket does not refer to a socket.
    }
}


pub fn close(fd: Socket) void {
    switch (builtin.os) {
        builtin.Os.windows => impl.closesocket(fd),
        builtin.Os.linux, builtin.Os.macosx => os.close(fd),
        else => @compileError("unsupported os"),
    }
}
