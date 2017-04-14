//
//  Posts.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 14/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import Foundation

struct Posts {
    var posts = [Post]()
    
    static let sharedInstance = Posts()
}
