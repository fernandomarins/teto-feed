//
//  Post.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 14/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import UIKit
import Firebase

struct Post {
    let name: String?
    let profileImageName: String?
    let statusText: String?
    let statusImageName: String?
    
    init(data: NSDictionary) {
        name = data["name"] as? String
        profileImageName = data["profileImageName"] as? String
        statusText = data["statusText"] as? String
        statusImageName = data["statusImageName"] as? String
    }
}
