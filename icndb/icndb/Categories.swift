//
//  Categories.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class CategoryRealm: Object, Mappable {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    dynamic var category = ""
    dynamic var enabled = true
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        category <- map["value"]
    }
}