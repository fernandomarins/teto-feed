//
//  User.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 02/05/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var email: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.email = dictionary["email"] as? String
    }
}
