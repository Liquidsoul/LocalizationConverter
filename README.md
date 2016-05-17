# MobileLocalizationConverter

![Build Status](https://travis-ci.org/Liquidsoul/MobileLocalizationConverter.svg?branch=master)
[![codecov](https://codecov.io/gh/Liquidsoul/MobileLocalizationConverter/branch/master/graph/badge.svg)](https://codecov.io/gh/Liquidsoul/MobileLocalizationConverter)

A simple command-line tool to convert Android `strings.xml` files into iOS `Localizable.strings` and `Localizable.stringsdict` files.

## ⚠️ Limitations ⚠️

* Does not support [`String Array`](https://developer.android.com/guide/topics/resources/string-resource.html#StringArray) keys
* Support only one variable for plurals entries. An iOS `stringsdict` file [can support multiple variables](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/StringsdictFileFormat/StringsdictFileFormat.html#//apple_ref/doc/uid/10000171i-CH16-SW3)
* Require to use integer format specifier (`%d`) to format plurals
