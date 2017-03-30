//
//  MonthTVC.swift
//  90 DWT 3
//
//  Created by Jared Grant on 6/25/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class MonthTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, MPAdViewDelegate {
    
    // **********
    let debug = 0
    // **********

    var sectionsArray = [[], []]
    var weekOfMonthColorList =  [[], []]
    var lightWorkoutList = [[], []]
    
    var session = ""
    var longPGR = UILongPressGestureRecognizer()
    var indexPath = IndexPath()
    var request = ""
    var position = NSInteger()
    
    var adView = MPAdView()
    var headerView = UIView()
    var bannerSize = CGSize()
    
    fileprivate struct Week {
        static let week1 = "Week 1"
        static let week2 = "Week 2"
        static let week3 = "Week 3"
        static let week4 = "Week 4"
        static let week5 = "Week 5"
        static let week6 = "Week 6"
        static let week7 = "Week 7"
        static let week8 = "Week 8"
        static let week9 = "Week 9"
        static let week10 = "Week 10"
        static let week11 = "Week 11"
        static let week12 = "Week 12"
        static let week13 = "Week 13"
        static let week14 = "Week 14"
        static let week15 = "Week 15"
        static let week16 = "Week 16"
        static let week17 = "Week 17"
    }
    
    fileprivate struct Color {
        static let one = "One"
        static let two = "Two"
        static let three = "Three"
        static let four = "Four"
        static let five = "Five"
        static let orange = "Orange"
        static let white = "White"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
            
            print("VIEWDIDLOAD")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the current session
        session = CDOperation.getCurrentSession()
        
        // Get the current routine
        navigationItem.title = CDOperation.getCurrentRoutine()
        
        loadArraysForCell()
        
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
        
        if debug == 1 {
            
            print("VIEWDIDAPPEAR")
        }
        
        // Get the current session
        session = CDOperation.getCurrentSession()
        
        // Get the current routine
        navigationItem.title = CDOperation.getCurrentRoutine()
        
        loadArraysForCell()
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
        
        self.adView.removeFromSuperview()
    }
    
    func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return sectionsArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return sectionsArray[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! MonthTVC_TableViewCell

        // Configure the cell...
        cell.titleLabel.text = sectionsArray[indexPath.section][indexPath.row] as? String
        
        var weekNum = NSInteger()
        
        switch indexPath.section {
        case 0:
            // Section 1
            // 1-4
            weekNum = indexPath.row + 1
            
        case 1:
            // Section 2
            // 5-8
            weekNum = indexPath.row + 5
            
        default:
            // Section 3
            if CDOperation.getCurrentRoutine() == "Normal" {
                
                //  Normal 9-13
                weekNum = indexPath.row + 9
            }
            else {
                
                // Tone 9-13
                weekNum = indexPath.row + 9
            }
        }
        
        if lightWorkoutList[indexPath.section][indexPath.row] as! Bool == false {
            
            // Don't show the "Light" label
            cell.detailLabel.isHidden = true
        }
        else {
            cell.detailLabel.isHidden = false
        }

        switch weekOfMonthColorList[indexPath.section][indexPath.row] as! String {
        case "One":
            cell.weekOfMonthTextField.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 191/255, alpha: 1.0)
            cell.weekOfMonthTextField.textColor = UIColor.white
            
        case "Two":
            cell.weekOfMonthTextField.backgroundColor = UIColor(red: 0/255, green: 104/255, blue: 159/255, alpha: 1.0)
            cell.weekOfMonthTextField.textColor = UIColor.white
            
        case "Three":
            cell.weekOfMonthTextField.backgroundColor = UIColor(red: 0/255, green: 84/255, blue: 127/255, alpha: 1.0)
            cell.weekOfMonthTextField.textColor = UIColor.white
            
        case "Four":
            cell.weekOfMonthTextField.backgroundColor = UIColor(red: 0/255, green: 63/255, blue: 95/255, alpha: 1.0)
            cell.weekOfMonthTextField.textColor = UIColor.white
            
        case "Five":
            cell.weekOfMonthTextField.backgroundColor = UIColor(red: 0/255, green: 42/255, blue: 63/255, alpha: 1.0)
            cell.weekOfMonthTextField.textColor = UIColor.white
            
        case "Orange":
            cell.weekOfMonthTextField.backgroundColor = UIColor (red: 242/255, green: 83/255, blue: 24/255, alpha: 1.0)
            cell.weekOfMonthTextField.textColor = UIColor.white
            
        case "White":
            cell.weekOfMonthTextField.backgroundColor = UIColor.white
            cell.weekOfMonthTextField.textColor = UIColor.black
            
        default: break
            
        }

        if self.weekCompleted(weekNum) {
            
            // Week completed so put a checkmark as the accessoryview icon
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "Colored_White_CheckMark"))
            cell.accessoryView = tempAccessoryView
            
//            if let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "Colored_White_CheckMark")) {
//                
//                cell.accessoryView = tempAccessoryView
//            }
        }
        else {
            
            // Week was NOT completed so put the arrow as the accessory view icon
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
            cell.accessoryView = tempAccessoryView
            
//            if let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow")) {
//                
//                cell.accessoryView = tempAccessoryView
//            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 3{
            
            return 20
        }
        else {
            return 10
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionTitle = ""
        
        if section == 3 {
            
            sectionTitle = "Bonus"
        }
        
        return sectionTitle
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toWeekWorkoutList" {
            
            let destinationVC = segue.destination as? WeekTVC
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.session = session
            destinationVC?.workoutRoutine = navigationItem.title!
            destinationVC?.workoutWeek = (sectionsArray[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            
            switch (selectedRow?.section)! as Int {
            case 0:
                // Month 1
                destinationVC?.month = "Month 1"
                
            case 1:
                // Month 2
                destinationVC?.month = "Month 2"
                
            case 2:
                // Month 3
                destinationVC?.month = "Month 3"
                
            default:
                // Month 4
                destinationVC?.month = "Month 4"
            }
        }
    }
    
    func loadArraysForCell() {
        
        switch navigationItem.title! {
        case "Normal":
            sectionsArray = [[Week.week1, Week.week2, Week.week3, Week.week4],
                             [Week.week5, Week.week6, Week.week7, Week.week8],
                             [Week.week9, Week.week10, Week.week11, Week.week12, Week.week13],
                             [Week.week14, Week.week15, Week.week16, Week.week17]]
            
            weekOfMonthColorList = [[Color.one, Color.one, Color.one, Color.orange],
                                    [Color.two, Color.two, Color.two, Color.orange],
                                    [Color.three, Color.four, Color.three, Color.four, Color.orange],
                                    [Color.five, Color.five, Color.five, Color.orange]]
            
            lightWorkoutList = [[false, false, false, true], [false, false, false, true], [false, false, false, false, true],
                                [false, false, false, true]]
            
        case "Tone":
            sectionsArray = [[Week.week1, Week.week2, Week.week3, Week.week4],
                             [Week.week5, Week.week6, Week.week7, Week.week8],
                             [Week.week9, Week.week10, Week.week11, Week.week12, Week.week13],
                             [Week.week14, Week.week15, Week.week16, Week.week17]]
            
            weekOfMonthColorList = [[Color.one, Color.one, Color.one, Color.orange],
                                    [Color.two, Color.two, Color.two, Color.orange],
                                    [Color.three, Color.four, Color.three, Color.four, Color.orange],
                                    [Color.five, Color.five, Color.five, Color.orange]]
            
            lightWorkoutList = [[false, false, false, true], [false, false, false, true], [false, false, false, false, true],
                                [false, false, false, true]]
            
        case "2-A-Days":
            sectionsArray = [[Week.week1, Week.week2, Week.week3, Week.week4],
                             [Week.week5, Week.week6, Week.week7, Week.week8],
                             [Week.week9, Week.week10, Week.week11, Week.week12, Week.week13],
                             [Week.week14, Week.week15, Week.week16, Week.week17]]
            
            weekOfMonthColorList = [[Color.one, Color.one, Color.one, Color.orange],
                                    [Color.two, Color.two, Color.two, Color.orange],
                                    [Color.three, Color.four, Color.three, Color.four, Color.orange],
                                    [Color.five, Color.five, Color.five, Color.orange]]
            
            lightWorkoutList = [[false, false, false, true], [false, false, false, true], [false, false, false, false, true],
                                [false, false, false, true]]

        case "Bulk":
            sectionsArray = [[Week.week1, Week.week2, Week.week3, Week.week4],
                             [Week.week5, Week.week6, Week.week7, Week.week8],
                             [Week.week9, Week.week10, Week.week11, Week.week12, Week.week13]]
            
            weekOfMonthColorList = [[Color.one, Color.one, Color.one, Color.orange],
                                    [Color.two, Color.two, Color.two, Color.orange],
                                    [Color.three, Color.four, Color.three, Color.four, Color.orange]]
            
            lightWorkoutList = [[false, false, false, true], [false, false, false, true], [false, false, false, false, true]]
            
        default:
            sectionsArray = [[], []]
        }
    }
    
    func longPressGRAction(_ sender: UILongPressGestureRecognizer) {
        
        if (sender.isEqual(self.longPGR)) {
            
            if (sender.state == UIGestureRecognizerState.began) {
                
                let p = sender.location(in: self.tableView)
                
                if let tempIndexPath = self.tableView.indexPathForRow(at: p) {
                    
                    // Only show the alertview if longpressed on a cell, not a section header.
                    self.indexPath = tempIndexPath
                    
                    // get affected cell
                    let cell = self.tableView.cellForRow(at: self.indexPath) as! MonthTVC_TableViewCell
                    
                    let titleText = cell.titleLabel.text
                    
                    let tempMessage = ("Set the status for all \(CDOperation.getCurrentRoutine())-\(titleText!) workouts.")
                    
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
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        let tempMessage = "Set the status for every week of \(CDOperation.getCurrentRoutine()) workouts."
        
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
    
    func AddDeleteDatesFromOneWeek() {
        
        switch self.request {
        case "Not Completed":
            
            // ***DELETE***
            
            switch CDOperation.getCurrentRoutine() {
            case "Normal":
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[1] as NSNumber)
                }

            case "Tone":
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[1] as NSNumber)
                }

            case "2-A-Days":
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[1] as NSNumber)
                }

            default:
                // Bulk
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[1] as NSNumber)
                }
            }
            
        default:
            
            // "Completed"
            // ***ADD***
            
            switch CDOperation.getCurrentRoutine() {
            case "Normal":
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
                
            case "Tone":
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }

            case "2-A-Days":
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }

            default:
                // Bulk
                let nameArray = CDOperation.loadWorkoutNameArray()[self.position]
                let indexArray = CDOperation.loadWorkoutIndexArray()[self.position]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
            }
        }
    }
    
    func AddDeleteDatesFromAllWeeks() {
        
        switch self.request {
        case "Not Completed":
            
            // ***DELETE***
            
            switch CDOperation.getCurrentRoutine() {
            case "Normal":
                // Normal
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber)
                    }
                }
                
            case "Tone":
                // Tone
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber)
                    }
                }

            case "2-A-Days":
                // 2-A-Days
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber)
                    }
                }
                
            default:
                // Bulk
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.deleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber)
                    }
                }
            }
            
        default:
            
            // "Completed"
            // ***ADD***
            
            switch CDOperation.getCurrentRoutine() {
            case "Normal":
                // Normal
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber, useDate: Date())
                    }
                }
                
            case "Tone":
                // Tone
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber, useDate: Date())
                    }
                }
                
            case "2-A-Days":
                // 2-A-Days
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber, useDate: Date())
                    }
                }

            default:
                // Bulk
                for i in 0..<CDOperation.loadWorkoutNameArray().count {
                    
                    let nameArray = CDOperation.loadWorkoutNameArray()[i]
                    let indexArray = CDOperation.loadWorkoutIndexArray()[i]
                    
                    for j in 0..<nameArray.count {
                        
                        CDOperation.saveWorkoutCompleteDate(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: nameArray[j] as NSString, index: indexArray[j] as NSNumber, useDate: Date())
                    }
                }
            }
        }
    }
    
    func verifyAddDeleteRequestFromTableViewCell() {
        
        // get affected cell
        let cell = self.tableView.cellForRow(at: self.indexPath) as! MonthTVC_TableViewCell
        
        self.position = self.findArrayPosition(self.indexPath)
        
        let titleText = cell.titleLabel.text
        
        let tempMessage = ("You are about to set the status for all \(CDOperation.getCurrentRoutine())-\(titleText!) workouts to:\n\n\(self.request)\n\nDo you want to proceed?")
        
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
    
    func verifyAddDeleteRequestFromBarButtonItem() {
        
        let tempMessage = ("You are about to set the status for every week of the \(CDOperation.getCurrentRoutine()) workout to:\n\n\(self.request)\n\nDo you want to proceed?")
        
        let alertController = UIAlertController(title: "Warning", message: tempMessage, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            self.AddDeleteDatesFromAllWeeks()
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
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
    
    func weekCompleted(_ week: NSInteger) -> Bool {
        
        var tempWorkoutNameArray = [String]()
        var tempWorkoutIndexArray = [Int]()
        var resultsArray = [String]()
        
        switch CDOperation.getCurrentRoutine() {
        case "Normal":
            
            // Get Build Workout Arrays
            tempWorkoutNameArray = CDOperation.loadWorkoutNameArray()[week - 1]
            tempWorkoutIndexArray = CDOperation.loadWorkoutIndexArray()[week - 1]
            
        default:
            
            // Get Tone Workout Arrays
            tempWorkoutNameArray = CDOperation.loadWorkoutNameArray()[week - 1]
            tempWorkoutIndexArray = CDOperation.loadWorkoutIndexArray()[week - 1]
        }
        
        for i in 0..<tempWorkoutIndexArray.count {
            
            let workoutCompletedObjects = CDOperation.getWorkoutCompletedObjects(CDOperation.getCurrentSession() as NSString, routine: CDOperation.getCurrentRoutine() as NSString, workout: tempWorkoutNameArray[i] as NSString, index: tempWorkoutIndexArray[i] as NSNumber)
            
            if workoutCompletedObjects.count != 0 {
                
                // Workout Completed
                resultsArray.insert("YES", at: i)
            }
            else {
                
                // Workout NOT Completed
                resultsArray.insert("NO", at: i)
            }
        }
        
        var workoutsCompleted = 0
        var completed = false
        
        // Complete when the week ones are finished
        switch CDOperation.getCurrentRoutine() {
        case "Normal":
            
            // ***Normal***
            switch week {
            case 1:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 2:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 3:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 4:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 5:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 6:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 7:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 8:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 9:
                
                var group1 = "NO"
                var group2 = "NO"
                var group3 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 2 || i == 3 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group2 = "YES"
                        }
                    }
                    
                    else if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group3 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 4 && group1 == "YES" && group2 == "YES" && group3 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 10:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }

            case 11:
                
                var group1 = "NO"
                var group2 = "NO"
                var group3 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 2 || i == 3 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group2 = "YES"
                        }
                    }
                        
                    else if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group3 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 4 && group1 == "YES" && group2 == "YES" && group3 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 12:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 13:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
                
                /// BONUS ///
            case 14:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 15:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 16:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }

            default:
                
                // Case 17
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
            }
          
        case "Tone":
            
            // ***TONE***
            switch week {
            case 1:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 2:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 3:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 4:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 5:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 6:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }

            case 7:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 8:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 9:
                
                var group1 = "NO"
                var group2 = "NO"
                var group3 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 2 || i == 3 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group2 = "YES"
                        }
                    }
                        
                    else if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group3 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 4 && group1 == "YES" && group2 == "YES" && group3 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 10:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 11:
                
                var group1 = "NO"
                var group2 = "NO"
                var group3 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 2 || i == 3 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group2 = "YES"
                        }
                    }
                        
                    else if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group3 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 4 && group1 == "YES" && group2 == "YES" && group3 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 12:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }

            case 13:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
                
            /// BONUS ///
            case 14:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 15:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 16:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 8 || i == 9 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            default:
                
                // Case 17
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
            }

        case "2-A-Days":
            
            // ***2-A-Days***
            switch week {
            case 1:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 10 || i == 11 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 10 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 2:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 10 || i == 11 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 10 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 3:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 10 || i == 11 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 10 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 4:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 5:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 11 || i == 12 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 11 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 6:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 11 || i == 12 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 11 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 7:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 11 || i == 12 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 11 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 8:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 7 || i == 8 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                     
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 7 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 9:
                
                var group1 = "NO"
                var group2 = "NO"
                var group3 = "NO"
                var group4 = "NO"
                var group5 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 4 || i == 5 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group2 = "YES"
                        }
                    }
                        
                    else if i == 12 || i == 13 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group3 = "YES"
                        }
                    }
                        
                    else if i == 14 || i == 15 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group4 = "YES"
                        }
                    }
                        
                    else if i == 16 || i == 17 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group5 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 &&
                    group1 == "YES" &&
                    group2 == "YES" &&
                    group3 == "YES" &&
                    group4 == "YES" &&
                    group5 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 10:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 12 || i == 13 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 12 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 11:
                
                var group1 = "NO"
                var group2 = "NO"
                var group3 = "NO"
                var group4 = "NO"
                var group5 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 4 || i == 5 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group2 = "YES"
                        }
                    }
                        
                    else if i == 12 || i == 13 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group3 = "YES"
                        }
                    }
                        
                    else if i == 14 || i == 15 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group4 = "YES"
                        }
                    }
                        
                    else if i == 16 || i == 17 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group5 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 8 &&
                    group1 == "YES" &&
                    group2 == "YES" &&
                    group3 == "YES" &&
                    group4 == "YES" &&
                    group5 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 12:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 12 || i == 13 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 12 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 13:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
                
            /// BONUS ///
            case 14:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 14 || i == 15 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 14 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 15:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 14 || i == 15 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 14 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 16:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 14 || i == 15 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 14 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            default:
                
                // Case 17
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
            }
            
        default:
            
            // ***Bulk***
            switch week {
            case 1:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 2:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 3:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 4:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }

            case 5:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 6:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 7:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 8:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 9:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 10:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 11:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            case 12:
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 6 || i == 7 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
                
            default:
                
                // Case 13
                
                var group1 = "NO"
                
                for i in 0..<resultsArray.count {
                    
                    if i == 5 || i == 6 {
                        
                        // User has a choice to do 1 of 2 workouts.  Only needs to do 1.
                        if resultsArray[i] == "YES" {
                            
                            group1 = "YES"
                        }
                    }
                        
                    else {
                        
                        // User needs to do all these workouts
                        if resultsArray[i] == "YES" {
                            
                            workoutsCompleted += 1
                        }
                    }
                }
                
                if workoutsCompleted == 6 && group1 == "YES" {
                    
                    completed = true
                }
                else {
                    
                    completed = false
                }
            }
        }
        
        return completed
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
