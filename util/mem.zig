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
