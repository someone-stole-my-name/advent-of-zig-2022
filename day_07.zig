const std = @import("std");
const Result = @import("util/aoc.zig").Result;

const NodeType = union(enum) { File, Dir };
const Node = struct {
    Name: []const u8,
    Childs: struct {
        len: usize = 0,
        items: [300]?*Node = [_]?*Node{null} ** 300,
    } = .{},
    Parent: ?*Node = null,
    Type: NodeType,
    Size: usize = 0,

    pub fn append(self: *Node, node: *Node) void {
        self.Childs.items[self.Childs.len] = node;
        self.Childs.len += 1;
    }

    fn cd(self: *Node, to: []const u8) *Node {
        if (to.len == 1 and to[0] == '/') {
            if (self.Parent == null) return self;
            return self.Parent.?.cd("/");
        }

        if (std.mem.eql(u8, "..", to)) {
            return self.Parent.?;
        }

        for (self.Childs.items[0..self.Childs.len]) |child| {
            if (std.mem.eql(u8, child.?.Name, to)) return child.?;
        }

        unreachable;
    }

    fn size(self: Node) usize {
        if (self.Type == .File) return self.Size;
        var s: usize = 0;
        for (self.Childs.items[0..self.Childs.len]) |child| s += child.?.size();
        return s;
    }
};

fn compute_puzzle_1(node: Node) usize {
    var size: usize = 0;
    for (node.Childs.items[0..node.Childs.len]) |child| {
        if (child.?.Type != NodeType.Dir) continue;
        if (child.?.size() <= 100000) size += child.?.size();
        size += compute_puzzle_1(child.?.*);
    }
    return size;
}

fn compute_puzzle_2(node: Node, min: usize, target: usize) usize {
    var new_min = min;
    for (node.Childs.items[0..node.Childs.len]) |child| {
        if (child.?.Type != NodeType.Dir) continue;
        const child_size = child.?.size();
        if (child_size < new_min and child_size >= target) new_min = child_size;
        new_min = compute_puzzle_2(child.?.*, new_min, target);
    }
    return new_min;
}

fn build_tree(allocator: std.mem.Allocator, root: *Node, input: []const u8) !void {
    var iter = std.mem.split(u8, input, "\n");

    var current_root = &root;

    while (iter.next()) |line| {
        if (line[0] == '$') {
            if (std.mem.eql(u8, line[2..4], "cd")) current_root = &current_root.*.cd(line[5..]);
            continue;
        }

        var node = try allocator.create(Node);
        node.* = .{
            .Name = line[std.mem.indexOf(u8, line, " ").? + 1 ..],
            .Parent = current_root.*,
            .Type = blk: {
                if (std.mem.eql(u8, line[0..3], "dir")) break :blk NodeType.Dir;
                break :blk NodeType.File;
            },
            .Size = blk: {
                break :blk std.fmt.parseInt(
                    usize,
                    line[0..std.mem.indexOf(u8, line, " ").?],
                    0,
                ) catch 0;
            },
        };
        current_root.*.append(node);
    }
}

pub fn puzzle_1(allocator: std.mem.Allocator, input: []const u8) Result {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var node = Node{
        .Name = "/",
        .Type = .Dir,
    };

    build_tree(arena.allocator(), &node, input) catch unreachable;

    return .{ .int = @intCast(i32, compute_puzzle_1(node)) };
}

pub fn puzzle_2(allocator: std.mem.Allocator, input: []const u8) Result {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var node = Node{
        .Name = "/",
        .Type = .Dir,
    };

    build_tree(arena.allocator(), &node, input) catch unreachable;

    const target: usize = 30000000 - (70000000 - node.size());

    return .{ .int = @intCast(i32, compute_puzzle_2(
        node,
        node.size(),
        target,
    )) };
}
