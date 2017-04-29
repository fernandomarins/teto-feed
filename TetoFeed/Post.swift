//
//  Post.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 14/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    let statusText: String?
    let statusImageName: String?
    
    init(data: NSDictionary) {
        statusText = data["statusText"] as? String
        statusImageName = data["statusImageName"] as? String
    }
}
