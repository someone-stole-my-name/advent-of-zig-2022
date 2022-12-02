const std = @import("std");
const slurp = @import("util/file.zig").slurp;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Hand = enum(u8) { Rock = 1, Paper = 2, Scissors = 3 };
const Outcome = enum(u8) { Win = 6, Draw = 3, Lose = 0 };

const KV = struct { @"0": []const u8, @"1": Hand };

const Player_A_KV = std.ComptimeStringMap(Hand, [_]KV{
    .{ .@"0" = "A", .@"1" = .Rock },
    .{ .@"0" = "B", .@"1" = .Paper },
    .{ .@"0" = "C", .@"1" = .Scissors },
});

const Player_B_KV = std.ComptimeStringMap(Hand, [_]KV{
    .{ .@"0" = "X", .@"1" = .Rock },
    .{ .@"0" = "Y", .@"1" = .Paper },
    .{ .@"0" = "Z", .@"1" = .Scissors },
});

pub fn main() !void {
    const file_buffer = try slurp(allocator, "./input");
    defer allocator.free(file_buffer);

    var iter = std.mem.split(u8, file_buffer, "\n");

    var score: u16 = 0;

    while (iter.next()) |line| {
        if (line.len > 0) {
            score += match(
                Player_A_KV.get(&[_]u8{line[0]}).?,
                Player_B_KV.get(&[_]u8{line[2]}).?,
            );
        }
    }

    std.debug.print("{d}\n", .{score});
}

fn match(a: Hand, b: Hand) u8 {
    switch (b) {
        .Rock => {
            switch (a) {
                .Rock => return @enumToInt(b) + @enumToInt(Outcome.Draw),
                .Paper => return @enumToInt(b) + @enumToInt(Outcome.Lose),
                .Scissors => return @enumToInt(b) + @enumToInt(Outcome.Win),
            }
        },
        .Paper => {
            switch (a) {
                .Rock => return @enumToInt(b) + @enumToInt(Outcome.Win),
                .Paper => return @enumToInt(b) + @enumToInt(Outcome.Draw),
                .Scissors => return @enumToInt(b) + @enumToInt(Outcome.Lose),
            }
        },
        .Scissors => {
            switch (a) {
                .Rock => return @enumToInt(b) + @enumToInt(Outcome.Lose),
                .Paper => return @enumToInt(b) + @enumToInt(Outcome.Win),
                .Scissors => return @enumToInt(b) + @enumToInt(Outcome.Draw),
            }
        },
    }
}
