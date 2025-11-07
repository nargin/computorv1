const std = @import("std");
const helpers = @import("helpers.zig");
const allocator = std.heap.page_allocator;

/// Strictly parse the command-line arguments to extract polynomial coefficients
/// Take program arguments as input and return an array of coefficients for X^0, X^1, and X^2
pub fn strict_parser(args: []const []const u8) ![3]f64 {
    const args_len = args.len;

    if (args_len < 2) {
        return error.InsufficientArguments;
    }

    const equation = try helpers.removeWhitespace(args[1], allocator);

    // Check for invalid characters
    for (equation, 0..) |c, i| {
        if (!helpers.isEquationChar(c)) {
            helpers.printInvalidCharError(equation, i, c);
            return error.InvalidCharacter;
        }
    }

    const equal_sign_index = std.mem.indexOf(u8, equation, "=");
    const last_equal_sign_index = std.mem.lastIndexOf(u8, equation, "=");
    if (equal_sign_index != last_equal_sign_index) {
        return error.MultipleEqualSigns;
    }

    var left_part: []const u8 = undefined;
    var right_part: []const u8 = undefined;
    if (equal_sign_index == null) {
        left_part = equation;
        right_part = "0";
    } else {
        left_part = equation[0..equal_sign_index.?];
        right_part = equation[equal_sign_index.? + 1 ..];
    }

    var coefficients = [3]f64{ 0, 0, 0 }; // Coefficients for X^0, X^1, X^2

    extract_coefficients(left_part, &coefficients) catch |err| {
        return err;
    };

    if (right_part.len > 0 and std.mem.eql(u8, right_part, "0") == false) {
        var right_coefficients = [3]f64{ 0, 0, 0 };
        extract_coefficients(right_part, &right_coefficients) catch |err| {
            return err;
        };

        // Move right side coefficients to left side
        for (0..3) |i| {
            coefficients[i] -= right_coefficients[i];
        }
    }

    return coefficients;
}

/// Extract coefficients from a part of the equation and update the coefficients array
fn extract_coefficients(part: []const u8, coefficients: *[3]f64) !void {
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
        while (index < len and helpers.isValidCoeff(part[index])) {
            index += 1;
        }
        var coefficient: f64 = 1.0;
        var is_coefficient: bool = false;
        if (coeff_start != index) {
            is_coefficient = true;
            const coeff_str = part[coeff_start..index];
            coefficient = try std.fmt.parseFloat(f64, coeff_str);
        }
        coefficient *= @as(f64, sign);

        // Expecting '*'
        if (index >= len or part[index] != '*' and is_coefficient) {
            std.debug.print("Invalid format at position {d}: expected '*'\n", .{index});
            helpers.printErrorAt(part, index);
            return error.InvalidFormat;
        }
        if (is_coefficient) index += 1;

        // Expecting 'X'
        if (index >= len or part[index] != 'X') {
            std.debug.print("Invalid format at position {d}: expected 'X'\n", .{index});
            helpers.printErrorAt(part, index);
            return error.InvalidFormat;
        }
        index += 1;

        // Expecting '^'
        if (index >= len or part[index] != '^') {
            std.debug.print("Invalid format at position {d}: expected '^'\n", .{index});
            helpers.printErrorAt(part, index);
            return error.InvalidFormat;
        }
        index += 1;

        // Extract exponent
        // Calculate exponent even if we don't use it beyond 2
        // Everything done at the end dont care of performance use
        const exp_start = index;
        while (index < len and helpers.isNumber(part[index])) {
            index += 1;
        }

        if (exp_start == index) {
            return error.InvalidFormat;
        }
        const exp_str = part[exp_start..index];
        const exponent = std.fmt.parseInt(usize, exp_str, 10) catch {
            return error.InvalidFormat;
        };

        if (exponent > 2) {
            return error.ExponentTooHigh;
        }

        coefficients[exponent] += coefficient;
    }
}
