//
//  LocalizationStore.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

protocol LocalizationStore {
    func store(localization: LocalizationMap) throws
}
