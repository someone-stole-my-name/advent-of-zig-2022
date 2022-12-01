const std = @import("std");
const slurp = @import("util/file.zig").slurp;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    const file_buffer = try slurp(allocator, "./input");
    defer allocator.free(file_buffer);

    var iter = std.mem.split(u8, file_buffer, "\n");
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

    std.debug.print("{d}\n", .{max});
}
