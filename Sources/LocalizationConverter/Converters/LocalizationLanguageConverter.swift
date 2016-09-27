//
//  LocalizationLanguageConverter.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct LocalizationLanguageConverter {
    private let l10nLanguageProvider: LocalizationLanguageProvider
    private let l10nLanguageStore: LocalizationLanguageStore

    init(provider: LocalizationLanguageProvider, store: LocalizationLanguageStore) {
        self.l10nLanguageProvider = provider
        self.l10nLanguageStore = store
    }

    func execute() throws {
        try l10nLanguageProvider.languages.forEach { (language) in
            let contentProvider = l10nLanguageProvider.contentProvider(for: language)
            let store = l10nLanguageStore.store(for: language)
            let converter = SingleItemConverter(provider: contentProvider, store: store)
            try converter.execute()
        }
    }

}
