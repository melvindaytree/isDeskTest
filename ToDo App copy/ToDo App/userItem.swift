//
//  userItem.swift
//  ToDo App
//
//  Created by Daytree, Melvin (Synchrony) on 12/2/18.
//  Copyright © 2018 Echessa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class userItem {
    var ref: DatabaseReference?
    var seat: String?
    var streak: String?
    
    init (snapshot: DataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, String>
        seat = data["seat"]! as String
        streak = data["streak"]! as String
    }

}
