const std = @import("std");
const math = std.math;
const Result = @import("util/aoc.zig").Result;

pub fn puzzle_1(input: []const u8) !Result {
    var iter = std.mem.split(u8, input, "\n");
    var count: i32 = 0;
    var max: i32 = 0;

    while (iter.next()) |line| {
        if (line.len == 0) {
            if (count > max) {
                max = count;
            }
            count = 0;
        } else {
            count += try std.fmt.parseInt(i32, line, 0);
        }
    }

    return .{ .int = max };
}

pub fn puzzle_2(input: []const u8) !Result {
    var iter = std.mem.split(u8, input, "\n");
    var count: i32 = 0;
    var max: [3]i32 = std.mem.zeroes([3]i32);

    while (iter.next()) |line| {
        if (line.len == 0) {
            const lowest_u = min_idx(i32, &max);
            if (count > max[lowest_u]) {
                max[lowest_u] = count;
            }
            count = 0;
        } else {
            count += try std.fmt.parseInt(i32, line, 0);
        }
    }

    count = 0;
    for (max) |v| {
        count += v;
    }

    return .{ .int = count };
}

fn min_idx(comptime T: type, slice: []const T) usize {
    var best = slice[0];
    var idx: usize = 0;

    for (slice[1..]) |item, i| {
        const possible_best = math.min(best, item);
        if (best > possible_best) {
            best = possible_best;
            idx = i + 1;
        }
    }
    return idx;
}
