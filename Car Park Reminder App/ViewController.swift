//
//  ViewController.swift
//  Car Park Reminder App
//
//  Created by Jonathan Oakes on 12/07/2018.
//  Copyright © 2018 Jonathan Oakes. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var askRemindingLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myImage: UIImageView!
    let timePicker = UIDatePicker()
    let reminderTimePicker = UIDatePicker()
    
    override func viewDidLoad() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in })
        
        super.viewDidLoad()
        topLabel.isHidden = true
        bottomLabel.isHidden = true
        timeLabel.isHidden = true
        askRemindingLabel.isHidden = true
        datePicker.isHidden = true
        button.isHidden = true
        resetButton.isHidden = true
        imageView.isHidden = true
        createTimePicker()
        
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        createMethodAlert()
    }
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        createResetAlert()
    }
    
    func createAlert(titleText: String, messageText: String)  {
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createResetAlert()  {
        let cancelAlert = UIAlertController(title: "Are You Sure?", message: "Tapping Yes Will Stop This Notification From Happening ( If It's Not Already Happened ) And Reset The Form. This Will Allow You To Create A New Notication For A Different Time.", preferredStyle: .alert)
        cancelAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.timeTextField.isEnabled = true
            self.timeTextField.alpha = 1
            self.timeLabel.isHidden = true
            self.askRemindingLabel.isHidden = true
            self.datePicker.isHidden = true
            self.button.isHidden = true
            self.resetButton.isHidden = true
            self.timeTextField.text = ""
            self.imageView.isHidden = true
            self.myView.isHidden = false
            self.myImage.isHidden = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            var offset = CGPoint(x: -self.scrollView.contentInset.left,
                                 y: -self.scrollView.contentInset.top)
            
            if #available(iOS 11.0, *) {
                offset = CGPoint(x: -self.scrollView.adjustedContentInset.left,
                                 y: -self.scrollView.adjustedContentInset.top)
            }
            
            self.scrollView.setContentOffset(offset, animated: true)
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(cancelAlert, animated: true)
    }
    
    func createMethodAlert()  {
        let alert = UIAlertController(title: "Are You Sure This Is The Time You'd Like To Be Reminded At?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.timeTextField.isEnabled = false
            self.timeTextField.alpha = 0.5
            self.askRemindingLabel.alpha = 0.5
            self.resetButton.isHidden = false
            self.datePicker.isEnabled = false
            self.button.isEnabled = false
            self.button.alpha = 0
            
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.subtitle = "Your Parking Ticket Is Due For Expiry Soon!"
            content.body = "You Asked Me To Remind You At This Time :)"
            content.sound = UNNotificationSound(named: "alarm_beep.wav")
            content.badge = 1
            
            let dateComponent = self.datePicker.calendar.dateComponents([.hour, .minute], from: self.datePicker.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            let notificationReq = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
            UNUserNotificationCenter.current().delegate = self // foreground notification
            
            self.createAlert(titleText: "Your Reminder Has Been Set! :)", messageText: "Tap 'Cancel / Create New' Below If You Wish To Cancel The Notification.\nWhen You've Received Your Notification, Tap 'Cancel / Create New' Again When You're Ready To Set Up A New Reminder. :)")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
            
            self.timeTextField.isEnabled =  true
            self.timeTextField.alpha = 1
            self.askRemindingLabel.alpha = 1
            self.datePicker.isEnabled = true
        }))
        self.present(alert, animated: true)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])  //notifications work in foreground
    }
    
    func createTimePicker()  {
        // create toolbar
        let timeToolbar = UIToolbar()
        timeToolbar.sizeToFit()
        
        // create done button for toolbar
        let timeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action:               #selector(timePickerViewDoneButtonPressed))
        timeToolbar.setItems([timeDoneButton], animated: true)
        
        timeTextField.inputAccessoryView = timeToolbar
        timeTextField.inputView = timePicker
        
        // format picker for date only
        timePicker.datePickerMode = .time
    }
    
    @objc func  timePickerViewDoneButtonPressed()  {
        //format the time that appears in the text field
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        // create time in string format
        let timeString = timeFormatter.string(from: timePicker.date)
        
        let bounds = askRemindingLabel.bounds
        
        UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 0.2, initialSpringVelocity: 300, options: .curveEaseInOut, animations: {
            self.askRemindingLabel.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 10, height: bounds.size.height)
        }) { (success:Bool) in }
        
        let pickerBounds = datePicker.bounds
        
        UIView.animate(withDuration: 1, delay: 2, usingSpringWithDamping: 0.2, initialSpringVelocity: 300, options: .curveEaseInOut, animations: {
            self.datePicker.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 10, height: pickerBounds.size.height)
        }) { (success:Bool) in }
        
        timeTextField.text = "\(timeString)"
        timeLabel.text = "Your Ticket Expires At \(timeString)"
        self.view.endEditing(true)
        timeLabel.isHidden = false
        askRemindingLabel.isHidden = false
        askRemindingLabel.alpha = 1
        datePicker.isHidden = false
        datePicker.isEnabled = true
        datePicker.alpha = 1
        button.isHidden = false
        button.isEnabled = true
        button.alpha = 1
        imageView.isHidden = false
        myView.isHidden = true
        myImage.isHidden = true
        
    }
}



