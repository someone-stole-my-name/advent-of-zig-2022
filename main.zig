const std = @import("std");

const t = [_]struct {
    day: type,
    expect: [2]i32,
}{
    .{ .day = @import("day-1/main.zig"), .expect = [_]i32{ 69912, 208180 } },
    .{ .day = @import("day-2/main.zig"), .expect = [_]i32{ 12855, 13726 } },
    .{ .day = @import("day-3/main.zig"), .expect = [_]i32{ 8039, 2510 } },
};

test {
    std.testing.refAllDecls(@This());
}

const allocator = std.testing.allocator;
const slurp = @import("util/file.zig").slurp;

// just here to inline it, see: https://github.com/ziglang/zig/issues/12635
inline fn comptimePrint(comptime fmt: []const u8, args: anytype) *const [std.fmt.count(fmt, args):0]u8 {
    comptime {
        var buf: [std.fmt.count(fmt, args):0]u8 = undefined;
        _ = std.fmt.bufPrint(&buf, fmt, args) catch unreachable;
        buf[buf.len] = 0;
        return &buf;
    }
}

test "test" {
    std.debug.print("\n", .{});

    inline for (t) |aoc_day, day| {
        std.debug.print("\n", .{});
        const file_buffer = try slurp(std.testing.allocator, comptimePrint("./day-{d}/input", .{day + 1}));
        defer allocator.free(file_buffer);

        inline for (aoc_day.expect) |expected, idx| {
            const fn_name = comptimePrint("puzzle_{d}", .{idx + 1});

            const puzzle = @field(aoc_day.day, fn_name);
            const result = blk: {
                switch (@typeInfo(@TypeOf(puzzle))) {
                    .Fn => |f| {
                        switch (@typeInfo(f.return_type.?)) {
                            .ErrorUnion => {
                                if (f.args.len == 1)
                                    break :blk try puzzle(file_buffer);
                                break :blk try puzzle(allocator, file_buffer);
                            },
                            else => {
                                if (f.args.len == 1)
                                    break :blk puzzle(file_buffer);
                                break :blk puzzle(allocator, file_buffer);
                            },
                        }
                    },
                    else => unreachable,
                }
            };

            if (result == expected) {
                std.debug.print("day={d}, puzzle_{d}={d}\n", .{ day + 1, idx + 1, result });
            } else {
                std.debug.print("day={d}, puzzle_{d}={d}, expected={d}\n", .{ day + 1, idx + 1, result, expected });
            }
        }
    }

    std.debug.print("\n", .{});
}
