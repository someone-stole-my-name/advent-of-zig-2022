const std = @import("std");
const Result = @import("util/aoc.zig").Result;

const MAX_HEIGHT = 100;

const Command = struct { From: u8, To: u8, Crates: u8 };
const Data = struct {
    Commands: []Command,
    Crates: [][MAX_HEIGHT]u8,

    fn deinit(self: Data, allocator: std.mem.Allocator) void {
        allocator.free(self.Commands);
        allocator.free(self.Crates);
    }
};

pub fn puzzle_1(allocator: std.mem.Allocator, input: []const u8) !Result {
    var data = try parse_input(allocator, input);
    defer data.deinit(allocator);

    for (data.Commands) |*command| {
        while (command.Crates > 0) : (command.Crates -= 1) {
            const tmp = data.Crates[command.From][len(data.Crates[command.From]) - 1];
            data.Crates[command.From][len(data.Crates[command.From]) - 1] = 0;
            data.Crates[command.To][len(data.Crates[command.To])] = tmp;
        }
    }

    return build_answer(allocator, data.Crates);
}

pub fn puzzle_2(allocator: std.mem.Allocator, input: []const u8) !Result {
    var data = try parse_input(allocator, input);
    defer data.deinit(allocator);

    for (data.Commands) |*command| {
        const crate_stack = blk: {
            var r = std.mem.zeroes([MAX_HEIGHT]u8);
            var idx: usize = 0;

            while (command.Crates > 0) : (command.Crates -= 1) {
                r[idx] = data.Crates[command.From][len(data.Crates[command.From]) - 1];
                data.Crates[command.From][len(data.Crates[command.From]) - 1] = 0;
                idx += 1;
            }

            break :blk r;
        };
        var crate_stack_height = len(crate_stack);

        while (true) {
            data.Crates[command.To][len(data.Crates[command.To])] = crate_stack[crate_stack_height];
            if (crate_stack_height == 0) break;
            crate_stack_height -= 1;
        }
    }

    return build_answer(allocator, data.Crates);
}

fn build_answer(allocator: std.mem.Allocator, crates: [][MAX_HEIGHT]u8) !Result {
    var i: usize = 0;
    var r = try std.ArrayList(u8).initCapacity(allocator, crates.len);
    while (i < crates.len) : (i += 1) {
        r.appendAssumeCapacity(crates[i][len(crates[i]) - 1]);
    }

    return .{ .string = try r.toOwnedSlice() };
}

fn parse_input(allocator: std.mem.Allocator, input: []const u8) !Data {
    var iter = std.mem.split(u8, input, "\n");

    var floor: u8 = 0;
    var rows: usize = 0;

    while (iter.next()) |line| : (floor += 1) {
        if (line[1] == '1') {
            rows = (line.len + 1) / 4;
            iter.reset();
            break;
        }
    }

    var crates = blk: {
        var r = try std.ArrayList([MAX_HEIGHT]u8).initCapacity(allocator, rows);
        var i: usize = 0;
        while (i < rows) : (i += 1) r.appendAssumeCapacity(std.mem.zeroes([MAX_HEIGHT]u8));
        break :blk try r.toOwnedSlice();
    };

    while (iter.next()) |line| : (floor -= 1) {
        if (floor == 0) break;

        var row: usize = 0;
        var offset: usize = 1;
        while (row < rows) : (row += 1) {
            if (line[offset] != ' ')
                crates[row][floor - 1] = line[offset];
            offset += 4;
        }
    }

    // There is an extra line between floor and commands
    iter.index = iter.index.? + 1;
    var commands = std.ArrayList(Command).init(allocator);
    var i: usize = 0;
    while (iter.next()) |line| : (i += 1) {
        var command: Command = undefined;
        var line_iter = std.mem.split(u8, line, " ");
        _ = line_iter.next(); // move
        command.Crates = try std.fmt.parseInt(u8, line_iter.next() orelse unreachable, 0);
        _ = line_iter.next(); // from
        command.From = try std.fmt.parseInt(u8, line_iter.next() orelse unreachable, 0) - 1;
        _ = line_iter.next(); // to
        command.To = try std.fmt.parseInt(u8, line_iter.next() orelse unreachable, 0) - 1;
        try commands.append(command);
    }
    return .{ .Commands = try commands.toOwnedSlice(), .Crates = crates };
}

fn len(row: [MAX_HEIGHT]u8) usize {
    for (row) |v, i| {
        if (v == 0) {
            if (i > 0) return i;
            return 0;
        }
    }
    unreachable;
}
