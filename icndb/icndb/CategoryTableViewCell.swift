//
//  CategoryTableViewCell.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var enableSwitch: UISwitch!
    var handleToggle: (() -> ())?
    
    func bind(item: CategoryRealm)
    {
        
        nameLabel!.text = item.category
        
        if item.enabled == true {
            enableSwitch.on = true
        } else {
            enableSwitch.on = false
        }
    }

    @IBAction func enableSwitchToggle(sender: AnyObject) {
        handleToggle?()
    }
}
