//
//  AndroidStringsParser.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class AndroidStringsParser: LocalizationParser {

    func parse(string: String) throws -> LocalizationMap {
        let parser = XMLParser(data: string.data(using: String.Encoding.utf8)!)
        parser.delegate = parserDelegate

        let success = parser.parse()

        if !success {
            throw delegateError()
        }

        return LocalizationMap(format: .android, localizationsDictionary: parserDelegate.localizations)
    }

    fileprivate let parserDelegate = XMLDelegate() // swiftlint:disable:this weak_delegate
}

fileprivate extension AndroidStringsParser {
    func delegateError() -> Error {
        return parserDelegate.lastError ?? NSError(domain: "\(type(of: self))",
                                                   code: 404,
                                                   userInfo: [NSLocalizedFailureReasonErrorKey: "No error found"])

    }
}

fileprivate extension AndroidStringsParser {

    fileprivate class XMLDelegate: NSObject, XMLParserDelegate {

        var localizations = [String: LocalizationItem]()

        var parseStackItem: ParseStack?

        var lastError: NSError?

        @objc
        func parserDidStartDocument(_ parser: XMLParser) {
            localizations = [String: LocalizationItem]()
        }

        @objc
        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String : String]) {
            parseStackItem?.start(element: elementName, attributes: attributeDict)

            switch elementName {
            case "string":
                if let nameAttribute = attributeDict["name"] {
                    parseStackItem = StringParseStack(keyName: nameAttribute)
                }
            case "plurals":
                if let nameAttribute = attributeDict["name"] {
                    parseStackItem = PluralsParseStack(keyName: nameAttribute)
                }
            default:
                break
            }
        }

        @objc
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            parseStackItem?.append(characters: string)
        }

        @objc
        func parser(_ parser: XMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {
            switch elementName {
            case "string": fallthrough
            case "plurals":
                if let (key, value) = parseStackItem?.result() {
                    localizations[key] = value
                }
                parseStackItem = nil
                break
            default:
                break
            }
            parseStackItem?.end(element: elementName)
        }

        @objc
        fileprivate func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
            lastError = validationError as NSError?
        }

        @objc
        fileprivate func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            lastError = parseError as NSError?
        }
    }

    fileprivate class ParseStack {
        fileprivate var stack: [String] = []
        fileprivate let keyName: String
        fileprivate let formatElements: [String] = ["b", "u", "i"]

        init(keyName: String) {
            self.keyName = keyName
        }

        func append(characters string: String) {
            stack.append(string)
        }

        func start(element: String, attributes attributeDict: [String : String]) {
            if formatElements.contains(element) {
                stack.append("<\(element)>")
            }
        }

        func end(element: String) {
            if formatElements.contains(element) {
                stack.append("</\(element)>")
            } else if element == "br" {
                stack.append("<br />")
            }
        }

        func result() -> (String, LocalizationItem) {
            fatalError("Must be implemented by subclasses")
        }
    }

    fileprivate class StringParseStack: ParseStack {
        override func result() -> (String, LocalizationItem) {
            guard !stack.isEmpty else {
                fatalError("Stack should not be empty when parsing 'string' element.")
            }
            let value = stack.reduce("", { $0 + $1 })
            return (keyName, .string(value: value))
        }
    }

    fileprivate class PluralsParseStack: ParseStack {
        fileprivate let itemTerminator = "itemTerminator"
        fileprivate var inItem: Bool = false

        override func start(element: String, attributes attributeDict: [String : String]) {
            if element == "item" {
                inItem = true
                guard let quantityName = attributeDict["quantity"] else {
                    fatalError("Missing quantity attribute in item element.")
                }
                stack.append(quantityName)
            } else {
                super.start(element: element, attributes: attributeDict)
            }
        }

        override func append(characters string: String) {
            if !inItem {
                return
            }
            super.append(characters: string)
        }

        override func end(element: String) {
            if element == "item" {
                stack.append(itemTerminator)
                inItem = false
            } else {
                super.end(element: element)
            }
        }

        override func result() -> (String, LocalizationItem) {
            var pluralLocalizations = [PluralType: String]()
            while !stack.isEmpty {
                let pluralTypeString = stack.removeFirst()
                guard let pluralType = PluralType(rawValue: pluralTypeString) else {
                    fatalError("Unknown pluralType \(pluralTypeString)")
                }

                var localizationValue = stack.removeFirst()
                guard localizationValue != itemTerminator else {
                    fatalError("Empty item content for key \(keyName)")
                }
                var localizationValueComponent = stack.removeFirst()
                while localizationValueComponent != itemTerminator {
                    localizationValue += localizationValueComponent
                    localizationValueComponent = stack.removeFirst()
                }

                pluralLocalizations[pluralType] = localizationValue
            }

            return (keyName, .plurals(values: pluralLocalizations))
        }
    }
}
