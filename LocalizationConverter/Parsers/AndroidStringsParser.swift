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

            if elementName == "resources" {
                if inResourcesElement {
                    fatalError("Nested '\(elementName)' elements. There should only be one as the root element.")
                }
                inResourcesElement = true
                return
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

            let waitingForValue = elementStack.last.map({ ["string", "item"].contains($0) }) ?? false
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
                guard parseStack.count >= 2 else {
                    fatalError("Invalid number of elements in stack \(parseStack)")
                }
                let key = parseStack.removeFirst()
                let value = parseStack.reduce("", combine: { $0 + $1 })
                localizations[key] = .string(value: value)
                parseStack.removeAll()
            case "item":
                parseStack.append(itemTerminator)
                break
            case "plurals":
                assert(!parseStack.isEmpty, "Parse stack was found empty once done parsing element \(elementName)!")
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

                localizations[key] = .plurals(values: pluralLocalizations)

                parseStack.removeAll()
                break
            default:
                print("Warning: unexpected end of element \(elementName). Flushing the parse stack...")
                parseStack.removeAll()
                break
            }
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
