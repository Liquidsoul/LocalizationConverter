//
//  String+Path.swift
//  MobileLocalizationConverter
//
//  Created by Sébastien Duperron on 23/05/2016.
//  Copyright © 2016 Sébastien Duperron. All rights reserved.
//

import Foundation

extension String {
    func appending(pathComponent component: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(component)
    }
}
