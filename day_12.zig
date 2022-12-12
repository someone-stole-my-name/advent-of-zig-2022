const std = @import("std");
const Result = @import("util/aoc.zig").Result;

const Point = struct { row: i32, col: i32, count: u16 = 0 };

const Movements = [_]Point{
    .{ .row = 0, .col = -1, .count = 0 },
    .{ .row = -1, .col = 0, .count = 0 },
    .{ .row = 1, .col = 0, .count = 0 },
    .{ .row = 0, .col = 1, .count = 0 },
};

fn parse(allocator: std.mem.Allocator, input: []const u8) [][]u8 {
    var grid = std.ArrayList([]u8).init(allocator);

    var iter = std.mem.split(u8, input, "\n");
    while (iter.next()) |line| {
        var row = std.ArrayList(u8).initCapacity(allocator, line.len) catch unreachable;
        for (line) |char| row.append(char) catch unreachable;
        grid.append(row.toOwnedSlice() catch unreachable) catch unreachable;
    }

    return grid.toOwnedSlice() catch unreachable;
}

fn parse_free(allocator: std.mem.Allocator, grid: [][]u8) void {
    for (grid) |row| allocator.free(row);
    allocator.free(grid);
}

fn bfs(allocator: std.mem.Allocator, grid: [][]const u8, start: []Point, end: Point) u16 {
    var visited = std.AutoHashMap([2]i32, bool).init(allocator);
    defer visited.deinit();
    var queue = std.ArrayList(Point).init(allocator);
    defer queue.deinit();

    for (start) |p| queue.append(p) catch unreachable;

    while (queue.items.len > 0) {
        const point = queue.orderedRemove(0);

        if (visited.contains([_]i32{ point.row, point.col }))
            continue;

        if (point.row == end.row and point.col == end.col)
            return point.count;

        visited.put([_]i32{ point.row, point.col }, true) catch unreachable;

        for (Movements) |m| {
            const p = Point{
                .row = point.row + m.row,
                .col = point.col + m.col,
                .count = point.count + 1,
            };

            if (!(p.row >= 0 and p.col >= 0 and p.row < grid.len and p.col < grid[0].len)) continue;
            if (visited.contains([_]i32{ p.row, p.col })) continue;
            if (grid[@intCast(usize, p.row)][@intCast(usize, p.col)] > (grid[@intCast(usize, point.row)][@intCast(usize, point.col)] + 1)) continue;

            queue.append(p) catch unreachable;
        }
    }

    return @intCast(u16, grid.len * grid[0].len);
}

pub fn puzzle_1(allocator: std.mem.Allocator, input: []const u8) Result {
    const grid = parse(allocator, input);
    defer parse_free(allocator, grid);

    var start: ?Point = null;
    var end: ?Point = null;

    outLoop: for (grid) |row, x| {
        for (row) |c, y| {
            if (c == 'S') {
                grid[x][y] = 'a';
                start = Point{ .row = @intCast(i32, x), .col = @intCast(i32, y) };
            }

            if (c == 'E') {
                grid[x][y] = 'z';
                end = Point{ .row = @intCast(i32, x), .col = @intCast(i32, y) };
            }

            if (start != null and end != null)
                break :outLoop;
        }
    }

    return .{ .int = bfs(allocator, grid, &[_]Point{start.?}, end.?) };
}

pub fn puzzle_2(allocator: std.mem.Allocator, input: []const u8) Result {
    const grid = parse(allocator, input);
    defer parse_free(allocator, grid);

    var start_points = std.ArrayList(Point).init(allocator);
    var end: Point = undefined;

    for (grid) |row, x| {
        for (row) |c, y| {
            if (c == 'a' or c == 'S') {
                start_points.append(Point{ .row = @intCast(i32, x), .col = @intCast(i32, y) }) catch unreachable;
            }

            if (c == 'S') {
                grid[x][y] = 'a';
            }

            if (c == 'E') {
                grid[x][y] = 'z';
                end = Point{ .row = @intCast(i32, x), .col = @intCast(i32, y) };
            }
        }
    }

    const p = start_points.toOwnedSlice() catch unreachable;
    defer allocator.free(p);

    return .{ .int = bfs(allocator, grid, p, end) };
}
