const std = @import("std");
const dupl_values = @import("util/mem.zig").dupl_values;

pub fn puzzle_1(input: []u8) !u16 {
    var iter = std.mem.split(u8, input, "\n");

    var count: u16 = 0;
    while (iter.next()) |line| {
        const range = try parse_range(line);

        if ((range[0][0] >= range[1][0] and range[0][1] <= range[1][1]) or
            (range[0][0] <= range[1][0] and range[0][1] >= range[1][1]))
            count += 1;
    }

    return count;
}

pub fn puzzle_2(input: []u8) !u16 {
    var iter = std.mem.split(u8, input, "\n");

    var count: u16 = 0;
    while (iter.next()) |line| {
        const range = try parse_range(line);

        if ((range[0][0] >= range[1][0] and range[0][0] <= range[1][1]) or
            (range[0][0] <= range[1][0] and range[0][1] >= range[1][0]))
            count += 1;
    }

    return count;
}

fn parse_range(line: []const u8) ![2][2]u8 {
    var r = std.mem.zeroes([2][2]u8);

    var parts = std.mem.split(u8, line, ",");
    var p1 = std.mem.split(u8, parts.next().?, "-");
    var p2 = std.mem.split(u8, parts.next().?, "-");

    r[0][0] = try std.fmt.parseInt(u8, p1.next().?, 0);
    r[0][1] = try std.fmt.parseInt(u8, p1.next().?, 0);

    r[1][0] = try std.fmt.parseInt(u8, p2.next().?, 0);
    r[1][1] = try std.fmt.parseInt(u8, p2.next().?, 0);

    return r;
}
