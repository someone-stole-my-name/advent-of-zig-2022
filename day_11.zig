const std = @import("std");
const Result = @import("util/aoc.zig").Result;

const Operation = struct {
    symbol: u8,
    fixed: bool = false,
    fixed_number: u8 = 0,

    fn exe(self: Operation, b: u64) u64 {
        if (self.symbol == '*') {
            switch (self.fixed) {
                true => return self.fixed_number * b,
                false => return b * b,
            }
        }

        switch (self.fixed) {
            true => return self.fixed_number + b,
            false => return b + b,
        }
    }
};

const Monkey = struct {
    const Throw_rules = struct {
        multiple_of: u8,
        true: u8,
        false: u8,
    };

    id: u8,
    inspect_count: usize = 0,
    items: std.ArrayList(u64),
    operation: Operation,
    throw_rules: Throw_rules,

    fn throws_to(self: Monkey, worry_level: u64) usize {
        if (worry_level % self.throw_rules.multiple_of == 0) return self.throw_rules.true;
        return self.throw_rules.false;
    }

    fn inspect(self: *Monkey) u64 {
        self.inspect_count += 1;
        return self.operation.exe(self.items.orderedRemove(0));
    }
};

fn answer(monkeys: []Monkey) u64 {
    var max: [2]u64 = std.mem.zeroes([2]u64);
    for (monkeys) |*monkey| {
        if (monkey.inspect_count > max[0] and monkey.inspect_count > max[1]) {
            max[1] = max[0];
            max[0] = monkey.inspect_count;
        } else if (monkey.inspect_count > max[1]) {
            max[1] = monkey.inspect_count;
        }

        monkey.items.deinit();
    }
    return max[0] * max[1];
}

fn parse(allocator: std.mem.Allocator, input: []const u8) []Monkey {
    var monkeys = std.ArrayList(Monkey).init(allocator);

    var monkey_iter = std.mem.split(u8, input, "\n\n");
    while (monkey_iter.next()) |monkey_data| {
        var monkey = std.mem.split(u8, monkey_data, "\n");

        var line = monkey.next().?;
        var id = std.fmt.parseInt(u8, line[7 .. line.len - 1], 0) catch unreachable;

        var items = std.ArrayList(u64).init(allocator);
        line = monkey.next().?;
        var items_iter = std.mem.split(u8, line[18..], ", ");
        while (items_iter.next()) |item| {
            items.append(std.fmt.parseInt(u64, item, 0) catch unreachable) catch unreachable;
        }

        const operation = blk: {
            line = monkey.next().?;
            var op = Operation{ .symbol = line[23] };

            if (line[25] != 'o') {
                op.fixed = true;
                op.fixed_number = std.fmt.parseInt(u8, line[25..], 0) catch unreachable;
            }

            break :blk op;
        };

        const throw_rules = blk: {
            line = monkey.next().?;
            const multiple_of = std.fmt.parseInt(u8, line[21..], 0) catch unreachable;

            line = monkey.next().?;
            const iftrue = std.fmt.parseInt(u8, line[29..], 0) catch unreachable;

            line = monkey.next().?;
            const iffalse = std.fmt.parseInt(u8, line[30..], 0) catch unreachable;

            break :blk Monkey.Throw_rules{
                .multiple_of = multiple_of,
                .true = iftrue,
                .false = iffalse,
            };
        };

        monkeys.append(Monkey{
            .id = id,
            .items = items,
            .operation = operation,
            .throw_rules = throw_rules,
        }) catch unreachable;
    }

    return monkeys.toOwnedSlice() catch unreachable;
}

pub fn puzzle_1(allocator: std.mem.Allocator, input: []const u8) Result {
    var monkeys = parse(allocator, input);
    defer allocator.free(monkeys);

    var i: usize = 0;
    while (i < 20) : (i += 1) {
        for (monkeys) |*monkey| {
            while (monkey.items.items.len > 0) {
                const new_worry_level = monkey.inspect();
                const throw_to = monkey.throws_to(new_worry_level / 3);
                monkeys[throw_to].items.append(new_worry_level / 3) catch unreachable;
            }
        }
    }

    return .{ .int = @intCast(i32, answer(monkeys)) };
}

pub fn puzzle_2(allocator: std.mem.Allocator, input: []const u8) Result {
    var monkeys = parse(allocator, input);
    defer allocator.free(monkeys);

    const mod = blk: {
        var r: u64 = 1;
        for (monkeys) |monkey| r *= monkey.throw_rules.multiple_of;
        break :blk r;
    };

    var i: usize = 0;
    while (i < 10000) : (i += 1) {
        for (monkeys) |*monkey| {
            while (monkey.items.items.len > 0) {
                const new_worry_level = monkey.inspect();
                const throw_to = monkey.throws_to(new_worry_level % mod);
                monkeys[throw_to].items.append(new_worry_level % mod) catch unreachable;
            }
        }
    }

    return .{ .int = @intCast(i64, answer(monkeys)) };
}
