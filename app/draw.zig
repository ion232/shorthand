const std = @import("std");

const graph = @import("graph.zig");
const rl = @import("raylib");
const rg = @import("raygui");

// ion232: There's probably a cleaner way of doing this. May end up refactoring it.

pub const Context = struct {
    info: Info,
    render: Render,
    configuration: Configuration,
    ally: std.mem.Allocator,

    const Self = @This();

    pub fn init(ally: std.mem.Allocator) Self {
        return Self{
            .info = Info.init(ally),
            .render = Render.init(ally),
            .configuration = Configuration.init(ally),
            .ally = ally,
        };
    }

    pub fn draw(self: *Self) void {
        self.info.draw();
        self.render.draw();
        self.configuration.draw();
    }
};

const Info = struct {
    description: TextBox,

    const Self = @This();

    fn init(ally: std.mem.Allocator) Self {
        return Self{
            .description = TextBox{
                .rect = rl.Rectangle.init(168.0, 24.0, 132.0, 132.0),
                .text = make_text("Press 'Optimise' to optimise.", ally),
            },
        };
    }

    fn draw(self: *Self) void {
        self.description.draw();
    }
};

const Render = struct {
    display: Panel,
    text_input: TextBox,

    const Self = @This();

    fn init(ally: std.mem.Allocator) Self {
        return Self{
            .display = Panel{
                .rect = rl.Rectangle.init(168.0, 24.0, 264.0, 264.0),
                .text = make_text("", ally),
            },
            .text_input = TextBox{
                .rect = rl.Rectangle.init(168.0, 288.0, 264.0, 24.0),
                .text = make_text("Example", ally),
            },
        };
    }

    fn draw(self: *Self) void {
        self.display.draw();
    }
};

const Configuration = struct {
    title: TextBox,
    optimise: Button,
    characters: [][]TextBox,
    metrics: TextBox,
    cost: ValueBox,

    const Self = @This();

    fn init(ally: std.mem.Allocator) Self {
        const width = graph.default_width;
        const height = graph.default_height;

        var characters = ally.alloc([]TextBox, height) catch unreachable;
        for (characters) |*row| {
            row.* = ally.alloc(TextBox, width) catch unreachable;
        }

        for (0..height) |j| {
            for (0..width) |i| {
                const character = graph.default_characters[(j * width) + i];
                const cell_width: f32 = 24.0;
                const cell_height: f32 = 24.0;
                const x = 456.0 + (@as(f32, @floatFromInt(i)) * cell_width);
                const y = 168.0 + (@as(f32, @floatFromInt(j)) * cell_height);
                characters[i][j] = TextBox{
                    .rect = rl.Rectangle.init(x, y, cell_width, cell_height),
                    .text = make_text(character, ally),
                };
            }
        }

        return Self{
            .title = TextBox{
                .rect = rl.Rectangle.init(456.0, 144.0, 120.0, 24.0),
                .text = make_text("Configuration", ally),
            },
            .optimise = Button{
                .rect = rl.Rectangle.init(456.0, 288.0, 120.0, 24.0),
                .text = make_text("Optimise", ally),
            },
            .characters = characters,
            .metrics = TextBox{
                .rect = rl.Rectangle.init(456.0, 24.0, 120.0, 24.0),
                .text = make_text("Metrics", ally),
            },
            .cost = ValueBox{
                .rect = rl.Rectangle.init(496.0, 48.0, 80.0, 24.0),
                .text = make_text("Cost: ", ally),
                .value = 100.0,
            },
        };
    }

    fn draw(self: *Self) void {
        self.title.draw();
        self.optimise.draw();

        for (self.characters) |row| {
            for (row) |character| {
                character.draw();
            }
        }

        self.metrics.draw();
        self.cost.draw();
    }
};

const Panel = struct {
    rect: rl.Rectangle,
    text: [:0]u8,

    const Self = @This();

    fn draw(self: *Self) void {
        _ = rg.guiPanel(self.rect, self.text);
    }
};

const TextBox = struct {
    rect: rl.Rectangle,
    text: [:0]u8,

    const Self = @This();

    fn draw(self: *const Self) void {
        _ = rg.guiTextBox(self.rect, self.text, 128, false);
    }
};

const ValueBox = struct {
    rect: rl.Rectangle,
    text: [:0]u8,
    value: f32,

    const Self = @This();

    fn draw(self: *Self) void {
        _ = rg.guiValueBoxFloat(self.rect, self.text, self.text, &self.value, false);
    }
};

const Button = struct {
    rect: rl.Rectangle,
    text: [:0]u8,

    const Self = @This();

    fn draw(self: *Self) void {
        _ = rg.guiButton(self.rect, self.text);
    }
};

fn make_text(source: []const u8, ally: std.mem.Allocator) [:0]u8 {
    const text = ally.allocSentinel(u8, source.len, 0) catch unreachable;
    @memcpy(text, source);
    return text;
}
