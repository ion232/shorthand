const std = @import("std");

const bigrams = @import("./data.zig").bigrams;
const char_to_index = @import("./data.zig").char_to_index;
const index_to_char = @import("./data.zig").index_to_char;
const point_count = @import("./data.zig").point_count;

pub const Point = struct {
    x: f64,
    y: f64,

    pub fn init(x: f64, y: f64) Point {
        return Point{
            .x = x,
            .y = y,
        };
    }

    pub fn distance(self: Point, other: Point) f64 {
        const dx = other.x - self.x;
        const dy = other.y - self.y;
        return @sqrt((dx * dx) + (dy * dy));
    }
};

pub fn Matrix(comptime T: type) type {
    return struct {
        data: [][]T,
        width: usize,
        height: usize,

        const Self = @This();

        pub fn init(width: usize, height: usize, ally: std.mem.Allocator) Self {
            const data = ally.alloc([]T, height) catch unreachable;

            for (0..height) |i| {
                data[i] = ally.alloc(T, width) catch unreachable;
            }

            return .{
                .data = data,
                .width = width,
                .height = height,
            };
        }

        pub fn deinit(self: *Self, ally: std.mem.Allocator) void {
            for (0..self.height) |i| {
                ally.free(self.data[i]);
            }

            ally.free(self.data);
        }

        pub fn reindex(self: *const Self, indices: std.ArrayList(usize), ally: std.mem.Allocator) Self {
            var matrix = Self.init(self.width, self.height, ally);

            for (indices.items, 0..) |index1, i| {
                for (indices.items, 0..) |index2, j| {
                    matrix.data[i][j] = self.data[index1][index2];
                }
            }

            return matrix;
        }
    };
}

pub fn dot(m1: *const Matrix(f64), m2: *const Matrix(f64)) f64 {
    var total: f64 = 0.0;

    for (m1.data, m2.data) |r1, r2| {
        for (r1, r2) |n1, n2| {
            total += n1 * n2;
        }
    }

    return total;
}

pub fn make_distances(ally: std.mem.Allocator) Matrix(f64) {
    var points = std.ArrayList(Point).init(ally);
    defer points.deinit();

    const sqrt: usize = @intFromFloat(std.math.sqrt(@as(f64, @floatFromInt(point_count))));

    for (0..sqrt) |x| {
        for (0..sqrt) |y| {
            const point = Point.init(@floatFromInt(x), @floatFromInt(y));
            points.append(point) catch unreachable;
        }
    }

    var distances = Matrix(f64).init(points.items.len, points.items.len, ally);

    for (points.items, 0..) |p1, i| {
        for (points.items, 0..) |p2, j| {
            if (i == j) {
                // ion232: I'm assuming here that a circle or loop is drawn around the letter.
                distances.data[i][j] = 0.7;
            } else {
                distances.data[i][j] = p1.distance(p2);
            }
        }
    }

    return distances;
}

pub fn make_weights(ally: std.mem.Allocator) Matrix(f64) {
    const count = point_count;
    var weights = Matrix(f64).init(count, count, ally);

    for (bigrams.keys()) |k| {
        const i = char_to_index.get(&[_]u8{k[0]}).?;
        const j = char_to_index.get(&[_]u8{k[1]}).?;
        const value = bigrams.get(k).?;

        weights.data[i][j] = @floatFromInt(value);
    }

    return weights;
}

pub fn make_assignments(ally: std.mem.Allocator) std.ArrayList(usize) {
    var assignments = std.ArrayList(usize).init(ally);

    for (0..point_count) |i| {
        assignments.append(i) catch unreachable;
    }

    return assignments;
}

pub fn print_assignments(assignments: std.ArrayList(usize)) void {
    for (assignments.items, 0..) |index, i| {
        if (i % 5 == 0) {
            std.debug.print("\n", .{});
        }

        const c = index_to_char[index];
        std.debug.print("{c} ", .{c});
    }

    std.debug.print("\n", .{});
}

pub fn optimise(distances: *const Matrix(f64), weights: *const Matrix(f64), random: std.rand.Random, ally: std.mem.Allocator) std.ArrayList(usize) {
    const cooling_rate: f64 = 0.001;
    const final_temperature: f64 = 1.0;
    _ = final_temperature;
    var temperature: f64 = 1000.0;

    var current_cost = std.math.floatMax(f64);
    var current_assignments = make_assignments(ally);
    defer current_assignments.deinit();
    var best_cost = current_cost;
    var best_assignments = current_assignments.clone() catch unreachable;

    for (0..110001) |it| {
        // Swap elements.
        const i = random.intRangeAtMost(usize, 0, current_assignments.items.len - 1);
        var j = random.intRangeAtMost(usize, 0, current_assignments.items.len - 2);
        if (j == i) j += 1;

        var tmp = current_assignments.items[i];
        current_assignments.items[i] = current_assignments.items[j];
        current_assignments.items[j] = tmp;

        var reindexed = weights.reindex(current_assignments, ally);
        defer reindexed.deinit(ally);

        const new_cost = dot(distances, &reindexed);
        const lower_cost = new_cost < current_cost;
        const do_swap = random.float(f64) < std.math.exp(current_cost - new_cost / temperature);

        current_cost = new_cost;

        if (!lower_cost and !do_swap) {
            tmp = current_assignments.items[i];
            current_assignments.items[i] = current_assignments.items[j];
            current_assignments.items[j] = tmp;
        }

        if (current_cost < best_cost) {
            best_cost = current_cost;
            best_assignments.deinit();
            best_assignments = current_assignments.clone() catch unreachable;
            std.debug.print("Index: {} Cost: {}", .{ it, best_cost });
            print_assignments(best_assignments);
        }

        temperature *= cooling_rate;
    }

    return best_assignments;
}

pub fn main() !void {
    var rng = std.rand.DefaultPrng.init(1337);
    const random = rng.random();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    var distances = make_distances(ally);
    defer distances.deinit(ally);

    var weights = make_weights(ally);
    defer weights.deinit(ally);

    const best_assignments = optimise(&distances, &weights, random, ally);
    defer best_assignments.deinit();
}
