///
//  WorkoutTVC.swift
//  90 DWT 3
//
//  Created by Jared Grant on 6/25/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import Social
import CoreData

class WorkoutTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, MPAdViewDelegate {

    // **********
    let debug = 0
    // **********
    
    var session = ""
    var workoutRoutine = ""
    var selectedWorkout = ""
    var workoutWeek = ""
    var month = ""
    var workoutIndex = 0
    var graphButtonText = "Reward Video = 1hr Graph"
    var segmentedControlTitle = "Round 1"
    
    var graphViewPurchased = false
    var adView = MPAdView()
    var headerView = UIView()
    var bannerSize = CGSize()
    
    var timer = Timer()
    
    var selectedCellIdentifier = ""
    var workoutCompleteCell = WorkoutTVC_CompletionTableViewCell()
    
    var exerciseNameArray = [[], []]
    var exerciseRepsArray = [[], []]
    var cellArray = [[], []]
    
    fileprivate struct CellType {
        static let straight_1 = "WorkoutCell_Straight_1"
        static let straight_2 = "WorkoutCell_Straight_2"
        static let straight_4_Rep = "WorkoutCell_Straight_4_Rep"
        static let straight_4_Weight = "WorkoutCell_Straight_4_Weight"
        static let straight_5_Rep = "WorkoutCell_Straight_5_Rep"
        static let straight_5_Weight = "WorkoutCell_Straight_5_Weight"
        static let completion = "CompletionCell"
    }
    
    fileprivate struct Round {
        static let round1 = "Round 1"
        static let round2 = "Round 2"
        static let round3 = "Round 3"
        static let empty = ""
    }
    
    fileprivate struct LabelNumber {
        static let _6 = "6"
        static let _8 = "8"
        static let _10 = "10"
        static let _12 = "12"
        static let _16 = "16"
        static let empty = ""
    }

    fileprivate struct LabelTitle {
        static let reps = "R"
        static let reps_Long = "Reps"
        static let sec = "Sec"
        static let empty = ""
        static let weight = "W"
    }
    
    fileprivate struct Color {
        static let one = UIColor (red: 0/255, green: 125/255, blue: 191/255, alpha: 1)
        static let two = UIColor (red: 0/255, green: 97/255, blue: 148/255, alpha: 1)
        static let three = UIColor (red: 0/255, green: 70/255, blue: 106/255, alpha: 1)
        static let four = UIColor (red: 0/255, green: 42/255, blue: 63/255, alpha: 1)
        static let red = UIColor (red: 202/255, green: 20/255, blue: 34/255, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadExerciseNameArray(selectedWorkout)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
        
        // Add rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WorkoutTVC.actionButtonPressed(_:)))
        
        self.graphViewPurchased = self.wasGraphViewPurchased()
        
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

        self.graphViewPurchased = self.wasGraphViewPurchased()
        
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
        
        // Setup timer if reward video was viewed
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.shouldShowRewardGraph {
            
            //  Show the Reward Graph
            let now = Date()
            let calendar = Calendar.current
            
            // Calculate the time left from now til the Reward Graph expiration date
            let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: appDelegate.endDate as Date)
            let seconds = (diff.minute! * 60) + diff.second!
            
            // Set timer to disalbe access to Graph after the 1 hour is up
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(seconds), target: self, selector: #selector(self.disableRewardedGraph), userInfo: nil, repeats: false)
        }
        
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
        
        self.adView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }
    
    func disableRewardedGraph() {
        
        timer.invalidate()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldShowRewardGraph = false
        
        if !self.graphViewPurchased {
            // Graph not purchased yet
            // Reload data so that the graph button will now be disabled
            self.tableView.reloadData()
        }
    }
    
    func wasGraphViewPurchased() -> Bool {
        
        if Products.store.isProductPurchased("com.grantsoftware.90DWT3.slidergraph") {
            
            return true
        }
        else {
            
            return false
        }
    }

    func actionButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Share", message: "How you want to share your progress?", preferredStyle: .actionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: {
            action in
            
            self.sendEmail(CDOperation.singleWorkoutStringForEmail(self.selectedWorkout, index: self.workoutIndex))
        })
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: {
            action in
            
            if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
                let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                //            socialController.setInitialText("Hello World!")
                //            socialController.addImage(someUIImageInstance)
                //            socialController.addURL(someNSURLInstance)
                
                self.present(socialController!, animated: true, completion: nil)
            }
            else {
                
                let alertControllerError = UIAlertController(title: "Error", message: "Please ensure you are connected to the internet AND signed into the Facebook app on your device before posting to Facebook.", preferredStyle: .alert)
                
                let cancelActionError = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertControllerError.addAction(cancelActionError)
                
                if let popoverError = alertControllerError.popoverPresentationController {
                    
                    popoverError.barButtonItem = sender
                    popoverError.sourceView = self.view
                    popoverError.delegate = self
                    popoverError.permittedArrowDirections = .any
                }
                
                self.present(alertControllerError, animated: true, completion: nil)
            }
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: {
            action in
            
            if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
                let socialController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                //            socialController.setInitialText("Hello World!")
                //            socialController.addImage(someUIImageInstance)
                //            socialController.addURL(someNSURLInstance)
                
                self.present(socialController!, animated: true, completion: nil)
            }
            else {
                
                let alertControllerError = UIAlertController(title: "Error", message: "Please ensure you are connected to the internet AND signed into the Twitter app on your device before posting to Twitter.", preferredStyle: .alert)
                
                let cancelActionError = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertControllerError.addAction(cancelActionError)
                
                if let popoverError = alertControllerError.popoverPresentationController {
                    
                    popoverError.barButtonItem = sender
                    popoverError.sourceView = self.view
                    popoverError.delegate = self
                    popoverError.permittedArrowDirections = .any
                }
                
                self.present(alertControllerError, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(emailAction)
        alertController.addAction(facebookAction)
        alertController.addAction(twitterAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.barButtonItem = sender
            popover.sourceView = self.view
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func sendEmail(_ cvsString: String) {
        
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            // Send email
            let csvData = cvsString.data(using: String.Encoding.ascii)
            let subject = "90 DWT 3 Workout Data"
            let fileName = NSString .localizedStringWithFormat("%@ - Session %@.csv", self.navigationItem.title!, session)
            var emailAddress = [""]
            
            // Fetch defaultEmail data.
            let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Email")
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortDate]
            
            do {
                if let emailObjects = try CoreDataHelper.shared().context.fetch(request) as? [Email] {
                    
                    if debug == 1 {
                        
                        print("emailObjects.count = \(emailObjects.count)")
                    }
                    
                    if emailObjects.count != 0 {
                        
                        // There is a default email address.
                        emailAddress = [(emailObjects.last?.defaultEmail)!]
                    }
                    else {
                        
                        // There is NOT a default email address.  Put an empty email address in the arrary.
                        emailAddress = [""]
                    }
                }
                
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            mailcomposer.setToRecipients(emailAddress)
            mailcomposer.setSubject(subject as String)
            mailcomposer.addAttachmentData(csvData!, mimeType: "text/csv", fileName: fileName as String)
            
            present(mailcomposer, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return cellArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        return cellArray[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let workoutObject = cellArray[indexPath.section][indexPath.row] as? NSArray {
            
            if let cellIdentifierArray = workoutObject[5] as? [String] {
                
                let cellIdentifier = cellIdentifierArray[0]
                
                if cellIdentifier == "WorkoutCell_Straight_1" || cellIdentifier == "WorkoutCell_Straight_2" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_WorkoutTableViewCell
                    
                    let titleArray = workoutObject[0] as? NSArray
                    cell.title.text = (titleArray![0] as AnyObject).uppercased
                    cell.nonUpperCaseExerciseName = titleArray![0] as! String

                    cell.workoutRoutine = workoutRoutine // Bulk or Tone
                    cell.selectedWorkout = selectedWorkout // B1: Chest+Tri etc...
                    cell.workoutIndex = workoutIndex // Index of the workout in the program
                    cell.session = session
                    cell.workoutWeek = workoutWeek
                    cell.month = month

                    if let roundNumbers = workoutObject[1] as? [String] {
                        
                        cell.roundLabel1.text = roundNumbers[0].uppercased()
                        cell.roundLabel2.text = roundNumbers[1].uppercased()
//                        cell.roundLabel3.text = roundNumbers[2]
//                        cell.roundLabel4.text = roundNumbers[3]
//                        cell.roundLabel5.text = roundNumbers[4]
//                        cell.roundLabel6.text = roundNumbers[5]
                    }
                    
                    if let labelTypeTitles = workoutObject[2] as? [String] {
                        
                        // Round 1
                        cell.repLabel1.text = labelTypeTitles[0]
                        cell.weightLabel1.text = labelTypeTitles[1]
                        
                        // Round 2
                        cell.repLabel2.text = labelTypeTitles[2]
                        cell.weightLabel2.text = labelTypeTitles[3]
                        
//                        // Round3
//                        cell.repLabel3.text = labelTypeTitles[4]
//                        cell.weightLabel3.text = labelTypeTitles[5]
                    }
                    
                    if let cellColor = workoutObject[3] as? [UIColor] {
                        
                        // Round 1
                        cell.currentRep1.backgroundColor = cellColor[0]
                        cell.currentWeight1.backgroundColor = cellColor[1]
                        
                        // Round 2
                        cell.currentRep2.backgroundColor = cellColor[2]
                        cell.currentWeight2.backgroundColor = cellColor[3]
                        
//                        // Round 3
//                        cell.currentRep3.backgroundColor = cellColor[4]
//                        cell.currentWeight3.backgroundColor = cellColor[5]
                        
                        if titleArray![0] as! String == "BONUS Military Push-Ups" ||
                            titleArray![0] as! String == "BONUS Wide Pull-Ups" ||
                            titleArray![0] as! String == "BONUS Push-Ups Plank Sphinx" ||
                            titleArray![0] as! String == "BONUS Pull-Up Push-Up"
                        {
                            
                            cell.repLabel1.backgroundColor = Color.red
                        }
                    }
                    
                    if let textFields = workoutObject[4] as? [Bool] {
                        
                        // PREVIOUS
                        // Round 1
                        cell.repLabel1.isHidden = textFields[0]
                        cell.previousRep1.isHidden = textFields[0]
                        
                        if textFields[1] {
                            cell.weightLabel1.text = ""
                        }
                        cell.previousWeight1.isHidden = textFields[1]
                        
                        // Round 2
                        cell.repLabel2.isHidden = textFields[2]
                        cell.previousRep2.isHidden = textFields[2]
                        
                        if textFields[3] {
                            cell.weightLabel2.text = ""
                        }
                        cell.previousWeight2.isHidden = textFields[3]
                        
//                        // Round 3
//                        cell.repLabel3.isHidden = textFields[4]
//                        cell.previousRep3.isHidden = textFields[4]
//                        
//                        if textFields[5] {
//                            cell.weightLabel3.text = ""
//                        }
//                        cell.previousWeight3.isHidden = textFields[5]
                        
                        // CURRENT
                        // Round 1
                        cell.currentRep1.isHidden = textFields[0]
                        cell.currentWeight1.isHidden = textFields[1]
                        
                        // Round 2
                        cell.currentRep2.isHidden = textFields[2]
                        cell.currentWeight2.isHidden = textFields[3]
                        
//                        // Round 3
//                        cell.currentRep3.isHidden = textFields[4]
//                        cell.currentWeight3.isHidden = textFields[5]
                    }
                    
                    cell.currentRep1.text = "0.0"
                    cell.currentRep2.text = "0.0"
//                    cell.currentRep3.text = "0.0"
                    cell.currentWeight1.text = "0.0"
                    cell.currentWeight2.text = "0.0"
//                    cell.currentWeight3.text = "0.0"
                    cell.currentNotes.text = "CURRENT NOTES"
                    
                    cell.originalCurrentRep1_Text = "0.0"
                    cell.originalCurrentRep2_Text = "0.0"
//                    cell.originalCurrentRep3_Text = "0.0"
                    cell.originalCurrentWeight1_Text = "0.0"
                    cell.originalCurrentWeight2_Text = "0.0"
//                    cell.originalCurrentWeight3_Text = "0.0"
                    cell.originalCurrentNotes_Text = "CURRENT NOTES"
                    
                    cell.previousRep1.text = "0.0"
                    cell.previousRep2.text = "0.0"
//                    cell.previousRep3.text = "0.0"
                    cell.previousWeight1.text = "0.0"
                    cell.previousWeight2.text = "0.0"
//                    cell.previousWeight3.text = "0.0"
                    cell.previousNotes.text = "PREVIOUS NOTES"

                    // Current Rep Fields and Notes
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(session, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: workoutIndex as NSNumber) as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }

                        for object in workoutObjects {
                            
                            // Reps
                            var tempReps = ""
                            
                            if object.reps != nil {
                                
                                tempReps = object.reps!
                            }
                            else {
                                
                                tempReps = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Reps = \(tempReps)")
                            }
                            
                            // Weight
                            var tempWeight = ""
                            
                            if object.weight != nil {
                                
                                tempWeight = object.weight!
                            }
                            else {
                                
                                tempWeight = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Weight = \(tempWeight)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                // Switch on the Round
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    // Reps
                                    if object.reps != nil {
                                        
                                        cell.currentRep1.text = object.reps
                                        cell.originalCurrentRep1_Text = object.reps!
                                    }
                                    else {
                                        cell.currentRep1.text = "0.0"
                                        cell.originalCurrentRep1_Text = "0.0"
                                    }

                                    // Weight
                                    if object.weight != nil {
                                        
                                        cell.currentWeight1.text = object.weight
                                        cell.originalCurrentWeight1_Text = object.weight!
                                    }
                                    else {
                                        cell.currentWeight1.text = "0.0"
                                        cell.originalCurrentWeight1_Text = "0.0"
                                    }
                                    
                                    // Notes
                                    if object.notes != nil {
                                        
                                        cell.currentNotes.text = object.notes?.uppercased()
                                        cell.originalCurrentNotes_Text = object.notes!.uppercased()
                                    }
                                    else {
                                        
                                        cell.currentNotes.text = "CURRENT NOTES"
                                        cell.originalCurrentNotes_Text = "CURRENT NOTES"
                                    }

                                case 1:
                                    // Reps
                                    if object.reps != nil {
                                        
                                        cell.currentRep2.text = object.reps
                                        cell.originalCurrentRep2_Text = object.reps!
                                    }
                                    else {
                                        
                                        cell.currentRep2.text = "0.0"
                                        cell.originalCurrentRep2_Text = "0.0"
                                    }

                                    // Weight
                                    if object.weight != nil {
                                       
                                        cell.currentWeight2.text = object.weight
                                        cell.originalCurrentWeight2_Text = object.weight!
                                    }
                                    else {
                                        
                                        cell.currentWeight2.text = "0.0"
                                        cell.originalCurrentWeight2_Text = "0.0"
                                    }
                                    
//                                case 2:
//                                    if object.weight != nil {
//                                        
//                                        cell.currentWeight3.text = object.weight
//                                        cell.originalCurrentWeight3_Text = object.weight!
//                                    }
//                                    else {
//                                        
//                                        cell.currentWeight3.text = "0.0"
//                                        cell.originalCurrentWeight3_Text = "0.0"
//                                    }
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }

                    // Previous Weight Fields
                    
                    var localSession = ""
                    var localIndex = 0
                    
                    // Get previous data based on if the user selected to import the previous session's last index data for each workout to use on the 1st index of each workout.  Will be placed in the Previous Text Field box.
                    
                    if workoutIndex == 1 && CDOperation.getImportPreviousSessionData() == true {
                        
                        //  Get the previous session last index data for this workout
                        let tempSession = Int(self.session)! - 1
                        localSession = String(tempSession)
                        
                        localIndex = CDOperation.findMaxIndexForWorkout(routine: self.workoutRoutine, workoutName: self.selectedWorkout)
                    }
                    else {
                        
                        // Either the user didn't want to import the previous session data or it is not the 1st index workout
                        localSession = self.session
                        localIndex = self.workoutIndex - 1
                    }
                    
                    
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(localSession, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: localIndex as NSNumber) as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }
                        
                        for object in workoutObjects {
                            
                            // Reps
                            var tempReps = ""
                            
                            if object.reps != nil {
                                
                                tempReps = object.reps!
                            }
                            else {
                                
                                tempReps = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Reps = \(tempReps)")
                            }

                            // Weight
                            var tempWeight = ""
                            
                            if object.weight != nil {
                                
                                tempWeight = object.weight!
                            }
                            else {
                                
                                tempWeight = "0.0"
                            }

                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Weight = \(tempWeight)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    cell.previousRep1.text = object.reps
                                    cell.previousWeight1.text = object.weight
                                    
                                    cell.previousNotes.text = object.notes?.uppercased()
                                    
                                case 1:
                                    cell.previousRep2.text = object.reps
                                    cell.previousWeight2.text = object.weight
                                    
//                                case 2:
//                                    cell.previousRep3.text = object.reps
//                                    cell.previousWeight3.text = object.weight
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                    
                    
                    
                                        
                    
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    if self.graphViewPurchased {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("GraphView was purchased")
                        }
                    }
                    else if appDelegate.shouldShowRewardGraph {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("Reward GraphView was purchased")
                        }
                    }
                    else {
                        
                        cell.graphButton.isHidden = true
                        cell.rewardVideoButton.isHidden = false
                    }
                    
                    
                    
                    
                    
                    
//                    //  TESTING PURPOSES ONLY!!!  COMMENT OUT WHEN DONE TAKING SCREENSHOTS
//                    cell.graphButton.isHidden = false
                    
                    
                    return cell
                }
                else if cellIdentifier == "WorkoutCell_Straight_4_Rep" || cellIdentifier == "WorkoutCell_Straight_5_Rep" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_Workout5Round_Rep_TableViewCell
                    
                    let titleArray = workoutObject[0] as? NSArray
                    cell.title.text = (titleArray![0] as AnyObject).uppercased
                    cell.nonUpperCaseExerciseName = titleArray![0] as! String
                    
                    cell.workoutRoutine = workoutRoutine // Bulk or Tone
                    cell.selectedWorkout = selectedWorkout // B1: Chest+Tri etc...
                    cell.workoutIndex = workoutIndex // Index of the workout in the program
                    cell.session = session
                    cell.workoutWeek = workoutWeek
                    cell.month = month
                    
                    if let repNumbers = workoutObject[1] as? [String] {
                        
                        cell.repNumberLabel1.text = repNumbers[0]
                        cell.repNumberLabel2.text = repNumbers[1]
                        cell.repNumberLabel3.text = repNumbers[2]
                        cell.repNumberLabel4.text = repNumbers[3]
                        cell.repNumberLabel5.text = repNumbers[4]
//                        cell.repNumberLabel6.text = repNumbers[5]
                    }
                    
                    if let repTitles = workoutObject[2] as? [String] {
                        
                        cell.repTitleLabel1.text = repTitles[0]
                        cell.repTitleLabel2.text = repTitles[1]
                        cell.repTitleLabel3.text = repTitles[2]
                        cell.repTitleLabel4.text = repTitles[3]
                        cell.repTitleLabel5.text = repTitles[4]
//                        cell.repTitleLabel6.text = repTitles[5]
                    }
                    
                    if let cellColor = workoutObject[3] as? [UIColor] {
                        
                        cell.currentReps1.backgroundColor = cellColor[0]
                        cell.currentReps2.backgroundColor = cellColor[1]
                        cell.currentReps3.backgroundColor = cellColor[2]
                        cell.currentReps4.backgroundColor = cellColor[3]
                        cell.currentReps5.backgroundColor = cellColor[4]
//                        cell.currentReps6.backgroundColor = cellColor[5]
                    }
                    
                    if let weightFields = workoutObject[4] as? [Bool] {
                        
                        // PREVIOUS
                        cell.currentReps1.isHidden = weightFields[0]
                        cell.currentReps2.isHidden = weightFields[1]
                        cell.currentReps3.isHidden = weightFields[2]
                        cell.currentReps4.isHidden = weightFields[3]
                        cell.currentReps5.isHidden = weightFields[4]
//                        cell.currentReps6.isHidden = weightFields[5]
                        
                        // CURRENT
                        cell.currentReps1.isHidden = weightFields[0]
                        cell.currentReps2.isHidden = weightFields[1]
                        cell.currentReps3.isHidden = weightFields[2]
                        cell.currentReps4.isHidden = weightFields[3]
                        cell.currentReps5.isHidden = weightFields[4]
//                        cell.ccurrentReps6.isHidden = weightFields[5]
                    }
                    
                    cell.currentReps1.text = "0.0"
                    cell.currentReps2.text = "0.0"
                    cell.currentReps3.text = "0.0"
                    cell.currentReps4.text = "0.0"
                    cell.currentReps5.text = "0.0"
//                    cell.currentReps6.text = "0.0"
                    cell.currentNotes.text = "CURRENT NOTES"
                    
                    cell.originalCurrentRep1_Text = "0.0"
                    cell.originalCurrentRep2_Text = "0.0"
                    cell.originalCurrentRep3_Text = "0.0"
                    cell.originalCurrentRep4_Text = "0.0"
                    cell.originalCurrentRep5_Text = "0.0"
//                    cell.ooriginalCurrentRep6_Text = "0.0"
                    cell.originalCurrentNotes_Text = "CURRENT NOTES"
                    
                    cell.previousReps1.text = "0.0"
                    cell.previousReps2.text = "0.0"
                    cell.previousReps3.text = "0.0"
                    cell.previousReps4.text = "0.0"
                    cell.previousReps5.text = "0.0"
//                    cell.previousReps6.text = "0.0"
                    cell.previousNotes.text = "PREVIOUS NOTES"
                    
                    // Current Rep Fields and Notes
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(session, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: workoutIndex as NSNumber)  as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }
                        
                        for object in workoutObjects {
                            
                            var tempRep = ""
                            
                            if object.reps != nil {
                                
                                tempRep = object.reps!
                            }
                            else {
                                
                                tempRep = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Reps = \(tempRep)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    if object.reps != nil {
                                        
                                        cell.currentReps1.text = object.reps
                                        cell.originalCurrentRep1_Text = object.reps!
                                    }
                                    else {
                                        cell.currentReps1.text = "0.0"
                                        cell.originalCurrentRep1_Text = "0.0"
                                    }
                                    
                                    // Notes
                                    if object.notes != nil {
                                        
                                        cell.currentNotes.text = object.notes?.uppercased()
                                        cell.originalCurrentNotes_Text = object.notes!.uppercased()
                                    }
                                    else {
                                        
                                        cell.currentNotes.text = "CURRENT NOTES"
                                        cell.originalCurrentNotes_Text = "CURRENT NOTES"
                                    }
                                    
                                case 1:
                                    if object.reps != nil {
                                        
                                        cell.currentReps2.text = object.reps
                                        cell.originalCurrentRep2_Text = object.reps!
                                    }
                                    else {
                                        
                                        cell.currentReps2.text = "0.0"
                                        cell.originalCurrentRep2_Text = "0.0"
                                    }
                                    
                                case 2:
                                    if object.reps != nil {
                                        
                                        cell.currentReps3.text = object.reps
                                        cell.originalCurrentRep3_Text = object.reps!
                                    }
                                    else {
                                        
                                        cell.currentReps3.text = "0.0"
                                        cell.originalCurrentRep3_Text = "0.0"
                                    }
                                    
                                case 3:
                                    if object.reps != nil {
                                        
                                        cell.currentReps4.text = object.reps
                                        cell.originalCurrentRep4_Text = object.reps!
                                    }
                                    else {
                                        
                                        cell.currentReps4.text = "0.0"
                                        cell.originalCurrentRep4_Text = "0.0"
                                    }
                                    
                                case 4:
                                    if object.reps != nil {
                                        
                                        cell.currentReps5.text = object.reps
                                        cell.originalCurrentRep5_Text = object.reps!
                                    }
                                    else {
                                        
                                        cell.currentReps5.text = "0.0"
                                        cell.originalCurrentRep5_Text = "0.0"
                                    }
                                    
//                                case 5:
//                                    if object.weight != nil {
//                                        
//                                        cell.currentWeight6.text = object.weight
//                                        cell.originalCurrentWeight6_Text = object.weight!
//                                        
//                                    }
//                                    else {
//                                        
//                                        cell.currentWeight6.text = "0.0"
//                                        cell.originalCurrentWeight6_Text = "0.0"
//                                    }
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                    
                    // Previous Reps Fields and Notes
                    
                    var localSession = ""
                    var localIndex = 0
                    
                    // Get previous data based on if the user selected to import the previous session's last index data for each workout to use on the 1st index of each workout.  Will be placed in the Previous Text Field box.
                    
                    if workoutIndex == 1 && CDOperation.getImportPreviousSessionData() == true {
                        
                        //  Get the previous session last index data for this workout
                        let tempSession = Int(self.session)! - 1
                        localSession = String(tempSession)
                        
                        localIndex = CDOperation.findMaxIndexForWorkout(routine: self.workoutRoutine, workoutName: self.selectedWorkout)
                    }
                    else {
                        
                        // Either the user didn't want to import the previous session data or it is not the 1st index workout
                        localSession = self.session
                        localIndex = self.workoutIndex - 1
                    }
                    
                    
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(localSession, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: localIndex as NSNumber) as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }
                        
                        for object in workoutObjects {
                            
                            var tempReps = ""
                            
                            if object.reps != nil {
                                
                                tempReps = object.reps!
                            }
                            else {
                                
                                tempReps = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Reps = \(tempReps)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    cell.previousReps1.text = object.reps
                                    
                                    cell.previousNotes.text = object.notes?.uppercased()
                                    
                                case 1:
                                    cell.previousReps2.text = object.reps
                                    
                                case 2:
                                    cell.previousReps3.text = object.reps
                                    
                                case 3:
                                    cell.previousReps4.text = object.reps
                                    
                                case 4:
                                    cell.previousReps5.text = object.reps
                                    
//                                case 5:
//                                    cell.previousReps6.text = object.reps
//                                    cell.previousNotes.text = object.notes?.uppercased()
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    if self.graphViewPurchased {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("GraphView was purchased")
                        }
                    }
                    else if appDelegate.shouldShowRewardGraph {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("Reward GraphView was purchased")
                        }
                    }
                    else {
                        
                        cell.graphButton.isHidden = true
                        cell.rewardVideoButton.isHidden = false
                    }
                    
                    
                    
                    
                    
                    
//                    //  TESTING PURPOSES ONLY!!!  COMMENT OUT WHEN DONE TAKING SCREENSHOTS
//                    cell.graphButton.isHidden = false
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    return cell
                }
                else if cellIdentifier == "WorkoutCell_Straight_4_Weight" || cellIdentifier == "WorkoutCell_Straight_5_Weight" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_Workout5Round_Weight_TableViewCell
                    
                    let titleArray = workoutObject[0] as? NSArray
                    cell.title.text = (titleArray![0] as AnyObject).uppercased
                    cell.nonUpperCaseExerciseName = titleArray![0] as! String
                    
                    cell.workoutRoutine = workoutRoutine // Bulk or Tone
                    cell.selectedWorkout = selectedWorkout // B1: Chest+Tri etc...
                    cell.workoutIndex = workoutIndex // Index of the workout in the program
                    cell.session = session
                    cell.workoutWeek = workoutWeek
                    cell.month = month
                    
                    if let repNumbers = workoutObject[1] as? [String] {
                        
                        cell.repNumberLabel1.text = repNumbers[0]
                        cell.repNumberLabel2.text = repNumbers[1]
                        cell.repNumberLabel3.text = repNumbers[2]
                        cell.repNumberLabel4.text = repNumbers[3]
                        cell.repNumberLabel5.text = repNumbers[4]
                        //                        cell.repNumberLabel6.text = repNumbers[5]
                    }
                    
                    if let repTitles = workoutObject[2] as? [String] {
                        
                        cell.repTitleLabel1.text = repTitles[0]
                        cell.repTitleLabel2.text = repTitles[1]
                        cell.repTitleLabel3.text = repTitles[2]
                        cell.repTitleLabel4.text = repTitles[3]
                        cell.repTitleLabel5.text = repTitles[4]
                        //                        cell.repTitleLabel6.text = repTitles[5]
                    }
                    
                    if let cellColor = workoutObject[3] as? [UIColor] {
                        
                        cell.currentWeight1.backgroundColor = cellColor[0]
                        cell.currentWeight2.backgroundColor = cellColor[1]
                        cell.currentWeight3.backgroundColor = cellColor[2]
                        cell.currentWeight4.backgroundColor = cellColor[3]
                        cell.currentWeight5.backgroundColor = cellColor[4]
                        //                        cell.currentWeight6.backgroundColor = cellColor[5]
                    }
                    
                    if let weightFields = workoutObject[4] as? [Bool] {
                        
                        // PREVIOUS
                        cell.previousWeight1.isHidden = weightFields[0]
                        cell.previousWeight2.isHidden = weightFields[1]
                        cell.previousWeight3.isHidden = weightFields[2]
                        cell.previousWeight4.isHidden = weightFields[3]
                        cell.previousWeight5.isHidden = weightFields[4]
                        //                        cell.previousWeight6.isHidden = weightFields[5]
                        
                        // CURRENT
                        cell.currentWeight1.isHidden = weightFields[0]
                        cell.currentWeight2.isHidden = weightFields[1]
                        cell.currentWeight3.isHidden = weightFields[2]
                        cell.currentWeight4.isHidden = weightFields[3]
                        cell.currentWeight5.isHidden = weightFields[4]
                        //                        cell.currentWeight6.isHidden = weightFields[5]
                    }
                    
                    cell.currentWeight1.text = "0.0"
                    cell.currentWeight2.text = "0.0"
                    cell.currentWeight3.text = "0.0"
                    cell.currentWeight4.text = "0.0"
                    cell.currentWeight5.text = "0.0"
                    //                    cell.currentWeight6.text = "0.0"
                    cell.currentNotes.text = "CURRENT NOTES"
                    
                    cell.originalCurrentWeight1_Text = "0.0"
                    cell.originalCurrentWeight2_Text = "0.0"
                    cell.originalCurrentWeight3_Text = "0.0"
                    cell.originalCurrentWeight4_Text = "0.0"
                    cell.originalCurrentWeight5_Text = "0.0"
                    //                    cell.originalCurrentWeight6_Text = "0.0"
                    cell.originalCurrentNotes_Text = "CURRENT NOTES"
                    
                    cell.previousWeight1.text = "0.0"
                    cell.previousWeight2.text = "0.0"
                    cell.previousWeight3.text = "0.0"
                    cell.previousWeight4.text = "0.0"
                    cell.previousWeight5.text = "0.0"
                    //                    cell.previousWeight6.text = "0.0"
                    cell.previousNotes.text = "PREVIOUS NOTES"
                    
                    // Current Weight Fields and Notes
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(session, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: workoutIndex as NSNumber)  as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }
                        
                        for object in workoutObjects {
                            
                            var tempWeight = ""
                            
                            if object.weight != nil {
                                
                                tempWeight = object.weight!
                            }
                            else {
                                
                                tempWeight = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Weight = \(tempWeight)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    if object.weight != nil {
                                        
                                        cell.currentWeight1.text = object.weight
                                        cell.originalCurrentWeight1_Text = object.weight!
                                    }
                                    else {
                                        cell.currentWeight1.text = "0.0"
                                        cell.originalCurrentWeight1_Text = "0.0"
                                    }
                                    
                                    // Notes
                                    if object.notes != nil {
                                        
                                        cell.currentNotes.text = object.notes?.uppercased()
                                        cell.originalCurrentNotes_Text = object.notes!.uppercased()
                                    }
                                    else {
                                        
                                        cell.currentNotes.text = "CURRENT NOTES"
                                        cell.originalCurrentNotes_Text = "CURRENT NOTES"
                                    }
                                    
                                case 1:
                                    if object.weight != nil {
                                        
                                        cell.currentWeight2.text = object.weight
                                        cell.originalCurrentWeight2_Text = object.weight!
                                    }
                                    else {
                                        
                                        cell.currentWeight2.text = "0.0"
                                        cell.originalCurrentWeight2_Text = "0.0"
                                    }
                                    
                                case 2:
                                    if object.weight != nil {
                                        
                                        cell.currentWeight3.text = object.weight
                                        cell.originalCurrentWeight3_Text = object.weight!
                                    }
                                    else {
                                        
                                        cell.currentWeight3.text = "0.0"
                                        cell.originalCurrentWeight3_Text = "0.0"
                                    }
                                    
                                case 3:
                                    if object.weight != nil {
                                        
                                        cell.currentWeight4.text = object.weight
                                        cell.originalCurrentWeight4_Text = object.weight!
                                    }
                                    else {
                                        
                                        cell.currentWeight4.text = "0.0"
                                        cell.originalCurrentWeight4_Text = "0.0"
                                    }
                                    
                                case 4:
                                    if object.weight != nil {
                                        
                                        cell.currentWeight5.text = object.weight
                                        cell.originalCurrentWeight5_Text = object.weight!
                                    }
                                    else {
                                        
                                        cell.currentWeight5.text = "0.0"
                                        cell.originalCurrentWeight5_Text = "0.0"
                                    }
                                    
                                    //                                case 5:
                                    //                                    if object.weight != nil {
                                    //
                                    //                                        cell.currentWeight6.text = object.weight
                                    //                                        cell.originalCurrentWeight6_Text = object.weight!
                                    //
                                    //                                    }
                                    //                                    else {
                                    //
                                    //                                        cell.currentWeight6.text = "0.0"
                                    //                                        cell.originalCurrentWeight6_Text = "0.0"
                                    //                                    }
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                    
                    // Previous Weight Fields and Notes
                    
                    var localSession = ""
                    var localIndex = 0
                    
                    // Get previous data based on if the user selected to import the previous session's last index data for each workout to use on the 1st index of each workout.  Will be placed in the Previous Text Field box.
                    
                    if workoutIndex == 1 && CDOperation.getImportPreviousSessionData() == true {
                        
                        //  Get the previous session last index data for this workout
                        let tempSession = Int(self.session)! - 1
                        localSession = String(tempSession)
                        
                        localIndex = CDOperation.findMaxIndexForWorkout(routine: self.workoutRoutine, workoutName: self.selectedWorkout)
                    }
                    else {
                        
                        // Either the user didn't want to import the previous session data or it is not the 1st index workout
                        localSession = self.session
                        localIndex = self.workoutIndex - 1
                    }
                    
                    
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(localSession, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: localIndex as NSNumber) as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }
                        
                        for object in workoutObjects {
                            
                            var tempWeight = ""
                            
                            if object.weight != nil {
                                
                                tempWeight = object.weight!
                            }
                            else {
                                
                                tempWeight = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Weight = \(tempWeight)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    cell.previousWeight1.text = object.weight
                                    
                                    cell.previousNotes.text = object.notes?.uppercased()
                                    
                                case 1:
                                    cell.previousWeight2.text = object.weight
                                    
                                case 2:
                                    cell.previousWeight3.text = object.weight
                                    
                                case 3:
                                    cell.previousWeight4.text = object.weight
                                    
                                case 4:
                                    cell.previousWeight5.text = object.weight
                                    
                                    //                                case 5:
                                    //                                    cell.previousWeight6.text = object.weight
                                    //                                    cell.previousNotes.text = object.notes?.uppercased()
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    if self.graphViewPurchased {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("GraphView was purchased")
                        }
                    }
                    else if appDelegate.shouldShowRewardGraph {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("Reward GraphView was purchased")
                        }
                    }
                    else {
                        
                        cell.graphButton.isHidden = true
                        cell.rewardVideoButton.isHidden = false
                    }
                    
                    
                    
                    
                    
                    
//                    //  TESTING PURPOSES ONLY!!!  COMMENT OUT WHEN DONE TAKING SCREENSHOTS
//                    cell.graphButton.isHidden = false
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    return cell
                }

                else {
                    
                    // CompletionCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_CompletionTableViewCell
                    
                    cell.workoutRoutine = workoutRoutine // Bulk or Tone
                    cell.selectedWorkout = selectedWorkout // B1: Chest+Tri etc...
                    cell.workoutIndex = workoutIndex // Index of the workout in the program
                    cell.session = session
                    cell.indexPath = indexPath
                    
                    cell.updateWorkoutCompleteCellUI()
                    
                    cell.previousDateButton.addTarget(self, action: #selector(WorkoutTVC.previousButtonPressed(_:)), for: .touchUpInside)
                    
                    workoutCompleteCell = cell
                    
                    return cell
                }
            }
        }
        
        let emptyCell = UITableViewCell()
        
        return emptyCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headerString = ""
        
        if numberOfSections(in: tableView) == 2 && section != numberOfSections(in: tableView) - 1 {
            
            headerString = "Set \(section + 1) of \(numberOfSections(in: tableView) - 1)"
        }
        else if numberOfSections(in: tableView) >= 3 && section < numberOfSections(in: tableView) - 2 {
            
            headerString = "Set \(section + 1) of \(numberOfSections(in: tableView) - 1)"
        }
        else if numberOfSections(in: tableView) >= 3 && section == numberOfSections(in: tableView) - 2 {
            
            headerString = "Set \(section + 1) of \(numberOfSections(in: tableView) - 1) - BONUS"
        }
        else {
            
            headerString = "Finished"
        }
        
        return headerString
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Set the color of the header/footer text
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
        // Set the background color of the header/footer
        if numberOfSections(in: tableView) >= 3 && section == numberOfSections(in: tableView) - 2 {
         
            header.contentView.backgroundColor = Color.red
        }
        else {
            
            header.contentView.backgroundColor = UIColor (red: 60/255, green: 153/255, blue: 202/255, alpha: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        if selectedCellIdentifier == "PreviousButtonPressed" {
            
            workoutCompleteCell.updateWorkoutCompleteCellUI()
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        
        if debug == 1 {
            
            print("Previous Button Pressed")
        }

        selectedCellIdentifier = "PreviousButtonPressed"
        
        let popOverContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        
        popOverContent.session = session
        popOverContent.workoutRoutine = workoutRoutine
        popOverContent.selectedWorkout = selectedWorkout
        popOverContent.workoutIndex = workoutIndex
        
        popOverContent.modalPresentationStyle = .popover
        
        let popOver = popOverContent.popoverPresentationController
        popOver?.sourceView = sender
        popOver?.sourceRect = sender.bounds
        popOver?.permittedArrowDirections = .any
        popOver?.delegate = self
        
        present(popOverContent, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "WorkoutCell_Straight_1" ||
            segue.identifier == "WorkoutCell_Straight_2" {
            
            let destinationNavController = segue.destination as? UINavigationController
            let destinationVC = destinationNavController?.topViewController as! ExerciseChartViewController
            
            destinationVC.session = self.session
            destinationVC.workoutRoutine = self.workoutRoutine
            destinationVC.selectedWorkout = self.selectedWorkout
            destinationVC.workoutIndex = self.workoutIndex
            destinationVC.segueIdentifier = segue.identifier!
            
            let button = sender as! UIButton
            let view = button.superview
            
            //  WorkoutTVC_WorkoutTableViewCell
            //  Round 1 and 2 with Reps and/or Weight
            let cell = view?.superview as! WorkoutTVC_WorkoutTableViewCell
            
            destinationVC.exerciseName = cell.nonUpperCaseExerciseName
            destinationVC.navigationItem.title = CDOperation.trimStringForWorkoutName(self.selectedWorkout)
            
            // Find the number of series to show on the graph and pass it to ExerciseChartViewController
            // Find the series configuration to layout the graph and pass it to ExerciseChartViewController
            // 0 = OFF
            // 1 = ON
            if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == false &&
                cell.currentWeight1.isHidden == false &&
                cell.currentWeight2.isHidden == false {
                
                //  Both round 1 and round 2 Reps and Weight fields are showing
                destinationVC.numberOfSeriesToShow = 4
                destinationVC.seriesConfiguration = 1111 // ON, ON, ON, ON
            }
            else if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == false &&
                cell.currentWeight1.isHidden == true &&
                cell.currentWeight2.isHidden == true {
                
                //  Only round 1 and round 2 Reps fields are showing
                destinationVC.numberOfSeriesToShow = 2
                destinationVC.seriesConfiguration = 1010 // ON, OFF, ON, OFF
            }
            else if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == true &&
                cell.currentWeight1.isHidden == false &&
                cell.currentWeight2.isHidden == true {
                
                //  Only round 1 Reps and Weight fields are showing
                destinationVC.numberOfSeriesToShow = 2
                destinationVC.seriesConfiguration = 1100 // ON, ON, OFF, OFF
            }
            else if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == true &&
                cell.currentWeight1.isHidden == true &&
                cell.currentWeight2.isHidden == true {
                
                //  Only round 1 Reps fields are showing
                destinationVC.numberOfSeriesToShow = 1
                destinationVC.seriesConfiguration = 1000 // ON, OFF, OFF, OFF
            }
            
            if debug == 1 {
                
                let exerciseName = cell.nonUpperCaseExerciseName
                print("Exercise Name = \(exerciseName)")
            }
        }
            
        else if segue.identifier == "WorkoutCell_Straight_4_Rep" ||
            segue.identifier == "WorkoutCell_Straight_5_Rep" {
            
            let destinationNavController = segue.destination as? UINavigationController
            let destinationVC = destinationNavController?.topViewController as! ExerciseChartViewController
            
            destinationVC.session = session
            destinationVC.workoutRoutine = workoutRoutine
            destinationVC.selectedWorkout = selectedWorkout
            destinationVC.workoutIndex = workoutIndex
            destinationVC.segueIdentifier = segue.identifier!
            
            let button = sender as! UIButton
            let view = button.superview
            let cell = view?.superview as! WorkoutTVC_Workout5Round_Rep_TableViewCell
            
            destinationVC.exerciseName = cell.nonUpperCaseExerciseName
            destinationVC.navigationItem.title = selectedWorkout
            let graphDataPoints = [cell.repNumberLabel1.text,
                                   cell.repNumberLabel2.text,
                                   cell.repNumberLabel3.text,
                                   cell.repNumberLabel4.text,
                                   cell.repNumberLabel5.text]
            
            destinationVC.graphDataPoints = graphDataPoints
            
            let exerciseName = cell.nonUpperCaseExerciseName
            
            if debug == 1 {
                
                print("Exercise Name = \(exerciseName)")
            }
        }

        else if segue.identifier == "WorkoutCell_Straight_4_Weight" ||
            segue.identifier == "WorkoutCell_Straight_5_Weight" {
            
            let destinationNavController = segue.destination as? UINavigationController
            let destinationVC = destinationNavController?.topViewController as! ExerciseChartViewController
            
            destinationVC.session = session
            destinationVC.workoutRoutine = workoutRoutine
            destinationVC.selectedWorkout = selectedWorkout
            destinationVC.workoutIndex = workoutIndex
            destinationVC.segueIdentifier = segue.identifier!
            
            let button = sender as! UIButton
            let view = button.superview
            let cell = view?.superview as! WorkoutTVC_Workout5Round_Weight_TableViewCell
            
            destinationVC.exerciseName = cell.nonUpperCaseExerciseName
            destinationVC.navigationItem.title = selectedWorkout
            let graphDataPoints = [cell.repNumberLabel1.text,
                                   cell.repNumberLabel2.text,
                                   cell.repNumberLabel3.text,
                                   cell.repNumberLabel4.text,
                                   cell.repNumberLabel5.text]
            
            destinationVC.graphDataPoints = graphDataPoints
            
            let exerciseName = cell.nonUpperCaseExerciseName
            
            if debug == 1 {
                
                print("Exercise Name = \(exerciseName)")
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    func loadExerciseNameArray(_ workout: String) {
        
        switch workout {
        case "Negative Lower":
            
            let cell1 = [["Squat"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true], // isHidden
                [CellType.straight_1]]
            
            let cell2 = [["Lunge"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Wide Squat"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["1 Leg Squat"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Side High Knee Kick"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Front High Knee Kick"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["1 Leg Lunge"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Side Lunge Raise"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["1 Leg Squat Punch"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["Side Sphinx Leg Lift"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Laying Heel Raise"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["Pommel Horse V"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Downward Dog Calf Extension"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10, cell11, cell12, cell13],
                         [completeCell]]
            
        case "Negative Upper":
            
            let cell1 = [["Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true], // isHidden
                [CellType.straight_1]]
            
            let cell2 = [["Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Shoulder Press"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Military Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Underhand Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Bicep Curl to Shoulder Press"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Wide Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Side to Side Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["Upright Row to Hammer"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["Offset Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Leaning Row"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["2 Way Shoulder Raise"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Plyometric Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Opposite Grip Pull-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Leaning Shoulder Flys"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["Leaning Tricep Extension"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell17 = [["2 Way Bicep Curl"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell18 = [["Tricep Pelvis Raise"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell19 = [["Leaning Preacher Curl"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell20 = [["BONUS Military Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.red, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell21 = [["BONUS Wide Pull-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.red, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3],
                         [cell4, cell5, cell6],
                         [cell7, cell8, cell9],
                         [cell10, cell11, cell12],
                         [cell13, cell14, cell15],
                         [cell16, cell17, cell18, cell19],
                         [cell20, cell21],
                         [completeCell]]
            
        case "Agility Upper":
            
            let cell1 = [["Slow Underhand Pull-Ups"],
                         [LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._6, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, Color.red, UIColor.white],
                         [false, false, false, false, false, true], // isHidden
                [CellType.straight_5_Rep]]
            
            let cell2 = [["Rotating Plyometric Push-Ups"],
                         [LabelNumber._8, LabelNumber._8, LabelNumber._8, LabelNumber._8, LabelNumber._6, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, Color.red, UIColor.white],
                         [false, false, false, false, false, true],
                         [CellType.straight_5_Rep]]
            
            let cell3 = [["Plyometric Lunge Press"],
                         [LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, Color.red, UIColor.white],
                         [false, false, false, false, false, true],
                         [CellType.straight_5_Weight]]
            
            let cell4 = [["3 Way Pull-Ups"],
                         [LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._6, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, Color.red, UIColor.white],
                         [false, false, false, false, false, true],
                         [CellType.straight_5_Rep]]
            
            let cell5 = [["Push-Up Plank Cross Crunch"],
                         [LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._12, LabelNumber._8, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, Color.red, UIColor.white],
                         [false, false, false, false, false, true],
                         [CellType.straight_5_Rep]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5],
                         [completeCell]]

        case "Agility Lower":
            
            let cell1 = [["1 Leg Squat"],
                         [LabelNumber._10, LabelNumber._10, LabelNumber._10, LabelNumber._10, LabelNumber.empty, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true], // isHidden
                         [CellType.straight_4_Weight]]
            
            let cell2 = [["Plyometric Lunge Press"],
                         [LabelNumber._16, LabelNumber._16, LabelNumber._16, LabelNumber._16, LabelNumber.empty, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_4_Weight]]
            
            let cell3 = [["Side Jump Hops"],
                         [LabelNumber._16, LabelNumber._16, LabelNumber._16, LabelNumber._16, LabelNumber.empty, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_4_Rep]]
            
            let cell4 = [["Dead Squat Lunge"],
                         [LabelNumber._10, LabelNumber._10, LabelNumber._10, LabelNumber._10, LabelNumber.empty, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_4_Weight]]
            
            let cell5 = [["Alt Side Sphinx Leg Raise"],
                         [LabelNumber._10, LabelNumber._10, LabelNumber._10, LabelNumber._10, LabelNumber.empty, LabelNumber.empty],
                         [LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.reps_Long, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.two, Color.three, Color.four, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_4_Rep]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5],
                         [completeCell]]
           
        case "Devastator":
            
            let cell1 = [["Plank Row"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true], // isHidden
                [CellType.straight_1]]
            
            let cell2 = [["Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Laying Chest Flys"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Leaning Row"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Underhand Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Laying Chest Press"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Military Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["3 Way Shoulder"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["Decline Shoulder Press"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Leaning Shoulder Flys"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["Sphinx to A"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Hammer Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Leaning Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Laying Cross Tricep Extension"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["Tricep Pelvis Raise"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell17 = [["2 Way Curl"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell18 = [["Leaning Tricep Extension"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell19 = [["BONUS Push-Ups Plank Sphinx"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.red, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10, cell11, cell12, cell13, cell14, cell15, cell16, cell17, cell18],
                         [cell19],
                         [completeCell]]
            
        case "Complete Fitness":
            
            let cell1 = [["Push-Up to Arm Balance"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true], // isHidden
                [CellType.straight_1]]
            
            let cell2 = [["Crescent to Chair"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Pull-Up Crunch"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Side Sphinx Crunch"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Plyometric Runner Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Wide Squat on Toes"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Underhand Pull-Up Crunch"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["V to Plow"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["Balance Circle Press"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["Lateral Jump Press"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Balance 2 Way Hammer"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["V Crunch"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Balance 2 Way Arm Raise"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Squat Front Back"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Laying Tricep Extension Punch"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["3 Way Warrior"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty, LabelTitle.empty],
                          [Color.one, Color.four, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10, cell11, cell12, cell13, cell14, cell15, cell16],
                         [completeCell]]
            
        case "The Goal":
            
            let cell1 = [["Wide Pull-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true], // isHidden
                [CellType.straight_2]]
            
            let cell2 = [["Push-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell3 = [["Underhand Pull-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell4 = [["Military Push-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell5 = [["Narrow Pull-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell6 = [["Wide Push-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell7 = [["Opposite Grip Pull-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell8 = [["Offset Push-Up"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.one, Color.one, Color.four, Color.four, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell9 = [["BONUS Pull-Up Push-Up"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelTitle.reps, LabelTitle.weight, LabelTitle.reps, LabelTitle.weight, LabelTitle.empty, LabelTitle.empty],
                         [Color.red, Color.four,UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2],
                         [cell3, cell4],
                         [cell5, cell6],
                         [cell7, cell8],
                         [cell9],
                         [completeCell]]
            
        default:
            break
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
