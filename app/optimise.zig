const std = @import("std");

const Graph = @import("graph.zig").Graph;

pub const Optimiser = struct {
    pub const Options = struct {
        cooling_rate: f64,
        temperature_start: f64,
        temeprature_end: f64,
    };

    pub const Solution = struct {
        cost: f64,
        graph: Graph,

        fn deinit(self: *Self) void {
            self.graph.deinit();
        }

        fn clone(self: *const Self) Solution {
            return Solution{ .cost = self.cost, .graph = self.graph };
        }
    };

    ally: std.mem.Allocator,
    random: std.rand.Random,

    const Self = @This();

    pub fn init(random: std.rand.Random, ally: std.mem.Allocator) Self {
        return Self{
            .ally = ally,
            .random = random,
        };
    }

    pub fn optimised(self: *Self, graph: *const Graph, options: Options) Solution {
        var temperature: f64 = options.temperature_start;
        var current = Solution{
            .cost = self.calculate_cost(graph),
            .graph = graph.clone(),
        };
        defer current.graph.deinit();
        var best = current.clone();

        while (temperature > options.temperature_end) {
            const new = blk: {
                const characters = current.graph.nodes.keys();
                const index1 = self.random.uintLessThan(usize, characters.len);
                const index2 = self.random.uintLessThan(usize, characters.len);
                var new = current.clone();
                new.graph.update_character(characters[index1], characters[index2]);
                new.cost = self.calculate_cost(new.graph);
                break :blk new;
            };

            const should_swap = self.random.float(f64) < std.math.exp(current.cost - new.cost / temperature);
            if (new.cost < current.cost or should_swap) {
                current.deinit();
                current = new;
            }
            if (current.cost < best.cost) {
                best.deinit();
                best = current;
            }

            temperature *= options.cooling_rate;
        }

        return best;
    }

    pub fn calculate_cost(self: *const Self, graph: *const Graph) f64 {
        const distances = self.make_distances(graph, self.ally);
        var cost: f64 = 0.0;

        for (distances.keys()) |k| {
            const d = distances.get(k).?;
            const w = graph.weights.get(k).?;
            cost += (d * w);
        }

        return cost;
    }

    fn make_distances(self: *const Self, graph: *const Graph) std.StringHashMap(f64) {
        var distances = std.StringHashMap(f64).init(self.ally);

        for (graph.nodes.keys()) |k1| {
            for (graph.nodes.keys()) |k2| {
                const edge = try std.mem.concat(self.ally, u8, &[_][]const u8{ k1, k2 });
                defer self.ally.free(edge);

                var distance: f64 = blk: {
                    if (k1 == k2) {
                        // ion232: Connecting a node to itself still has a cost.
                        break :blk 0.7;
                    } else {
                        const n1 = graph.nodes.get(k1).?;
                        const n2 = graph.nodes.get(k2).?;
                        break :blk n1.point.distance(n2.point);
                    }
                };

                distances.put(edge, distance);
            }
        }

        return distances;
    }
};
