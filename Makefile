.PHONY: all build clean run test help visualize venv
.DEFAULT_GOAL := help


# Clean build artifacts
clean:
	rm -rf .zig-cache
	rm computor

# Setup virtual environment for visualization
venv:
	python3 -m venv venv
	. venv/bin/activate && pip install -r requirements.txt

# Visualize coefficients using Python script
bonus: venv
	. venv/bin/activate && python3 visualizer.py $(ARGS)

# Help message
help:
	@echo "Available targets:"
	@echo "  make clean              - Clean build artifacts"
	@echo "  make venv               - Setup Python virtual environment"
	@echo "  make bonus ARGS=\"a b c\" - Run Python visualization with coefficients"
	@echo "  make help               - Show this help message"
	@echo ""
