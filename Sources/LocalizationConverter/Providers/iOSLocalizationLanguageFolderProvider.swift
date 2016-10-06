//
//  iOSLocalizationLanguageFolderProvider.swift
//
//  Created by Sébastien Duperron on 04/10/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

struct iOSLocalizationLanguageFolderProvider {
    fileprivate struct LocalizableFiles {
        let stringsPath: String
        let stringsDictPath: String
    }

    fileprivate typealias Mapping = [Language:LocalizableFiles]

    fileprivate let languageToFilePath: Mapping

    init(folderPath: String, provider: DirectoryContentProvider = FileManager()) throws {
        let staticType = type(of: self)
        let folders = try provider.contentsOfDirectory(atPath: folderPath)
        self.languageToFilePath = staticType.listLanguages(from: folders, at: folderPath)
    }

    private static func listLanguages(from folders: [String], at folderPath: String) -> Mapping {
        let languageToFilePath = folders.reduce(Mapping()) { (values, folderName) in
            guard let language = language(fromFolderName: folderName) else { return values }
            let localizationPath = folderPath.appending(pathComponent: folderName)
            let stringsFilePath = localizationPath.appending(pathComponent: "localizable.strings")
            let stringsDictFilePath = localizationPath.appending(pathComponent: "localizable.stringsDict")
            var output = values
            output[language] = LocalizableFiles(stringsPath: stringsFilePath, stringsDictPath: stringsDictFilePath)
            return output
        }
        return languageToFilePath
    }

    private static func language(fromFolderName folderName: String) -> Language? {
        // let suffix = ".lproj"
        let suffix = "lproj"
        guard folderName.hasSuffix(suffix) else { return nil }
        let languageName = folderName.replacingOccurrences(of: suffix, with: "")
        if languageName == "Base" { return .base }
        return .named(languageName)
    }
}

struct iOSLocalizationFileProvider {
    let stringsPath: String
    let stringsDictPath: String
}

extension iOSLocalizationFileProvider: LocalizationProvider {
    func localization() throws -> LocalizationMap {
        return LocalizationMap(format: .ios)
    }
}

extension iOSLocalizationLanguageFolderProvider: LocalizationLanguageProvider {
    var languages: [Language] {
        return Array(languageToFilePath.keys)
    }

    func contentProvider(for language: Language) -> LocalizationProvider {
        guard let localizableFiles = languageToFilePath[language] else {
            fatalError()
        }
        return iOSLocalizationFileProvider(stringsPath: localizableFiles.stringsPath, stringsDictPath: localizableFiles.stringsDictPath)
    }
}
