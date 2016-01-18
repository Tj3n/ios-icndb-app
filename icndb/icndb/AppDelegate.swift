//
//  AppDelegate.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Check for ios9
    enum FetchState: Int {
        case NotFetching = 1
        case DidFetch = 2
        
//        init() {
//            self = .NotFetching
//        }
        
        var description : Int {
            get {
                return self.rawValue
            }
        }
    }
    
    private(set) var fetch: FetchState = .NotFetching


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UINavigationBar.appearance().barTintColor = UIColor ( red: 0.0762, green: 0.6204, blue: 0.9986, alpha: 1.0 )
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound,.Alert,.Badge], categories: nil))
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(notification.alertBody)
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
    }
    
    //Test background fetch
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        //iOS 9 called twice, need check
        if fetch == .NotFetching {
            fetch = .DidFetch
            
            let fetchStart = NSDate()
            let navigation = self.window?.rootViewController as! UINavigationController
            let vc = navigation.topViewController as! JokeViewController
            
            vc.getJoke(Person.sharedPerson) { [weak self](result, joke) -> Void in
                let localNotification:UILocalNotification = UILocalNotification()
                localNotification.alertAction = "See in app"
                localNotification.alertBody = joke
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
                
                print(UIApplication.sharedApplication().applicationIconBadgeNumber)
                
                var currentBadgeNum = UIApplication.sharedApplication().applicationIconBadgeNumber
                currentBadgeNum++
                
                localNotification.applicationIconBadgeNumber = currentBadgeNum
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                
                completionHandler(result)
                self?.fetch = .NotFetching
                
                let fetchEnd = NSDate()
                print("Background Fetch Duration:\(fetchEnd.timeIntervalSinceDate(fetchStart)) seconds")
            }
        } else {
            completionHandler(.NoData)
        }
    }
}

