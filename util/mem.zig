const std = @import("std");

const math = std.math;
const testing_allocator = std.testing.allocator;

/// Returns the position of the smallest number in a slice.
pub fn min_idx(comptime T: type, slice: []const T) usize {
    var best = slice[0];
    var idx: usize = 0;

    for (slice[1..]) |item, i| {
        const possible_best = math.min(best, item);
        if (best > possible_best) {
            best = possible_best;
            idx = i + 1;
        }
    }
    return idx;
}

/// Returns a slice of the duplicated values amongst all slices.
/// { {1,2,3,4}, {4,5,6,1} } -> {1,4}
pub fn dupl_values(comptime T: type, allocator: std.mem.Allocator, haystacks: []const []const T) ![]T {
    var haystacks_maps = blk: {
        var r = std.ArrayList(std.AutoHashMap(T, bool)).init(allocator);
        for (haystacks) |haystack| {
            var haystack_map = std.AutoHashMap(T, bool).init(allocator);
            for (haystack) |item| {
                try haystack_map.put(item, true);
            }
            try r.append(haystack_map);
        }
        break :blk r.toOwnedSlice();
    };

    defer blk: {
        for (haystacks_maps) |*haystack| {
            haystack.deinit();
        }
        allocator.free(haystacks_maps);
        break :blk;
    }

    var dupl = std.ArrayList(T).init(allocator);
    var seen = std.AutoHashMap(T, bool).init(allocator);
    defer seen.deinit();

    for (haystacks[0]) |item| {
        if (seen.contains(item))
            continue;

        try seen.put(item, true);

        var duplicated = true;

        for (haystacks_maps[1..]) |map| {
            if (!map.contains(item)) {
                duplicated = false;
                continue;
            }
        }

        if (duplicated)
            try dupl.append(item);
    }

    return dupl.toOwnedSlice();
}

test "dupl_values" {
    const haystack = [_][]const u8{ &[_]u8{ 1, 2, 3, 1 }, &[_]u8{ 2, 3, 1, 5 }, &[_]u8{ 3, 2, 1, 4 } };
    var foo = try dupl_values(u8, testing_allocator, &haystack);
    defer testing_allocator.free(foo);

    try std.testing.expect(std.mem.eql(u8, foo, &[_]u8{ 1, 2, 3 }));
}
