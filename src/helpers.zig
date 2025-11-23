const std = @import("std");

pub fn is_equation_char(c: u8, could_also: ?[]const u8) bool {
    if (could_also) |extra| {
        for (extra) |ec| if (c == ec) return true;
    }

    return switch (c) {
        '0'...'9', 'X', '.', '+', '-', '*', '/', '^', '=', ' ' => true,
        else => false,
    };
}

pub fn is_number(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn is_whitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

pub fn is_valid_coeff(c: u8) bool {
    return is_number(c) or (c == '.');
}

// String utilities

pub fn remove_whitespace(s: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var cleaned = try allocator.alloc(u8, s.len);
    var index: usize = 0;

    for (s) |c| {
        if (!is_whitespace(c)) {
            cleaned[index] = c;
            index += 1;
        }
    }

    return cleaned[0..index];
}

/// Cleans input by removing whitespace and unallowed characters
/// Will remain permissive only
/// Not really optimized but works
pub fn clean_input(s: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var validc: usize = 0;
    for (s) |c| {
        if (is_equation_char(c, "x²¹") and !is_whitespace(c)) {
            validc += 1;
        }
    }

    std.debug.print("Valid characters count: {d}\n", .{validc});

    var cleaned = try allocator.alloc(u8, validc + 1);
    var index: usize = 0;
    for (s) |c| {
        if (!is_whitespace(c) and is_equation_char(c, "x²¹")) {
            cleaned[index] = c;
            index += 1;
        }
    }
    if (index != validc) {
        // Sanity check
        return error.InternalError;
    }

    return cleaned[0..validc];
}

// Error display functions

pub fn print_error_at(text: []const u8, position: usize) void {
    std.debug.print("{s}\n", .{text});
    var j: usize = 0;
    while (j < position) : (j += 1) {
        std.debug.print(" ", .{});
    }
    std.debug.print("^\n", .{});
}

pub fn printInvalidCharError(text: []const u8, position: usize, char: u8) void {
    if (char < 128) {
        // ASCII character - safe to print
        std.debug.print("Invalid character at position {d}: '{c}'\n", .{ position, char });
    } else {
        // Non-ASCII (possibly UTF-8 multi-byte)
        std.debug.print("Invalid character at position {d}: (non-ASCII byte 0x{x})\n", .{ position, char });
    }
    print_error_at(text, position);
}

pub fn get_user_input() ![]const u8 {
    const allocator = std.heap.page_allocator;

    // Setup stdin with buffer
    var stdin_buffer: [4096]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    // Setup stdout
    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;

    // Create ArrayList - NOTE: In 0.15+, it's unmanaged by default
    var input_data: std.ArrayList(u8) = .empty;
    defer input_data.deinit(allocator);

    try stdout.writeAll("> Enter equation: ");
    try stdout.flush();

    // Read until delimiter and append to ArrayList
    // takeDelimiterExclusive returns a slice from the internal buffer
    const line = try reader.takeDelimiterExclusive('\n');

    // Copy the line data into the ArrayList
    try input_data.appendSlice(allocator, line);

    return input_data.toOwnedSlice(allocator);
}

pub fn validate_args(args: []const []const u8) ![]const u8 {
    const args_len = args.len;

    if (args_len == 1) {
        return get_user_input();
    }

    if (args_len > 2) {
        return error.TooManyArguments;
    }

    return args[1];
}
