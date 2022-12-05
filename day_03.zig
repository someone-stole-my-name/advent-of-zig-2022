const std = @import("std");
const Result = @import("util/aoc.zig").Result;

pub fn puzzle_1(input: []const u8) Result {
    var iter = std.mem.split(u8, input, "\n");

    var count: u16 = 0;
    while (iter.next()) |line| {
        var p1: u64 = 0;
        var p2: u64 = 0;

        // A note to whoever reads this in the future
        // A to Z -> 65 to 90
        // a to z -> 97 to 122
        //
        // u64 is ok
        // 90 - 65 + 122 - 97 = 50

        for (line[0 .. line.len / 2]) |_, i| {
            p1 |= @as(u64, 1) << @intCast(u6, line[i] - 65); // 65 == 'A'
            p2 |= @as(u64, 1) << @intCast(u6, line[i + line.len / 2] - 65);
        }

        // Example
        //
        // p1: 0000000101100010001000110000000000011000000011000010000100
        // p2: 1000001000000000000110000000000000000001011001100001100000
        //
        //  &: 0000000000000000000000000000000000000000000001000000000000 = 46 0s
        //
        //  65 + 63 - 46 = 82 = R

        count += char_to_priority(@intCast(u8, 65 + 63) - @clz(p1 & p2));
    }

    return .{ .int = count };
}

pub fn puzzle_2(input: []const u8) Result {
    var iter = std.mem.split(u8, input, "\n");

    var count: u16 = 0;
    mainLoop: while (true) {
        var parts = std.mem.zeroes([3]u64);

        for (parts) |*p| {
            const line = iter.next() orelse break :mainLoop;
            for (line) |_, i| {
                p.* |= @as(u64, 1) << @intCast(u6, line[i] - 65);
            }
        }

        count += char_to_priority(@intCast(u8, 65 + 63) - @clz(parts[0] & parts[1] & parts[2]));
    }

    return .{ .int = count };
}

fn char_to_priority(char: u8) u8 {
    if (char >= 65 and char <= 90)
        return char - 38;
    return char - 96;
}
