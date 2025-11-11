.PHONY: all build clean run test help visualize venv

all: build

# Build the Zig project
build:
	zig build

# Clean build artifacts
clean:
	zig build clean
	rm -rf .zig-cache

# Run the solver with an equation (use: make run ARGS="equation")
run: build
	./computor $(ARGS)

# Run tests
test: build
	zig build test

# Setup virtual environment for visualization
venv:
	python3 -m venv venv
	. venv/bin/activate && pip install -r requirements.txt

# Visualize coefficients (use: make bonus ARGS="a b c" or default example)
bonus: venv
	. venv/bin/activate && python3 visualizer.py $(ARGS)

# Help message
help:
	@echo "Available targets:"
	@echo "  make build              - Build the Zig project"
	@echo "  make clean              - Clean build artifacts"
	@echo "  make run ARGS=\"eq\"      - Run solver with equation"
	@echo "  make test               - Run tests"
	@echo "  make venv               - Setup Python virtual environment"
	@echo "  make bonus ARGS=\"a b c\" - Run Python visualization with coefficients"
	@echo "  make help               - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make run ARGS=\"5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0\""
	@echo "  make bonus ARGS=\"-9.3 4 5\""
