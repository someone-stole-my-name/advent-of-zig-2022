const std = @import("std");

pub const Result = union(enum) {
    int: i64,
    string: []const u8,

    pub fn cmp(self: Result, result: Result) bool {
        switch (self) {
            .int => |i| return i == result.int,
            .string => |s| return std.mem.eql(u8, s, result.string),
        }
    }

    pub fn deinit(self: Result, allocator: std.mem.Allocator) void {
        switch (self) {
            .string => |s| return allocator.free(s),
            else => {},
        }
    }
};
