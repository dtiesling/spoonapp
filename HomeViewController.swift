//
//  HomeViewController.swift
//  Resty
//
//  Created by Daniel Tiesling on 6/14/14.
//  Copyright (c) 2014 Daniel Tiesling. All rights reserved.
//

import UIKit
import CoreMotion


class HomeViewController: UIViewController {

    @IBOutlet var stepLabel : UILabel!
    @IBOutlet var homeView : UIView!
    @IBOutlet var countLabel : UILabel!
    @IBOutlet var fromLabel : UILabel!
    @IBOutlet var toLabel : UILabel!
    @IBOutlet var stepLimitLabel : UILabel!
    @IBOutlet weak var spoonStepper: UIStepper!
    @IBOutlet var stepsTakenLabel : UILabel!
    @IBOutlet var progress : UIProgressView!
    @IBOutlet var sleepSwitch : UISwitch!
    @IBOutlet var napLabel: UILabel!
    @IBOutlet var toolBar : UIToolbar!
    @IBOutlet var sleepPointLabel : UILabel!
    @IBOutlet var sleepPoints : UILabel!
    @IBOutlet var sleepSpinner : UIActivityIndicatorView!
    var stepTimer: NSTimer? = nil
    var sleepTimer: NSTimer? = nil
    var defaults = NSUserDefaults.standardUserDefaults()
    let napInterval : Double = 300
    var notificationPercentage : CFloat = 0
    var spoonRatio = 100
    
    @IBAction func sleepSwitchChanged() {
        if self.sleepSwitch.on {
            self.sleepPoints.text = "0"
            self.sleepPointLabel.hidden = false
            self.sleepSpinner.hidden = false
            self.sleepPoints.hidden = false
            self.sleepTimer = startNapTimer()
        }
        else {
            self.sleepPointLabel.hidden = true
            self.sleepSpinner.hidden = true
            self.sleepPoints.hidden = true
            self.sleepTimer!.invalidate()
        }
    }

    @IBAction func stepperChanged(sender : UIStepper) {
        self.stepLimitLabel.text = String(self.spoonStepper.value.description)
        self.defaults.setDouble(self.spoonStepper.value, forKey: "spoonLimit")
        updateSteps()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide sleep switch until next release.
        //updateNapLabel()
        self.sleepSwitch.hidden = true
        self.sleepPoints.hidden = true
        self.napLabel.hidden = true
        //self.sleepPoints.text = "0"
        
        var spoonLimit = self.defaults.doubleForKey("spoonLimit")
        if spoonLimit > 0 {
            self.spoonStepper.value = spoonLimit
        }
        else {
            self.spoonStepper.value = 70
        }
        self.stepLimitLabel.text = String(self.spoonStepper.value.description)
        updateSteps()
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startTimer () {
        self.stepTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateSteps"), userInfo: nil,repeats: true)
    }
    
    func startNapTimer () -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(self.napInterval, target: self, selector: Selector("updateNap"), userInfo: nil, repeats: true)
    }
    
    func updateSteps () {
        var from = today()
        var to = NSDate()
        self.fromLabel.text = from.descriptionWithLocale(NSLocale.currentLocale())
        self.toLabel.text = to.descriptionWithLocale(NSLocale.currentLocale())
        var counter = CMStepCounter()
        counter.queryStepCountStartingFrom(from, to:to, toQueue:NSOperationQueue.currentQueue(), withHandler:stepHandler)
    }
    
    func updateNap () {
        var from = NSDate(timeIntervalSinceNow:-self.napInterval)
        var to = NSDate()
        NSLog(from.description)
        NSLog(to.description)
        var motionMan = CMMotionActivityManager()
        motionMan.queryActivityStartingFromDate(from, toDate:to, toQueue:NSOperationQueue.currentQueue(), withHandler:napHandler)
    }
    
    func stepHandler (steps: Int, error: NSError!) -> Void {
        self.stepsTakenLabel.text = String(steps/spoonRatio)
        var total: Int = Int(self.spoonStepper.value)*spoonRatio + self.getNapPoints()
        var percentage: CFloat = Float(steps)/Float(total)
        if percentage > 0.9 {
            self.sendNotificaton(percentage)
            self.progress.trackTintColor = UIColor.redColor()
        }
        else if percentage > 0.7 {
            self.sendNotificaton(percentage)
            self.progress.trackTintColor = UIColor.orangeColor()
        }
        else if percentage > 0.5 {
            self.sendNotificaton(percentage)
            self.progress.trackTintColor = UIColor.yellowColor()
        }
        else {
            self.progress.trackTintColor = UIColor.greenColor()
        }
        self.progress.setProgress(percentage, animated:true)
        self.stepLabel.text = String((Int(total) - steps)/spoonRatio)
    }
    
    func napHandler (activities:[AnyObject]!, error:NSError!) {
        for activity : AnyObject in  activities {
            if !activity.stationary  {
                NSLog(activity.description)
                return
            }
        }
        var curNapPoints = self.sleepPoints.text!.toInt()
        self.sleepPoints.text = String(curNapPoints! + 1)
        self.addNapPoints(1)
        self.updateNapLabel()
    }
    
    func getNapKey () -> String {
        // Returns the key for the defaults dict that stores today's nap  points.
        return today().descriptionWithLocale(NSLocale.currentLocale())! + "_nap"
    }
    
    func getNapPoints () -> Int {
        // Retrieves today's nap points.
        let key = self.getNapKey()
        return self.defaults.integerForKey(key)
    }
    
    func addNapPoints (points: Int) -> Void {
        // Adds to today's nap points.
        let key = self.getNapKey()
        var total = self.getNapPoints() + points
        self.defaults.setInteger(total, forKey:key)
    }
    
    func updateNapLabel () {
        self.napLabel.text = String(self.getNapPoints())
    }
    
    func sendNotificaton(percentage: CFloat) {
        NSLog("sending note")
//        if self.notificationPercentage < percentage {
            var note = UILocalNotification()
            note.alertBody = "Slow down. You only have " + self.stepLabel.text! + " steps left."
            let app = UIApplication.sharedApplication()
             self.notificationPercentage = percentage
//        }
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
