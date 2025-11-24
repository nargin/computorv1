const std = @import("std");
const helpers = @import("helpers.zig");
const allocator = std.heap.page_allocator;

pub const ParserType = enum { Strict, Ultra };

pub fn parser(parser_type: ParserType, equation: []const u8) ![11]f64 {
    switch (parser_type) {
        ParserType.Strict => return strict_parser(equation),
        ParserType.Ultra => return final_boss_parser(equation),
    }
}

/// A very permissive parser
/// Does not support parentheses
/// Returning 11 coefficients but only 3 will be populated for degrees 0 to 2
fn final_boss_parser(equation: []const u8) ![11]f64 {
    const parsed = try helpers.clean_input(equation, allocator);

    const parts = try split_equation(parsed);

    var coefficients = [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    try parse_flexible_expression(parts.left, &coefficients);

    if (parts.right.len > 0 and !std.mem.eql(u8, parts.right, "0")) {
        var right_coefficients = [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        try parse_flexible_expression(parts.right, &right_coefficients);

        for (0..11) |i| {
            coefficients[i] -= right_coefficients[i];
        }
    }

    return coefficients;
}

/// Parse a flexible expression and extract coefficients
/// Handles formats like: "5x^2+3x+1", "x²+3x-2", etc.
fn parse_flexible_expression(expression: []const u8, coefficients: *[11]f64) !void {
    var i: usize = 0;
    const len = expression.len;

    while (i < len) {
        var sign: f64 = 1.0;

        if (i < len and (expression[i] == '+' or expression[i] == '-')) {
            if (expression[i] == '-') {
                sign = -1.0;
            }
            i += 1;
        }

        if (i >= len) break;

        // Parse coefficient (optional)
        var coefficient: f64 = 1.0;
        const coeff_start = i;

        if (helpers.is_number(expression[i]) or expression[i] == '.') {
            while (i < len and (helpers.is_number(expression[i]) or expression[i] == '.')) {
                i += 1;
            }
            const coeff_str = expression[coeff_start..i];

            if (helpers.has_multiple_dots(coeff_str)) {
                std.debug.print("Error: Invalid coefficient '{s}' (multiple decimal points)\n", .{coeff_str});
                return error.InvalidFormat;
            }

            coefficient = std.fmt.parseFloat(f64, coeff_str) catch {
                return error.InvalidFormat;
            };
        }

        // Skip optional '*'
        if (i < len and expression[i] == '*') {
            i += 1;
        }

        // Parse variable and exponent
        var exponent: usize = 0;
        if (i < len and (expression[i] == 'X' or expression[i] == 'x')) {
            i += 1;
            exponent = 1; // Default exponent if not specified

            // Check for exponent notation: ^number or unicode superscript
            if (i < len and expression[i] == '^') {
                i += 1;

                const exp_start = i;
                while (i < len and helpers.is_number(expression[i])) {
                    i += 1;
                }

                if (exp_start < i) {
                    const exp_str = expression[exp_start..i];
                    exponent = std.fmt.parseInt(usize, exp_str, 10) catch {
                        return error.InvalidFormat;
                    };
                }
            } else if (i < len and expression[i] == 0xC2) {
                // 0xC2 exponent marker
                // Handle UTF-8 encoded superscript digits (² = 0xC2 0xB2, ¹ = 0xC2 0xB9)
                if (i + 1 < len) {
                    const next_byte = expression[i + 1];
                    if (next_byte == 0xB2) {
                        exponent = 2;
                        i += 2;
                    } else if (next_byte == 0xB9) {
                        exponent = 1;
                        i += 2;
                    }
                }
            } else if (i < len and helpers.is_number(expression[i])) {
                // Directly following number as exponent (e.g., x2)
                const exp_start = i;
                while (i < len and helpers.is_number(expression[i])) {
                    i += 1;
                }
                const exp_str = expression[exp_start..i];
                exponent = std.fmt.parseInt(usize, exp_str, 10) catch {
                    return error.InvalidFormat;
                };
            }
        } else if (coeff_start == i) {
            // We have neither coefficient nor variable - this is an error
            return error.InvalidFormat;
        } else {
            // We have a coefficient but no variable - this is a constant term (X^0)
            exponent = 0;
        }

        if (exponent > 10) {
            return error.ExponentTooHigh;
        }

        coefficient *= sign;
        coefficients[exponent] += coefficient;
    }
}

const EquationParts = struct {
    left: []const u8,
    right: []const u8,
};

/// Split equation into left and right parts around the '=' sign
fn split_equation(equation: []const u8) !EquationParts {
    const equal_sign_index = std.mem.indexOf(u8, equation, "=");
    const last_equal_sign_index = std.mem.lastIndexOf(u8, equation, "=");

    if (equal_sign_index != last_equal_sign_index) {
        return error.MultipleEqualSigns;
    }

    if (equal_sign_index == null) {
        return EquationParts{ .left = equation, .right = "0" };
    }

    return EquationParts{
        .left = equation[0..equal_sign_index.?],
        .right = equation[equal_sign_index.? + 1 ..],
    };
}

/// Strictly parse the command-line arguments to extract polynomial coefficients
/// Take program arguments as input and return an array of coefficients for X^0 to X^10
fn strict_parser(equation: []const u8) ![11]f64 {
    const parsed = try helpers.remove_whitespace(equation, allocator);

    // Check for invalid characters
    for (parsed, 0..) |c, i| {
        if (!helpers.is_equation_char(c, null)) {
            helpers.printInvalidCharError(parsed, i, c);
            return error.InvalidCharacter;
        }
    }

    const parts = try split_equation(parsed);

    var coefficients = [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; // Coefficients for X^0 to X^10

    extract_coefficients(parts.left, &coefficients) catch |err| {
        return err;
    };

    if (parts.right.len > 0 and std.mem.eql(u8, parts.right, "0") == false) {
        var right_coefficients = [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        extract_coefficients(parts.right, &right_coefficients) catch |err| {
            return err;
        };

        // Move right side coefficients to left side
        for (0..11) |i| {
            coefficients[i] -= right_coefficients[i];
        }
    }

    return coefficients;
}

/// Extract coefficients from a part of the equation and update the coefficients array
fn extract_coefficients(part: []const u8, coefficients: *[11]f64) !void {
    var index: usize = 0;
    const len = part.len;

    while (index < len) {
        var sign: f64 = 1.0;

        if (part[index] == '+' or part[index] == '-') {
            if (part[index] == '-') {
                sign = -1.0;
            }
            index += 1;
        }

        // Extract and calculate coefficient
        const coeff_start = index;
        while (index < len and helpers.is_valid_coeff(part[index])) {
            index += 1;
        }
        var coefficient: f64 = 1.0;
        var is_coefficient: bool = false;
        if (coeff_start != index) {
            is_coefficient = true;
            const coeff_str = part[coeff_start..index];

            if (helpers.has_multiple_dots(coeff_str)) {
                std.debug.print("Error: Invalid coefficient '{s}' (multiple decimal points)\n", .{coeff_str});
                return error.InvalidFormat;
            }

            coefficient = try std.fmt.parseFloat(f64, coeff_str);
        }
        coefficient *= @as(f64, sign);

        // Expecting '*'
        if (index >= len or part[index] != '*' and is_coefficient) {
            std.debug.print("Invalid format at position {d}: expected '*'\n", .{index});
            helpers.print_error_at(part, index);
            return error.InvalidFormat;
        }
        if (is_coefficient) index += 1;

        // Expecting 'X'
        if (index >= len or part[index] != 'X') {
            std.debug.print("Invalid format at position {d}: expected 'X'\n", .{index});
            helpers.print_error_at(part, index);
            return error.InvalidFormat;
        }
        index += 1;

        // Expecting '^'
        if (index >= len or part[index] != '^') {
            std.debug.print("Invalid format at position {d}: expected '^'\n", .{index});
            helpers.print_error_at(part, index);
            return error.InvalidFormat;
        }
        index += 1;

        // Extract exponent
        const exp_start = index;
        while (index < len and helpers.is_number(part[index])) {
            index += 1;
        }

        if (exp_start == index) {
            return error.InvalidFormat;
        }
        const exp_str = part[exp_start..index];
        const exponent = std.fmt.parseInt(usize, exp_str, 10) catch {
            return error.InvalidFormat;
        };

        if (exponent > 10) {
            return error.ExponentTooHigh;
        }

        coefficients[exponent] += coefficient;
    }
}
