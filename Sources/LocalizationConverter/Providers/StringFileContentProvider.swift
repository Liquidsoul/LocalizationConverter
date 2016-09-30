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

protocol FileContentProvider {
    func contents(atPath path: String) -> Data?
}

extension FileManager: FileContentProvider {}

struct StringFileContentProvider: StringContentProvider {
    let filePath: String
    let encoding: String.Encoding
    let provider: FileContentProvider

    init(filePath: String, encoding: String.Encoding = .utf16, provider: FileContentProvider = FileManager()) {
        self.filePath = filePath
        self.encoding = encoding
        self.provider = provider
    }

    func content() throws -> String {
        return try readFile(atPath: filePath, encoding: encoding)
    }

    private func readFile(atPath path: String, encoding: String.Encoding) throws -> String {
        guard let content = provider.contents(atPath: path) else {
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
