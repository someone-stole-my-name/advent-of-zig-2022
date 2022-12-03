const std = @import("std");
const slurp = @import("util/file.zig").slurp;

const Hand = enum(u8) { Rock = 1, Paper = 2, Scissors = 3 };
const Outcome = enum(u8) { Win = 6, Draw = 3, Lose = 0 };

const KV_Hand = struct { @"0": []const u8, @"1": Hand };
const KV_Outcome = struct { @"0": []const u8, @"1": Outcome };

const Player_A_KV = std.ComptimeStringMap(Hand, [_]KV_Hand{
    .{ .@"0" = "A", .@"1" = .Rock },
    .{ .@"0" = "B", .@"1" = .Paper },
    .{ .@"0" = "C", .@"1" = .Scissors },
});

const Player_B_KV = std.ComptimeStringMap(Hand, [_]KV_Hand{
    .{ .@"0" = "X", .@"1" = .Rock },
    .{ .@"0" = "Y", .@"1" = .Paper },
    .{ .@"0" = "Z", .@"1" = .Scissors },
});

const Outcome_KV = std.ComptimeStringMap(Outcome, [_]KV_Outcome{
    .{ .@"0" = "X", .@"1" = .Lose },
    .{ .@"0" = "Y", .@"1" = .Draw },
    .{ .@"0" = "Z", .@"1" = .Win },
});

const match_impl = struct {
    fn puzzle_1(a: Hand, b: Hand) u8 {
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

    fn puzzle_2(a: Hand, b: Outcome) u8 {
        switch (a) {
            .Rock => {
                switch (b) {
                    .Win => return @enumToInt(b) + @enumToInt(Hand.Paper),
                    .Lose => return @enumToInt(b) + @enumToInt(Hand.Scissors),
                    .Draw => return @enumToInt(b) + @enumToInt(Hand.Rock),
                }
            },
            .Paper => {
                switch (b) {
                    .Win => return @enumToInt(b) + @enumToInt(Hand.Scissors),
                    .Lose => return @enumToInt(b) + @enumToInt(Hand.Rock),
                    .Draw => return @enumToInt(b) + @enumToInt(Hand.Paper),
                }
            },
            .Scissors => {
                switch (b) {
                    .Win => return @enumToInt(b) + @enumToInt(Hand.Rock),
                    .Lose => return @enumToInt(b) + @enumToInt(Hand.Paper),
                    .Draw => return @enumToInt(b) + @enumToInt(Hand.Scissors),
                }
            },
        }
    }
};

pub fn puzzle_1(input: []u8) u16 {
    var iter = std.mem.split(u8, input, "\n");

    var score: u16 = 0;

    while (iter.next()) |line| {
        score += match_impl.puzzle_1(
            Player_A_KV.get(&[_]u8{line[0]}).?,
            Player_B_KV.get(&[_]u8{line[2]}).?,
        );
    }

    return score;
}

pub fn puzzle_2(input: []u8) u16 {
    var iter = std.mem.split(u8, input, "\n");

    var score: u16 = 0;

    while (iter.next()) |line| {
        score += match_impl.puzzle_2(
            Player_A_KV.get(&[_]u8{line[0]}).?,
            Outcome_KV.get(&[_]u8{line[2]}).?,
        );
    }

    return score;
}
