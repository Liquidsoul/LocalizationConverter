//
//  SingleItemConverter.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct SingleItemConverter {
    let provider: LocalizationProvider
    let store: LocalizationStore

    func execute() throws {
        let localization = try provider.localization()
        try store.store(localization: localization)
    }
}
