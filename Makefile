.DEFAULT_GOAL := test

BIN_FILENAME=l10nconverter
RELEASE_BIN_PATH=.build/release/$(BIN_FILENAME)
OUTPUT_PATH=release/

.PHONY: install test clean ci release

# Install the required dependencies.
install:
	brew bundle

# Build and run the tests and run the linting tool.
test:
	swift test
	swiftlint

# Clean the build artifacts.
clean:
	swift package clean

# Target for the ci runner.
ci: install test

# Generate a release build.
release: clean $(OUTPUT_PATH)/$(BIN_FILENAME)

$(OUTPUT_PATH)/$(BIN_FILENAME): $(RELEASE_BIN_PATH)
	if [ ! -e $(OUTPUT_PATH) ]; then mkdir -p $(OUTPUT_PATH); fi
	cp $< $@

$(RELEASE_BIN_PATH):
	swift build --configuration release -Xswiftc -static-stdlib
