//
//  AndroidStringsParser.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class AndroidStringsParser: StringParser {

    private class ParseStack {
        private var stack: [String] = []
        private let keyName: String
        private let formatElements: [String] = ["b", "u", "i"]

        init(keyName: String) {
            self.keyName = keyName
        }

        func append(characters string: String) {
            stack.append(string)
        }

        func start(element element: String, attributes attributeDict: [String : String]) {
            if formatElements.contains(element) {
                stack.append("<\(element)>")
            }
        }

        func end(element element: String) {
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

    private class StringParseStack: ParseStack {
        override func result() -> (String, LocalizationItem) {
            guard !stack.isEmpty else {
                fatalError("Stack should not be empty when parsing 'string' element.")
            }
            let value = stack.reduce("", combine: { $0 + $1 })
            return (keyName, .string(value: value))
        }
    }

    private class PluralsParseStack: ParseStack {
        private let itemTerminator = "itemTerminator"
        private var inItem: Bool = false

        override func start(element element: String, attributes attributeDict: [String : String]) {
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

        override func end(element element: String) {
            if element == "item" {
                stack.append(itemTerminator)
                inItem = false
            } else {
                super.end(element: element)
            }
        }

        override func result() -> (String, LocalizationItem) {
            var pluralLocalizations = [PluralType:String]()
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

    private class XMLDelegate: NSObject, NSXMLParserDelegate {

        var localizations = [String:LocalizationItem]()

        var parseStackItem: ParseStack?

        @objc
        func parserDidStartDocument(parser: NSXMLParser) {
            localizations = [String:LocalizationItem]()
        }

        @objc
        func parser(parser: NSXMLParser,
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
        func parser(parser: NSXMLParser, foundCharacters string: String) {
            parseStackItem?.append(characters: string)
        }

        @objc
        func parser(parser: NSXMLParser,
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
                print("Warning: unexpected end of element \(elementName)")
                break
            }
            parseStackItem?.end(element: elementName)
        }
    }

    private let parserDelegate = XMLDelegate()

    func parse(string string: String) -> LocalizationMap {
        let parser = NSXMLParser(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
        parser.delegate = parserDelegate

        _ = parser.parse()

        return LocalizationMap(type: .android, localizationsDictionary: parserDelegate.localizations)
    }
}
