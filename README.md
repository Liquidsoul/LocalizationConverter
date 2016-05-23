# MobileLocalizationConverter

[![Build Status](https://travis-ci.org/Liquidsoul/MobileLocalizationConverter.svg?branch=master)](https://travis-ci.org/Liquidsoul/MobileLocalizationConverter)
[![codecov](https://codecov.io/gh/Liquidsoul/MobileLocalizationConverter/branch/master/graph/badge.svg)](https://codecov.io/gh/Liquidsoul/MobileLocalizationConverter)

A simple command-line tool to convert Android `strings.xml` files into iOS `Localizable.strings` and `Localizable.stringsdict` files.

## Usage

You need to pass the action to the tool to execute the conversion or get the usage help:

    mobloconv help

You can convert a android strings directory with this command:

    moblocconv convertAndroidFolder android/ --output=ios/

The tool expects the folder to have the following layout:
```
android
├── values
│   └── strings.xml
└── values-fr
    └── strings.xml
```
Which is the standard Android resources layout. See the [Android String Resources documentation](https://developer.android.com/guide/topics/resources/string-resource.html) for more details.

It will output the following folder tree containing iOS localization files:
```
ios
├── Base.lproj
│   ├── Localizable.strings
│   └── Localizable.stringsdict
└── fr.lproj
    ├── Localizable.strings
    └── Localizable.stringsdict
```
The presence of `stringsdict` files will depend on the existance of plurals in your localization. None will be generated if you do not have plurals keys.
You can look at the [Apple documentation](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/LocalizingYourApp/LocalizingYourApp.html#//apple_ref/doc/uid/10000171i-CH5-SW10) for more information on plurals on iOS.

## ⚠️ Limitations ⚠️

* Does not support [`String Array`](https://developer.android.com/guide/topics/resources/string-resource.html#StringArray) keys
* Support only one variable for plurals entries. An iOS `stringsdict` file [can support multiple variables](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/StringsdictFileFormat/StringsdictFileFormat.html#//apple_ref/doc/uid/10000171i-CH16-SW3)
* Require to use integer format specifier (`%d`) to format plurals
