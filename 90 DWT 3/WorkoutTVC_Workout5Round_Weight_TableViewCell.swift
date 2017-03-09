//
//  WorkoutTVC_Workout5Round_Weight_TableViewCell.swift
//  90 DWT 3
//
//  Created by Grant, Jared on 3/6/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import UIKit

class WorkoutTVC_Workout5Round_Weight_TableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var title: UILabel!
    
    // **********
    let debug = 0
    // **********
    
    var session = ""
    var workoutRoutine = ""
    var selectedWorkout = ""
    var workoutWeek = ""
    var month = ""
    var nonUpperCaseExerciseName = ""
    var workoutIndex = 0
    
    var originalCurrentWeight1_Text = ""
    var originalCurrentWeight2_Text = ""
    var originalCurrentWeight3_Text = ""
    var originalCurrentWeight4_Text = ""
    var originalCurrentWeight5_Text = ""
    
    var originalCurrentNotes_Text = ""
    
    var activeTextField = UITextField()
    
    @IBOutlet weak var repNumberLabel1: UILabel!
    @IBOutlet weak var repNumberLabel2: UILabel!
    @IBOutlet weak var repNumberLabel3: UILabel!
    @IBOutlet weak var repNumberLabel4: UILabel!
    @IBOutlet weak var repNumberLabel5: UILabel!
    
    @IBOutlet weak var repTitleLabel1: UILabel!
    @IBOutlet weak var repTitleLabel2: UILabel!
    @IBOutlet weak var repTitleLabel3: UILabel!
    @IBOutlet weak var repTitleLabel4: UILabel!
    @IBOutlet weak var repTitleLabel5: UILabel!
    
    @IBOutlet weak var previousWeight1: UITextField!
    @IBOutlet weak var previousWeight2: UITextField!
    @IBOutlet weak var previousWeight3: UITextField!
    @IBOutlet weak var previousWeight4: UITextField!
    @IBOutlet weak var previousWeight5: UITextField!
    
    @IBOutlet weak var currentWeight1: UITextField!
    @IBOutlet weak var currentWeight2: UITextField!
    @IBOutlet weak var currentWeight3: UITextField!
    @IBOutlet weak var currentWeight4: UITextField!
    @IBOutlet weak var currentWeight5: UITextField!
    
    @IBOutlet weak var previousNotes: UITextField!
    @IBOutlet weak var currentNotes: UITextField!
    
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var rewardVideoButton: UIButton!
    
    @IBAction func saveCurrentWeight1(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != self.originalCurrentWeight1_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, weight: sender.text!, round: "Round 1")
        }
        else {
            
            sender.text = self.originalCurrentWeight1_Text
        }
    }
    
    @IBAction func saveCurrentWeight2(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != self.originalCurrentWeight2_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, weight: sender.text!, round: "Round 2")
        }
        else {
            
            sender.text = self.originalCurrentWeight2_Text
        }
    }

    @IBAction func saveCurrentWeight3(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != self.originalCurrentWeight3_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, weight: sender.text!, round: "Round 3")
        }
        else {
            
            sender.text = self.originalCurrentWeight3_Text
        }
    }

    @IBAction func saveCurrentWeight4(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != self.originalCurrentWeight4_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, weight: sender.text!, round: "Round 4")
        }
        else {
            
            sender.text = self.originalCurrentWeight4_Text
        }
    }

    @IBAction func saveCurrentWeight5(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != self.originalCurrentWeight5_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, weight: sender.text!, round: "Round 5")
        }
        else {
            
            sender.text = self.originalCurrentWeight5_Text
        }
    }

    @IBAction func saveCurrentNotes(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "CURRENT NOTES" && sender.text != originalCurrentNotes_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveNoteWithPredicate(session, routine: workoutRoutine, workout: selectedWorkout, month: month, week: workoutWeek, exercise: nonUpperCaseExerciseName, index: workoutIndex as NSNumber, note: sender.text!, round: "Round 1")
        }
        else {
            
            sender.text = originalCurrentNotes_Text
        }
    }
    
    @IBAction func graphButtonPressed(_ sender: UIButton) {
        
        switch self.activeTextField.tag {
        case 0:
            self.saveCurrentWeight1(self.currentWeight1)
            
        case 1:
            self.saveCurrentWeight2(self.currentWeight2)
            
        case 2:
            self.saveCurrentWeight3(self.currentWeight3)
            
        case 3:
            self.saveCurrentWeight4(self.currentWeight4)
            
        case 4:
            self.saveCurrentWeight5(self.currentWeight5)
            
        case 5:
            self.saveCurrentNotes(self.currentNotes)
            
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.currentWeight1.delegate = self
        self.currentWeight2.delegate = self
        self.currentWeight3.delegate = self
        self.currentWeight4.delegate = self
        self.currentWeight5.delegate = self
        
        self.currentNotes.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - UITextFieldDelegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.currentWeight1.resignFirstResponder()
        self.currentWeight2.resignFirstResponder()
        self.currentWeight3.resignFirstResponder()
        self.currentWeight4.resignFirstResponder()
        self.currentWeight5.resignFirstResponder()
        
        self.currentNotes.resignFirstResponder()
        
        return true
    }
}
