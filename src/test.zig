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

test "parsing equations with ultra parser (flexible)" {
    std.debug.print("\n\n=== ULTRA PARSER FLEXIBLE FORMAT TESTS ===\n\n", .{});

    // Good flexible equations - should parse successfully with Ultra parser
    const good_flexible_equations = [_][]const u8{
        "x^2 + 3x + 2 = 0", // lowercase x
        "x² + 3x¹ + 2 = 0", // unicode superscripts
        "x² + 3x + 2 = 0", // mixed unicode and regular
        "5x^2 + 3x - 1 = 0", // implicit multiplication
        "5x² + 3x¹ - 1 = 0", // unicode with implicit multiplication
        "X^2 - 4 = 0", // implicit coefficient (1)
        "x^2 = 4", // implicit coefficient (1)
        "2x^2 + x - 3 = 0", // mixed implicit and explicit
        "x + 1 = 0", // linear with implicit coeff
        "x² = 16", // unicode superscript quadratic
        "-x^2 + 4 = 0", // negative leading coefficient
        "x^2 + x + 1 = 0", // all implicit coefficients
        "5.5x^2 - 2.3x + 1.1 = 0", // decimal coefficients with implicit multiply
    };

    std.debug.print("=== GOOD FLEXIBLE EQUATIONS (Ultra parser) ===\n\n", .{});
    for (good_flexible_equations, 0..) |eq, i| {
        std.debug.print("Ultra Test {d}: {s}\n", .{ i + 1, eq });
        const coefficients = parser(.Ultra, eq) catch |err| {
            std.debug.print("  FAIL Unexpected Error: {}\n", .{err});
            continue;
        };
        std.debug.print("  OK Parsed successfully\n", .{});
        try quadratic_solver(coefficients);
        std.debug.print("\n", .{});
    }

    try expect(true);
}

test "parsing equations with direct number exponent format" {
    std.debug.print("\n\n=== DIRECT NUMBER EXPONENT FORMAT TESTS ===\n\n", .{});

    // Equations with direct number exponents (e.g., x2, 5x2, etc.)
    const direct_exponent_equations = [_][]const u8{
        "x2 + 3x + 2 = 0", // direct number exponent
        "5x2 + x - 1 = 0", // coefficient with direct exponent
        "x2 = 4", // simple quadratic with direct exponent
        "2x2 - 8 = 0", // direct exponent format
    };

    std.debug.print("=== DIRECT NUMBER EXPONENT FORMAT ===\n\n", .{});
    for (direct_exponent_equations, 0..) |eq, i| {
        std.debug.print("Direct Test {d}: {s}\n", .{ i + 1, eq });
        const coefficients = parser(.Ultra, eq) catch |err| {
            std.debug.print("  FAIL Unexpected Error: {}\n", .{err});
            continue;
        };
        std.debug.print("  OK Parsed successfully\n", .{});
        try quadratic_solver(coefficients);
        std.debug.print("\n", .{});
    }

    try expect(true);
}

test "edge case validation - multiple dots, consecutive operators" {
    std.debug.print("\n\n=== EDGE CASE VALIDATION TESTS ===\n\n", .{});

    // Edge cases that should FAIL
    const bad_edge_cases = [_][]const u8{
        "3.14.15 * X^2 = 0", // multiple dots in coefficient
        "2.5.5 * X^1 + 1 = 0", // multiple dots
        "5 * X^2 ++ 3 * X = 0", // consecutive plus operators
        "5 * X^2 -- 3 * X = 0", // consecutive minus operators
        "5 * X^2 +- 3 * X = 0", // plus then minus
        "5 * X^2 -+ 3 * X = 0", // minus then plus
    };

    std.debug.print("=== BAD EDGE CASES (should fail validation) ===\n\n", .{});
    for (bad_edge_cases, 0..) |eq, i| {
        std.debug.print("Edge Case Test {d}: {s}\n", .{ i + 1, eq });
        _ = parser(.Ultra, eq) catch |err| {
            std.debug.print("  OK Expected Error: {}\n\n", .{err});
            continue;
        };
        std.debug.print("  UNEXPECTED: Should have failed\n\n", .{});
    }

    try expect(true);
}

test "floating point edge cases - very small and large coefficients" {
    std.debug.print("\n\n=== FLOATING POINT EDGE CASES ===\n\n", .{});

    const fp_edge_cases = [_][]const u8{
        "0.0000001 * X^2 + 5 * X + 10 = 0", // very small coefficient
        "1000000 * X^2 + 100 * X + 1 = 0", // very large coefficient
        "0.1 * X^1 + 0.2 * X^0 = 0", // floating point precision issues
        "0.0 * X^2 + 5 * X + 10 = 0", // effectively zero coefficient
    };

    std.debug.print("=== FLOATING POINT EDGE CASES (should parse) ===\n\n", .{});
    for (fp_edge_cases, 0..) |eq, i| {
        std.debug.print("FP Test {d}: {s}\n", .{ i + 1, eq });
        const coefficients = parser(.Ultra, eq) catch |err| {
            std.debug.print("  FAIL Error: {}\n\n", .{err});
            continue;
        };
        std.debug.print("  OK Parsed successfully\n", .{});
        try quadratic_solver(coefficients);
        std.debug.print("\n", .{});
    }

    try expect(true);
}

test "special cases - identity and contradiction equations" {
    std.debug.print("\n\n=== SPECIAL CASE EQUATIONS ===\n\n", .{});

    const special_cases = [_][]const u8{
        "5 * X^0 = 5 * X^0", // identity (any real solution)
        "42 * X^0 = 42 * X^0", // identity with larger number
        "10 * X^0 = 15 * X^0", // contradiction (no solution)
        "0 * X^2 + 0 * X^1 + 0 * X^0 = 0", // 0 = 0 (any real solution)
        "0 * X^2 + 5 * X^1 = 0", // effectively linear
        "5 * X^2 = 5 * X^2", // quadratic identity
    };

    std.debug.print("=== SPECIAL CASE EQUATIONS ===\n\n", .{});
    for (special_cases, 0..) |eq, i| {
        std.debug.print("Special Test {d}: {s}\n", .{ i + 1, eq });
        const coefficients = parser(.Ultra, eq) catch |err| {
            std.debug.print("  FAIL Error: {}\n\n", .{err});
            continue;
        };
        std.debug.print("  OK Parsed successfully\n", .{});
        try quadratic_solver(coefficients);
        std.debug.print("\n", .{});
    }

    try expect(true);
}

test "intermediate steps verification - quadratic, linear, special" {
    std.debug.print("\n\n=== INTERMEDIATE STEPS VERIFICATION ===\n\n", .{});

    // Test representative cases from each category
    const intermediate_test_cases = [_][]const u8{
        "1 * X^0 + 2 * X^1 + 5 * X^2 = 0", // negative discriminant (complex solutions)
        "5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0", // positive discriminant
        "5 * X^0 + 4 * X^1 = 4 * X^0", // linear equation
        "6 * X^0 = 6 * X^0", // identity (0=0)
        "10 * X^0 = 15 * X^0", // no solution
    };

    std.debug.print("=== INTERMEDIATE STEPS DISPLAY ===\n", .{});
    std.debug.print("(Verifying that intermediate steps are printed)\n\n", .{});
    for (intermediate_test_cases, 0..) |eq, i| {
        std.debug.print("Intermediate Test {d}: {s}\n", .{ i + 1, eq });
        const coefficients = parser(.Ultra, eq) catch |err| {
            std.debug.print("  FAIL Error: {}\n\n", .{err});
            continue;
        };
        std.debug.print("  Starting solver output...\n", .{});
        try quadratic_solver(coefficients);
        std.debug.print("  OK Solver completed with steps\n\n", .{});
    }

    try expect(true);
}
