.DEFAULT_GOAL := test

PROJECTNAME=LocalizationConverter
RELEASE_BIN_PATH=.build/release/$(PROJECTNAME)

.PHONY: install test clean ci release

install:
	brew bundle

test:
	swift test
	swiftlint

clean:
	swift package clean

ci: install test

release: clean $(RELEASE_BIN_PATH)

$(RELEASE_BIN_PATH): install
	swift build --configuration release -Xswiftc -static-stdlib
