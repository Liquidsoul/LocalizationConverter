//
//  LanguagesLocalizationStore.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

protocol LanguagesLocalizationStore {
    func store(for language: Language) -> LocalizationStore
}
