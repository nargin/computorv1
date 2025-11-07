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

pub fn removeWhitespace(s: *[]const u8, allocator: std.mem.Allocator) !void {
    var cleaned = try allocator.alloc(u8, s.len);
    defer allocator.free(cleaned);
    var index: usize = 0;

    for (s) |c| {
        if (!isWhitespace(c)) {
            cleaned[index] = c;
            index += 1;
        }
    }
    s.* = cleaned[0..index];
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
    const stdin = std.Io.Reader.buffered();
    const stdout = std.Io.Writer.getStdOut().writer();

    try stdout.print("Enter equation: ", .{});

    // Read until newline, allocates memory dynamically
    const line = try stdin.readUntilDelimiterAlloc(allocator, '\n', 4096);
    defer allocator.free(line);

    return line;
}
