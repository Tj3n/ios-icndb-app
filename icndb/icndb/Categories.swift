//
//  Categories.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryRealm: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    dynamic var category = ""
    dynamic var enabled = true
}

class Categories: NSObject {
    var category = ""
    var enabled = true
}
