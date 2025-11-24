const std = @import("std");
const helpers = @import("helpers.zig");

/// Check if a float is approximately zero
fn is_approximately_zero(value: f64) bool {
    return @abs(value) < helpers.EPSILON;
}

/// Check if two floats are approximately equal
fn approximately_equal(a: f64, b: f64) bool {
    return @abs(a - b) < helpers.EPSILON;
}

/// Determine the polynomial degree (highest non-zero coefficient)
fn get_polynomial_degree(coefficients: [11]f64) usize {
    var degree: usize = 0;
    for (coefficients, 0..) |coeff, i| {
        if (!is_approximately_zero(coeff)) {
            degree = i;
        }
    }
    return degree;
}

/// Print the reduced form of the equation
fn print_reduced_form(coefficients: [11]f64) void {
    std.debug.print("Reduced form: ", .{});

    // Find the highest degree
    var max_degree: usize = 0;
    for (coefficients, 0..) |coeff, i| {
        if (!is_approximately_zero(coeff)) {
            max_degree = i;
        }
    }

    // If all coefficients are zero, just print 0
    if (max_degree == 0 and is_approximately_zero(coefficients[0])) {
        std.debug.print("0 * X^0 = 0\n", .{});
        return;
    }

    // Print all terms from X^0 to X^max_degree
    var first_term = true;
    for (0..max_degree + 1) |i| {
        const coeff = coefficients[i];

        if (!first_term) {
            if (coeff >= 0) {
                std.debug.print(" + ", .{});
            } else {
                std.debug.print(" - ", .{});
            }
            // Absolute value cause sign already above
            std.debug.print("{d} * X^{d}", .{ @abs(coeff), i });
        } else {
            // First term - print as-is (with sign if negative)
            std.debug.print("{d} * X^{d}", .{ coeff, i });
            first_term = false;
        }
    }

    std.debug.print(" = 0\n", .{});
}

pub fn quadratic_solver(coefficients: [11]f64) !void {
    // all prints are subject requirement
    print_reduced_form(coefficients);

    const degree = get_polynomial_degree(coefficients);
    std.debug.print("Polynomial degree: {d}\n", .{degree});

    // Handle degree > 2
    if (degree > 2) {
        std.debug.print("The polynomial degree is strictly greater than 2, I can't solve.\n", .{});
        return;
    }

    const a = coefficients[2];
    const b = coefficients[1];
    const c = coefficients[0];

    // Show intermediate steps
    std.debug.print("\n--- Intermediate Steps ---\n", .{});
    std.debug.print("Step 1: Identify coefficients\n", .{});
    std.debug.print("  a = {d}, b = {d}, c = {d}\n\n", .{ a, b, c });

    // Degree 0 or lower
    if (is_approximately_zero(a) and is_approximately_zero(b) and is_approximately_zero(c)) {
        std.debug.print("Step 2: Analyze constant equation\n", .{});
        std.debug.print("  Equation is 0 = 0 (always true)\n", .{});
        std.debug.print("Any real number is a solution.\n", .{});
        return;
    }

    if (is_approximately_zero(a) and is_approximately_zero(b)) {
        std.debug.print("Step 2: Analyze constant equation\n", .{});
        std.debug.print("  Equation is {d} = 0 (contradiction)\n", .{c});
        std.debug.print("No solution.\n", .{});
        return;
    }

    // Degree 1 (linear)
    if (is_approximately_zero(a)) {
        std.debug.print("Step 2: Solve linear equation (bx + c = 0)\n", .{});
        std.debug.print("  {d} * x + {d} = 0\n", .{ b, c });
        std.debug.print("  {d} * x = {d}\n", .{ b, -c });
        const solution = -c / b;
        std.debug.print("  x = {d} / {d}\n", .{ -c, b });
        std.debug.print("  x = {d:.6}\n\n", .{solution});
        std.debug.print("The solution is: x = {d:.6}\n", .{solution});
        return;
    }

    // Degree 2 (quadratic)
    // https://en.wikipedia.org/wiki/Quadratic_equation
    const discriminant = b * b - 4 * a * c;

    std.debug.print("Step 2: Calculate discriminant (Δ = b² - 4ac)\n", .{});
    std.debug.print("  Δ = {d}² - 4({d})({d})\n", .{ b, a, c });
    std.debug.print("  Δ = {d} - {d}\n", .{ b * b, 4 * a * c });
    std.debug.print("  Δ = {d}\n\n", .{discriminant});

    std.debug.print("Step 3: Apply quadratic formula (x = (-b ± √Δ) / 2a)\n", .{});

    if (discriminant > helpers.EPSILON) {
        std.debug.print("  x = (-{d} ± √{d}) / (2 * {d})\n", .{ b, discriminant, a });
        const root1 = (-b + std.math.sqrt(discriminant)) / (2 * a);
        const root2 = (-b - std.math.sqrt(discriminant)) / (2 * a);
        std.debug.print("  x₁ = {d:.6}, x₂ = {d:.6}\n\n", .{ root1, root2 });
        display_end_result(discriminant, root1, root2);
    } else if (approximately_equal(discriminant, 0)) {
        std.debug.print("  x = (-{d}) / (2 * {d})\n", .{ b, a });
        const root = -b / (2 * a);
        std.debug.print("  x = {d:.6}\n\n", .{root});
        display_end_result(discriminant, root, root);
    } else {
        std.debug.print("  x = (-{d} ± √({d})) / (2 * {d})\n", .{ b, discriminant, a });
        const realPart = -b / (2 * a);
        const imagPart = std.math.sqrt(-discriminant) / (2 * a);
        std.debug.print("  x = {d:.6} ± {d:.6}i\n\n", .{ realPart, imagPart });
        display_end_result(discriminant, realPart, imagPart);
    }
}

fn display_end_result(discriminant: f64, root1: f64, root2: f64) void {
    const fRoot1 = formatted_coeff(root1);
    const fRoot2 = formatted_coeff(root2);

    if (discriminant > helpers.EPSILON) {
        std.debug.print("Discriminant is strictly positive, the two solutions are:\n", .{});
        std.debug.print("x1 = {d} and x2 = {d}\n", .{ fRoot1, fRoot2 });
    } else if (approximately_equal(discriminant, 0)) {
        std.debug.print("Discriminant is zero, the solution is:\n", .{});
        std.debug.print("x1 = x2 = {d}\n", .{fRoot1});
    } else {
        std.debug.print("Discriminant is strictly negative, the two complex solutions are:\n", .{});
        std.debug.print("x1 = {d} + {d}i and x2 = {d} - {d}i\n", .{ fRoot1, fRoot2, fRoot1, fRoot2 });
    }
}

fn formatted_coeff(value: f64) f64 {
    // Round to 6 decimal places for better precision
    return @as(f64, @round(value * 1000000)) / 1000000;
}

fn decimal_to_fraction(value: f64) void {
    // len = number of digits after decimal point
    var len: usize = 0;
    var temp = value;
    while (temp != @as(f64, @round(temp))) : (len += 1) {
        temp *= 10;
    }

    const denominator = std.math.pow(10, len);
    _ = denominator;
}
