const std = @import("std");

/// Reads an entire file into memory, caller owns the returned slice.
pub fn slurp(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath(file_path, &path_buffer);

    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    return try file.readToEndAlloc(
        allocator,
        (try file.stat()).size,
    );
}
