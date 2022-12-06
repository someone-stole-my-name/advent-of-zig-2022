const std = @import("std");
const Result = @import("util/aoc.zig").Result;

pub fn puzzle_1(input: []const u8) Result {
    var iter = std.mem.split(u8, input, "\n");

    var i: usize = 0;
    mainLoop: while (iter.next()) |line| {
        var buf = std.mem.zeroes([4]u32);
        var buf_idx: usize = 0;
        for (line) |c, idx| {
            if (buf_idx > 3) buf_idx = 0;
            buf[buf_idx] = @as(u32, 1) << @intCast(u5, c - 97); // 97 == 'a'
            buf_idx += 1;
            if (@popCount(buf[0] | buf[1] | buf[2] | buf[3]) == 4) {
                i = idx + 1;
                break :mainLoop;
            }
        }
    }

    return .{ .int = @intCast(i32, i) };
}

pub fn puzzle_2(input: []const u8) Result {
    var iter = std.mem.split(u8, input, "\n");

    var i: usize = 0;
    mainLoop: while (iter.next()) |line| {
        var buf = std.mem.zeroes([14]u32);
        var buf_idx: usize = 0;
        for (line) |c, idx| {
            if (buf_idx > 13) buf_idx = 0;
            buf[buf_idx] = @as(u32, 1) << @intCast(u5, c - 97); // 97 == 'a'
            buf_idx += 1;

            const hammer: u32 = blk: {
                var hidx: usize = 0;
                var tmp: u32 = 0;
                while (hidx < 14) : (hidx += 1) tmp |= buf[hidx];
                break :blk tmp;
            };

            if (@popCount(hammer) == 14) {
                i = idx + 1;
                break :mainLoop;
            }
        }
    }

    return .{ .int = @intCast(i32, i) };
}

//pub fn puzzle_2(input: []const u8) Result {
//var iter = std.mem.split(u8, input, "\n");

//var count: u16 = 0;
//mainLoop: while (true) {
//var parts = std.mem.zeroes([3]u64);

//for (parts) |*p| {
//const line = iter.next() orelse break :mainLoop;
//for (line) |_, i| {
//p.* |= @as(u64, 1) << @intCast(u6, line[i] - 65);
//}
//}

//count += char_to_priority(@intCast(u8, 65 + 63) - @clz(parts[0] & parts[1] & parts[2]));
//}

//return .{ .int = count };
//}

//fn char_to_priority(char: u8) u8 {
//if (char >= 65 and char <= 90)
//return char - 38;
//return char - 96;
//}
