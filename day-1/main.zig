const std = @import("std");
const min_idx = @import("util/mem.zig").min_idx;

pub fn puzzle_1(input: []const u8) !i32 {
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

    return max;
}

pub fn puzzle_2(input: []const u8) !i32 {
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

    return count;
}
