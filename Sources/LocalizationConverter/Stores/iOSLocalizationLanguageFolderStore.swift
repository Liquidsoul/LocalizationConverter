//
//  iOSLocalizationLanguageFolderStore.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct iOSLocalizationLanguageFolderStore: LocalizationLanguageStore {
    let folderPath: String
    let includePlurals: Bool

    func store(for language: Language) -> LocalizationStore {
        let languageFolderPath = folderPath.appending(pathComponent: language.iOSFolderName)
        return iOSLocalizationFileStore(outputFolderPath: languageFolderPath, includePlurals: includePlurals)
    }
}

extension Language {
    var iOSFolderName: String {
        switch self {
            case .base: return "Base.lproj"
            case .named(let name): return "\(name).lproj"
        }
    }
}
