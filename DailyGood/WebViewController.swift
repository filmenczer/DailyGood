//
//  WebViewController.swift
//  DailyGood
//
//  Created by Filippo Menczer on 3/3/15.
//  Copyright (c) 2015 kelly. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var url: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = NSURLRequest(URL: NSURL(string: url)!)
        webView.loadRequest(request)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackBtn(sender: AnyObject) {
        navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func onForward(sender: AnyObject) {
        webView.goForward()
    }
    @IBAction func onBack(sender: AnyObject) {
        webView.goBack()
    }
    @IBAction func onReload(sender: AnyObject) {
        webView.reload()
    }
    @IBAction func onStop(sender: AnyObject) {
        webView.stopLoading()
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
