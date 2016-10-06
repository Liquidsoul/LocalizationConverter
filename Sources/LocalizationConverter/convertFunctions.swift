//
//  mainFunctions.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

public func convert(androidFileName fileName: String, outputPath: String, includePlurals: Bool) -> Bool {
    let provider = AndroidLocalizationFileProvider(filePath: fileName)
    let store = iOSLocalizationFileStore(outputFolderPath: outputPath, includePlurals: includePlurals)

    let converter = SingleItemConverter(provider: provider, store: store)

    do {
        try converter.execute()
    } catch {
        print("Error: \(error)")
        return false
    }

    return true
}

func convert(folder sourceFolder: String, outputPath: String, from srcFormat: LocalizationMap.Format, to dstFormat: LocalizationMap.Format, includePlurals: Bool = true) -> Bool {
    switch (srcFormat, dstFormat) {
        case let (src, dst) where src == dst:
            print("Nothing to do")
            return true
        case (.android, .ios):
            return convert(androidFolder: sourceFolder, outputPath: outputPath, includePlurals: includePlurals)
        case (.ios, .android):
            return convert(iOSFolder: sourceFolder, outputPath: outputPath)
        default:
            print("Unknown convert from \(srcFormat) to \(dstFormat)")
            return false
    }
}

public func convert(androidFolder resourceFolder: String, outputPath: String, includePlurals: Bool) -> Bool {
    do {
        let l10nLanguageProvider = try AndroidLocalizationLanguageFolderProvider(folderPath: resourceFolder)
        let l10nLanguageStore = iOSLocalizationLanguageFolderStore(folderPath: outputPath, includePlurals: includePlurals)
        let converter = LocalizationLanguageConverter(provider: l10nLanguageProvider, store: l10nLanguageStore)
        try converter.execute()

        return true
    } catch {
        print("Error: \(error)")
        return false
    }
}

func convert(iOSFolder sourceFolder: String, outputPath: String) -> Bool {
    do {
        let l10nLanguageProvider = try iOSLocalizationLanguageFolderProvider(folderPath: sourceFolder)
        let l10nLanguageStore = AndroidLocalizationLanguageFolderStore(folderPath: outputPath)
        let converter = LocalizationLanguageConverter(provider: l10nLanguageProvider, store: l10nLanguageStore)
        try converter.execute()
        return true
    } catch {
        print("Error: \(error)")
        return false
    }
}
