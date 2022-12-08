const std = @import("std");
const Result = @import("util/aoc.zig").Result;

pub fn puzzle_1(input: []const u8) Result {
    var grid = std.mem.zeroes([99][99]u8);
    load_grid(&grid, input);

    var count: i32 = 0;

    for (grid) |_, y| {
        for (grid[y]) |_, x| {
            const position = [_]usize{ y, x };
            if (is_visible_left(position, grid) or
                is_visible_right(position, grid) or is_visible_up(position, grid) or
                is_visible_down(position, grid)) count += 1;
        }
    }

    return .{ .int = count };
}

pub fn puzzle_2(input: []const u8) Result {
    var grid = std.mem.zeroes([99][99]u8);
    load_grid(&grid, input);

    var max: u32 = 0;

    for (grid) |_, y| {
        for (grid[y]) |_, x| {
            const position = [_]usize{ y, x };
            const down = view_distance_down(position, grid);
            const left = view_distance_left(position, grid);
            const right = view_distance_right(position, grid);
            const up = view_distance_up(position, grid);

            const n: u32 = down * up * left * right;
            max = std.math.max(n, max);
        }
    }

    return .{ .int = @intCast(i32, max) };
}

fn load_grid(grid: *[99][99]u8, input: []const u8) void {
    var iter = std.mem.split(u8, input, "\n");
    var row_idx: usize = 0;
    while (iter.next()) |line| : (row_idx += 1) {
        for (line) |char, column| {
            grid[row_idx][column] = std.fmt.parseInt(u8, &[_]u8{char}, 0) catch unreachable;
        }
    }
}

fn is_visible_down(pos: [2]usize, grid: [99][99]u8) bool {
    var max = grid[pos[0]][pos[1]];
    var i = pos[0] + 1;
    for (grid[i..]) |_| {
        if (grid[i][pos[1]] >= max) return false;
        i += 1;
    }
    return true;
}

fn is_visible_up(pos: [2]usize, grid: [99][99]u8) bool {
    var max = grid[pos[0]][pos[1]];
    for (grid[0..pos[0]]) |row| if (row[pos[1]] >= max) return false;
    return true;
}

fn is_visible_right(pos: [2]usize, grid: [99][99]u8) bool {
    var max = grid[pos[0]][pos[1]];
    for (grid[pos[0]][pos[1] + 1 ..]) |n| if (n >= max) return false;
    return true;
}

fn is_visible_left(pos: [2]usize, grid: [99][99]u8) bool {
    var max = grid[pos[0]][pos[1]];
    for (grid[pos[0]][0..pos[1]]) |n| if (n >= max) return false;
    return true;
}

fn view_distance_down(pos: [2]usize, grid: [99][99]u8) u32 {
    var max = grid[pos[0]][pos[1]];
    var treecount: u8 = 0;
    var i = pos[0] + 1;
    for (grid[i..]) |_| {
        if (grid[i][pos[1]] >= max) return treecount + 1;
        treecount += 1;
        i += 1;
    }
    return treecount;
}

fn view_distance_right(pos: [2]usize, grid: [99][99]u8) u32 {
    var max = grid[pos[0]][pos[1]];
    var treecount: u8 = 0;
    for (grid[pos[0]][pos[1] + 1 ..]) |n| {
        if (n >= max) return treecount + 1;
        treecount += 1;
    }
    return treecount;
}

fn view_distance_up(pos: [2]usize, grid: [99][99]u8) u32 {
    var max = grid[pos[0]][pos[1]];
    var treecount: u8 = 0;
    var i: usize = pos[0];
    while (i > 0) : (treecount += 1) {
        i -= 1;
        if (grid[i][pos[1]] >= max) return treecount + 1;
    }
    return treecount;
}

fn view_distance_left(pos: [2]usize, grid: [99][99]u8) u32 {
    var max = grid[pos[0]][pos[1]];
    var treecount: u8 = 0;
    var i: usize = pos[1];
    while (i > 0) : (treecount += 1) {
        i -= 1;
        if (grid[pos[0]][i] >= max) return treecount + 1;
    }
    return treecount;
}
