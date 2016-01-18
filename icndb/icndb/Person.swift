//
//  Person.swift
//  icndb
//
//  Created by Tien Nhat Vu on 1/14/16.
//  Copyright © 2016 Fun. All rights reserved.
//

import UIKit

class Person: NSObject {
    
    static let sharedPerson = Person()
    
    var firstName: String {
        set {
            if newValue.characters.count > 0 {
                NSUserDefaults.standardUserDefaults().setValue(newValue.firstCharacterUpperCase(), forKey: "firstName")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("firstName")
            }
        }
        
        get {
            if let string = NSUserDefaults.standardUserDefaults().valueForKey("firstName") as? String {
                return string
            } else {
                return ""
            }
        }
    }
    
    var lastName: String {
        set {
            if newValue.characters.count > 0 {
                NSUserDefaults.standardUserDefaults().setValue(newValue.firstCharacterUpperCase(), forKey: "lastName")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("lastName")
            }
        }
        
        get {
            if let string = NSUserDefaults.standardUserDefaults().valueForKey("lastName") as? String {
                return string
            } else {
                return ""
            }
        }
    }

}
