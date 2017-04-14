//
//  Post.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 14/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import UIKit

class Post: SafeJsonObject {
    var name: String?
    var profileImageName: String?
    var statusText: String?
    var statusImageName: String?
}



class SafeJsonObject: NSObject {
    override func setValue(_ value: Any?, forKey key: String) {
        let selectorString = "set\(key.uppercased().characters.first!)\(String(key.characters.dropFirst())):"
        let selector = Selector(selectorString)
        if responds(to: selector) {
            super.setValue(value, forKey: key)
        }
    }
}
