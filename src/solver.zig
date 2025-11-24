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

        // Avoid displaying -0
        const neg_c = if (is_approximately_zero(c)) 0 else -c;
        std.debug.print("  {d} * x = {d}\n", .{ b, neg_c });

        const solution = -c / b;
        std.debug.print("  x = {d} / {d}\n", .{ neg_c, b });

        const display_solution = if (is_approximately_zero(solution)) 0 else solution;
        std.debug.print("  x = {d:.6}\n\n", .{display_solution});

        std.debug.print("The solution is: x = ", .{});
        format_real_fraction(solution);
        std.debug.print("\n", .{});
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
    if (discriminant > helpers.EPSILON) {
        std.debug.print("Discriminant is strictly positive, the two solutions are:\n", .{});
        std.debug.print("x1 = ", .{});
        format_real_fraction(root1);
        std.debug.print(" and x2 = ", .{});
        format_real_fraction(root2);
        std.debug.print("\n", .{});
    } else if (approximately_equal(discriminant, 0)) {
        std.debug.print("Discriminant is zero, the solution is:\n", .{});
        std.debug.print("x1 = x2 = ", .{});
        format_real_fraction(root1);
        std.debug.print("\n", .{});
    } else {
        std.debug.print("Discriminant is strictly negative, the two complex solutions are:\n", .{});
        std.debug.print("x1 = ", .{});
        format_complex_fraction(root1, root2);
        std.debug.print(" and x2 = ", .{});
        format_complex_fraction(root1, -root2);
        std.debug.print("\n", .{});
    }
}

fn formatted_coeff(value: f64) f64 {
    // Round to 6 decimal places for better precision
    return @as(f64, @round(value * 1000000)) / 1000000;
}

// https://en.wikipedia.org/wiki/Greatest_common_divisor#Euclidean_algorithm
fn gcd(a: i64, b: u64) u64 {
    const abs_a = @as(u64, @intCast(@abs(a)));
    if (b == 0) return abs_a;
    if (abs_a == 0) return b;
    return gcd_impl(abs_a, b);
}

fn gcd_impl(a: u64, b: u64) u64 {
    if (b == 0) return a;
    return gcd_impl(b, a % b);
}

fn decimal_to_fraction(value: f64) struct { numerator: i64, denominator: u64 } {
    const is_negative = value < 0;
    const abs_value = @abs(value);

    // Check if it's effectively a whole number
    const rounded = @round(abs_value);
    if (@abs(abs_value - rounded) < helpers.EPSILON) {
        const int_val = @as(i64, @intFromFloat(rounded));
        return .{ .numerator = if (is_negative) -int_val else int_val, .denominator = 1 };
    }

    // Convert using fixed decimal places (up to 6)
    // This handles most practical cases without precision issues
    var decimal_places: u32 = 0;
    var scaled = abs_value;
    const max_places = 6;

    while (decimal_places < max_places) {
        scaled *= 10;
        const scaled_int = @as(i64, @intFromFloat(scaled));
        const diff = scaled - @as(f64, @floatFromInt(scaled_int));
        decimal_places += 1;

        // If we've got a good integer approximation, stop
        if (@abs(diff) < helpers.EPSILON) {
            break;
        }
    }

    // Create fraction
    const power_of_10 = std.math.pow(f64, 10.0, @as(f64, @floatFromInt(decimal_places)));
    var numerator = @as(i64, @intFromFloat(abs_value * power_of_10));
    var denominator = @as(u64, @intFromFloat(power_of_10));

    // Reduce using GCD
    const common = gcd(numerator, denominator);
    numerator = @divExact(numerator, @as(i64, @intCast(common)));
    denominator /= common;

    if (is_negative) numerator = -numerator;

    return .{ .numerator = numerator, .denominator = denominator };
}

/// Format and print a single fraction (only if it's a "clean" fraction)
fn format_real_fraction(value: f64) void {
    var val = value;
    if (is_approximately_zero(val)) val = 0;

    const frac = decimal_to_fraction(val);

    // Only show fraction if denominator is reasonable (max 100)
    // If denominator > 100, it's likely an irrational number, so show as decimal instead
    if (frac.denominator == 1) {
        // Handle -0 case: always show 0, never -0
        if (frac.numerator == 0) {
            std.debug.print("0", .{});
        } else {
            std.debug.print("{d}", .{frac.numerator});
        }
    } else if (frac.denominator <= 100) {
        std.debug.print("{d}/{d}", .{ frac.numerator, frac.denominator });
    } else {
        // For irrational or very small decimals, show decimal (avoid -0)
        const display_val = if (is_approximately_zero(val)) 0 else val;
        std.debug.print("{d:.6}", .{display_val});
    }
}

/// Format and print complex solution with fractions (real + imaginary)
fn format_complex_fraction(real: f64, imag: f64) void {
    var real_val = real;
    var imag_val = imag;

    if (is_approximately_zero(real_val)) real_val = 0;
    if (is_approximately_zero(imag_val)) imag_val = 0;

    const real_frac = decimal_to_fraction(real_val);
    const imag_frac = decimal_to_fraction(imag_val);

    // Display real part
    if (real_frac.denominator == 1) {
        if (real_frac.numerator == 0) {
            std.debug.print("0", .{});
        } else {
            std.debug.print("{d}", .{real_frac.numerator});
        }
    } else if (real_frac.denominator <= 100) {
        std.debug.print("{d}/{d}", .{ real_frac.numerator, real_frac.denominator });
    } else {
        const display_real = if (is_approximately_zero(real_val)) 0 else real_val;
        std.debug.print("{d:.6}", .{display_real});
    }

    // Display imaginary part with sign
    if (imag_frac.numerator >= 0) {
        std.debug.print(" + ", .{});
    } else {
        std.debug.print(" - ", .{});
    }

    if (imag_frac.denominator == 1) {
        const abs_imag = @abs(imag_frac.numerator);
        if (abs_imag == 0) {
            std.debug.print("0i", .{});
        } else {
            std.debug.print("{d}i", .{abs_imag});
        }
    } else if (imag_frac.denominator <= 100) {
        std.debug.print("{d}i/{d}", .{ @abs(imag_frac.numerator), imag_frac.denominator });
    } else {
        const display_imag = if (is_approximately_zero(imag_val)) 0 else @abs(imag_val);
        std.debug.print("{d:.6}i", .{display_imag});
    }
}
