
RELEASE_BIN_PATH=.build/release/LocalizationConverter

.PHONY: build release clean

build:
	swift build

release: clean $(RELEASE_BIN_PATH)

clean:
	swift build --clean

$(RELEASE_BIN_PATH):
	swift build --configuration release
