const std = @import("std");
const slurp = @import("util/file.zig").slurp;
const min_idx = @import("util/mem.zig").min_idx;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    const file_buffer = try slurp(allocator, "./input");
    defer allocator.free(file_buffer);

    var iter = std.mem.split(u8, file_buffer, "\n");
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

    std.debug.print("{d}\n", .{count});
}
