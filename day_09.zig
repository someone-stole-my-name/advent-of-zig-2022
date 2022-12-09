const std = @import("std");
const Result = @import("util/aoc.zig").Result;

const GRID_SIZE = [_]usize{ 500, 500 };

const Rope = struct {
    grid: [GRID_SIZE[0]][GRID_SIZE[1]]i16,
    head_position: *[2]i16 = undefined,
    tail_position: *[2]i16 = undefined,

    knots: [][2]i16,

    tail_visits: [GRID_SIZE[0]][GRID_SIZE[1]]u2,

    allocator: std.mem.Allocator,

    const start_position = [2]i16{ GRID_SIZE[0] / 2 - 1, GRID_SIZE[1] / 2 - 1 };

    // in theory? knots can be comptime
    fn init(allocator: std.mem.Allocator, knots: usize) Rope {
        var k = allocator.alloc([2]i16, knots + 2) catch unreachable;
        for (k) |_, i| k[i] = Rope.start_position;

        var rope = Rope{
            .knots = k,
            .grid = std.mem.zeroes([GRID_SIZE[0]][GRID_SIZE[1]]i16),
            .tail_visits = std.mem.zeroes([GRID_SIZE[0]][GRID_SIZE[1]]u2),
            .allocator = allocator,
        };

        rope.tail_position = &rope.knots[k.len - 1];
        rope.head_position = &rope.knots[0];

        return rope;
    }

    fn deinit(self: *Rope) void {
        self.allocator.free(self.knots);
    }

    fn sync(self: *Rope) void {
        for (self.knots[0..self.knots.len]) |*knot, knot_idx| {
            if (knot_idx == 0) continue;

            const previous_knot = self.knots[knot_idx - 1];
            const delta = [2]i16{ previous_knot[0] - knot[0], previous_knot[1] - knot[1] };

            if (std.math.absCast(delta[0]) == 2 and std.math.absCast(delta[1]) == 0) {
                knot[0] += std.math.divExact(i16, delta[0], 2) catch unreachable;
            } else if (std.math.absCast(delta[0]) == 0 and std.math.absCast(delta[1]) == 2) {
                knot[1] += std.math.divExact(i16, delta[1], 2) catch unreachable;
            } else if (std.math.absCast(delta[0]) == 2 and std.math.absCast(delta[1]) == 2) {
                knot[0] += std.math.divExact(i16, delta[0], 2) catch unreachable;
                knot[1] += std.math.divExact(i16, delta[1], 2) catch unreachable;
            } else if (std.math.absCast(delta[0]) == 1 and std.math.absCast(delta[1]) == 2) {
                knot[0] += delta[0];
                knot[1] += std.math.divExact(i16, delta[1], 2) catch unreachable;
            } else if (std.math.absCast(delta[0]) == 2 and std.math.absCast(delta[1]) == 1) {
                knot[0] += std.math.divExact(i16, delta[0], 2) catch unreachable;
                knot[1] += delta[1];
            }
        }

        self.tail_visits[@intCast(usize, self.tail_position.*[0])][@intCast(usize, self.tail_position.*[1])] = 1;
        return;
    }

    fn up(self: *Rope) void {
        self.head_position.*[0] -= 1;
        self.sync();
    }

    fn down(self: *Rope) void {
        self.head_position.*[0] += 1;
        self.sync();
    }

    fn left(self: *Rope) void {
        self.head_position.*[1] -= 1;
        self.sync();
    }

    fn right(self: *Rope) void {
        self.head_position.*[1] += 1;
        self.sync();
    }
};

pub fn puzzle_1(allocator: std.mem.Allocator, input: []const u8) Result {
    var rope = Rope.init(allocator, 0);
    defer rope.deinit();

    var iter = std.mem.split(u8, input, "\n");
    while (iter.next()) |line| {
        const n = std.fmt.parseInt(u8, line[2..], 0) catch unreachable;
        var i: usize = 0;
        switch (line[0]) {
            'R' => while (i < n) : (i += 1) rope.right(),
            'L' => while (i < n) : (i += 1) rope.left(),
            'U' => while (i < n) : (i += 1) rope.up(),
            'D' => while (i < n) : (i += 1) rope.down(),
            else => unreachable,
        }
    }

    var i: u16 = 0;
    for (rope.tail_visits) |_, x| {
        for (rope.tail_visits[x]) |n| {
            if (n == 1) i += 1;
        }
    }

    return .{ .int = i };
}

pub fn puzzle_2(allocator: std.mem.Allocator, input: []const u8) Result {
    var rope = Rope.init(allocator, 8);
    defer rope.deinit();

    var iter = std.mem.split(u8, input, "\n");
    while (iter.next()) |line| {
        const n = std.fmt.parseInt(u8, line[2..], 0) catch unreachable;
        var i: usize = 0;
        switch (line[0]) {
            'R' => while (i < n) : (i += 1) rope.right(),
            'L' => while (i < n) : (i += 1) rope.left(),
            'U' => while (i < n) : (i += 1) rope.up(),
            'D' => while (i < n) : (i += 1) rope.down(),
            else => unreachable,
        }
    }

    var i: u16 = 0;
    for (rope.tail_visits) |_, x| {
        for (rope.tail_visits[x]) |n| {
            if (n == 1) i += 1;
        }
    }

    return .{ .int = i };
}
