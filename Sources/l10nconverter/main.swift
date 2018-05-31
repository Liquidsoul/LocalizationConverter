//
//  main.swift
//
//  Created by Sébastien Duperron on 23/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

let version = "0.1.0"

import Commander
import LocalizationConverter

let outputOption = Option<String>(
  "output", ".", flag: "o",
  description: "The path to the folder where to output the results " +
    "(Omit to generate in current working directory)"
)

let includePluralsFlag = Flag(
  "include-plurals", description: "include plurals keys in the Localizable.strings file."
)

let convertAndroidFileCommand = command(
  outputOption,
  includePluralsFlag,
  Argument<String>("STRINGS_FILE", description: "path to a strings.xml file to parse")
) { (output, includePlurals, inputFile) in
  print(output)
  _ = LocalizationConverter.convert(androidFileName: inputFile,
                                    outputPath: output,
                                    includePlurals: includePlurals)
}

let convertAndroidFolderCommand = command(
  outputOption,
  includePluralsFlag,
  Argument<String>("RES_FOLDER", description: "Android strings res/ folder")
) { (output, includePlurals, inputFolder) in
  _ = LocalizationConverter.convert(androidFolder: inputFolder,
                                    outputPath: output,
                                    includePlurals: includePlurals)
}

let main = Group {
  $0.addCommand("convertAndroidFile",
                "Read a given Android strings.xml file and generate the corresponding " +
                  "Localizable.strings and Localizable.stringsdict files for iOS.",
                convertAndroidFileCommand)
  $0.addCommand("convertAndroidFolder",
                "Convert an Android strings resource folder into an iOS Localization folder.",
                convertAndroidFolderCommand)
}

main.run("l10nconverter v\(version)")
