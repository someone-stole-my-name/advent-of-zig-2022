const std = @import("std");
const slurp = @import("util/file.zig").slurp;
const dupl_values = @import("util/mem.zig").dupl_values;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    const file_buffer = try slurp(allocator, "./input");
    defer allocator.free(file_buffer);

    var iter = std.mem.split(u8, file_buffer, "\n");

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

    std.debug.print("{d}\n", .{count});
}

fn char_to_priority(char: u8) u8 {
    if (char >= 65 and char <= 90)
        return char - 38;
    return char - 96;
}
