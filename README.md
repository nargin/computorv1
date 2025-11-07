# Computor

A quadratic equation solver written in Zig.

## Quick Start

The compiled binary is included in the repo:

```bash
./computor "5 * X^2 + 3 * X + 2 = 1 + X"
```

## Building from Source

Install Zig 0.15.2 from:
https://ziglang.org/download/0.15.2/zig-0.15.2.tar.xz

> **Note:** This specific version is required due to breaking changes in the Zig language. Since Zig is still in development, language features and APIs change frequently between versions.

Then build with:

```bash
zig build
```

## Testing

```bash
zig build test
```

## Usage

```bash
./computor "equation"
```

## License

See LICENSE file for details
