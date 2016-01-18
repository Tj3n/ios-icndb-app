//
//  Categories.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class CategoryRealm: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    dynamic var category = ""
    dynamic var enabled = true
    
    class func allCategory() -> Results<CategoryRealm> {
        return try! Realm().objects(CategoryRealm)
    }
    
    class func mapCategory(response: NSData) -> Bool  {
        
        let json = JSON(data: response)
        
        print("category\(json)")
        
        if let type = json["type"].string {
            if type == "success" {
                let realm = try! Realm() // Create realm pointing to default file
                realm.beginWrite()
                realm.delete(realm.objects(CategoryRealm))
                let obj = CategoryRealm()
                obj.category = "Other"
                realm.add(obj)
                try! realm.commitWrite()
                if let categoryArray:[String] = json["value"].arrayObject as? [String] {
                    for value in categoryArray {
                        let categoryRealm = CategoryRealm()
                        categoryRealm.category = value.firstCharacterUpperCase()
                        
                        realm.beginWrite()
                        realm.add(categoryRealm)
                        try! realm.commitWrite()
                    }
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
}