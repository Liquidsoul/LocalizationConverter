//
//  LocalizationStringProvider.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

protocol LocalizationStringProvider {
    var languages: [Language] { get }
    func contentProvider(for language: Language) -> StringContentProvider
}
