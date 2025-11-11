#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np
import sys

def plot_equation(a, b, c):
    """Plot a quadratic equation: y = ax^2 + bx + c"""

    # Create x values
    x = np.linspace(-10, 10, 1000)

    # Calculate y values
    y = a * x**2 + b * x + c

    # Create the plot
    plt.figure(figsize=(10, 7))
    plt.plot(x, y, 'b-', linewidth=2, label=f'y = {a}x² + {b}x + {c}')

    # Add grid and axes
    plt.grid(True, alpha=0.3)
    plt.axhline(y=0, color='k', linewidth=0.5)
    plt.axvline(x=0, color='k', linewidth=0.5)

    # Labels and title
    plt.xlabel('x', fontsize=12)
    plt.ylabel('y', fontsize=12)
    plt.title(f'Quadratic Equation: y = {a}x² + {b}x + {c}', fontsize=14)
    plt.legend(fontsize=11)

    # Show the plot
    plt.tight_layout()
    plt.show()

    plt.savefig('graph.png')
    print("Graph saved to graph.png")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 visualizer.py <a> <b> <c>")
        print("Example: python3 visualizer.py -9.3 4 4")
        sys.exit(1)

    try:
        a = float(sys.argv[1])
        b = float(sys.argv[2])
        c = float(sys.argv[3])
        plot_equation(a, b, c)
    except ValueError:
        print("Error: Arguments must be numbers")
        sys.exit(1)
