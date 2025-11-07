const std = @import("std");
const expect = std.testing.expect;
const allocator = std.heap.page_allocator;
const strict_parser = @import("parser.zig").strict_parser;
const quadratic_solver = @import("solver.zig").quadratic_solver;

fn printHelp() void {
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

    const coefficients = strict_parser(args) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return err;
    };

    // std.debug.print("Extracted Coefficients:\n", .{});
    // std.debug.print("  X^0: {d}\n", .{coefficients[0]});
    // std.debug.print("  X^1: {d}\n", .{coefficients[1]});
    // std.debug.print("  X^2: {d}\n", .{coefficients[2]});

    try quadratic_solver(coefficients);
}

test "parsing equations" {
    std.debug.print("Running tests...\n\n", .{});

    // Good equations - should parse successfully
    const good_equations = [_][]const u8{
        "5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0",
        "5 * X^0 + 4 * X^1 = 4 * X^0",
        "1 * X^0 + 2 * X^1 + 5 * X^2 = 0",
        "6 * X^0 = 6 * X^0",
        "10 * X^0 = 15 * X^0",
        "X^2 + 3*X^1 - 4*X^0 = 0", // No spaces
        "1.5*X^2 - 2.3*X^1 + 0.7*X^0 = 0", // Decimals
        "X^2 = 16 * X^0", // Simple quadratic
        "42 * X^0 = 42 * X^0", // Identity
        "X^1 = 0", // Simple linear
        "100*X^2+50*X^1+25*X^0=0", // No spaces at all
        "  5 * X^2  +  3 * X^1  = 0  ", // Extra whitespace
    };

    // Bad equations - should fail parsing
    const bad_equations = [_][]const u8{
        "5 * x^2 + 3 * x^1 = 0", // lowercase x
        "5 * X^2 + 3 * X^1 = 0 = 1", // multiple equal signs
        "5 * Y^2 + 3 * X^1 = 0", // wrong variable
        "5 @ X^2 + 3 * X^1 = 0", // invalid operator
        "5 * X^2 + 3 * X#1 = 0", // invalid character
        "Hello World", // not an equation at all
        "5 * X^2 + (3 * X^1) = 0", // parentheses not supported
        "5 * X^2 + 3 * X^1 = 0!", // invalid character at end
        "5 * X^2 + a * X^1 = 0", // letter coefficient
        "X² + 3X = 0", // unicode superscript
    };

    std.debug.print("=== GOOD EQUATIONS (should parse) ===\n\n", .{});
    for (good_equations, 0..) |eq, i| {
        std.debug.print("Good Test {d}: {s}\n", .{ i + 1, eq });
        var args = [_][]const u8{ "computor", eq };
        const coefficients = strict_parser(&args) catch |err| {
            std.debug.print("  ❌ Unexpected Error: {}\n", .{err});
            continue;
        };
        std.debug.print("  ✓ Coefficients: X^0 = {d}, X^1 = {d}, X^2 = {d}\n", .{ coefficients[0], coefficients[1], coefficients[2] });
        try quadratic_solver(coefficients);
        std.debug.print("\n", .{});
    }

    std.debug.print("\n=== BAD EQUATIONS (should fail) ===\n\n", .{});
    for (bad_equations, 0..) |eq, i| {
        std.debug.print("Bad Test {d}: {s}\n", .{ i + 1, eq });
        var args = [_][]const u8{ "computor", eq };
        _ = strict_parser(&args) catch |err| {
            std.debug.print("  ✓ Expected Error: {}\n", .{err});
            continue;
        };
        std.debug.print("\n", .{});
    }

    try expect(true);
}
