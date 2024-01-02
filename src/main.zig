const std = @import("std");
const ArrayList = std.ArrayList;

const Token = @import("tokens.zig").Token;

const Zigstr = @import("zigstr");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var stdoutConfig = std.io.tty.detectConfig(std.io.getStdOut());
    _ = stdoutConfig;
    var stderrConfig = std.io.tty.detectConfig(std.io.getStdErr());
    _ = stderrConfig;
    const stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();
    var stderr = std.io.getStdErr().writer();
    _ = stderr;

    var line = ArrayList(u8).init(gpa.allocator());

    while (true) {
        stdin.streamUntilDelimiter(line.writer(), '\n', null) catch |e| switch (e) {
            error.EndOfStream => return,
            else => return e,
        };
        var toks = Token.parse(gpa.allocator(), line.items);
        while (try toks.next()) |tok| try stdout.print("Token: {}\n", .{tok});
        line.clearAndFree();
    }
}

test "all" {
    std.testing.refAllDecls(@This());
}

test "Zigstr README tests" {
    var str = try Zigstr.fromConstBytes(std.testing.allocator, "Héllo");
    defer str.deinit();

    // Byte count.
    try std.testing.expectEqual(@as(usize, 6), str.byteLen());
}
