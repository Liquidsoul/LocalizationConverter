//
//  AndroidLocalizationFileProvider.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct AndroidLocalizationFileProvider: LocalizationProvider {
    private let provider: StringContentProvider
    let filePath: String

    init(filePath path: String) {
        filePath = path
        provider = StringFileContentProvider(filePath: path, encoding: .utf8)
    }

    func localization() throws -> LocalizationMap {
        let androidLocalizationString = try provider.content()
        let localization = try AndroidStringsParser().parse(string: androidLocalizationString)
        return localization
    }
}
