//
//  JokeViewController.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation

let realm = try! Realm()

class JokeViewController: UIViewController {
    
    enum Case {
        case All
        case Limit
        case Exclude
        case None
    }
    private(set) var jokeCase: Case = .All
    
    @IBOutlet var firstNameTextField: UITextField! {
        didSet {
            firstNameTextField.delegate = self
            firstNameTextField.text = Person.sharedPerson.firstName
        }
    }
    @IBOutlet var lastNameTextField: UITextField!{
        didSet {
            lastNameTextField.delegate = self
            lastNameTextField.text = Person.sharedPerson.lastName
        }
    }
    @IBOutlet var jokeLabel: UILabel! {
        didSet {
        }
    }
    @IBOutlet var generateButton: UIButton!
    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var categoryTableHeight: NSLayoutConstraint!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var resetButton: UIBarButtonItem!
    
//    let realm = try! Realm()
    let categoryRealm = try! Realm().objects(CategoryRealm)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.tableFooterView = UIView()
        
        categoryTableView.reloadData()
        let frame = categoryTableView.rectForSection(0) as CGRect!
        categoryTableHeight.constant = frame.size.height >= 140 ? 140 : frame.size.height
        categoryTableView.bounces = frame.size.height >= 140 ? true : false
        view.layoutIfNeeded()
        
        getcategoryRealm()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        jokeLabel.preferredMaxLayoutWidth =  self.view.bounds.size.width
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        jokeLabel.text = "Enter name and press Generate"
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        view.layoutIfNeeded()
    }
    
    @IBAction func generateButtonPressed(sender: AnyObject) {
        jokeLabel.text = ""
        loadingIndicator.startAnimating()
        
        Person.sharedPerson.firstName = firstNameTextField.text!
        Person.sharedPerson.lastName = lastNameTextField.text!
        
        getJoke(Person.sharedPerson, completionHandler: nil)
    }
    
    func getJoke(person: Person, completionHandler:((UIBackgroundFetchResult, String) -> Void)?) {
        
        let array = generateJokeCase(categoryRealm)
        var arrayLimit = [String]()
        var arrayExclude = [String]()
        var none = false
        
        switch jokeCase {
        case .All:
            break
        case.Exclude:
             arrayExclude = array
             print("Exclude \(arrayExclude)")
            break
        case .Limit:
             arrayLimit = array
             print("Limit \(arrayLimit)")

            break
        case.None:
            none = true
        }
        
        NetworkProvider.request(.Joke(person.firstName, person.lastName, arrayLimit,arrayExclude)) { [weak self] (result) -> () in
            var success = true
            var message = "Unable to fetch from API"
            let messageNone = "No category choosed"
            
            if none == false
            {
                switch result {
                case let .Success(response):
                    do {
                        let json: [String:AnyObject]? = try response.mapJSON() as? [String:AnyObject]
                        
                        if let json = json {
                            if let type = json["type"] as? String {
                                if type == "success" {
                                    print(json)
                                    if let value = json["value"] as? [String:AnyObject] {
                                        if let joke = value["joke"] as? String  {
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self?.loadingIndicator.stopAnimating()
                                                let jokeString = String(htmlEncodedString: joke)
                                                self?.jokeLabel.text = jokeString
                                                let jokeStore = NSUserDefaults.init(suiteName: "group.com.fun.app.icndbTest") //use to share data to today extension widget
                                                jokeStore?.setValue(jokeString, forKey: "jokeString")
                                                completionHandler?(.NewData, jokeString)
                                            })
                                        }
                                    }
                                } else {
                                    success = false
                                }
                            }
                        } else {
                            success = false
                        }
                    } catch {
                        success = false
                    }
                    
                case let .Failure(error):
                    guard let error = error as? CustomStringConvertible else {
                        break
                    }
                    message = error.description
                    print(error.description)
                    success = false
                }
            } else {
                success = false
            }
            
            if !success {
                completionHandler?(.Failed, "Failed to fetch")
                
                let alertController = UIAlertController(title: "Category Fetch", message: none == false ? message : messageNone, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                })
                alertController.addAction(ok)
                self?.presentViewController(alertController, animated: true, completion: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.loadingIndicator.stopAnimating()
                    //Press barbutton
                    UIApplication.sharedApplication().sendAction((self?.resetButton.action)!, to: self?.resetButton.target, from: self, forEvent: nil)
                })
            }
        }
    }
    
    private func generateJokeCase(category: Results<CategoryRealm>) -> [String] {
        var array = [String]()
        var allFalse = true
        jokeCase = .All
        
        for obj: CategoryRealm in category {
            
            
            if obj.category != "Other" && obj.enabled == false && jokeCase != .Limit {
                jokeCase = .Exclude
            }
            
            if obj.category == "Other" && obj.enabled == false {
                jokeCase = .Limit
            }
            
            if obj.enabled == true || allFalse == false {
                allFalse = false
                if obj.category != "Other" && obj.enabled == false && jokeCase == .Exclude {
                    array.append(obj.category.lowercaseString)
                } else if obj.category != "Other" && obj.enabled == true && jokeCase == .Limit {
                    array.append(obj.category.lowercaseString)
                }
            }
        }
        
        if allFalse == true {
            jokeCase = .None
        }
        return array
    }
    
    private func getcategoryRealm() {
        NetworkProvider.request(.Category, completion: {[weak self] result in
            
            var success = true
            var message = "Unable to fetch from API"
            

            switch result {
            case let .Success(response):
//                do {
                
                    success = CategoryRealm.mapCategory(response.data)
                    
//                    let json: [String:AnyObject]? = try response.mapJSON() as? [String:AnyObject]
//                    
//                    if let json = json {
//                        if let type = json["type"] as? String {
//                            if type == "success" {
//                                if let valueArray = json["value"] as? [String] {
//                                    // Realms are used to group data together
//                                    let realm = try! Realm() // Create realm pointing to default file
//                                    realm.beginWrite()
//                                    realm.delete(realm.objects(CategoryRealm))
//                                    let obj = CategoryRealm()
//                                    obj.category = "Other"
//                                    realm.add(obj)
//                                    
//                                    try! realm.commitWrite()
//                                    
//                                    for value in valueArray {
//                                    
//                                        //Realm Test
//                                        let categoryRealm = CategoryRealm()
//                                        categoryRealm.category = value.firstCharacterUpperCase()
//
//                                        // Save your object
//                                        realm.beginWrite()
//                                        realm.add(categoryRealm)
//                                        try! realm.commitWrite()
//                                    }
//                                }
//                            } else {
//                                success = false
//                            }
//                        }
//                    } else {
//                        success = false
//                    }
//                } catch {
//                    success = false
//                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self?.categoryTableView.reloadData()
                    let frame = self?.categoryTableView.rectForSection(0) as CGRect!
                    self?.categoryTableHeight.constant = frame.size.height >= 150 ? 150 : frame.size.height
                    self?.categoryTableView.bounces = frame.size.height >= 150 ? true : false
                    self?.view.layoutIfNeeded()
                    
                    
                })
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                print(error.description)
                success = false
            }
            
            if !success {
                let alertController = UIAlertController(title: "Category Fetch", message: message, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                })
                alertController.addAction(ok)
                self?.presentViewController(alertController, animated: true, completion: nil)
            }
        })
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        if !(touch.view is UITextField) {
            view.endEditing(true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension JokeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
//        NSLog(@"row height : %f", frame.size.height);
        
        return categoryRealm.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CategoryTableViewCell
        
        //Realm Test
        cell.bind(categoryRealm[indexPath.row])
        cell.handleToggle = { [weak self] in
            let obj = self?.categoryRealm[indexPath.row]
            realm.beginWrite()
            obj!.enabled = !obj!.enabled
            try! realm.commitWrite()
        }

        
//        cell.bind(categoryRealm[indexPath.row])
//        cell.handleToggle = {
//            let obj = self.categoryRealm[indexPath.row]
//            obj.enabled = !obj.enabled
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        categoryTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension JokeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            lastNameTextField.resignFirstResponder()
            //Press button
            generateButton.sendActionsForControlEvents(.TouchUpInside)
        } else {
            
        }
        return true
    }
}

extension String {
    func firstCharacterUpperCase() -> String {
        let lowercaseString = self.lowercaseString
        
        return lowercaseString.characters.count > 0 ? lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString) : lowercaseString
    }
    
    //Decode html and strip tags
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        let attributedString = try? NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        self.init(attributedString!.string)
    }
}

extension NSLayoutConstraint {
    // For identify breaking constraint with their identifier
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
