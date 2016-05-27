//
//  AndroidStringsParser.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class AndroidStringsParser: StringParser {

    class XMLDelegate: NSObject, NSXMLParserDelegate {

        var inResourcesElement: Bool = false
        var localizations = [String:LocalizationItem]()
        var parseStack = [String]()
        var elementStack = [String]()

        let itemTerminator = "itemTerminator"

        func parserDidStartDocument(parser: NSXMLParser) {
            localizations = [String:LocalizationItem]()
        }

        func parser(parser: NSXMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String : String]) {
            elementStack.append(elementName)

            switch elementName {
            case "b": fallthrough
            case "u": fallthrough
            case "i":
                parseStack.append("<\(elementName)>")
                return
            case "resources":
                if inResourcesElement {
                    fatalError("Nested '\(elementName)' elements. There should only be one as the root element.")
                }
                inResourcesElement = true
                return
            default:
                break
            }

            if !inResourcesElement {
                return
            }

            if let nameAttribute = attributeDict["name"] {
                parseStack.append(nameAttribute)
            } else if let quantityAttribute = attributeDict["quantity"] {
                parseStack.append(quantityAttribute)
            }
        }

        func parser(parser: NSXMLParser, foundCharacters string: String) {
            if !inResourcesElement {
                return
            }

            let waitingForValue = elementStack.last.map({ ["string", "item", "b", "u", "i"].contains($0) }) ?? false
            if !waitingForValue {
                // ignore characters found when not searching for a value
                return
            }

            parseStack.append(string)
        }

        func parser(parser: NSXMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {
            elementStack.removeLast()

            if elementName == "resources" {
                assert(inResourcesElement, "End of element \(elementName) which did not start!")
                inResourcesElement = false
                parseStack.removeAll()
                return
            }

            switch elementName {
            case "string":
                extractAndStoreStringFromParseStack()
            case "item":
                parseStack.append(itemTerminator)
                break
            case "plurals":
                extractAndStorePluralsFromParseStack()
                break
            case "b": fallthrough
            case "i": fallthrough
            case "u":
                parseStack.append("</\(elementName)>")
            case "br":
                parseStack.append("<br />")
            default:
                print("Warning: unexpected end of element \(elementName). Flushing the parse stack...")
                parseStack.removeAll()
                break
            }
        }

        func extractAndStoreStringFromParseStack() {
            let (key, value) = extractStringPairFromParseStack()
            localizations[key] = value
            parseStack.removeAll()
        }

        func extractStringPairFromParseStack() -> (String, LocalizationItem) {
            guard parseStack.count >= 2 else {
                fatalError("Invalid number of elements in stack \(parseStack) for 'string' element.")
            }
            let key = parseStack.removeFirst()
            let value = parseStack.reduce("", combine: { $0 + $1 })
            return (key, .string(value: value))
        }

        func extractAndStorePluralsFromParseStack() {
            let (key, value) = extractPluralsPairFromParseStack()
            localizations[key] = value
            parseStack.removeAll()
        }

        func extractPluralsPairFromParseStack() -> (String, LocalizationItem) {
            guard !parseStack.isEmpty else {
                fatalError("Parse stack was found empty once done parsing 'plurals' element.!")
            }
            let key = parseStack.removeFirst()

            var pluralLocalizations = [PluralType:String]()
            while !parseStack.isEmpty {
                let pluralTypeString = parseStack.removeFirst()
                guard let pluralType = PluralType(rawValue: pluralTypeString) else {
                    fatalError("Unknown pluralType \(pluralTypeString)")
                }

                var localizationValue = parseStack.removeFirst()
                guard localizationValue != itemTerminator else {
                    fatalError("Empty item content for key \(key)")
                }
                var localizationValueComponent = parseStack.removeFirst()
                while localizationValueComponent != itemTerminator {
                    localizationValue += localizationValueComponent
                    localizationValueComponent = parseStack.removeFirst()
                }

                pluralLocalizations[pluralType] = localizationValue
            }

            return (key, .plurals(values: pluralLocalizations))
        }
    }

    let parserDelegate = XMLDelegate()

    func parse(string string: String) -> LocalizationMap {
        let parser = NSXMLParser(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
        parser.delegate = parserDelegate

        _ = parser.parse()

        return LocalizationMap(type: .android, localizationsDictionary: parserDelegate.localizations)
    }
}
