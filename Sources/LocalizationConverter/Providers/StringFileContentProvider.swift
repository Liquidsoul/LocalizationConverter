//
//  StringFileContentProvider.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

protocol StringContentProvider {
    func content() throws -> String
}

import Foundation

struct StringFileContentProvider: StringContentProvider {
    let filePath: String
    let encoding: String.Encoding

    init(filePath: String, encoding: String.Encoding = .utf16) {
        self.filePath = filePath
        self.encoding = encoding
    }

    func content() throws -> String {
        return try readFile(atPath: filePath, encoding: encoding)
    }

    private func readFile(atPath path: String, encoding: String.Encoding) throws -> String {
        let fileManager = FileManager()
        guard let content = fileManager.contents(atPath: path) else {
            throw Error.fileNotFound(path: path)
        }
        guard let contentAsString = String(data: content, encoding: encoding) else {
            throw Error.invalidFileContent(path: path, data: content)
        }
        return contentAsString
    }

    enum Error: Swift.Error {
        case fileNotFound(path: String)
        case invalidFileContent(path: String, data: Data)
    }
}