const std = @import("std");

test {
    std.testing.refAllDecls(@This());
}

fn solve(allocator: std.mem.Allocator, puzzle: anytype, input: []const u8) !i32 {
    return blk: {
        switch (@typeInfo(@TypeOf(puzzle))) {
            .Fn => |f| {
                switch (@typeInfo(f.return_type.?)) {
                    .ErrorUnion => {
                        if (f.args.len == 1)
                            break :blk try puzzle(input);
                        break :blk try puzzle(allocator, input);
                    },
                    else => {
                        if (f.args.len == 1)
                            break :blk puzzle(input);
                        break :blk puzzle(allocator, input);
                    },
                }
            },
            else => unreachable,
        }
    };
}

const testing_allocator = std.testing.allocator;

// same as the real comptimePrint but inlined, see: https://github.com/ziglang/zig/issues/12635
inline fn comptimePrint(comptime fmt: []const u8, args: anytype) *const [std.fmt.count(fmt, args):0]u8 {
    comptime {
        var buf: [std.fmt.count(fmt, args):0]u8 = undefined;
        _ = std.fmt.bufPrint(&buf, fmt, args) catch unreachable;
        buf[buf.len] = 0;
        return &buf;
    }
}

test "test" {
    const t = [_]struct {
        day: type,
        expect: []const i32,
        input: []const u8,
    }{
        .{ .day = @import("day-1/main.zig"), .input = @embedFile("day-1/input"), .expect = &[_]i32{ 69912, 208180 } },
        .{ .day = @import("day-2/main.zig"), .input = @embedFile("day-2/input"), .expect = &[_]i32{ 12855, 13726 } },
        .{ .day = @import("day-3/main.zig"), .input = @embedFile("day-3/input"), .expect = &[_]i32{ 8039, 2510 } },
        .{ .day = @import("day-4/main.zig"), .input = @embedFile("day-4/input"), .expect = &[_]i32{ 483, 874 } },
    };

    std.debug.print("\n", .{});

    inline for (t) |aoc_day, day| {
        std.debug.print("\n", .{});
        inline for (aoc_day.expect) |expected, idx| {
            const fn_name = comptimePrint("puzzle_{d}", .{idx + 1});
            const puzzle = @field(aoc_day.day, fn_name);
            const start_time = try std.time.Instant.now();

            const result = try solve(
                testing_allocator,
                puzzle,
                aoc_day.input[0 .. aoc_day.input.len - 1], // remove the last '^\n$'
            );

            const end_time = try std.time.Instant.now();
            const elapsed_us = end_time.since(start_time) / std.time.ns_per_us;

            if (result == expected) {
                std.debug.print("day={d}, puzzle_{d}={d}, input_bytes={d}, time={d}µs\n", .{
                    day + 1,
                    idx + 1,
                    result,
                    aoc_day.input.len,
                    elapsed_us,
                });
            } else {
                std.debug.print("day={d}, puzzle_{d}={d}, input_bytes={d}, time={d}µs, expected={d}\n", .{
                    day + 1,
                    idx + 1,
                    result,
                    aoc_day.input.len,
                    elapsed_us,
                    expected,
                });
                return error.UnexpectedValue;
            }
        }
    }

    std.debug.print("\n", .{});
}
