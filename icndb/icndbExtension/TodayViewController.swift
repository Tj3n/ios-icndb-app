//
//  TodayViewController.swift
//  icndbExtension
//
//  Created by Tien Nhat Vu on 1/15/16.
//  Copyright © 2016 Fun. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet var jokeLabel: UILabel!
    @IBOutlet var openAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let jokeStore = NSUserDefaults.init(suiteName: "group.com.fun.app.icndbTest") //use to share data to today extension widget ,Need to config provisioning and App Group
        guard let jokeString = jokeStore?.valueForKey("jokeString") as? String else {
            jokeLabel.text = "Failed to get"
            return
        }
        jokeLabel.text = jokeString
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let jokeStore = NSUserDefaults.init(suiteName: "group.com.fun.app.icndbTest") //use to share data to today extension widget ,Need to config provisioning and App Group
        guard let jokeString = jokeStore?.valueForKey("jokeString") as? String else {
            jokeLabel.text = "Failed to get"
            return
        }
        jokeLabel.text = jokeString
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let jokeStore = NSUserDefaults.init(suiteName: "group.com.fun.app.icndbTest") //use to share data to today extension widget ,Need to config provisioning and App Group
        guard let jokeString = jokeStore?.valueForKey("jokeString") as? String else {
            jokeLabel.text = "Failed to get"
            return
        }
        jokeLabel.text = jokeString
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    //margin for Large phone
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    @IBAction func openAppButtonPressed(sender: AnyObject) {
        let appURL = NSURL(string: "RandomJoke://") //SEt custom url in Info -> URL types
        extensionContext?.openURL(appURL!, completionHandler: nil)
    }

    
}
