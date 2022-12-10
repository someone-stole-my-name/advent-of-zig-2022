const std = @import("std");
const Result = @import("util/aoc.zig").Result;

pub fn puzzle_1(input: []const u8) Result {
    var cycle: u16 = 1;
    var register: i16 = 1;
    var sum: u16 = 0;

    var iter = std.mem.split(u8, input, "\n");
    while (iter.next()) |line| {
        if (cycle % 40 == 20) sum += cycle * @intCast(u16, register);
        cycle += 1;

        if (line[0] != 'a') continue;

        const n = std.fmt.parseInt(i16, line[5..], 0) catch unreachable;

        if (cycle % 40 == 20) sum += cycle * @intCast(u16, register);
        cycle += 1;

        register += n;
    }

    return .{ .int = sum };
}

fn crt(cycle: u16, register: i16, screen: *[6][40]bool) void {
    const pixel_id = (cycle - 1) % 240;
    const pixel_row = pixel_id / 40;
    const pixel_col = pixel_id % 40;

    if (pixel_col == register or pixel_col == (register - 1) or pixel_col == (register + 1)) {
        screen.*[pixel_row][pixel_col] = true;
    } else {
        screen.*[pixel_row][pixel_col] = false;
    }
}

pub fn puzzle_2(input: []const u8) Result {
    var cycle: u16 = 1;
    var register: i16 = 1;
    var screen = [_][40]bool{[_]bool{false} ** 40} ** 6;

    var iter = std.mem.split(u8, input, "\n");
    while (iter.next()) |line| {
        crt(cycle, register, &screen);
        cycle += 1;
        crt(cycle, register, &screen);
        if (line[0] != 'a') continue;
        const n = std.fmt.parseInt(i16, line[5..], 0) catch unreachable;
        cycle += 1;
        crt(cycle, register, &screen);
        register += n;
    }

    //for (screen) |row| {
    //for (row) |pixel| {
    //if (pixel) {
    //std.debug.print("@", .{});
    //} else {
    //std.debug.print(" ", .{});
    //}
    //}
    //std.debug.print("\n", .{});
    //}

    var r: usize = 0;
    for (screen) |row, x| {
        for (row) |pixel, y| r += y * x * @boolToInt(pixel);
    }

    return .{ .int = @intCast(i32, r) };
}
