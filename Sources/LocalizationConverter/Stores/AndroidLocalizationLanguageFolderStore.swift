//
//  AndroidLocalizationLanguageFolderStore.swift
//
//  Created by Sébastien Duperron on 04/10/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct AndroidLocalizationFileStore: LocalizationStore {
    func store(localization: LocalizationMap) throws {
        let data = try AndroidStringFormatter().format(localization)
        let localizableString = try LocalizableFormatter(includePlurals: includePlurals).format(localization)
        try storeFormattedLocalizable(data: localizableString)

        do {
            let stringsDictContent = try StringsDictFormatter().format(localization)
            try storeFormattedStringsDict(data: stringsDictContent)
        } catch StringsDictFormatter.Error.noPlurals {
            print("No plural found, skipping stringsdict file.")
        }
    }
}

struct AndroidLocalizationLanguageFolderStore: LocalizationLanguageStore {
    let folderPath: String
    let includePlurals: Bool

    func store(for language: Language) -> LocalizationStore {
        let languageFolderPath = folderPath.appending(pathComponent: language.androidFolderName)
        return AndroidLocalizationFileStore(outputFolderPath: languageFolderPath)
    }
}

extension Language {
    var androidFolderName: String {
        switch self {
            case .base: return "values"
            case .named(let name): return "values-\(name)"
        }
    }
}
