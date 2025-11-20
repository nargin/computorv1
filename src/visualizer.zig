const std = @import("std");

/// Prints information on how to visualize using Python
pub fn generate_visualization(coefficients: [11]f64, _: std.mem.Allocator) !void {
    const a = coefficients[2];
    const b = coefficients[1];
    const c = coefficients[0];

    std.debug.print("{}X^2 + {}X + {}\n", .{ a, b, c });

    std.debug.print("\nVisualization:\n", .{});
    std.debug.print("Run this command to visualize the graph:\n", .{});
    std.debug.print("make bonus ARGS=\"{d} {d} {d}\"\n\n", .{ a, b, c });
}
