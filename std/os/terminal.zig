const std = @import("../index.zig");
const builtin = @import("builtin");
const os = std.os;

const windows = os.windows;
const posix = os.posix;
const io = std.io;

const is_windows = builtin.os == Os.windows;
const is_posix = switch (builtin.os) {
    builtin.Os.linux, builtin.Os.macosx => true,
    else => false,
};

const Os = builtin.Os;
const OutStream = os.File.OutStream;


// TODO
// [ ] getWidth
// [ ] getHeight
// [ ] setWidth
// [ ] setHeight

// [ ] hideCursor
// [ ] showCursor

// [ ] setCursorX
// [ ] setCursorY

// [ ] cursorUp
// [ ] cursorDown
// [ ] cursorForward
// [ ] cursorBackward

// [ ] eraseLine
// [ ] eraseScreen

// [x] setForegroundColor
// [x] setBackgroundColor
// [ ] getForegroundColor
// [ ] getBackgroundColor
// [ ] getForegroundColor (no change)
// [ ] getBackgroundColor (no change)

// [ ] getch
// [x] reset

pub const Color = enum.{
    Black,
    Blue,
    Green,
    Aqua,
    Red,
    Purple,
    Yellow,
    White,
};

pub const Attribute = enum.{
    Bright,
    Reversed,
    Underlined,
};

pub const Mode = enum.{
    ForeGround,
    BackGround,
};

pub const Terminal = struct.{
    const Self = @This();

    const Error = error.{
        InvalidFile,
        InvalidMode,
    };

    file: os.File,
    file_stream: OutStream,
    out_stream: ?*OutStream.Stream,

    // windows
    default_attrs: u16,
    current_attrs: u16,

    // public
    pub background: Color,
    pub foreground: Color,
    
    pub fn new(file: os.File) !Self {
        // TODO handle error
        var info: CONSOLE_SCREEN_BUFFER_INFO = undefined;
        _ = GetConsoleScreenBufferInfo(file.handle, &info);

        if (!file.isTty()) {
            return error.InvalidFile;
        }

        return Self.{
            .file = file,
            .file_stream = file.outStream(),
            .out_stream = null,
            .default_attrs = info.wAttributes,
            .current_attrs = 0,
            .background = undefined,
            .foreground = undefined,
        };
    }

    fn setAttributeWindows(self: *Self, attr: Attribute, mode: ?Mode) !void {
        if (mode == null and attr == Attribute.Bright) {
            return error.InvalidMode;
        }

        self.current_attrs ^= switch (attr) {
            Attribute.Bright     => switch (mode.?) {
                Mode.ForeGround => FOREGROUND_INTENSITY,
                Mode.BackGround => BACKGROUND_INTENSITY,
            },
            // these dont work without [this](https://docs.microsoft.com/en-us/windows/console/console-screen-buffers)
            // Attribute.Reversed   => COMMON_LVB_REVERSE_VIDEO,
            // Attribute.Underlined => COMMON_LVB_UNDERSCORE,
            else => 0,
        };

        // TODO handle errors
        _ = SetConsoleTextAttribute(self.file.handle, self.current_attrs | self.foreground | self.background);
    }

    fn setColorWindows(self: *Self, color: Color, mode: Mode) void {
        var foreground = seld.default_attrs & 0x00ff;
        var background = seld.default_attrs & 0xff00;

        switch (mode) {
            Mode.ForeGround => {
                foreground = switch (color) {
                    Color.Black  => FOREGROUND_BLACK,
                    Color.Blue   => FOREGROUND_BLUE,
                    Color.Green  => FOREGROUND_GREEN,
                    Color.Aqua   => FOREGROUND_AQUA,
                    Color.Red    => FOREGROUND_RED,
                    Color.Purple => FOREGROUND_PURPLE,
                    Color.Yellow => FOREGROUND_YELLOW,
                    Color.White  => FOREGROUND_WHITE,
                };
            },
            Mode.BackGround => {
                background = switch (color) {
                    Color.Black  => BACKGROUND_BLACK,
                    Color.Blue   => BACKGROUND_BLUE,
                    Color.Green  => BACKGROUND_GREEN,
                    Color.Aqua   => BACKGROUND_AQUA,
                    Color.Red    => BACKGROUND_RED,
                    Color.Purple => BACKGROUND_PURPLE,
                    Color.Yellow => BACKGROUND_YELLOW,
                    Color.White  => BACKGROUND_WHITE,
                };
            },
        }

        // TODO handle errors
        _ = SetConsoleTextAttribute(self.file.handle, self.current_attrs | foreground | background);
    }

    // can't be done in `new` because of no copy-elision
    fn outStream(self: *Self) *OutStream.Stream {
        if (self.out_stream) |out_stream| {
            return out_stream;
        } else {
            self.out_stream = &self.file_stream.stream;
            return self.out_stream.?;
        }
    }

    /// returns the terminal to it's prevoius state
    pub fn reset(self: *Self) !void {
        if (builtin.os == builtin.Os.windows and !supportsAnsiEscapeCodes(self.file.handle)) {
            // TODO handle errors
            _ = SetConsoleTextAttribute(self.file.handle, self.default_attrs);
        } else {
            var out = self.outStream();
            try out.write("\x1b[0m");
        }
        self.current_attrs = self.default_attrs;
    }

    pub fn setAttribute(self: *Self, attr: Attribute, mode: ?Mode) !void {
        if (builtin.os == builtin.Os.windows and !supportsAnsiEscapeCodes(self.file.handle)) {
            try self.setAttributeWindows(attr, mode);
        } else {
            var out = self.outStream();
            if (mode == null and attr == Attribute.Bright) {
                return error.InvalidMode;
            }
            switch (attr) {
                Attribute.Bright     => try out.write("\x1b[1m"),
                Attribute.Underlined => try out.write("\x1b[4m"),
                Attribute.Reversed   => try out.write("\x1b[7m"),
            }
        }
    }

    pub fn setColor(self: *Self, color: Color, mode: Mode, attributes: ?[]const Attribute) !void {
        if (attributes) |attrs| {
            for (attrs) |attr| {
                try self.setAttribute(attr, mode);
            }
        }

        if (builtin.os == builtin.Os.windows and !supportsAnsiEscapeCodes(self.file.handle)) {
            self.setColorWindows(color, mode);
        } else {
            var out = self.outStream();
            switch (mode) {
                Mode.ForeGround => {
                    switch (color) {
                        Color.Black  => try out.write("\x1b[30m"),
                        Color.Red    => try out.write("\x1b[31m"),
                        Color.Green  => try out.write("\x1b[32m"),
                        Color.Yellow => try out.write("\x1b[33m"),
                        Color.Blue   => try out.write("\x1b[34m"),
                        Color.Purple => try out.write("\x1b[35m"),
                        Color.Aqua   => try out.write("\x1b[36m"),
                        Color.White  => try out.write("\x1b[37m"),
                    }
                    self.foreground = color;
                },
                Mode.BackGround => {
                    switch (color) {
                        Color.Black  => try out.write("\x1b[40m"),
                        Color.Red    => try out.write("\x1b[41m"),
                        Color.Green  => try out.write("\x1b[42m"),
                        Color.Yellow => try out.write("\x1b[43m"),
                        Color.Blue   => try out.write("\x1b[44m"),
                        Color.Purple => try out.write("\x1b[45m"),
                        Color.Aqua   => try out.write("\x1b[46m"),
                        Color.White  => try out.write("\x1b[47m"),
                    }
                    self.foreground = color;
                }
            }
        }
    }

    pub fn getWidth(self: *const Self) usize {
        if (is_windows) {
            if (!os.supportsAnsiEscapeCodes(self.file.handle)) {
                var info: CONSOLE_SCREEN_BUFFER_INFO = undefined;
                if (windows.GetConsoleScreenBufferInfo(self.file.handle, &info) != 0) {
                    return @intCast(usize, info.srWindow.Right - info.srWindow.Left + 1);
                }
            }
        }
    }

    pub fn getHeight(self: *const Self) usize {
        if (is_windows) {
            if (!os.supportsAnsiEscapeCodes(self.file.handle)) {
                var info: CONSOLE_SCREEN_BUFFER_INFO = undefined;
                if (windows.GetConsoleScreenBufferInfo(self.file.handle, &info) != 0) {
                    return (info.srWindow.Bottom - info.srWindow.Top + 1);
                }
            }
        }
    }

    pub fn setCursorVisible(self: *const Self) usize {
        if (is_windows) {
            if (!os.supportsAnsiEscapeCodes(self.file.handle)) {
                var info: CONSOLE_SCREEN_BUFFER_INFO = undefined;
                if (windows.GetConsoleScreenBufferInfo(self.file.handle, &info) != 0) {
                    return (info.srWindow.Bottom - info.srWindow.Top + 1);
                }
            }
        }
    }
};
