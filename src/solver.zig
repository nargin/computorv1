const std = @import("std");

pub fn quadratic_solver(coefficients: [3]f64) !void {
    const a = coefficients[2];
    const b = coefficients[1];
    const c = coefficients[0];

    if (a == 0 and b == 0 and c == 0) {
        std.debug.print("All real numbers are solutions.\n", .{});
        return;
    }

    if (a == 0 and b == 0) {
        std.debug.print("No solution exists.\n", .{});
        return;
    }

    if (a == 0) {
        const solution = -c / b;
        std.debug.print("Linear solution: X = {d}\n", .{solution});
        return;
    }

    const discriminant = b * b - 4 * a * c;

    // Solution will be rounded to 3 decimal places
    // Just for better readability, sorry for math incorrectness :(
    if (discriminant > 0) {
        const root1 = (-b + std.math.sqrt(discriminant)) / (2 * a);
        const root2 = (-b - std.math.sqrt(discriminant)) / (2 * a);
        std.debug.print("Two real solutions: X1 = {d:.3}, X2 = {d:.3}\n", .{ root1, root2 });
    } else if (discriminant == 0) {
        const root = -b / (2 * a);
        std.debug.print("One real solution: X = {d:.3}\n", .{root});
    } else {
        const realPart = -b / (2 * a);
        const imagPart = std.math.sqrt(-discriminant) / (2 * a);
        std.debug.print("Two complex solutions: X1 = {d:.3} + {d:.3}i, X2 = {d:.3} - {d:.3}i\n", .{ realPart, imagPart, realPart, imagPart });
    }
}
