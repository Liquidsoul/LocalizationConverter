//
//  LocalizationLanguageConverter.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct LocalizationLanguageConverter {
    let localizationProvider: LocalizationStringProvider
    let languagesStore: LanguagesLocalizationStore
    let includePlurals: Bool

    func execute() throws {
        try localizationProvider.languages.forEach { (language) in
            let contentProvider = localizationProvider.contentProvider(for: language)
            let store = languagesStore.store(for: language)
            let converter = SingleItemConverter(provider: contentProvider, store: store, includePlurals: includePlurals)
            try converter.execute()
        }
    }

}
