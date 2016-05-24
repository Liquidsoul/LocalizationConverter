
ARCHIVE_NAME=release.xcarchive
ARCHIVE_FULLNAME=$(ARCHIVE_NAME).xcarchive
PROJECT=LocalizationConverter.xcodeproj
SCHEME=LocalizationConverter

.PHONY: release clean

release: clean $(ARCHIVE_FULLNAME)

clean:
	rm -rf $(ARCHIVE_FULLNAME)

$(ARCHIVE_FULLNAME):
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) archive -archivePath $(ARCHIVE_NAME)