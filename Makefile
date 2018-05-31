.DEFAULT_GOAL := help

BIN_FILENAME=l10nconverter
RELEASE_BIN_PATH=.build/release/$(BIN_FILENAME)
OUTPUT_PATH=release/

.PHONY: install
## Install the required dependencies.
install:
	brew bundle

.PHONY: test
## Build and run the tests and run the linting tool.
test:
	swift test
	swiftlint

.PHONY: clean
## Clean the build artifacts.
clean:
	swift package clean

.PHONY: ci
## Target for the ci runner.
ci: install test

.PHONY: release
## Generate a release build.
release: clean $(OUTPUT_PATH)/$(BIN_FILENAME)

$(OUTPUT_PATH)/$(BIN_FILENAME): $(RELEASE_BIN_PATH)
	if [ ! -e $(OUTPUT_PATH) ]; then mkdir -p $(OUTPUT_PATH); fi
	cp $< $@

$(RELEASE_BIN_PATH):
	@swift --version
	swift build --disable-sandbox --configuration release -Xswiftc -static-stdlib

.PHONY: help
# taken from this gist https://gist.github.com/rcmachado/af3db315e31383502660
## Show this help message.
help:
	$(info Usage: make [target...])
	$(info Available targets)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
		nb = sub( /^## /, "", helpMsg );              \
		if(nb == 0) {                                 \
			helpMsg = $$0;                              \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
		}                                             \
		if (nb)                                       \
			print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts $$'\t' |          \
	grep --color '^[^ ]*'
