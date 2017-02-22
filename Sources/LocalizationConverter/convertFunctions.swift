//
//  mainFunctions.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

public func convert(androidFileName fileName: String, outputPath: String, includePlurals: Bool) -> Bool {
    let provider = AndroidL10nFileProvider(filePath: fileName)
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

public func convert(androidFolder resourceFolder: String, outputPath: String, includePlurals: Bool) -> Bool {
    do {
        let l10nLanguageProvider = try AndroidL10nLanguageFolderProvider(folderPath: resourceFolder)
        let l10nLanguageStore = iOSLocalizationLanguageFolderStore(folderPath: outputPath, includePlurals: includePlurals)
        let converter = LocalizationLanguageConverter(provider: l10nLanguageProvider, store: l10nLanguageStore)
        try converter.execute()

        return true
    } catch {
        print("Error: \(error)")
        return false
    }
}
