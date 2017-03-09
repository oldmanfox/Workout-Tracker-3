//
//  WorkoutTVC_Workout5Round_Rep_TableViewCell_TableViewCell.swift
//  90 DWT 3
//
//  Created by Grant, Jared on 3/1/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import UIKit

class WorkoutTVC_Workout5Round_Rep_TableViewCell: UITableViewCell, UITextFieldDelegate {

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
    
    var originalCurrentRep1_Text = ""
    var originalCurrentRep2_Text = ""
    var originalCurrentRep3_Text = ""
    var originalCurrentRep4_Text = ""
    var originalCurrentRep5_Text = ""
    
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
    
    @IBOutlet weak var previousReps1: UITextField!
    @IBOutlet weak var previousReps2: UITextField!
    @IBOutlet weak var previousReps3: UITextField!
    @IBOutlet weak var previousReps4: UITextField!
    @IBOutlet weak var previousReps5: UITextField!
    
    @IBOutlet weak var currentReps1: UITextField!
    @IBOutlet weak var currentReps2: UITextField!
    @IBOutlet weak var currentReps3: UITextField!
    @IBOutlet weak var currentReps4: UITextField!
    @IBOutlet weak var currentReps5: UITextField!
    
    @IBOutlet weak var previousNotes: UITextField!
    @IBOutlet weak var currentNotes: UITextField!
    
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var rewardVideoButton: UIButton!
    
    @IBAction func saveCurrentRep1(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != originalCurrentRep1_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, reps: sender.text!, round: "Round 1")
        }
        else {
            
            sender.text = originalCurrentRep1_Text
        }
    }
    
    @IBAction func saveCurrentRep2(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != originalCurrentRep2_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, reps: sender.text!, round: "Round 2")
        }
        else {
            
            sender.text = originalCurrentRep2_Text
        }
    }
    
    @IBAction func saveCurrentRep3(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != originalCurrentRep3_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, reps: sender.text!, round: "Round 3")
        }
        else {
            
            sender.text = originalCurrentRep3_Text
        }
    }
    
    @IBAction func saveCurrentRep4(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != originalCurrentRep4_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, reps: sender.text!, round: "Round 4")
        }
        else {
            
            sender.text = originalCurrentRep4_Text
        }
    }
    
    @IBAction func saveCurrentRep5(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if ((sender.text?.characters.count)! > 0 && sender.text != "0.0" && sender.text != originalCurrentRep5_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(self.session, routine: self.workoutRoutine, workout: self.selectedWorkout, month: self.month, week: self.workoutWeek, exercise: self.nonUpperCaseExerciseName, index: self.workoutIndex as NSNumber, reps: sender.text!, round: "Round 5")
        }
        else {
            
            sender.text = originalCurrentRep5_Text
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
            self.saveCurrentRep1(self.currentReps1)
            
        case 1:
            self.saveCurrentRep2(self.currentReps2)
            
        case 2:
            self.saveCurrentRep3(self.currentReps3)
            
        case 3:
            self.saveCurrentRep4(self.currentReps4)
            
        case 4:
            self.saveCurrentRep5(self.currentReps5)
            
        case 5:
            self.saveCurrentNotes(self.currentNotes)
            
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.currentReps1.delegate = self
        self.currentReps2.delegate = self
        self.currentReps3.delegate = self
        self.currentReps4.delegate = self
        self.currentReps5.delegate = self
        
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
        
        self.currentReps1.resignFirstResponder()
        self.currentReps2.resignFirstResponder()
        self.currentReps3.resignFirstResponder()
        self.currentReps4.resignFirstResponder()
        self.currentReps5.resignFirstResponder()
        
        self.currentNotes.resignFirstResponder()
        
        return true
    }
}
