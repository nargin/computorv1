const std = @import("std");
const helpers = @import("helpers.zig");
const allocator = std.heap.page_allocator;
const parser = @import("parser.zig").parser;
const quadratic_solver = @import("solver.zig").quadratic_solver;
const visualizer = @import("visualizer.zig");

fn print_help() void {
    std.debug.print("Usage: computor <equation>\n\n", .{});
    std.debug.print("Solves polynomial equations up to degree 2.\n", .{});
    std.debug.print("Format: <left side> = <right side>\n\n", .{});
    std.debug.print("Examples:\n", .{});
    std.debug.print("  ./computor \"5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0\"\n", .{});
    std.debug.print("  ./computor \"5 * X^0 + 4 * X^1 = 4 * X^0\"\n", .{});
    std.debug.print("  ./computor \"1 * X^0 + 2 * X^1 + 5 * X^2 = 0\"\n\n", .{});
    std.debug.print("Equation format:\n", .{});
    std.debug.print("  - Use X as the variable\n", .{});
    std.debug.print("  - Use ^ for exponents (e.g., X^2)\n", .{});
    std.debug.print("  - Use * for multiplication\n", .{});
    std.debug.print("  - Separate terms with + or -\n", .{});
    std.debug.print("  - Use = to separate left and right sides\n", .{});
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var equation: []const u8 = undefined;

    equation = helpers.validate_args(args) catch |err| {
        if (err == error.TooManyArguments) {
            print_help();
        }
        return err;
    };

    const coefficients = parser(.Ultra, equation) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return err;
    };

    _ = coefficients;
    // try quadratic_solver(coefficients);

    // Generate visualization
    // try visualizer.generate_visualization(coefficients, allocator);
}
