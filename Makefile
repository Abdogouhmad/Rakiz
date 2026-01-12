# Variables
FLUTTER := flutter
BUILD_CMD := $(FLUTTER) build apk --release --split-per-abi

# Default task
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make build         - Build release APKs (split per ABI)"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make get           - Get dependencies (flutter pub get)"
	@echo "  make upgrade       - Upgrade dependencies"
	@echo "  make doctor        - Run flutter doctor"
	@echo "  make run           - Run the app in release mode"

.PHONY: build
img:
	@echo "Generate icon launcher"
	$(FLUTTER) clean
	$(FLUTTER) pub get
	dart run flutter_launcher_icons
build: check img
	@echo "Building Release APK (Split per ABI)..."
	$(BUILD_CMD)

.PHONY: clean
clean:
	@echo "Cleaning project..."
	$(FLUTTER) clean

.PHONY: get
get:
	@echo "Getting dependencies..."
	$(FLUTTER) pub get

.PHONY: upgrade
upgrade:
	@echo "Upgrading dependencies..."
	$(FLUTTER) pub upgrade

.PHONY: doctor
doctor:
	$(FLUTTER) doctor

.PHONY: run
run:
	$(FLUTTER) clean
	$(FLUTTER) pub get
	$(FLUTTER) run -d linux

check:
	$(FLUTTER) analyze
