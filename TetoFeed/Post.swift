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
    
    let name: String?
    let profileImageName: String?
    let statusText: String?
    let statusImageName: String?
    let ref: FIRDatabaseReference?
    
//    init(name: String, profileImageName: String, statusText: String, statusImageName: String) {
//        self.name = name
//        self.profileImageName = profileImageName
//        self.statusText = statusText
//        self.statusImageName = statusImageName
//        self.ref = nil
//    }
    
//    init(snapshot: FIRDataSnapshot) {
//        let snapshotValue = snapshot.value as? NSDictionary
//        name = snapshotValue?["name"] as? String
//        profileImageName = snapshotValue?["profileImageName"] as? String
//        statusText = snapshotValue?["statusText"] as? String
//        statusImageName = snapshotValue?["statusImageName"] as? String
//        ref = snapshot.ref
//    }
//    
//    func toAnyObject() -> Any {
//        return [
//            "name": name,
//            "profileImageName": profileImageName,
//            "statusText": statusText,
//            "statusImageName": statusImageName
//        ]
//    }
    
}
