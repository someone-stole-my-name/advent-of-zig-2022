const std = @import("std");
const dupl_values = @import("util/mem.zig").dupl_values;

pub fn puzzle_1(allocator: std.mem.Allocator, input: []u8) !u16 {
    var iter = std.mem.split(u8, input, "\n");

    var count: u16 = 0;
    while (iter.next()) |line| {
        const duplicates = try dupl_values(
            u8,
            allocator,
            &[_][]const u8{
                line[0 .. line.len / 2],
                line[line.len / 2 ..],
            },
        );
        defer allocator.free(duplicates);

        for (duplicates) |char| {
            count += char_to_priority(char);
        }
    }

    return count;
}

pub fn puzzle_2(allocator: std.mem.Allocator, input: []u8) !u16 {
    var iter = std.mem.split(u8, input, "\n");

    var count: u16 = 0;
    while (iter.next()) |line| {
        const duplicates = try dupl_values(
            u8,
            allocator,
            &[_][]const u8{
                line,
                iter.next().?,
                iter.next().?,
            },
        );
        defer allocator.free(duplicates);

        for (duplicates) |char| {
            count += char_to_priority(char);
        }
    }

    return count;
}

fn char_to_priority(char: u8) u8 {
    if (char >= 65 and char <= 90)
        return char - 38;
    return char - 96;
}
