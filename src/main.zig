// const std = @import("std");

// const bigrams = @import("./data.zig").bigrams;
// const char_to_index = @import("./data.zig").char_to_index;
// const index_to_char = @import("./data.zig").index_to_char;
// const point_count = @import("./data.zig").point_count;

// pub const Point = struct {
//     x: f64,
//     y: f64,

//     pub fn init(x: f64, y: f64) Point {
//         return Point{
//             .x = x,
//             .y = y,
//         };
//     }

//     pub fn distance(self: Point, other: Point) f64 {
//         const dx = other.x - self.x;
//         const dy = other.y - self.y;
//         return @sqrt((dx * dx) + (dy * dy));
//     }
// };

// pub fn Matrix(comptime T: type) type {
//     return struct {
//         data: [][]T,
//         width: usize,
//         height: usize,

//         const Self = @This();

//         pub fn init(width: usize, height: usize, ally: std.mem.Allocator) Self {
//             const data = ally.alloc([]T, height) catch unreachable;

//             for (0..height) |i| {
//                 data[i] = ally.alloc(T, width) catch unreachable;
//             }

//             return .{
//                 .data = data,
//                 .width = width,
//                 .height = height,
//             };
//         }

//         pub fn deinit(self: *Self, ally: std.mem.Allocator) void {
//             for (0..self.height) |i| {
//                 ally.free(self.data[i]);
//             }

//             ally.free(self.data);
//         }

//         pub fn reindex(self: *const Self, indices: std.ArrayList(usize), ally: std.mem.Allocator) Self {
//             var matrix = Self.init(self.width, self.height, ally);

//             for (indices.items, 0..) |index1, i| {
//                 for (indices.items, 0..) |index2, j| {
//                     matrix.data[i][j] = self.data[index1][index2];
//                 }
//             }

//             return matrix;
//         }
//     };
// }

// pub fn dot(m1: *const Matrix(f64), m2: *const Matrix(f64)) f64 {
//     var total: f64 = 0.0;

//     for (m1.data, m2.data) |r1, r2| {
//         for (r1, r2) |n1, n2| {
//             total += n1 * n2;
//         }
//     }

//     return total;
// }

// pub fn make_distances(ally: std.mem.Allocator) Matrix(f64) {
//     var points = std.ArrayList(Point).init(ally);
//     defer points.deinit();

//     const sqrt: usize = @intFromFloat(std.math.sqrt(@as(f64, @floatFromInt(point_count))));

//     for (0..sqrt) |x| {
//         for (0..sqrt) |y| {
//             const point = Point.init(@floatFromInt(x), @floatFromInt(y));
//             points.append(point) catch unreachable;
//         }
//     }

//     var distances = Matrix(f64).init(points.items.len, points.items.len, ally);

//     for (points.items, 0..) |p1, i| {
//         for (points.items, 0..) |p2, j| {
//             if (i == j) {
//                 // ion232: I'm assuming here that a circle or loop is drawn around the letter.
//                 distances.data[i][j] = 0.7;
//             } else {
//                 distances.data[i][j] = p1.distance(p2);
//             }
//         }
//     }

//     return distances;
// }

// pub fn make_weights(ally: std.mem.Allocator) Matrix(f64) {
//     const count = point_count;
//     var weights = Matrix(f64).init(count, count, ally);

//     for (bigrams.keys()) |k| {
//         const i = char_to_index.get(&[_]u8{k[0]}).?;
//         const j = char_to_index.get(&[_]u8{k[1]}).?;
//         const value = bigrams.get(k).?;

//         weights.data[i][j] = @floatFromInt(value);
//     }

//     return weights;
// }

// pub fn make_assignments(ally: std.mem.Allocator) std.ArrayList(usize) {
//     var assignments = std.ArrayList(usize).init(ally);

//     for (0..point_count) |i| {
//         assignments.append(i) catch unreachable;
//     }

//     return assignments;
// }

// pub fn print_assignments(assignments: std.ArrayList(usize)) void {
//     for (assignments.items, 0..) |index, i| {
//         if (i % 5 == 0) {
//             std.debug.print("\n", .{});
//         }

//         const c = index_to_char[index];
//         std.debug.print("{c} ", .{c});
//     }

//     std.debug.print("\n", .{});
// }

// pub fn optimise(distances: *const Matrix(f64), weights: *const Matrix(f64), random: std.rand.Random, ally: std.mem.Allocator) std.ArrayList(usize) {
//     const cooling_rate: f64 = 0.001;
//     const final_temperature: f64 = 1.0;
//     _ = final_temperature;
//     var temperature: f64 = 1000.0;

//     var current_cost = std.math.floatMax(f64);
//     var current_assignments = make_assignments(ally);
//     defer current_assignments.deinit();
//     var best_cost = current_cost;
//     var best_assignments = current_assignments.clone() catch unreachable;

//     for (0..110001) |it| {
//         // Swap elements.
//         const i = random.intRangeAtMost(usize, 0, current_assignments.items.len - 1);
//         var j = random.intRangeAtMost(usize, 0, current_assignments.items.len - 2);
//         if (j == i) j += 1;

//         var tmp = current_assignments.items[i];
//         current_assignments.items[i] = current_assignments.items[j];
//         current_assignments.items[j] = tmp;

//         var reindexed = weights.reindex(current_assignments, ally);
//         defer reindexed.deinit(ally);

//         const new_cost = dot(distances, &reindexed);
//         const lower_cost = new_cost < current_cost;
//         const do_swap = random.float(f64) < std.math.exp(current_cost - new_cost / temperature);

//         current_cost = new_cost;

//         if (!lower_cost and !do_swap) {
//             tmp = current_assignments.items[i];
//             current_assignments.items[i] = current_assignments.items[j];
//             current_assignments.items[j] = tmp;
//         }

//         if (current_cost < best_cost) {
//             best_cost = current_cost;
//             best_assignments.deinit();
//             best_assignments = current_assignments.clone() catch unreachable;
//             std.debug.print("Index: {} Cost: {}", .{ it, best_cost });
//             print_assignments(best_assignments);
//         }

//         temperature *= cooling_rate;
//     }

//     return best_assignments;
// }

// pub fn main() !void {
//     var rng = std.rand.DefaultPrng.init(1337);
//     const random = rng.random();

//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer _ = gpa.deinit();
//     const ally = gpa.allocator();

//     var distances = make_distances(ally);
//     defer distances.deinit(ally);

//     var weights = make_weights(ally);
//     defer weights.deinit(ally);

//     const best_assignments = optimise(&distances, &weights, random, ally);
//     defer best_assignments.deinit();
// }

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const index_to_char = @import("./data.zig").index_to_char;

const origin_x: f32 = 0.0;
const origin_y: f32 = 0.0;

pub fn draw_panel(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    text: []const u8,
) void {
    var text_buffer = std.mem.zeroes([128]u8);
    const length = @min(text.len, text_buffer.len);
    @memcpy(text_buffer[0..length], text[0..length]);

    const rect = rl.Rectangle.init(origin_x + x, origin_y + y, width, height);
    _ = rg.guiPanel(rect, text_buffer[0..length :0]);
}

pub fn draw_text_box(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    text: []const u8,
) void {
    var text_buffer = std.mem.zeroes([128]u8);
    const length = @min(text.len, text_buffer.len);
    @memcpy(text_buffer[0..length], text[0..length]);

    const rect = rl.Rectangle.init(origin_x + x, origin_y + y, width, height);
    _ = rg.guiTextBox(rect, text_buffer[0..length :0], 128, false);
}

pub fn draw_status_bar(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    text: []const u8,
) void {
    var text_buffer = std.mem.zeroes([128]u8);
    const length = @min(text.len, text_buffer.len);
    @memcpy(text_buffer[0..length], text[0..length]);

    const rect = rl.Rectangle.init(origin_x + x, origin_y + y, width, height);
    _ = rg.guiPanel(rect, text_buffer[0..length :0]);
}

pub fn draw_value_box(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    text: []const u8,
) void {
    var text_buffer = std.mem.zeroes([128]u8);
    const length = @min(text.len, text_buffer.len);
    @memcpy(text_buffer[0..length], text[0..length]);

    const rect = rl.Rectangle.init(origin_x + x, origin_y + y, width, height);
    var value: f32 = 5.0;

    _ = rg.guiValueBoxFloat(rect, text_buffer[0..length :0], text_buffer[0..length :0], &value, false);
}

pub fn draw_button(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    text: []const u8,
) void {
    var text_buffer = std.mem.zeroes([128]u8);
    const length = @min(text.len, text_buffer.len);
    @memcpy(text_buffer[0..length], text[0..length]);

    const rect = rl.Rectangle.init(origin_x + x, origin_y + y, width, height);
    _ = rg.guiButton(rect, text_buffer[0..length :0]);
}

pub fn main() anyerror!void {
    const screenWidth = 600;
    const screenHeight = 350;

    rl.initWindow(screenWidth, screenHeight, "Shorthand");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        // Update

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        const render_panel_width: f32 = 264.0;
        const render_panel_height: f32 = 264.0;

        draw_panel(168, 24, render_panel_width, render_panel_height, "Render");

        const grid_origin_x: f32 = 456.0;
        const grid_origin_y: f32 = 168.0;
        const cell_width: f32 = 24.0;
        const cell_height: f32 = 24.0;

        for (0..5) |j| {
            for (0..5) |i| {
                const char = index_to_char[i + (j * 5)];
                const text: [1:0]u8 = .{char};
                const x = grid_origin_x + (@as(f32, @floatFromInt(i)) * cell_width);
                const y = grid_origin_y + (@as(f32, @floatFromInt(j)) * cell_height);
                draw_text_box(x, y, cell_width, cell_height, &text);
            }
        }

        draw_text_box(456, 144, 120, 24, "Configuration");
        draw_text_box(168, 288, 264, 24, "Example");
        draw_text_box(456, 24, 120, 24, "Stats");
        draw_value_box(496, 48, 80, 24, "Cost ");
        draw_text_box(24, 24, 120, 288, "Press 'Optimise' to generate shorthand.");
        _ = draw_button(456, 288, 120, 24, "Optimise");
    }
}
