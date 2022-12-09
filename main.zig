const std = @import("std");
const Result = @import("util/aoc.zig").Result;

const t = [_]struct {
    day: type,
    expect: []const Result,
    input: []const u8,
}{
    .{ .day = @import("day_01.zig"), .input = @embedFile("inputs/day_01"), .expect = &[_]Result{ .{ .int = 69912 }, .{ .int = 208180 } } },
    .{ .day = @import("day_02.zig"), .input = @embedFile("inputs/day_02"), .expect = &[_]Result{ .{ .int = 12855 }, .{ .int = 13726 } } },
    .{ .day = @import("day_03.zig"), .input = @embedFile("inputs/day_03"), .expect = &[_]Result{ .{ .int = 8039 }, .{ .int = 2510 } } },
    .{ .day = @import("day_04.zig"), .input = @embedFile("inputs/day_04"), .expect = &[_]Result{ .{ .int = 483 }, .{ .int = 874 } } },
    .{ .day = @import("day_05.zig"), .input = @embedFile("inputs/day_05"), .expect = &[_]Result{ .{ .string = "SHMSDGZVC" }, .{ .string = "VRZGHDFBQ" } } },
    .{ .day = @import("day_06.zig"), .input = @embedFile("inputs/day_06"), .expect = &[_]Result{ .{ .int = 1896 }, .{ .int = 3452 } } },
    .{ .day = @import("day_07.zig"), .input = @embedFile("inputs/day_07"), .expect = &[_]Result{ .{ .int = 1427048 }, .{ .int = 2940614 } } },
    .{ .day = @import("day_08.zig"), .input = @embedFile("inputs/day_08"), .expect = &[_]Result{ .{ .int = 1859 }, .{ .int = 332640 } } },
    .{ .day = @import("day_09.zig"), .input = @embedFile("inputs/day_09"), .expect = &[_]Result{ .{ .int = 6087 }, .{ .int = 2493 } } },
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    return run_all(allocator);
}

test {
    std.testing.refAllDecls(@This());
}

fn run_all(allocator: std.mem.Allocator) !void {
    inline for (t) |aoc_day, day| {
        std.debug.print("\n", .{});
        inline for (aoc_day.expect) |expect, idx| {
            const fn_name = comptimePrint("puzzle_{d}", .{idx + 1});
            const puzzle = @field(aoc_day.day, fn_name);
            const start_time = try std.time.Instant.now();

            const result = try solve(
                allocator,
                puzzle,
                aoc_day.input[0 .. aoc_day.input.len - 1], // remove the last '^\n$'
            );
            defer result.deinit(allocator);

            const end_time = try std.time.Instant.now();
            const elapsed_us = end_time.since(start_time) / std.time.ns_per_us;

            std.debug.print("day={d}, input_bytes={d}, time={d}µs, ", .{
                day + 1,
                aoc_day.input.len,
                elapsed_us,
            });

            switch (result) {
                .string => |s| std.debug.print("puzzle_{d}={s}", .{ idx + 1, s }),
                .int => |i| std.debug.print("puzzle_{d}={d}", .{ idx + 1, i }),
            }

            if (!expect.cmp(result)) {
                switch (expect) {
                    .string => |s| std.debug.print(", expected={s}\n", .{s}),
                    .int => |i| std.debug.print(", expected={d}\n", .{i}),
                }
                return error.UnexpectedValue;
            }

            std.debug.print("\n", .{});
        }
    }
}

fn solve(allocator: std.mem.Allocator, puzzle: anytype, input: []const u8) !Result {
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
    std.debug.print("\n", .{});
    try run_all(testing_allocator);
    std.debug.print("\n", .{});
}
