//
//  String+Path.swift
//
//  Created by Sébastien Duperron on 23/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

extension String {
    func appending(pathComponent component: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(component)
    }
}
