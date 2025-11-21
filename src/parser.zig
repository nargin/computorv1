const std = @import("std");
const helpers = @import("helpers.zig");
const allocator = std.heap.page_allocator;

pub const ParserType = enum { Strict, Ultra };

pub fn parser(parser_type: ParserType, equation: []const u8) ![11]f64 {
    switch (parser_type) {
        ParserType.Strict => return strict_parser(equation),
        ParserType.Ultra => return last_boss_parser(equation),
    }
}

/// A very permissive parser
/// Does not handle Superscript symbols or complex numbers
fn last_boss_parser(equation: []const u8) ![11]f64 {
    const parsed = try helpers.remove_whitespace(equation, allocator);

    std.debug.print("Last boss parser activated. Parsed equation: {s}\n", .{parsed});

    for (parsed, 0..) |c, i| {
        if (!helpers.is_equation_char(c, "x²")) {
            helpers.printInvalidCharError(parsed, i, c);
            return error.InvalidCharacter;
        }
    }

    // The parser should parse anything excluding UTF-8 invalid characters
    for (parsed, 0..) |c, i| {
        _ = c; // Just to avoid unused variable warning
        _ = i;
    }

    return [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; // Dummy return
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

    const equal_sign_index = std.mem.indexOf(u8, parsed, "=");
    const last_equal_sign_index = std.mem.lastIndexOf(u8, parsed, "=");
    if (equal_sign_index != last_equal_sign_index) {
        return error.MultipleEqualSigns;
    }

    var left_part: []const u8 = undefined;
    var right_part: []const u8 = undefined;
    if (equal_sign_index == null) {
        left_part = parsed;
        right_part = "0";
    } else {
        left_part = parsed[0..equal_sign_index.?];
        right_part = parsed[equal_sign_index.? + 1 ..];
    }

    var coefficients = [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; // Coefficients for X^0 to X^10

    extract_coefficients(left_part, &coefficients) catch |err| {
        return err;
    };

    if (right_part.len > 0 and std.mem.eql(u8, right_part, "0") == false) {
        var right_coefficients = [11]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        extract_coefficients(right_part, &right_coefficients) catch |err| {
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
