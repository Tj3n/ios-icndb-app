//
//  TestWebViewController.swift
//  icndb
//
//  Created by Tien Nhat Vu on 1/12/16.
//  Copyright © 2016 Fun. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class TestWebViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, SFSafariViewControllerDelegate {
    
    var webView: WKWebView
    var webViewOld: UIWebView
    
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        self.webViewOld = UIWebView(frame: CGRectZero)
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string:"https://www.google.com")
        let request = NSURLRequest(URL:url!)
        
//        guard #available(iOS 9, *) else {
//            
//            return
//        }
        
//        if #available(iOS 9, *) {
//            let svc = SFSafariViewController(URL: url!)
//            self.presentViewController(svc, animated: true, completion: nil)
//        } else
            if #available(iOS 8, *) {
            view.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
            view.addConstraints([height, width])
            webView.loadRequest(request)
            webView.navigationDelegate = self
        } else {
            view.addSubview(webViewOld)
            webViewOld.translatesAutoresizingMaskIntoConstraints = false
            let height = NSLayoutConstraint(item: webViewOld, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: webViewOld, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
            view.addConstraints([height, width])
            webViewOld.delegate = self
            webViewOld.backgroundColor = UIColor.clearColor()
            webViewOld.loadRequest(request)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start wkweb")
    }
    
    @available(iOS 9, *)
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("start safari")
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
