const std = @import("std");

// Character validation functions

pub fn isNumber(c: u8) bool {
    return (c >= '0' and c <= '9');
}

pub fn isOperator(c: u8) bool {
    return (c == '+' or c == '-' or c == '*' or c == '/' or c == '^' or c == '=');
}

pub fn isEquationChar(c: u8) bool {
    return isNumber(c) or (c == '.') or (c == 'X') or isOperator(c) or (c == ' ');
}

pub fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

pub fn isValidCoeff(c: u8) bool {
    return isNumber(c) or (c == '.');
}

// String utilities

pub fn removeWhitespace(s: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var cleaned = try allocator.alloc(u8, s.len);
    var index: usize = 0;

    for (s) |c| {
        if (!isWhitespace(c)) {
            cleaned[index] = c;
            index += 1;
        }
    }

    return cleaned[0..index];
}

// Error display functions

pub fn printErrorAt(text: []const u8, position: usize) void {
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
    printErrorAt(text, position);
}

pub fn getUserInput() ![]const u8 {
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
