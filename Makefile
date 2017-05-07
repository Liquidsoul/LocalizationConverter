.DEFAULT_GOAL := test

BIN_FILENAME=l10nconverter
RELEASE_BIN_PATH=.build/release/$(BIN_FILENAME)
OUTPUT_PATH=release/

.PHONY: install test clean ci release

install:
	brew bundle

test:
	swift test
	swiftlint

clean:
	swift package clean

ci: install test

release: clean $(OUTPUT_PATH)/$(BIN_FILENAME)

$(OUTPUT_PATH)/$(BIN_FILENAME): $(RELEASE_BIN_PATH)
	if [ ! -e $(OUTPUT_PATH) ]; then mkdir -p $(OUTPUT_PATH); fi
	cp $< $@

$(RELEASE_BIN_PATH):
	swift build --configuration release -Xswiftc -static-stdlib
