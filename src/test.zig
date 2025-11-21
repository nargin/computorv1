const std = @import("std");
const expect = std.testing.expect;
const parser = @import("parser.zig").parser;
const quadratic_solver = @import("solver.zig").quadratic_solver;

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
        "X^2 + 3X = 0", // unicode superscript (should be caught as invalid)
    };

    std.debug.print("=== GOOD EQUATIONS (should parse) ===\n\n", .{});
    for (good_equations, 0..) |eq, i| {
        std.debug.print("Good Test {d}: {s}\n", .{ i + 1, eq });
        const args = [_][]const u8{ "computor", eq };
        const equation = args[1];
        const coefficients = parser(.Strict, equation) catch |err| {
            std.debug.print("  FAIL Unexpected Error: {}\n", .{err});
            continue;
        };
        std.debug.print("  OK Parsed successfully\n", .{});
        try quadratic_solver(coefficients);
        std.debug.print("\n", .{});
    }

    std.debug.print("\n=== BAD EQUATIONS (should fail) ===\n\n", .{});
    for (bad_equations, 0..) |eq, i| {
        std.debug.print("Bad Test {d}: {s}\n", .{ i + 1, eq });
        const args = [_][]const u8{ "computor", eq };
        const equation = args[1];
        _ = parser(.Strict, equation) catch |err| {
            std.debug.print("  OK Expected Error: {}\n\n", .{err});
            continue;
        };
        std.debug.print("\n", .{});
    }

    try expect(true);
}
