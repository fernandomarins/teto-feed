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
    
    // Send image with base64
    let familyName: String?
    let familyText: String?
    let familyImage: String?
    
    init(data: NSDictionary) {
        familyName = data["familyName"] as? String
        familyText = data["familyText"] as? String
        familyImage = data["familyImage"] as? String
    }
}
