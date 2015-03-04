//
//  ProfileViewController.swift
//  DailyGood
//
//  Created by Kelly Xu on 2/16/15.
//  Copyright (c) 2015 kelly. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var jobView: UIView!
    
    @IBOutlet weak var demographicView: UIView!
    
    @IBOutlet weak var historyView: UIView!
    
    @IBOutlet weak var closeBtn_job: UIButton!
    @IBOutlet weak var closeBtn_demographic: UIButton!
    @IBOutlet weak var closeBtn_history: UIButton!
    
    @IBOutlet weak var btn_open_job: UIButton!
    @IBOutlet weak var btn_open_demographics: UIButton!
    @IBOutlet weak var btn_open_history: UIButton!
    
    var profileTag: String = "Environment"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.contentSize = CGSize(width: 320, height: 811)
        self.closeBtn_job.alpha = 0
        self.closeBtn_demographic.alpha = 0
        self.closeBtn_history.alpha = 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    // (This is not a good way, trying wih unwide segue...)
    //    @IBAction func onTapBackBtn(sender: AnyObject) {
    //        var navigationController = self.presentingViewController as UINavigationController
    //        var feedVC = navigationController.topViewController as FeedViewController
    //        feedVC.categoryTag = self.profileTag
    //        dismissViewControllerAnimated(true, completion: nil)
    //    }

    @IBAction func onTapJobView(sender: AnyObject) {
        self.btn_open_job.enabled = false
        UIView .animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.closeBtn_job.alpha = 1
            
            self.jobView.center.y -= 230
            self.demographicView.alpha = 0
            self.historyView.alpha = 0
        }, completion:nil)
    }
    
    @IBAction func onTapDemographicView(sender: AnyObject) {
        self.btn_open_demographics.enabled = false
        UIView .animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.closeBtn_demographic.alpha = 1
            
            self.demographicView.center.y -= 290
            self.jobView.alpha = 0
            self.historyView.alpha = 0
            }, completion:nil)

    }
    
    @IBAction func onTapHistoryView(sender: AnyObject) {
        self.btn_open_history.enabled = false
        UIView .animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.closeBtn_history.alpha = 1
            
            self.historyView.center.y -= 360
            self.jobView.alpha = 0
            self.demographicView.alpha = 0
            }, completion:nil)
    }
    
    
    @IBAction func onTapCloseBtn(sender: AnyObject) {
        UIView .animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.jobView.frame.origin.y = self.view.frame.size.height - 188
            self.demographicView.frame.origin.y = self.view.frame.size.height - 125
            self.historyView.frame.origin.y = self.view.frame.size.height - 57
            
            self.jobView.alpha = 1
            self.demographicView.alpha = 1
            self.historyView.alpha = 1
            self.resetCloseBtnState()
            self.resetOpenBtns()
            
        }, completion: nil)
    }
    
    func resetCloseBtnState(){
        self.closeBtn_job.alpha = 0
        self.closeBtn_demographic.alpha = 0
        self.closeBtn_history.alpha = 0
    }
    
    func resetOpenBtns(){
        self.btn_open_job.enabled = true
        self.btn_open_demographics.enabled = true
        self.btn_open_history.enabled = true
    }
    
    @IBAction func onTagChoice(sender: UIButton) {
        if let tag = sender.titleLabel?.text {
            profileTag = tag
            if let s = sender.superview {
                let bs: [UIButton] = s.subviews as [UIButton]
                for b in bs {
                    b.enabled = true
                }
            }
            sender.enabled = false
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
