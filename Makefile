
RELEASE_BIN_PATH=.build/release/LocalizationConverter

.PHONY: test release clean install

test: install
	bundle exec fastlane test

clean: install
	bundle exec fastlane clean

install:
	bundle install --quiet

release: clean $(RELEASE_BIN_PATH)

$(RELEASE_BIN_PATH): install
	bundle exec fastlane release
