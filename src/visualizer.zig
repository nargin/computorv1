const std = @import("std");

/// Prints information on how to visualize using Python
pub fn generate_visualization(coefficients: [11]f64, _: std.mem.Allocator) !void {
    const a = coefficients[2];
    const b = coefficients[1];
    const c = coefficients[0];

    std.debug.print("\nVisualization:\n", .{});
    std.debug.print("Run this command to visualize the graph:\n", .{});
    std.debug.print("source venv/bin/activate && python3 visualizer.py {d} {d} {d}\n\n", .{ a, b, c });
}
