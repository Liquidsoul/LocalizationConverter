
ARCHIVE_NAME=release.xcarchive
ARCHIVE_FULLNAME=$(ARCHIVE_NAME).xcarchive
PROJECT=MobileLocalizationConverter.xcodeproj
SCHEME=MobileLocalizationConverter

.PHONY: release clean

release: clean $(ARCHIVE_FULLNAME)

clean:
	rm -rf $(ARCHIVE_FULLNAME)

$(ARCHIVE_FULLNAME):
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) archive -archivePath $(ARCHIVE_NAME)