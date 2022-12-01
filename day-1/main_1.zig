const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath("./input", &path_buffer);

    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;

    const file_buffer = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(file_buffer);

    var iter = std.mem.split(u8, file_buffer, "\n");
    var count: i32 = 0;
    var max: [3]i32 = std.mem.zeroes([3]i32);

    while (iter.next()) |line| {
        if (line.len == 0) {
            const lowest_u = lowest(i32, &max);
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

fn lowest(comptime T: type, items: []const T) usize {
    var lowest_u: usize = 0;
    var previous: T = items[0];

    for (items) |item, idx| {
        if (item < previous) {
            lowest_u = idx;
        }

        previous = item;
    }

    return lowest_u;
}
