//
//  WeekTVC.swift
//  90 DWT 3
//
//  Created by Jared Grant on 6/25/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class WeekTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, MPAdViewDelegate {
    
    // **********
    let debug = 0
    // **********
    
    fileprivate var currentWeekWorkoutList = [[], []]
    fileprivate var daysOfWeekNumberList = [[], []]
    fileprivate var daysOfWeekColorList = [[], []]
    fileprivate var optionalWorkoutList = [[], []]
    fileprivate var workoutIndexList = [[], []]
    
    var workoutRoutine = ""
    var session = ""
    var workoutWeek = ""
    var month = ""
    
    var adView = MPAdView()
    var headerView = UIView()
    var bannerSize = CGSize()
    
    var longPGR = UILongPressGestureRecognizer()
    var indexPath = IndexPath()
    var position = NSInteger()
    var request = ""
    
    fileprivate struct Color {
        static let regular_One = "Regular 1"
        static let regular_two = "Regular 2"
        static let regular_three = "Regular 3"
        static let regular_four = "Regular 4"
        static let regular_five = "Regular 5"
        
        static let light_One = "Light 1"
        static let light_two = "Light 2"
        static let light_three = "Light 3"
        static let light_four = "Light 4"
        static let light_five = "Light 5"
        static let light_six = "Light 6"
        static let light_seven = "Light 7"
        static let orange = "Orange"
        static let white = "White"
    }
    
    fileprivate struct WorkoutName {

        static let Negative_Lower = "Negative Lower"
        static let Negative_Upper = "Negative Upper"
        static let Agility_Lower = "Agility Lower"
        static let Agility_Upper = "Agility Upper"
        static let Devastator = "Devastator"
        static let Complete_Fitness = "Complete Fitness"
        static let The_Goal = "The Goal"
        static let Cardio_Resistance = "Cardio Resistance"
        static let MMA = "MMA"
        static let Dexterity = "Dexterity"
        static let Gladiator = "Gladiator"
        static let Plyometrics_T = "Plyometrics T"
        static let Plyometrics_D = "Plyometrics D"
        static let Cardio_Speed = "Cardio Speed"
        static let Yoga = "Yoga"
        static let Pilates = "Pilates"
        static let Core_I = "Core I"
        static let Core_D = "Core D"
        
        static let Warm_Up = "Warm Up"
        static let Ab_Workout = "Ab Workout"
        static let Rest = "Rest"
        static let Finished = "Finished"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Workout"
        
        loadArraysForCell()
        
        // Add rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(WeekTVC.editButtonPressed(_:)))
        
        if Products.store.isProductPurchased("com.grantsoftware.90DWT3.removeads1") {
            
            // User purchased the Remove Ads in-app purchase so don't show any ads.
        }
        else {
            
            // Show the Banner Ad
            self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
                
                // iPhone
                // Month Ad Unit
                self.adView = MPAdView(adUnitId: "ec3e53b6f4b14bca87772951a23139f8", size: MOPUB_BANNER_SIZE)
                self.bannerSize = MOPUB_BANNER_SIZE
            }
            else {
                
                // iPad
                // Month Ad Unit
                self.adView = MPAdView(adUnitId: "9041ef410d53400bbcaa965b3cd4ab86", size: MOPUB_LEADERBOARD_SIZE)
                self.bannerSize = MOPUB_LEADERBOARD_SIZE
            }
            
            self.adView.delegate = self
            self.adView.frame = CGRect(x: (self.view.bounds.size.width - self.bannerSize.width) / 2,
                                           y: self.bannerSize.height - self.bannerSize.height,
                                           width: self.bannerSize.width, height: self.bannerSize.height)
        }

        // Add a long press gesture recognizer
        self.longPGR = UILongPressGestureRecognizer(target: self, action: #selector(MonthTVC.longPressGRAction(_:)))
        self.longPGR.minimumPressDuration = 1.0
        self.longPGR.allowableMovement = 10.0
        self.tableView.addGestureRecognizer(self.longPGR)

        if debug == 1 {
            
            print("SHARED CONTEXT - \(CDOperation.objectCountForEntity("Workout", context: CoreDataHelper.shared().context))")
            
            print("IMPORT CONTEXT - \(CDOperation.objectCountForEntity("Workout", context: CoreDataHelper.shared().importContext))")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT3.removeads1") {
            
            // Don't show ads.
            self.tableView.tableHeaderView = nil
            self.adView.delegate = nil
            
        } else {
            
            // Show ads
            self.headerView.addSubview(self.adView)
            
            self.adView.loadAd()
            
            self.adView.isHidden = true;
        }

        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force fetch when notified of significant data changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.doNothing), name: NSNotification.Name(rawValue: "SomethingChanged"), object: nil)
        
        // Set the AutoLock Setting
        if CDOperation.getAutoLockSetting() == "ON" {
            
            // User wants to disable the autolock timer.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else {
            
            // User doesn't want to disable the autolock timer.
            UIApplication.shared.isIdleTimerDisabled = false
        }

        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT3.removeads1") {
            
            // Don't show ads.
            self.tableView.tableHeaderView = nil
            self.adView.delegate = nil
            
        } else {
            
            // Show ads
            self.adView.frame = CGRect(x: (self.view.bounds.size.width - self.bannerSize.width) / 2,
                                           y: self.bannerSize.height - self.bannerSize.height,
                                           width: self.bannerSize.width, height: self.bannerSize.height)
            self.adView.isHidden = false
        }

        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
        
        self.adView.removeFromSuperview()
    }
    
    @objc func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func editButtonPressed(_ sender: UIBarButtonItem) {
        
        let tempMessage = "Set the status for all workouts of:\n\n\(workoutRoutine) - \(workoutWeek)"
        
        let alertController = UIAlertController(title: "Workout Status", message: tempMessage, preferredStyle: .actionSheet)
        
        let notCompletedAction = UIAlertAction(title: "Not Completed", style: .destructive, handler: {
            action in
            
            self.request = "Not Completed"
            self.verifyAddDeleteRequestFromBarButtonItem()
        })
        
        let completedAction = UIAlertAction(title: "Completed", style: .default, handler: {
            action in
            
            self.request = "Completed"
            self.verifyAddDeleteRequestFromBarButtonItem()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(notCompletedAction)
        alertController.addAction(completedAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.barButtonItem = sender
            popover.sourceView = self.view
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }

    func longPressGRAction(_ sender: UILongPressGestureRecognizer) {
     
        if (sender.isEqual(self.longPGR)) {
            
            if sender.state == UIGestureRecognizerState.began {
                
                let p = sender.location(in: self.tableView)
                
                if let tempIndexPath = self.tableView.indexPathForRow(at: p) {
                    
                    self.indexPath = tempIndexPath
                    self.position = self.findArrayPosition(self.indexPath)
                    
                    // get affected cell and label
                    let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
                    
                    let tempMessage = ("Set the status for:\n\n\(workoutRoutine) - \(workoutWeek) - \(cell.titleLabel.text!)")
                    
                    let alertController = UIAlertController(title: "Workout Status", message: tempMessage, preferredStyle: .actionSheet)
                    
                    let notCompletedAction = UIAlertAction(title: "Not Completed", style: .destructive, handler: {
                        action in
                        
                        self.request = "Not Completed"
                        self.verifyAddDeleteRequestFromTableViewCell()
                    })
                    
                    let completedAction = UIAlertAction(title: "Completed", style: .default, handler: {
                        action in
                        
                        self.request = "Completed"
                        self.verifyAddDeleteRequestFromTableViewCell()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alertController.addAction(notCompletedAction)
                    alertController.addAction(completedAction)
                    alertController.addAction(cancelAction)
                    
                    if let popover = alertController.popoverPresentationController {
                        
                        popover.sourceView = cell
                        popover.delegate = self
                        popover.sourceRect = (cell.bounds)
                        popover.permittedArrowDirections = .any
                    }
                    
                    present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func verifyAddDeleteRequestFromTableViewCell() {
        
        // get affected cell
        let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
        
        self.position = self.findArrayPosition(self.indexPath)
        
        let tempMessage = ("You are about to set the status for\n\n\(CDOperation.getCurrentRoutine()) - \(workoutWeek) - \(cell.titleLabel.text!)\n\nto:\n\n\(self.request)\n\nDo you want to proceed?")
        
        let alertController = UIAlertController(title: "Warning", message: tempMessage, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            self.addDeleteDate()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func verifyAddDeleteRequestFromBarButtonItem() {
        
        let tempMessage = "You are about to set the status for all workouts of:\n\n\(workoutRoutine) - \(workoutWeek)\n\nto:\n\n\(self.request)\n\nDo you want to proceed?"
        
        let alertController = UIAlertController(title: "Warning", message: tempMessage, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            self.AddDeleteDatesFromOneWeek()
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addDeleteDate() {
        
        switch self.request {
        case "Not Completed":
            
            // ***DELETE***
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }
                
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }
                
            case "2-A-Days":
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }

            default:
                
                // Bulk
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }
            }

            // Update TableViewCell Accessory Icon - Arrow
            let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
            
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
            cell.accessoryView = tempAccessoryView
            
        default:
            
            // Completed
            
            // ***ADD***
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }
                
            case "2-A-Days":
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }

            default:
                
                // Bulk
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }
            }
            
            // Update TableViewCell Accessory Icon - Checkmark
            let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "Colored_White_CheckMark"))
            cell.accessoryView = tempAccessoryView
        }
    }

    func AddDeleteDatesFromOneWeek() {
        
        switch self.request {
        case "Not Completed":
            
            // ***DELETE***
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }
                
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }
                
            case "2-A-Days":
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }

            default:
                
                // Bulk
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }
            }
            
        default:
            
            // Completed
            
            // ***ADD***
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
                
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
                
            case "2-A-Days":
                
                // 2-A-Days

                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
                
            default:
                
                // Bulk
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
            }
        }
    }
    
    func findArrayPosition(_ indexPath: IndexPath) -> NSInteger {
        
        var position = NSInteger(0)
        
        for i in 0...indexPath.section {
            
            if (i == indexPath.section) {
                
                position = position + (indexPath.row + 1)
            }
            else {
                
                let totalRowsInSection = self.tableView.numberOfRows(inSection: i)
                
                position = position + totalRowsInSection
            }
        }
        
        return position - 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return currentWeekWorkoutList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return currentWeekWorkoutList[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! WeekTVC_TableViewCell

        // Configure the cell...
        cell.titleLabel.text = CDOperation.trimStringForWorkoutName((currentWeekWorkoutList[indexPath.section][indexPath.row] as? String)!)
        cell.dayOfWeekTextField.text = daysOfWeekNumberList[indexPath.section][indexPath.row] as? String
        
        if optionalWorkoutList[indexPath.section][indexPath.row] as! Bool == false {
            
            // Don't show the "Select 1"
            cell.detailLabel.isHidden = true
        }
        else {
            cell.detailLabel.isHidden = false
        }
        
        let workoutCompletedObjects = CDOperation.getWorkoutCompletedObjects(session as NSString, routine: workoutRoutine as NSString, workout: currentWeekWorkoutList[indexPath.section][indexPath.row] as! NSString, index: workoutIndexList[indexPath.section][indexPath.row] as! NSNumber)
        
        if workoutCompletedObjects.count != 0 {
            
            // Workout completed so put a checkmark as the accessoryview icon
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "Colored_White_CheckMark"))
            cell.accessoryView = tempAccessoryView
        }
        else {
            
            // Workout was NOT completed so put the arrow as the accessory view icon
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
            cell.accessoryView = tempAccessoryView
        }
        
        switch daysOfWeekColorList[indexPath.section][indexPath.row] as! String {
        case "Regular 1":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 191/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Regular 2":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 104/255, blue: 159/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Regular 3":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 84/255, blue: 127/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Regular 4":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 63/255, blue: 95/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Regular 5":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 42/255, blue: 63/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 1":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 191/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 2":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 111/255, blue: 170/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 3":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 97/255, blue: 148/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 4":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 84/255, blue: 127/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 5":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 70/255, blue: 106/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 6":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 56/255, blue: 84/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Light 7":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 42/255, blue: 63/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Orange":
            cell.dayOfWeekTextField.backgroundColor = UIColor (red: 242/255, green: 83/255, blue: 24/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "White":
            cell.dayOfWeekTextField.backgroundColor = UIColor.white
            cell.dayOfWeekTextField.textColor = UIColor.black
            
        default: break

        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "\(workoutRoutine) - \(workoutWeek)"
        }
        else {
            return ""
        }
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 30
        }
        else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? WeekTVC_TableViewCell {
            
            if cell.titleLabel.text == "Negative Lower" ||
                cell.titleLabel.text == "Negative Upper" ||
                cell.titleLabel.text == "Agility Upper" ||
                cell.titleLabel.text == "Agility Lower" ||
                cell.titleLabel.text == "Devastator" ||
                cell.titleLabel.text == "Complete Fitness" ||
                cell.titleLabel.text == "The Goal" {
                
                self.performSegue(withIdentifier: "toWorkout", sender: indexPath)
            }
            else {
                
                self.performSegue(withIdentifier: "toNotes", sender: indexPath)
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toWorkout" {
            
            let destinationVC = segue.destination as? WorkoutTVC
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = CDOperation.trimStringForWorkoutName((self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!)
            destinationVC!.selectedWorkout = (self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            destinationVC?.workoutIndex = (self.workoutIndexList[(selectedRow?.section)!][(selectedRow?.row)!] as? Int)!
            destinationVC!.workoutRoutine = self.workoutRoutine
            destinationVC?.session = self.session
            destinationVC?.workoutWeek = self.workoutWeek
            destinationVC?.month = self.month
        }
        else {
            // NotesViewController
            
            let destinationVC = segue.destination as? NotesViewController
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = (self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            destinationVC!.selectedWorkout = (self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            destinationVC?.workoutIndex = (self.workoutIndexList[(selectedRow?.section)!][(selectedRow?.row)!] as? Int)!
            destinationVC!.workoutRoutine = self.workoutRoutine
            destinationVC?.session = self.session
            destinationVC!.workoutWeek = self.workoutWeek
            destinationVC?.month = self.month
        }
    }
    
    func getIntValueforWeekString() -> Int {
        
        switch workoutWeek {
        case "Week 1":
            
            return 1
          
        case "Week 2":
            
            return 2
            
        case "Week 3":
            
            return 3
            
        case "Week 4":
            
            return 4
            
        case "Week 5":
            
            return 5
            
        case "Week 6":
            
            return 6
            
        case "Week 7":
            
            return 7
            
        case "Week 8":
            
            return 8
            
        case "Week 9":
            
            return 9
            
        case "Week 10":
            
            return 10
            
        case "Week 11":
            
            return 11

        case "Week 12":
            
            return 12
            
        case "Week 13":
            
            return 13
            
        case "Week 14":
            
            return 14
            
        case "Week 15":
            
            return 15
            
        case "Week 16":
            
            return 16
            
        default:
            
            // Week 17
            return 17
        }
    }
    
    fileprivate func loadArraysForCell() {
        
        if workoutRoutine == "Normal" {
            
            // Normal Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Cardio_Resistance, WorkoutName.Gladiator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 1, 1, 1, 1, 1],
                                    [1, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Cardio_Resistance, WorkoutName.Gladiator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 2, 2, 2, 2, 2],
                                    [2, 2]]
                
            case "Week 3":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Cardio_Resistance, WorkoutName.Gladiator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 3, 3, 3, 3, 3],
                                    [3, 3]]
                
            case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Cardio_Resistance, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 4, 1, 1, 4, 4],
                                    [5, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Plyometrics_T, WorkoutName.Yoga, WorkoutName.Negative_Lower, WorkoutName.Devastator, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 1, 5, 1, 1, 1],
                                    [6, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Plyometrics_T, WorkoutName.Yoga, WorkoutName.Negative_Lower, WorkoutName.Devastator, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 2, 6, 2, 2, 2],
                                    [7, 6]]
                
            case "Week 7":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Plyometrics_T, WorkoutName.Yoga, WorkoutName.Negative_Lower, WorkoutName.Devastator, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 3, 7, 3, 3, 3],
                                    [8, 7]]
                
            case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Cardio_Resistance, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 9, 2, 2, 5, 8],
                                    [10, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.Dexterity],
                                          [WorkoutName.The_Goal, WorkoutName.Agility_Upper],
                                          [WorkoutName.Yoga, WorkoutName.Plyometrics_T],
                                          [WorkoutName.Complete_Fitness, WorkoutName.Agility_Lower],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"],
                                        ["3", "3"],
                                        ["4", "5"],
                                        ["6", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three]]
                
                optionalWorkoutList = [[false, false],
                                       [true, true],
                                       [false, false],
                                       [true, true],
                                       [true, true]]
                
                workoutIndexList = [[1, 4],
                                    [4, 1],
                                    [9, 4],
                                    [4, 1],
                                    [11, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.MMA, WorkoutName.Negative_Upper, WorkoutName.Plyometrics_T, WorkoutName.Pilates, WorkoutName.Negative_Lower],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 4, 4, 5, 3, 4],
                                    [12, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.Dexterity],
                                          [WorkoutName.The_Goal, WorkoutName.Agility_Upper],
                                          [WorkoutName.Yoga, WorkoutName.Plyometrics_T],
                                          [WorkoutName.Complete_Fitness, WorkoutName.Agility_Lower],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"],
                                        ["3", "3"],
                                        ["4", "5"],
                                        ["6", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three]]
                
                optionalWorkoutList = [[false, false],
                                       [true, true],
                                       [false, false],
                                       [true, true],
                                       [true, true]]
                
                workoutIndexList = [[3, 5],
                                    [5, 2],
                                    [10, 6],
                                    [5, 2],
                                    [13, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.MMA, WorkoutName.Negative_Upper, WorkoutName.Plyometrics_T, WorkoutName.Pilates, WorkoutName.Negative_Lower],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[4, 5, 5, 7, 4, 5],
                                    [14, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Yoga, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[3, 3, 5, 11, 15],
                                    [16, 13],
                                    [1]]
                
            case "Week 14":
                /// BONUS ///
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Yoga],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2", "3"],
                                        ["4A", "4B"],
                                        ["5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 1],
                                    [3, 12],
                                    [4, 2],
                                    [4, 6],
                                    [17, 14]]
                
            case "Week 15":
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Yoga],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2", "3"],
                                        ["4A", "4B"],
                                        ["5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 3],
                                    [5, 13],
                                    [6, 4],
                                    [6, 7],
                                    [18, 15]]
                
            case "Week 16":
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Yoga],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2", "3"],
                                        ["4A", "4B"],
                                        ["5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[7, 5],
                                    [7, 14],
                                    [8, 6],
                                    [8, 8],
                                    [19, 16]]
                
            case "Week 17":
                currentWeekWorkoutList = [[WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.Cardio_Resistance, WorkoutName.Pilates, WorkoutName.Core_I],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[6, 15, 6, 9, 4],
                                    [20, 17],
                                    [2]]
                
            default:
                currentWeekWorkoutList = [[],[]]
            }
        }
        else if workoutRoutine == "Tone" {
            
            // Tone Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Cardio_Speed, WorkoutName.Gladiator, WorkoutName.Yoga, WorkoutName.Cardio_Resistance, WorkoutName.Core_I, WorkoutName.Dexterity],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 1, 1, 1, 1, 1],
                                    [1, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Cardio_Speed, WorkoutName.Gladiator, WorkoutName.Yoga, WorkoutName.Cardio_Resistance, WorkoutName.Core_I, WorkoutName.Dexterity],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 2, 2, 2, 2, 2],
                                    [2, 2]]
                
            case "Week 3":
                currentWeekWorkoutList = [[WorkoutName.Cardio_Speed, WorkoutName.Gladiator, WorkoutName.Yoga, WorkoutName.Cardio_Resistance, WorkoutName.Core_I, WorkoutName.Dexterity],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 3, 3, 3, 3, 3],
                                    [3, 3]]
                
            case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Dexterity, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[4, 4, 4, 1, 4, 4],
                                    [5, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_T, WorkoutName.Gladiator, WorkoutName.Yoga, WorkoutName.MMA, WorkoutName.Devastator, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 4, 5, 1, 1, 4],
                                    [6, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_T, WorkoutName.Gladiator, WorkoutName.Yoga, WorkoutName.MMA, WorkoutName.Devastator, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 5, 6, 2, 2, 5],
                                    [7, 6]]
                
            case "Week 7":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_T, WorkoutName.Gladiator, WorkoutName.Yoga, WorkoutName.MMA, WorkoutName.Devastator, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 6, 7, 3, 3, 6],
                                    [8, 7]]
                
            case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Dexterity, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 9, 5, 2, 5, 8],
                                    [10, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.MMA],
                                          [WorkoutName.Negative_Lower, WorkoutName.Agility_Lower],
                                          [WorkoutName.Yoga, WorkoutName.Plyometrics_T],
                                          [WorkoutName.Negative_Upper, WorkoutName.Agility_Upper],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"],
                                        ["3", "3"],
                                        ["4", "5"],
                                        ["6", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [true, true],
                                       [false, false],
                                       [true, true],
                                       [true, true]]
                
                workoutIndexList = [[1, 4],
                                    [1, 1],
                                    [9, 4],
                                    [1, 1],
                                    [11, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.MMA, WorkoutName.Plyometrics_D, WorkoutName.Plyometrics_T, WorkoutName.Pilates, WorkoutName.Plyometrics_D, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 2, 5, 3, 3, 7],
                                    [12, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.MMA],
                                          [WorkoutName.Negative_Lower, WorkoutName.Agility_Lower],
                                          [WorkoutName.Yoga, WorkoutName.Plyometrics_T],
                                          [WorkoutName.Negative_Upper, WorkoutName.Agility_Upper],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"],
                                        ["3", "3"],
                                        ["4", "5"],
                                        ["6", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [true, true],
                                       [false, false],
                                       [true, true],
                                       [true, true]]
                
                workoutIndexList = [[4, 6],
                                    [2, 2],
                                    [10, 6],
                                    [2, 2],
                                    [13, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.MMA, WorkoutName.Plyometrics_D, WorkoutName.Plyometrics_T, WorkoutName.Pilates, WorkoutName.Plyometrics_D, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[7, 5, 7, 4, 6, 8],
                                    [14, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Yoga, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five],
                                       [Color.light_six, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[6, 6, 5, 11, 15],
                                    [16, 13],
                                    [1]]
                
            case "Week 14":
                /// BONUS ///
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Yoga],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2", "3"],
                                        ["4A", "4B"],
                                        ["5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 1],
                                    [3, 12],
                                    [4, 2],
                                    [4, 6],
                                    [17, 14]]
                
            case "Week 15":
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Yoga],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2", "3"],
                                        ["4A", "4B"],
                                        ["5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 3],
                                    [5, 13],
                                    [6, 4],
                                    [6, 7],
                                    [18, 15]]
                
            case "Week 16":
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Yoga],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout],
                                          [WorkoutName.Agility_Lower, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2", "3"],
                                        ["4A", "4B"],
                                        ["5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[7, 5],
                                    [7, 14],
                                    [8, 6],
                                    [8, 8],
                                    [19, 16]]
                
            case "Week 17":
                currentWeekWorkoutList = [[WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.Cardio_Resistance, WorkoutName.Pilates, WorkoutName.Core_I],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five],
                                       [Color.light_six, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[6, 15, 9, 9, 7],
                                    [20, 17],
                                    [2]]
                
            default:
                currentWeekWorkoutList = [[], []]
            }
        }
        else if workoutRoutine == "2-A-Days" {
            
            // 2-A-Days Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Warm_Up, WorkoutName.Complete_Fitness],
                                          [WorkoutName.Dexterity, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Warm_Up, WorkoutName.The_Goal],
                                          [WorkoutName.Cardio_Resistance, WorkoutName.Core_D],
                                          [WorkoutName.Gladiator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false],
                                       [false, false],
                                       [false, false],
                                       [false],
                                       [true, true]]
                
                workoutIndexList = [[1, 1],
                                    [1, 1],
                                    [1],
                                    [2, 1],
                                    [1, 2],
                                    [1],
                                    [3, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Warm_Up, WorkoutName.Complete_Fitness],
                                          [WorkoutName.Dexterity, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Warm_Up, WorkoutName.The_Goal],
                                          [WorkoutName.Cardio_Resistance, WorkoutName.Core_D],
                                          [WorkoutName.Gladiator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false],
                                       [false, false],
                                       [false, false],
                                       [false],
                                       [true, true]]
                
                workoutIndexList = [[3, 2],
                                    [2, 4],
                                    [2],
                                    [4, 2],
                                    [2, 5],
                                    [2],
                                    [6, 2]]
                
            case "Week 3":
                currentWeekWorkoutList = [[WorkoutName.Warm_Up, WorkoutName.Complete_Fitness],
                                          [WorkoutName.Dexterity, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Warm_Up, WorkoutName.The_Goal],
                                          [WorkoutName.Cardio_Resistance, WorkoutName.Core_D],
                                          [WorkoutName.Gladiator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.regular_One],
                                       [Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false],
                                       [false, false],
                                       [false, false],
                                       [false],
                                       [true, true]]
                
                workoutIndexList = [[5, 3],
                                    [3, 7],
                                    [3],
                                    [6, 3],
                                    [3, 8],
                                    [3],
                                    [9, 3]]
                
            case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Dexterity, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 10, 1, 1, 4, 4],
                                    [11, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Negative_Lower, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Devastator, WorkoutName.Core_I],
                                          [WorkoutName.MMA, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[4, 2],
                                    [1, 12],
                                    [5],
                                    [1, 4],
                                    [1, 2],
                                    [1, 13],
                                    [14, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Negative_Lower, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Devastator, WorkoutName.Core_I],
                                          [WorkoutName.MMA, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 3],
                                    [2, 15],
                                    [6],
                                    [2, 5],
                                    [2, 3],
                                    [2, 16],
                                    [17, 6]]
                
            case "Week 7":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Negative_Lower, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Devastator, WorkoutName.Core_I],
                                          [WorkoutName.MMA, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.regular_two],
                                       [Color.regular_two, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[6, 4],
                                    [3, 18],
                                    [7],
                                    [3, 6],
                                    [3, 4],
                                    [3, 19],
                                    [20, 7]]
                
            case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Cardio_Speed, WorkoutName.Pilates],
                                          [WorkoutName.Dexterity, WorkoutName.Core_D],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4"],
                                        ["5A", "5B"],
                                        ["6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four],
                                       [Color.light_five, Color.light_five],
                                       [Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false],
                                       [false, false],
                                       [false],
                                       [true, true]]
                
                workoutIndexList = [[5, 21, 5, 2],
                                    [5, 22],
                                    [8],
                                    [23, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.Cardio_Speed],
                                          [WorkoutName.MMA, WorkoutName.Pilates],
                                          [WorkoutName.The_Goal, WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Core_D],
                                          [WorkoutName.Yoga, WorkoutName.Dexterity],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_I],
                                          [WorkoutName.Complete_Fitness, WorkoutName.Agility_Lower, WorkoutName.Ab_Workout, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3A", "3A", "3B", "3B"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6A", "6B", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three, Color.orange, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three, Color.orange, Color.regular_three],
                                       [Color.regular_three, Color.white]]
                
                optionalWorkoutList = [[false, false,],
                                       [false, false],
                                       [true, true, true, true],
                                       [false, false,],
                                       [false, false],
                                       [true, true, true, true],
                                       [true, true]]
                
                workoutIndexList = [[1, 6],
                                    [4, 3],
                                    [4, 1, 1, 24],
                                    [9, 6],
                                    [4, 6],
                                    [7, 1, 2, 25],
                                    [26, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Cardio_Resistance, WorkoutName.Pilates],
                                          [WorkoutName.Negative_Upper, WorkoutName.MMA],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_I],
                                          [WorkoutName.Yoga, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Negative_Lower, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3A", "3A"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 7],
                                    [7, 4],
                                    [1, 5],
                                    [5, 7],
                                    [10, 8],
                                    [4, 27],
                                    [28, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.Cardio_Speed],
                                          [WorkoutName.MMA, WorkoutName.Pilates],
                                          [WorkoutName.The_Goal, WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Core_D],
                                          [WorkoutName.Yoga, WorkoutName.Dexterity],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_I],
                                          [WorkoutName.Complete_Fitness, WorkoutName.Agility_Lower, WorkoutName.Ab_Workout, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3A", "3A", "3B", "3B"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6A", "6B", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three, Color.orange, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three],
                                       [Color.regular_three, Color.regular_three, Color.orange, Color.regular_three],
                                       [Color.regular_three, Color.white]]
                
                optionalWorkoutList = [[false, false,],
                                       [false, false],
                                       [true, true, true, true],
                                       [false, false,],
                                       [false, false],
                                       [true, true, true, true],
                                       [true, true]]
                
                workoutIndexList = [[3, 8],
                                    [6, 5],
                                    [5, 2, 3, 29],
                                    [11, 7],
                                    [6, 8],
                                    [8, 2, 4, 30],
                                    [31, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.Plyometrics_D, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Cardio_Resistance, WorkoutName.Pilates],
                                          [WorkoutName.Negative_Upper, WorkoutName.MMA],
                                          [WorkoutName.Plyometrics_T, WorkoutName.Core_I],
                                          [WorkoutName.Yoga, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Negative_Lower, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"],
                                        ["2A", "2B"],
                                        ["3A", "3A"],
                                        ["4A", "4B"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.regular_four],
                                       [Color.regular_four, Color.white]]
                
                optionalWorkoutList = [[false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[4, 9],
                                    [9, 6],
                                    [2, 7],
                                    [7, 9],
                                    [12, 10],
                                    [5, 32],
                                    [33, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Cardio_Speed, WorkoutName.Pilates, WorkoutName.Yoga, WorkoutName.Core_D],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five],
                                       [Color.light_six, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[10, 10, 7, 13, 34],
                                    [35, 13],
                                    [1]]
                
            case "Week 14":
                /// BONUS ///
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Agility_Lower, WorkoutName.Core_I],
                                          [WorkoutName.Yoga, WorkoutName.Pilates],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Agility_Lower, WorkoutName.MMA],
                                          [WorkoutName.Yoga, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"],
                                        ["2A", "2B"],
                                        ["3A", "3B"],
                                        ["4A", "4B", "4C"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 5, 11],
                                    [3, 11],
                                    [14, 8],
                                    [4, 6, 11],
                                    [4, 8],
                                    [15, 9],
                                    [36, 14]]
                
            case "Week 15":
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Agility_Lower, WorkoutName.Core_I],
                                          [WorkoutName.Yoga, WorkoutName.Pilates],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Agility_Lower, WorkoutName.MMA],
                                          [WorkoutName.Yoga, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"],
                                        ["2A", "2B"],
                                        ["3A", "3B"],
                                        ["4A", "4B", "4C"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 7, 12],
                                    [5, 12],
                                    [16, 10],
                                    [6, 8, 12],
                                    [6, 9],
                                    [17, 11],
                                    [37, 15]]
                
            case "Week 16":
                currentWeekWorkoutList = [[WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Cardio_Speed],
                                          [WorkoutName.Agility_Lower, WorkoutName.Core_I],
                                          [WorkoutName.Yoga, WorkoutName.Pilates],
                                          [WorkoutName.Agility_Upper, WorkoutName.Ab_Workout, WorkoutName.Cardio_Resistance],
                                          [WorkoutName.Agility_Lower, WorkoutName.MMA],
                                          [WorkoutName.Yoga, WorkoutName.Pilates],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"],
                                        ["2A", "2B"],
                                        ["3A", "3B"],
                                        ["4A", "4B", "4C"],
                                        ["5A", "5B"],
                                        ["6A", "6B"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_five, Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.regular_five],
                                       [Color.regular_five, Color.white]]
                
                optionalWorkoutList = [[false, false, false],
                                       [false, false],
                                       [false, false],
                                       [false, false, false],
                                       [false, false],
                                       [false, false],
                                       [true, true]]
                
                workoutIndexList = [[7, 9, 13],
                                    [7, 13],
                                    [18, 12],
                                    [8, 10, 13],
                                    [8, 10],
                                    [19, 13],
                                    [38, 16]]
                
            case "Week 17":
                currentWeekWorkoutList = [[WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.Cardio_Resistance, WorkoutName.Pilates, WorkoutName.Core_I],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five],
                                       [Color.light_six, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[8, 20, 14, 14, 14],
                                    [39, 17],
                                    [2]]
                
            default:
                currentWeekWorkoutList = [[], []]
            }
        }
        else {
            
            // Bulk Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Pilates, WorkoutName.Devastator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 1, 1, 1, 1, 1],
                                    [1, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Pilates, WorkoutName.Devastator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 2, 2, 2, 2, 2],
                                    [2, 2]]
                
            case "Week 3":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Pilates, WorkoutName.Devastator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One, Color.regular_One],
                                       [Color.regular_One, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 3, 3, 3, 3, 3],
                                    [3, 3]]
                
            case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Gladiator, WorkoutName.Pilates, WorkoutName.Dexterity, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 4, 1, 4, 4, 4],
                                    [5, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.Yoga, WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_three, Color.light_three, Color.light_three, Color.light_three, Color.light_three, Color.light_three],
                                       [Color.light_three, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[1, 1, 5, 2, 2, 1],
                                    [6, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.Yoga, WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_three, Color.light_three, Color.light_three, Color.light_three, Color.light_three, Color.light_three],
                                       [Color.light_three, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[3, 3, 6, 4, 4, 2],
                                    [7, 6]]
                
            case "Week 7":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.Yoga, WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_three, Color.light_three, Color.light_three, Color.light_three, Color.light_three, Color.light_three],
                                       [Color.light_three, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 5, 7, 6, 6, 3],
                                    [8, 7]]
                
            case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Core_D, WorkoutName.Gladiator, WorkoutName.Pilates, WorkoutName.Plyometrics_D, WorkoutName.Yoga],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five, Color.light_six],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[2, 9, 2, 5, 1, 8],
                                    [10, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.Yoga, WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_five, Color.light_five, Color.light_five, Color.light_five, Color.light_five, Color.light_five],
                                       [Color.light_five, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[7, 7, 9, 8, 8, 4],
                                    [11, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Pilates, WorkoutName.Devastator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_seven, Color.light_seven, Color.light_seven, Color.light_seven, Color.light_seven, Color.light_seven],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[4, 5, 10, 4, 6, 4],
                                    [12, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.Yoga, WorkoutName.Negative_Upper, WorkoutName.Negative_Lower, WorkoutName.MMA],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_five, Color.light_five, Color.light_five, Color.light_five, Color.light_five, Color.light_five],
                                       [Color.light_five, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[9, 9, 11, 10, 10, 5],
                                    [13, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.Complete_Fitness, WorkoutName.Dexterity, WorkoutName.Yoga, WorkoutName.The_Goal, WorkoutName.Pilates, WorkoutName.Devastator],
                                          [WorkoutName.Core_D, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"],
                                        ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light_seven, Color.light_seven, Color.light_seven, Color.light_seven, Color.light_seven, Color.light_seven],
                                       [Color.light_seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false],
                                       [true, true]]
                
                workoutIndexList = [[5, 6, 12, 5, 7, 5],
                                    [14, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Core_I, WorkoutName.Yoga, WorkoutName.Plyometrics_D, WorkoutName.Negative_Lower, WorkoutName.Negative_Upper],
                                          [WorkoutName.Core_D, WorkoutName.Rest],
                                          [WorkoutName.Finished]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5"],
                                        ["6", "6"],
                                        ["7"]]
                
                daysOfWeekColorList = [[Color.light_One, Color.light_two, Color.light_three, Color.light_four, Color.light_five],
                                       [Color.light_six, Color.white],
                                       [Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false],
                                       [true, true],
                                       [false]]
                
                workoutIndexList = [[3, 13, 2, 11, 11],
                                    [15, 13],
                                    [1]]
                
            default:
                currentWeekWorkoutList = [[],[]]
            }
        }
    }
    
    // MARK: - <MPAdViewDelegate>
    func viewControllerForPresentingModalView() -> UIViewController! {
        
        return self
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        
        let size = view.adContentViewSize()
        let centeredX = (self.view.bounds.size.width - size.width) / 2
        let bottomAlignedY = self.bannerSize.height - size.height
        view.frame = CGRect(x: centeredX, y: bottomAlignedY, width: size.width, height: size.height)
        
        if (self.headerView.frame.size.height == 0) {
            
            // No ads shown yet.  Animate showing the ad.
            let headerViewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.bannerSize.height)
            
            UIView.animate(withDuration: 0.25, animations: {self.headerView.frame = headerViewFrame
                self.tableView.tableHeaderView = self.headerView
                self.adView.isHidden = true},
                           completion: {(finished: Bool) in
                            self.adView.isHidden = false
                            
            })
        }
        else {
            
            // Ad is already showing.
            self.tableView.tableHeaderView = self.headerView
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.adView.isHidden = true
        self.adView.rotate(to: toInterfaceOrientation)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        let size = self.adView.adContentViewSize()
        let centeredX = (self.view.bounds.size.width - size.width) / 2
        let bottomAlignedY = self.headerView.bounds.size.height - size.height
        
        self.adView.frame = CGRect(x: centeredX, y: bottomAlignedY, width: size.width, height: size.height)
        
        self.adView.isHidden = false
    }
}
