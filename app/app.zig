const std = @import("std");

const draw = @import("draw.zig");

const rl = @import("raylib");
const rg = @import("raygui");

pub fn run() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    const window_width = 600;
    const window_height = 350;
    const window_title = "Shorthand";

    rl.initWindow(window_width, window_height, window_title);
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var context = draw.Context.init(ally);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        context.draw();

        rl.clearBackground(rl.Color.white);
    }
}
