//
//  CDOperation.swift
//
//  Created by Tim Roadley on 1/10/2015.
//  Copyright © 2015 Tim Roadley. All rights reserved.
//

import Foundation
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CDOperation {
 
    class func objectCountForEntity (_ entityName:String, context:NSManagedObjectContext) -> Int {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //var error:NSError? = nil
        
        do {
            
            let count = try context.count(for: request)
            print("There are \(count) \(entityName) object(s) in \(context)")
            return count
            
        } catch let error as NSError {
            
            print("\(#function) Error: \(error.localizedDescription)")
            return 0
        }
        
        //        let count = context.count(for: request, error: &error)
        //
        //        if let _error = error {
        //            print("\(#function) Error: \(_error.localizedDescription)")
        //        } else {
        //            print("There are \(count) \(entityName) object(s) in \(context)")
        //        }
        //        return count
    }
    
    class func objectsForEntity(_ entityName:String, context:NSManagedObjectContext, filter:NSPredicate?, sort:[NSSortDescriptor]?) -> [AnyObject]? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName:entityName)
        request.predicate = filter
        request.sortDescriptors = sort

        do {
            return try context.fetch(request)
        } catch {
            print("\(#function) FAILED to fetch objects for \(entityName) entity")
            return nil
        }
    }
    
    class func objectName(_ object:NSManagedObject) -> String {
        
        if let name = object.value(forKey: "name") as? String {
            return name
        }
        return object.description
    }
    
    class func objectDeletionIsValid(_ object:NSManagedObject) -> Bool {
        
        do {
            try object.validateForDelete()
            return true // object can be deleted
        } catch let error as NSError {
            print("'\(objectName(object))' can't be deleted. \(error.localizedDescription)")
            return false // object can't be deleted
        }
    }
    
    class func objectWithAttributeValueForEntity(_ entityName:String, context:NSManagedObjectContext, attribute:String, value:String) -> NSManagedObject? {
        
        let predicate = NSPredicate(format: "%K == %@", attribute, value)
        let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicate, sort: nil)
        if let object = objects?.first as? NSManagedObject {
            return object
        }
        return nil
    }
    
    class func predicateForAttributes (_ attributes:[AnyHashable: Any], type:NSCompoundPredicate.LogicalType ) -> NSPredicate? {
            
        // Create an array of predicates, which will be later combined into a compound predicate.
        var predicates:[NSPredicate]?
            
        // Iterate unique attributes in order to create a predicate for each
        for (attribute, value) in attributes {
                
            var predicate:NSPredicate?
                
            // If the value is a string, create the predicate based on a string value
            if let stringValue = value as? String {
                predicate = NSPredicate(format: "%K == %@", attribute as CVarArg, stringValue)
            }
                
            // If the value is a number, create the predicate based on a numerical value
            if let numericalValue = value as? NSNumber {
                predicate = NSPredicate(format: "%K == %@", attribute as CVarArg, numericalValue)
            }
            
            // If the value is a date, create the predicate based on a date value
            if let dateValue = value as? Date {
                predicate = NSPredicate(format: "%K == %@", attribute as CVarArg, dateValue as CVarArg)
            }
                
            // Append new predicate to predicate array, or create it if it doesn't exist yet
            if let newPredicate = predicate {
                if var _predicates = predicates {
                    _predicates.append(newPredicate)
                } else {predicates = [newPredicate]}
            }
        }
            
        // Combine all predicates into a compound predicate
        if let _predicates = predicates {
            return NSCompoundPredicate(type: type, subpredicates: _predicates)
        }
        return nil
    }
    
    class func uniqueObjectWithAttributeValuesForEntity(_ entityName:String, context:NSManagedObjectContext, uniqueAttributes:[AnyHashable: Any]) -> NSManagedObject? {
            
        let predicate = CDOperation.predicateForAttributes(uniqueAttributes, type: .and)
        let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicate, sort: nil)
            
        if objects?.count > 0 {
            if let object = objects?[0] as? NSManagedObject {
                return object
            }
        }
        return nil
    }
    class func insertUniqueObject(_ entityName:String, context:NSManagedObjectContext, uniqueAttributes:[String:AnyObject], additionalAttributes:[String:AnyObject]?) -> NSManagedObject {
            
        // Return existing object after adding the additional attributes.
        if let existingObject = CDOperation.uniqueObjectWithAttributeValuesForEntity(entityName, context: context, uniqueAttributes: uniqueAttributes) {            
            if let _additionalAttributes = additionalAttributes {
                 existingObject.setValuesForKeys(_additionalAttributes)
            }
            return existingObject
        }
        
        // Create object with given attribute value
        let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        newObject.setValuesForKeys(uniqueAttributes)
        if let _additionalAttributes = additionalAttributes {
            newObject.setValuesForKeys(_additionalAttributes)
        }
        return newObject 
    }
    
    // MARK: - SAVE
    
    class func saveRepsWithPredicate(_ session: String, routine: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, reps: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.routine = routine
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.exercise = exercise
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.reps = reps
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.reps = reps
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.reps = reps
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }

    class func saveWeightWithPredicate(_ session: String, routine: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, weight: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index,
                                 round)

        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.routine = routine
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.exercise = exercise
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.weight = weight
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.weight = weight
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.weight = weight
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func saveNoteWithPredicate(_ session: String, routine: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, note: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.routine = routine
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.exercise = exercise
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.notes = note
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.notes = note
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.notes = note
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func saveNoteWithPredicateNoExercise(_ session: String, routine: String, workout: String, month: String, week: String, index: NSNumber, note: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
                                 workout,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.routine = routine
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.notes = note
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.notes = note
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.notes = note
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    // MARK: - GET
    
    class func getRepWeightTextForExercise(_ session: String, routine: String, workout: String, exercise: String, index: NSNumber) -> [NSManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortRound, sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                var workoutArray = [NSManagedObject]()
                
                for outerIndex in 0...4 {
                    
                    var objectsAtIndexArray = [NSManagedObject]()
                    
                    for object in workoutObjects {
                        
                        if self.renameRoundStringToInt(object.round!) == outerIndex {
                            objectsAtIndexArray.append(object)
                        }
                    }
                    
                    if objectsAtIndexArray.count != 0 {
                        
                        workoutArray.append(objectsAtIndexArray.last!)
                    }
                    
                }
                
                return workoutArray
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return []
    }
    
    class func getRepsTextForExerciseRound(_ session: String, routine: String, workout: String, exercise: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Reps with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round = %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    
                    return "0.0"
                    
                case 1:
                    let matchedWorkoutInfo = workoutObjects[0]
                    
                    if matchedWorkoutInfo.reps == nil || matchedWorkoutInfo.reps == ""  {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo.reps
                    }
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    if matchedWorkoutInfo?.reps == nil || matchedWorkoutInfo?.reps == ""  {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo?.reps
                    }
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "0.0"
    }
    
    class func getWeightTextForExerciseRound(_ session: String, routine: String, workout: String, exercise: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round = %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    
                    return "0.0"
                    
                case 1:
                    let matchedWorkoutInfo = workoutObjects[0]
                    
                    if matchedWorkoutInfo.weight == nil || matchedWorkoutInfo.weight == "" {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo.weight
                    }
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    if matchedWorkoutInfo?.weight == nil || matchedWorkoutInfo?.weight == "" {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo?.weight
                    }
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "0.0"
    }
    
    class func getNotesTextForRound(_ session: String, routine: String, workout: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@ AND round = %@",
                                 session,
                                 routine,
                                 workout,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    
                    return ""
                    
                case 1:
                    let matchedWorkoutInfo = workoutObjects[0]
                    
                    return matchedWorkoutInfo.notes
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    return matchedWorkoutInfo!.notes
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return ""
    }
    
    class func getNoteObjects(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber) -> [Workout] {
        
        let tempWorkoutCompleteArray = [Workout]()
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
                                 workout,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutNoteObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutNoteObjects.count = \(workoutNoteObjects.count)")
                
                return workoutNoteObjects
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return tempWorkoutCompleteArray
    }
    
    class func getCurrentRoutine() -> String {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Routine")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let routineObjects = try CoreDataHelper.shared().context.fetch(request) as? [Routine] {
                
                // print("routineObjects.count = \(routineObjects.count)")
                
                switch routineObjects.count {
                case 0:
                    // No matches for this object.
                    // Create a new record with the default routine - Normal
                    let insertRoutineInfo = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataHelper.shared().context) as! Routine
                    
                    insertRoutineInfo.defaultRoutine = "Normal"
                    insertRoutineInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                    // Return the default routine.
                    // Will be Normal until the user changes it in settings tab.
                    return "Normal"
                    
                case 1:
                    // Found an existing record
                    let matchedRoutineInfo = routineObjects[0]
                    
                    return matchedRoutineInfo.defaultRoutine!
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    var routineString = ""
                    for index in 0..<routineObjects.count {
                        
                        if (index == routineObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            
                            let matchedRoutineInfo = routineObjects[index]
                            routineString = matchedRoutineInfo.defaultRoutine!
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(routineObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    return routineString
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }

        return "Normal"
    }
    
    class func getCurrentSession() -> String {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Session")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                
                // print("sessionObjects.count = \(sessionObjects.count)")
                
                switch sessionObjects.count {
                case 0:
                    // No matches for this object.
                    // Create a new record with the default session - 1
                    let insertSessionInfo = NSEntityDescription.insertNewObject(forEntityName: "Session", into: CoreDataHelper.shared().context) as! Session
                    
                    insertSessionInfo.currentSession = "1"
                    insertSessionInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                    // Return the default routine.
                    // Will be 1 until the user changes it in settings tab.
                    return "1"
                    
                case 1:
                    // Found an existing record
                    let matchedSessionInfo = sessionObjects[0]
                    
                    return matchedSessionInfo.currentSession!
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    var sessionString = ""
                    for index in 0..<sessionObjects.count {
                        
                        if (index == sessionObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            
                            let matchedSessionInfo = sessionObjects[index]
                            sessionString = matchedSessionInfo.currentSession!
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(sessionObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    return sessionString
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "1"
    }
    
    class func getImportPreviousSessionData() -> Bool {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Session")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                
                // print("sessionObjects.count = \(sessionObjects.count)")
                
                if sessionObjects.count != 0 {
                    
                    // Match Found.
                    return (sessionObjects.last?.importPreviousSessionData)! as! Bool
                }
                else {
                    
                    // No Matches Found.  Create new record and save.
                    let insertSessionInfo = NSEntityDescription.insertNewObject(forEntityName: "Session", into: CoreDataHelper.shared().context) as! Session
                    
                    insertSessionInfo.importPreviousSessionData = false
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                    return false
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return false
    }

    class func getAutoLockSetting() -> String {
     
        // Fetch AutoLock data.
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "AutoLock")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let autoLockObjects = try CoreDataHelper.shared().context.fetch(request) as? [AutoLock] {
                
                if autoLockObjects.count != 0 {
                    
                    // Match Found.
                    return (autoLockObjects.last?.useAutoLock)!
                }
                else {
                    
                    // No Matches Found.  Create new record and save.
                    let insertAutoLockInfo = NSEntityDescription.insertNewObject(forEntityName: "AutoLock", into: CoreDataHelper.shared().context) as! AutoLock
                    
                    insertAutoLockInfo.useAutoLock = "OFF"
                    insertAutoLockInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                    return "OFF"
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "OFF"
    }
    
    // MARK: - WORKOUT COMPLETE DATE
    
    class func saveWorkoutCompleteDate(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber, useDate: Date) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
                                 workout,
                                 index)
        
        request.predicate = filter

        do {
            if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                
                // print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                
                switch workoutCompleteDateObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "WorkoutCompleteDate", into: CoreDataHelper.shared().context) as! WorkoutCompleteDate
                    
                    insertWorkoutInfo.session = session as String
                    insertWorkoutInfo.routine = routine as String
                    insertWorkoutInfo.workout = workout as String
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.workoutCompleted = true
                    insertWorkoutInfo.date = useDate as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutCompleteDateObjects[0]
                    
                    updateWorkoutInfo.workoutCompleted = true
                    updateWorkoutInfo.date = useDate as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutCompleteDateObjects.count {
                        
                        if (index == workoutCompleteDateObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutCompleteDateObjects[index]
                            
                            updateWorkoutInfo.workoutCompleted = true
                            updateWorkoutInfo.date = useDate as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutCompleteDateObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()

                }
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func getWorkoutCompletedObjects(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber) -> [WorkoutCompleteDate] {
        
        let tempWorkoutCompleteArray = [WorkoutCompleteDate]()
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
                                 workout,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                
                // print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                
                return workoutCompleteDateObjects
                
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return tempWorkoutCompleteArray
    }
    
    class func deleteDate(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
                                 workout,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                
                // print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                
                if workoutCompleteDateObjects.count != 0 {
                    
                    for object in workoutCompleteDateObjects {
                        
                        // Delete all date records for the index.
                        CoreDataHelper.shared().context.delete(object)
                    }
                    CoreDataHelper.shared().backgroundSaveContext()

                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    // MARK: - MEASUREMENTS
    
    class func getMeasurementObjects(_ session: NSString, month: NSString) -> [NSManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Measurement")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND month == %@",
                                 session,
                                 month)
        
        request.predicate = filter
        
        do {
            if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                
                // print("measurementObjects.count = \(measurementObjects.count)")
                
                return measurementObjects
                
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return []
    }
    
    class func saveMeasurements(_ session: String, month: String, weight: String, chest: String, waist: String, hips: String, leftArm: String, rightArm: String, leftThigh: String, rightThigh: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Measurement")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND month == %@",
                                 session,
                                 month)
        
        request.predicate = filter
        
        do {
            if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                
                // print("measurementObjects.count = \(measurementObjects.count)")
                
                switch measurementObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Measurement", into: CoreDataHelper.shared().context) as! Measurement
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    if weight != "" {
                        insertWorkoutInfo.weight = weight
                    }
                    
                    if chest != "" {
                        insertWorkoutInfo.chest = chest
                    }
                    
                    if waist != "" {
                        insertWorkoutInfo.waist = waist
                    }
                    
                    if hips != "" {
                        insertWorkoutInfo.hips = hips
                    }
                    
                    if leftArm != "" {
                        insertWorkoutInfo.leftArm = leftArm
                    }
                    
                    if rightArm != "" {
                        insertWorkoutInfo.rightArm = rightArm
                    }
                    
                    if leftThigh != "" {
                        insertWorkoutInfo.leftThigh = leftThigh
                    }
                    
                    if rightThigh != "" {
                        insertWorkoutInfo.rightThigh = rightThigh
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = measurementObjects[0]
                    
                    updateWorkoutInfo.session = session
                    updateWorkoutInfo.month = month
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    if weight != "" {
                        updateWorkoutInfo.weight = weight
                    }
                    
                    if chest != "" {
                        updateWorkoutInfo.chest = chest
                    }
                    
                    if waist != "" {
                        updateWorkoutInfo.waist = waist
                    }
                    
                    if hips != "" {
                        updateWorkoutInfo.hips = hips
                    }
                    
                    if leftArm != "" {
                        updateWorkoutInfo.leftArm = leftArm
                    }
                    
                    if rightArm != "" {
                        updateWorkoutInfo.rightArm = rightArm
                    }
                    
                    if leftThigh != "" {
                        updateWorkoutInfo.leftThigh = leftThigh
                    }
                    
                    if rightThigh != "" {
                        updateWorkoutInfo.rightThigh = rightThigh
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<measurementObjects.count {
                        
                        if (index == measurementObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = measurementObjects[index]
                            
                            updateWorkoutInfo.session = session
                            updateWorkoutInfo.month = month
                            updateWorkoutInfo.date = Date() as NSDate?
                            
                            if weight != "" {
                                updateWorkoutInfo.weight = weight
                            }
                            
                            if chest != "" {
                                updateWorkoutInfo.chest = chest
                            }
                            
                            if waist != "" {
                                updateWorkoutInfo.waist = waist
                            }
                            
                            if hips != "" {
                                updateWorkoutInfo.hips = hips
                            }
                            
                            if leftArm != "" {
                                updateWorkoutInfo.leftArm = leftArm
                            }
                            
                            if rightArm != "" {
                                updateWorkoutInfo.rightArm = rightArm
                            }
                            
                            if leftThigh != "" {
                                updateWorkoutInfo.leftThigh = leftThigh
                            }
                            
                            if rightThigh != "" {
                                updateWorkoutInfo.rightThigh = rightThigh
                            }
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(measurementObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }

    // MARK: - WORKOUT ARRAYS
    
    class func loadWorkoutNameArray() -> [[String]] {
        
        switch getCurrentRoutine() {
        case "Normal":
            // Normal
            let normal_Week1_WorkoutNameArray = ["Complete Fitness",
                                                 "Dexterity",
                                                 "Yoga",
                                                 "The Goal",
                                                 "Cardio Resistance",
                                                 "Gladiator",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week2_WorkoutNameArray = ["Complete Fitness",
                                                 "Dexterity",
                                                 "Yoga",
                                                 "The Goal",
                                                 "Cardio Resistance",
                                                 "Gladiator",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week3_WorkoutNameArray = ["Complete Fitness",
                                                 "Dexterity",
                                                 "Yoga",
                                                 "The Goal",
                                                 "Cardio Resistance",
                                                 "Gladiator",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week4_WorkoutNameArray = ["Core I",
                                                 "Core D",
                                                 "Cardio Speed",
                                                 "Pilates",
                                                 "Cardio Resistance",
                                                 "Yoga",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week5_WorkoutNameArray = ["Negative Upper",
                                                 "Plyometrics T",
                                                 "Yoga",
                                                 "Negative Lower",
                                                 "Devastator",
                                                 "MMA",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week6_WorkoutNameArray = ["Negative Upper",
                                                 "Plyometrics T",
                                                 "Yoga",
                                                 "Negative Lower",
                                                 "Devastator",
                                                 "MMA",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week7_WorkoutNameArray = ["Negative Upper",
                                                 "Plyometrics T",
                                                 "Yoga",
                                                 "Negative Lower",
                                                 "Devastator",
                                                 "MMA",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week8_WorkoutNameArray = ["Core I",
                                                 "Core D",
                                                 "Cardio Speed",
                                                 "Pilates",
                                                 "Cardio Resistance",
                                                 "Yoga",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week9_WorkoutNameArray = ["Plyometrics D",
                                                 "Dexterity",
                                                 "The Goal",
                                                 "Agility Upper",
                                                 "Yoga",
                                                 "Plyometrics T",
                                                 "Complete Fitness",
                                                 "Agility Lower",
                                                 "Core D",
                                                 "Rest"]
            
            let normal_Week10_WorkoutNameArray = ["Plyometrics D",
                                                  "MMA",
                                                  "Negative Upper",
                                                  "Plyometrics T",
                                                  "Pilates",
                                                  "Negative Lower",
                                                  "Core D",
                                                  "Rest"]
            
            let normal_Week11_WorkoutNameArray = ["Plyometrics D",
                                                  "Dexterity",
                                                  "The Goal",
                                                  "Agility Upper",
                                                  "Yoga",
                                                  "Plyometrics T",
                                                  "Complete Fitness",
                                                  "Agility Lower",
                                                  "Core D",
                                                  "Rest"]
            
            let normal_Week12_WorkoutNameArray = ["Plyometrics D",
                                                  "MMA",
                                                  "Negative Upper",
                                                  "Plyometrics T",
                                                  "Pilates",
                                                  "Negative Lower",
                                                  "Core D",
                                                  "Rest"]
            
            let normal_Week13_WorkoutNameArray = ["Core I",
                                                  "Cardio Speed",
                                                  "Pilates",
                                                  "Yoga",
                                                  "Core D",
                                                  "Core D",
                                                  "Rest",
                                                  "Finished"]
            
            /// BONUS ///
            let normal_Week14_WorkoutNameArray = ["Agility Upper",
                                                  "Ab Workout",
                                                  "Agility Lower",
                                                  "Yoga",
                                                  "Agility Upper",
                                                  "Ab Workout",
                                                  "Agility Lower",
                                                  "Pilates",
                                                  "Core D",
                                                  "Rest"]
            
            let normal_Week15_WorkoutNameArray = ["Agility Upper",
                                                  "Ab Workout",
                                                  "Agility Lower",
                                                  "Yoga",
                                                  "Agility Upper",
                                                  "Ab Workout",
                                                  "Agility Lower",
                                                  "Pilates",
                                                  "Core D",
                                                  "Rest"]
            
            let normal_Week16_WorkoutNameArray = ["Agility Upper",
                                                  "Ab Workout",
                                                  "Agility Lower",
                                                  "Yoga",
                                                  "Agility Upper",
                                                  "Ab Workout",
                                                  "Agility Lower",
                                                  "Pilates",
                                                  "Core D",
                                                  "Rest"]
            
            let normal_Week17_WorkoutNameArray = ["Dexterity",
                                                  "Yoga",
                                                  "Cardio Resistance",
                                                  "Pilates",
                                                  "Core I",
                                                  "Core D",
                                                  "Rest",
                                                  "Finished"]
            
            let normal_WorkoutNameArray = [normal_Week1_WorkoutNameArray,
                                           normal_Week2_WorkoutNameArray,
                                           normal_Week3_WorkoutNameArray,
                                           normal_Week4_WorkoutNameArray,
                                           normal_Week5_WorkoutNameArray,
                                           normal_Week6_WorkoutNameArray,
                                           normal_Week7_WorkoutNameArray,
                                           normal_Week8_WorkoutNameArray,
                                           normal_Week9_WorkoutNameArray,
                                           normal_Week10_WorkoutNameArray,
                                           normal_Week11_WorkoutNameArray,
                                           normal_Week12_WorkoutNameArray,
                                           normal_Week13_WorkoutNameArray,
                                           normal_Week14_WorkoutNameArray,
                                           normal_Week15_WorkoutNameArray,
                                           normal_Week16_WorkoutNameArray,
                                           normal_Week17_WorkoutNameArray]
            
            return normal_WorkoutNameArray
            
        case "Tone":
            // Tone
            let tone_Week1_WorkoutNameArray = ["Cardio Speed",
                                               "Gladiator",
                                               "Yoga",
                                               "Cardio Resistance",
                                               "Core I",
                                               "Dexterity",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week2_WorkoutNameArray = ["Cardio Speed",
                                               "Gladiator",
                                               "Yoga",
                                               "Cardio Resistance",
                                               "Core I",
                                               "Dexterity",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week3_WorkoutNameArray = ["Cardio Speed",
                                               "Gladiator",
                                               "Yoga",
                                               "Cardio Resistance",
                                               "Core I",
                                               "Dexterity",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week4_WorkoutNameArray = ["Core I",
                                               "Core D",
                                               "Cardio Speed",
                                               "Pilates",
                                               "Dexterity",
                                               "Yoga",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week5_WorkoutNameArray = ["Plyometrics T",
                                               "Gladiator",
                                               "Yoga",
                                               "MMA",
                                               "Devastator",
                                               "Cardio Resistance",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week6_WorkoutNameArray = ["Plyometrics T",
                                               "Gladiator",
                                               "Yoga",
                                               "MMA",
                                               "Devastator",
                                               "Cardio Resistance",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week7_WorkoutNameArray = ["Plyometrics T",
                                               "Gladiator",
                                               "Yoga",
                                               "MMA",
                                               "Devastator",
                                               "Cardio Resistance",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week8_WorkoutNameArray = ["Core I",
                                               "Core D",
                                               "Cardio Speed",
                                               "Pilates",
                                               "Dexterity",
                                               "Yoga",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week9_WorkoutNameArray = ["Plyometrics D",
                                               "MMA",
                                               "Negative Lower",
                                               "Agility Lower",
                                               "Yoga",
                                               "Plyometrics T",
                                               "Negative Upper",
                                               "Agility Upper",
                                               "Core D",
                                               "Rest"]
            
            let tone_Week10_WorkoutNameArray = ["MMA",
                                                "Plyometrics D",
                                                "Plyometrics T",
                                                "Pilates",
                                                "Plyometrics D",
                                                "Cardio Resistance",
                                                "Core D",
                                                "Rest"]
            
            let tone_Week11_WorkoutNameArray = ["Plyometrics D",
                                                "MMA",
                                                "Negative Lower",
                                                "Agility Lower",
                                                "Yoga",
                                                "Plyometrics T",
                                                "Negative Upper",
                                                "Agility Upper",
                                                "Core D",
                                                "Rest"]
            
            let tone_Week12_WorkoutNameArray = ["MMA",
                                                "Plyometrics D",
                                                "Plyometrics T",
                                                "Pilates",
                                                "Plyometrics D",
                                                "Cardio Resistance",
                                                "Core D",
                                                "Rest"]
            
            let tone_Week13_WorkoutNameArray = ["Core I",
                                                "Cardio Speed",
                                                "Pilates",
                                                "Yoga",
                                                "Core D",
                                                "Core D",
                                                "Rest",
                                                "Finished"]
            
            let tone_Week14_WorkoutNameArray = ["Agility Upper",
                                                "Ab Workout",
                                                "Agility Lower",
                                                "Yoga",
                                                "Agility Upper",
                                                "Ab Workout",
                                                "Agility Lower",
                                                "Pilates",
                                                "Core D",
                                                "Rest"]
            
            let tone_Week15_WorkoutNameArray = ["Agility Upper",
                                                "Ab Workout",
                                                "Agility Lower",
                                                "Yoga",
                                                "Agility Upper",
                                                "Ab Workout",
                                                "Agility Lower",
                                                "Pilates",
                                                "Core D",
                                                "Rest"]
            
            let tone_Week16_WorkoutNameArray = ["Agility Upper",
                                                "Ab Workout",
                                                "Agility Lower",
                                                "Yoga",
                                                "Agility Upper",
                                                "Ab Workout",
                                                "Agility Lower",
                                                "Pilates",
                                                "Core D",
                                                "Rest"]
            
            let tone_Week17_WorkoutNameArray = ["Dexterity",
                                                "Yoga",
                                                "Cardio Resistance",
                                                "Pilates",
                                                "Core I",
                                                "Core D",
                                                "Rest",
                                                "Finished"]
            
            let tone_WorkoutNameArray = [tone_Week1_WorkoutNameArray,
                                         tone_Week2_WorkoutNameArray,
                                         tone_Week3_WorkoutNameArray,
                                         tone_Week4_WorkoutNameArray,
                                         tone_Week5_WorkoutNameArray,
                                         tone_Week6_WorkoutNameArray,
                                         tone_Week7_WorkoutNameArray,
                                         tone_Week8_WorkoutNameArray,
                                         tone_Week9_WorkoutNameArray,
                                         tone_Week10_WorkoutNameArray,
                                         tone_Week11_WorkoutNameArray,
                                         tone_Week12_WorkoutNameArray,
                                         tone_Week13_WorkoutNameArray,
                                         tone_Week14_WorkoutNameArray,
                                         tone_Week15_WorkoutNameArray,
                                         tone_Week16_WorkoutNameArray,
                                         tone_Week17_WorkoutNameArray]
            
            return tone_WorkoutNameArray
            
        case "2-A-Days":
            // 2-A-Days
            let two_A_Days_Week1_WorkoutNameArray = ["Warm Up",
                                                     "Complete Fitness",
                                                     "Dexterity",
                                                     "Core D",
                                                     "Yoga",
                                                     "Warm Up",
                                                     "The Goal",
                                                     "Cardio Resistance",
                                                     "Core D",
                                                     "Gladiator",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week2_WorkoutNameArray = ["Warm Up",
                                                     "Complete Fitness",
                                                     "Dexterity",
                                                     "Core D",
                                                     "Yoga",
                                                     "Warm Up",
                                                     "The Goal",
                                                     "Cardio Resistance",
                                                     "Core D",
                                                     "Gladiator",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week3_WorkoutNameArray = ["Warm Up",
                                                     "Complete Fitness",
                                                     "Dexterity",
                                                     "Core D",
                                                     "Yoga",
                                                     "Warm Up",
                                                     "The Goal",
                                                     "Cardio Resistance",
                                                     "Core D",
                                                     "Gladiator",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week4_WorkoutNameArray = ["Core I",
                                                     "Core D",
                                                     "Cardio Speed",
                                                     "Pilates",
                                                     "Dexterity",
                                                     "Yoga",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week5_WorkoutNameArray = ["Complete Fitness",
                                                     "Cardio Speed",
                                                     "Plyometrics T",
                                                     "Core D",
                                                     "Yoga",
                                                     "Negative Lower",
                                                     "Cardio Resistance",
                                                     "Devastator",
                                                     "Core I",
                                                     "MMA",
                                                     "Core D",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week6_WorkoutNameArray = ["Complete Fitness",
                                                     "Cardio Speed",
                                                     "Plyometrics T",
                                                     "Core D",
                                                     "Yoga",
                                                     "Negative Lower",
                                                     "Cardio Resistance",
                                                     "Devastator",
                                                     "Core I",
                                                     "MMA",
                                                     "Core D",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week7_WorkoutNameArray = ["Complete Fitness",
                                                     "Cardio Speed",
                                                     "Plyometrics T",
                                                     "Core D",
                                                     "Yoga",
                                                     "Negative Lower",
                                                     "Cardio Resistance",
                                                     "Devastator",
                                                     "Core I",
                                                     "MMA",
                                                     "Core D",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week8_WorkoutNameArray = ["Core I",
                                                     "Core D",
                                                     "Cardio Speed",
                                                     "Pilates",
                                                     "Dexterity",
                                                     "Core D",
                                                     "Yoga",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week9_WorkoutNameArray = ["Plyometrics D",
                                                     "Cardio Speed",
                                                     "MMA",
                                                     "Pilates",
                                                     "The Goal",
                                                     "Agility Upper",
                                                     "Ab Workout",
                                                     "Core D",
                                                     "Yoga",
                                                     "Dexterity",
                                                     "Plyometrics T",
                                                     "Core I",
                                                     "Complete Fitness",
                                                     "Agility Lower",
                                                     "Ab Workout",
                                                     "Core D",
                                                     "Core D",
                                                     "Rest"]
            
            let two_A_Days_Week10_WorkoutNameArray = ["Plyometrics D",
                                                      "Cardio Speed",
                                                      "Cardio Resistance",
                                                      "Pilates",
                                                      "Negative Upper",
                                                      "MMA",
                                                      "Plyometrics T",
                                                      "Core I",
                                                      "Yoga",
                                                      "Cardio Resistance",
                                                      "Negative Lower",
                                                      "Core D",
                                                      "Core D",
                                                      "Rest"]
            
            let two_A_Days_Week11_WorkoutNameArray = ["Plyometrics D",
                                                      "Cardio Speed",
                                                      "MMA",
                                                      "Pilates",
                                                      "The Goal",
                                                      "Agility Upper",
                                                      "Ab Workout",
                                                      "Core D",
                                                      "Yoga",
                                                      "Dexterity",
                                                      "Plyometrics T",
                                                      "Core I",
                                                      "Complete Fitness",
                                                      "Agility Lower",
                                                      "Ab Workout",
                                                      "Core D",
                                                      "Core D",
                                                      "Rest"]
            
            let two_A_Days_Week12_WorkoutNameArray = ["Plyometrics D",
                                                      "Cardio Speed",
                                                      "Cardio Resistance",
                                                      "Pilates",
                                                      "Negative Upper",
                                                      "MMA",
                                                      "Plyometrics T",
                                                      "Core I",
                                                      "Yoga",
                                                      "Cardio Resistance",
                                                      "Negative Lower",
                                                      "Core D",
                                                      "Core D",
                                                      "Rest"]
            
            let two_A_Days_Week13_WorkoutNameArray = ["Core I",
                                                      "Cardio Speed",
                                                      "Pilates",
                                                      "Yoga",
                                                      "Core D",
                                                      "Core D",
                                                      "Rest",
                                                      "Finished"]
            
            let two_A_Days_Week14_WorkoutNameArray = ["Agility Upper",
                                                      "Ab Workout",
                                                      "Cardio Speed",
                                                      "Agility Lower",
                                                      "Core I",
                                                      "Yoga",
                                                      "Pilates",
                                                      "Agility Upper",
                                                      "Ab Workout",
                                                      "Cardio Resistance",
                                                      "Agility Lower",
                                                      "MMA",
                                                      "Yoga",
                                                      "Pilates",
                                                      "Core D",
                                                      "Rest"]
            
            let two_A_Days_Week15_WorkoutNameArray = ["Agility Upper",
                                                      "Ab Workout",
                                                      "Cardio Speed",
                                                      "Agility Lower",
                                                      "Core I",
                                                      "Yoga",
                                                      "Pilates",
                                                      "Agility Upper",
                                                      "Ab Workout",
                                                      "Cardio Resistance",
                                                      "Agility Lower",
                                                      "MMA",
                                                      "Yoga",
                                                      "Pilates",
                                                      "Core D",
                                                      "Rest"]
            
            let two_A_Days_Week16_WorkoutNameArray = ["Agility Upper",
                                                      "Ab Workout",
                                                      "Cardio Speed",
                                                      "Agility Lower",
                                                      "Core I",
                                                      "Yoga",
                                                      "Pilates",
                                                      "Agility Upper",
                                                      "Ab Workout",
                                                      "Cardio Resistance",
                                                      "Agility Lower",
                                                      "MMA",
                                                      "Yoga",
                                                      "Pilates",
                                                      "Core D",
                                                      "Rest"]
            
            let two_A_Days_Week17_WorkoutNameArray = ["Dexterity",
                                                      "Yoga",
                                                      "Cardio Resistance",
                                                      "Pilates",
                                                      "Core I",
                                                      "Core D",
                                                      "Rest",
                                                      "Finished"]
            
            let tone_WorkoutNameArray = [two_A_Days_Week1_WorkoutNameArray,
                                         two_A_Days_Week2_WorkoutNameArray,
                                         two_A_Days_Week3_WorkoutNameArray,
                                         two_A_Days_Week4_WorkoutNameArray,
                                         two_A_Days_Week5_WorkoutNameArray,
                                         two_A_Days_Week6_WorkoutNameArray,
                                         two_A_Days_Week7_WorkoutNameArray,
                                         two_A_Days_Week8_WorkoutNameArray,
                                         two_A_Days_Week9_WorkoutNameArray,
                                         two_A_Days_Week10_WorkoutNameArray,
                                         two_A_Days_Week11_WorkoutNameArray,
                                         two_A_Days_Week12_WorkoutNameArray,
                                         two_A_Days_Week13_WorkoutNameArray,
                                         two_A_Days_Week14_WorkoutNameArray,
                                         two_A_Days_Week15_WorkoutNameArray,
                                         two_A_Days_Week16_WorkoutNameArray,
                                         two_A_Days_Week17_WorkoutNameArray,]
            
            return tone_WorkoutNameArray
            
        default:
            // Bulk
            let bulk_Week1_WorkoutNameArray = ["Complete Fitness",
                                               "Dexterity",
                                               "Yoga",
                                               "The Goal",
                                               "Pilates",
                                               "Devastator",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week2_WorkoutNameArray = ["Complete Fitness",
                                               "Dexterity",
                                               "Yoga",
                                               "The Goal",
                                               "Pilates",
                                               "Devastator",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week3_WorkoutNameArray = ["Complete Fitness",
                                               "Dexterity",
                                               "Yoga",
                                               "The Goal",
                                               "Pilates",
                                               "Devastator",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week4_WorkoutNameArray = ["Core I",
                                               "Core D",
                                               "Gladiator",
                                               "Pilates",
                                               "Dexterity",
                                               "Yoga",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week5_WorkoutNameArray = ["Negative Upper",
                                               "Negative Lower",
                                               "Yoga",
                                               "Negative Upper",
                                               "Negative Lower",
                                               "MMA",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week6_WorkoutNameArray = ["Negative Upper",
                                               "Negative Lower",
                                               "Yoga",
                                               "Negative Upper",
                                               "Negative Lower",
                                               "MMA",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week7_WorkoutNameArray = ["Negative Upper",
                                               "Negative Lower",
                                               "Yoga",
                                               "Negative Upper",
                                               "Negative Lower",
                                               "MMA",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week8_WorkoutNameArray = ["Core I",
                                               "Core D",
                                               "Gladiator",
                                               "Pilates",
                                               "Plyometrics D",
                                               "Yoga",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week9_WorkoutNameArray = ["Negative Upper",
                                               "Negative Lower",
                                               "Yoga",
                                               "Negative Upper",
                                               "Negative Lower",
                                               "MMA",
                                               "Core D",
                                               "Rest"]
            
            let bulk_Week10_WorkoutNameArray = ["Complete Fitness",
                                                "Dexterity",
                                                "Yoga",
                                                "The Goal",
                                                "Pilates",
                                                "Devastator",
                                                "Core D",
                                                "Rest"]
            
            let bulk_Week11_WorkoutNameArray = ["Negative Upper",
                                                "Negative Lower",
                                                "Yoga",
                                                "Negative Upper",
                                                "Negative Lower",
                                                "MMA",
                                                "Core D",
                                                "Rest"]
            
            let bulk_Week12_WorkoutNameArray = ["Complete Fitness",
                                                "Dexterity",
                                                "Yoga",
                                                "The Goal",
                                                "Pilates",
                                                "Devastator",
                                                "Core D",
                                                "Rest"]
            
            let bulk_Week13_WorkoutNameArray = ["Core I",
                                                "Yoga",
                                                "Plyometrics D",
                                                "Negative Lower",
                                                "Negative Upper",
                                                "Core D",
                                                "Rest",
                                                "Finished"]
            
            let two_A_Days_WorkoutNameArray = [bulk_Week1_WorkoutNameArray,
                                               bulk_Week2_WorkoutNameArray,
                                               bulk_Week3_WorkoutNameArray,
                                               bulk_Week4_WorkoutNameArray,
                                               bulk_Week5_WorkoutNameArray,
                                               bulk_Week6_WorkoutNameArray,
                                               bulk_Week7_WorkoutNameArray,
                                               bulk_Week8_WorkoutNameArray,
                                               bulk_Week9_WorkoutNameArray,
                                               bulk_Week10_WorkoutNameArray,
                                               bulk_Week11_WorkoutNameArray,
                                               bulk_Week12_WorkoutNameArray,
                                               bulk_Week13_WorkoutNameArray]

            return two_A_Days_WorkoutNameArray
        }
    }
    
    class func loadWorkoutIndexArray() -> [[Int]] {
        
        switch getCurrentRoutine() {
        case "Normal":
            // Normal
            let normal_Week1_WorkoutIndexArray = [1,
                                                  1,
                                                  1,
                                                  1,
                                                  1,
                                                  1,
                                                  1,
                                                  1]
            
            let normal_Week2_WorkoutIndexArray = [2,
                                                  2,
                                                  2,
                                                  2,
                                                  2,
                                                  2,
                                                  2,
                                                  2]
            
            let normal_Week3_WorkoutIndexArray = [3,
                                                  3,
                                                  3,
                                                  3,
                                                  3,
                                                  3,
                                                  3,
                                                  3]
            
            let normal_Week4_WorkoutIndexArray = [1,
                                                  4,
                                                  1,
                                                  1,
                                                  4,
                                                  4,
                                                  5,
                                                  4]
            
            let normal_Week5_WorkoutIndexArray = [1,
                                                  1,
                                                  5,
                                                  1,
                                                  1,
                                                  1,
                                                  6,
                                                  5]
            
            let normal_Week6_WorkoutIndexArray = [2,
                                                  2,
                                                  6,
                                                  2,
                                                  2,
                                                  2,
                                                  7,
                                                  6]
            
            let normal_Week7_WorkoutIndexArray = [3,
                                                  3,
                                                  7,
                                                  3,
                                                  3,
                                                  3,
                                                  8,
                                                  7]
            
            let normal_Week8_WorkoutIndexArray = [2,
                                                  9,
                                                  2,
                                                  2,
                                                  5,
                                                  8,
                                                  10,
                                                  8]
            
            let normal_Week9_WorkoutIndexArray = [1,
                                                  4,
                                                  4,
                                                  1,
                                                  9,
                                                  4,
                                                  4,
                                                  1,
                                                  11,
                                                  9]
            
            let normal_Week10_WorkoutIndexArray = [2,
                                                   4,
                                                   4,
                                                   5,
                                                   3,
                                                   4,
                                                   12,
                                                   10]
            
            let normal_Week11_WorkoutIndexArray = [3,
                                                   5,
                                                   5,
                                                   2,
                                                   10,
                                                   6,
                                                   5,
                                                   2,
                                                   13,
                                                   11]
            
            let normal_Week12_WorkoutIndexArray = [4,
                                                   5,
                                                   5,
                                                   7,
                                                   4,
                                                   5,
                                                   14,
                                                   12]
            
            let normal_Week13_WorkoutIndexArray = [3,
                                                   3,
                                                   5,
                                                   11,
                                                   15,
                                                   16,
                                                   13,
                                                   1]
            
            let normal_Week14_WorkoutIndexArray = [3,
                                                   1,
                                                   3,
                                                   12,
                                                   4,
                                                   2,
                                                   4,
                                                   6,
                                                   17,
                                                   14]
            
            let normal_Week15_WorkoutIndexArray = [5,
                                                   3,
                                                   5,
                                                   13,
                                                   6,
                                                   4,
                                                   6,
                                                   7,
                                                   18,
                                                   15]
            
            let normal_Week16_WorkoutIndexArray = [7,
                                                   5,
                                                   7,
                                                   14,
                                                   8,
                                                   6,
                                                   8,
                                                   8,
                                                   19,
                                                   16]
            
            let normal_Week17_WorkoutIndexArray = [6,
                                                   15,
                                                   6,
                                                   9,
                                                   4,
                                                   20,
                                                   17,
                                                   2]
            
            let normal_WorkoutIndexArray = [normal_Week1_WorkoutIndexArray,
                                            normal_Week2_WorkoutIndexArray,
                                            normal_Week3_WorkoutIndexArray,
                                            normal_Week4_WorkoutIndexArray,
                                            normal_Week5_WorkoutIndexArray,
                                            normal_Week6_WorkoutIndexArray,
                                            normal_Week7_WorkoutIndexArray,
                                            normal_Week8_WorkoutIndexArray,
                                            normal_Week9_WorkoutIndexArray,
                                            normal_Week10_WorkoutIndexArray,
                                            normal_Week11_WorkoutIndexArray,
                                            normal_Week12_WorkoutIndexArray,
                                            normal_Week13_WorkoutIndexArray,
                                            normal_Week14_WorkoutIndexArray,
                                            normal_Week15_WorkoutIndexArray,
                                            normal_Week16_WorkoutIndexArray,
                                            normal_Week17_WorkoutIndexArray]
            
            return normal_WorkoutIndexArray

            case "Tone":
                // TONE
                let tone_Week1_WorkoutIndexArray = [1,
                                                    1,
                                                    1,
                                                    1,
                                                    1,
                                                    1,
                                                    1,
                                                    1]
                
                let tone_Week2_WorkoutIndexArray = [2,
                                                    2,
                                                    2,
                                                    2,
                                                    2,
                                                    2,
                                                    2,
                                                    2]
                
                let tone_Week3_WorkoutIndexArray = [3,
                                                    3,
                                                    3,
                                                    3,
                                                    3,
                                                    3,
                                                    3,
                                                    3]
                
                let tone_Week4_WorkoutIndexArray = [4,
                                                    4,
                                                    4,
                                                    1,
                                                    4,
                                                    4,
                                                    5,
                                                    4]
                
                let tone_Week5_WorkoutIndexArray = [1,
                                                    4,
                                                    5,
                                                    1,
                                                    1,
                                                    4,
                                                    6,
                                                    5]
                
                let tone_Week6_WorkoutIndexArray = [2,
                                                    5,
                                                    6,
                                                    2,
                                                    2,
                                                    5,
                                                    7,
                                                    6]
                
                let tone_Week7_WorkoutIndexArray = [3,
                                                    6,
                                                    7,
                                                    3,
                                                    3,
                                                    6,
                                                    8,
                                                    7]
                
                let tone_Week8_WorkoutIndexArray = [5,
                                                    9,
                                                    5,
                                                    2,
                                                    5,
                                                    8,
                                                    10,
                                                    8]
                
                let tone_Week9_WorkoutIndexArray = [1,
                                                    4,
                                                    1,
                                                    1,
                                                    9,
                                                    4,
                                                    1,
                                                    1,
                                                    11,
                                                    9]
                
                let tone_Week10_WorkoutIndexArray = [5,
                                                     2,
                                                     5,
                                                     3,
                                                     3,
                                                     7,
                                                     12,
                                                     10]
                
                let tone_Week11_WorkoutIndexArray = [4,
                                                     6,
                                                     2,
                                                     2,
                                                     10,
                                                     6,
                                                     2,
                                                     2,
                                                     13,
                                                     11]
                
                let tone_Week12_WorkoutIndexArray = [7,
                                                     5,
                                                     7,
                                                     4,
                                                     6,
                                                     8,
                                                     14,
                                                     12]
                
                let tone_Week13_WorkoutIndexArray = [6,
                                                     6,
                                                     5,
                                                     11,
                                                     15,
                                                     16,
                                                     13,
                                                     1]
                
                let tone_Week14_WorkoutIndexArray = [3,
                                                     1,
                                                     3,
                                                     12,
                                                     4,
                                                     2,
                                                     4,
                                                     6,
                                                     17,
                                                     14]
                
                let tone_Week15_WorkoutIndexArray = [5,
                                                     3,
                                                     5,
                                                     13,
                                                     6,
                                                     4,
                                                     6,
                                                     7,
                                                     18,
                                                     15]
                
                let tone_Week16_WorkoutIndexArray = [7,
                                                     5,
                                                     7,
                                                     14,
                                                     8,
                                                     6,
                                                     8,
                                                     8,
                                                     19,
                                                     16]
                
                let tone_Week17_WorkoutIndexArray = [6,
                                                     15,
                                                     9,
                                                     9,
                                                     7,
                                                     20,
                                                     17,
                                                     2]

                let tone_WorkoutIndexArray = [tone_Week1_WorkoutIndexArray,
                                              tone_Week2_WorkoutIndexArray,
                                              tone_Week3_WorkoutIndexArray,
                                              tone_Week4_WorkoutIndexArray,
                                              tone_Week5_WorkoutIndexArray,
                                              tone_Week6_WorkoutIndexArray,
                                              tone_Week7_WorkoutIndexArray,
                                              tone_Week8_WorkoutIndexArray,
                                              tone_Week9_WorkoutIndexArray,
                                              tone_Week10_WorkoutIndexArray,
                                              tone_Week11_WorkoutIndexArray,
                                              tone_Week12_WorkoutIndexArray,
                                              tone_Week13_WorkoutIndexArray,
                                              tone_Week14_WorkoutIndexArray,
                                              tone_Week15_WorkoutIndexArray,
                                              tone_Week16_WorkoutIndexArray,
                                              tone_Week17_WorkoutIndexArray]
                
                return tone_WorkoutIndexArray

        case "2-A-Days":
            // 2-A-Days
            let two_A_Days_Week1_WorkoutIndexArray = [1,
                                                      1,
                                                      1,
                                                      1,
                                                      1,
                                                      2,
                                                      1,
                                                      1,
                                                      2,
                                                      1,
                                                      3,
                                                      1]
            
            let two_A_Days_Week2_WorkoutIndexArray = [3,
                                                      2,
                                                      2,
                                                      4,
                                                      2,
                                                      4,
                                                      2,
                                                      2,
                                                      5,
                                                      2,
                                                      6,
                                                      2]
            
            let two_A_Days_Week3_WorkoutIndexArray = [5,
                                                      3,
                                                      3,
                                                      7,
                                                      3,
                                                      6,
                                                      3,
                                                      3,
                                                      8,
                                                      3,
                                                      9,
                                                      3]
            
            let two_A_Days_Week4_WorkoutIndexArray = [1,
                                                      10,
                                                      1,
                                                      1,
                                                      4,
                                                      4,
                                                      11,
                                                      4]
            
            let two_A_Days_Week5_WorkoutIndexArray = [4,
                                                      2,
                                                      1,
                                                      12,
                                                      5,
                                                      1,
                                                      4,
                                                      1,
                                                      2,
                                                      1,
                                                      13,
                                                      14,
                                                      5]
            
            let two_A_Days_Week6_WorkoutIndexArray = [5,
                                                      3,
                                                      2,
                                                      15,
                                                      6,
                                                      2,
                                                      5,
                                                      2,
                                                      3,
                                                      2,
                                                      16,
                                                      17,
                                                      6]
            
            let two_A_Days_Week7_WorkoutIndexArray = [6,
                                                      4,
                                                      3,
                                                      18,
                                                      7,
                                                      3,
                                                      6,
                                                      3,
                                                      4,
                                                      3,
                                                      19,
                                                      20,
                                                      7]
            
            let two_A_Days_Week8_WorkoutIndexArray = [5,
                                                      21,
                                                      5,
                                                      2,
                                                      5,
                                                      22,
                                                      8,
                                                      23,
                                                      8]
            
            let two_A_Days_Week9_WorkoutIndexArray = [1,
                                                      6,
                                                      4,
                                                      3,
                                                      4,
                                                      1,
                                                      1,
                                                      24,
                                                      9,
                                                      6,
                                                      4,
                                                      6,
                                                      7,
                                                      1,
                                                      2,
                                                      25,
                                                      26,
                                                      9]
            
            let two_A_Days_Week10_WorkoutIndexArray = [2,
                                                       7,
                                                       7,
                                                       4,
                                                       1,
                                                       5,
                                                       5,
                                                       7,
                                                       10,
                                                       8,
                                                       4,
                                                       27,
                                                       28,
                                                       10]
            
            let two_A_Days_Week11_WorkoutIndexArray = [3,
                                                       8,
                                                       6,
                                                       5,
                                                       5,
                                                       2,
                                                       3,
                                                       29,
                                                       11,
                                                       7,
                                                       6,
                                                       8,
                                                       8,
                                                       2,
                                                       4,
                                                       30,
                                                       31,
                                                       11]
            
            let two_A_Days_Week12_WorkoutIndexArray = [4,
                                                       9,
                                                       9,
                                                       6,
                                                       2,
                                                       7,
                                                       7,
                                                       9,
                                                       12,
                                                       10,
                                                       5,
                                                       32,
                                                       33,
                                                       12]
            
            let two_A_Days_Week13_WorkoutIndexArray = [10,
                                                       10,
                                                       7,
                                                       13,
                                                       34,
                                                       35,
                                                       13,
                                                       1]
            
            let two_A_Days_Week14_WorkoutIndexArray = [3,
                                                       5,
                                                       11,
                                                       3,
                                                       11,
                                                       14,
                                                       8,
                                                       4,
                                                       6,
                                                       11,
                                                       4,
                                                       8,
                                                       15,
                                                       9,
                                                       36,
                                                       14]
            
            let two_A_Days_Week15_WorkoutIndexArray = [5,
                                                       7,
                                                       12,
                                                       5,
                                                       12,
                                                       16,
                                                       10,
                                                       6,
                                                       8,
                                                       12,
                                                       6,
                                                       9,
                                                       17,
                                                       11,
                                                       37,
                                                       15]
            
            let two_A_Days_Week16_WorkoutIndexArray = [7,
                                                       9,
                                                       13,
                                                       7,
                                                       13,
                                                       18,
                                                       12,
                                                       8,
                                                       10,
                                                       13,
                                                       8,
                                                       10,
                                                       19,
                                                       13,
                                                       38,
                                                       16]
            
            let two_A_Days_Week17_WorkoutIndexArray = [8,
                                                       20,
                                                       14,
                                                       14,
                                                       14,
                                                       39,
                                                       17,
                                                       2]
            
            let two_A_Days_WorkoutIndexArray = [two_A_Days_Week1_WorkoutIndexArray,
                                                two_A_Days_Week2_WorkoutIndexArray,
                                                two_A_Days_Week3_WorkoutIndexArray,
                                                two_A_Days_Week4_WorkoutIndexArray,
                                                two_A_Days_Week5_WorkoutIndexArray,
                                                two_A_Days_Week6_WorkoutIndexArray,
                                                two_A_Days_Week7_WorkoutIndexArray,
                                                two_A_Days_Week8_WorkoutIndexArray,
                                                two_A_Days_Week9_WorkoutIndexArray,
                                                two_A_Days_Week10_WorkoutIndexArray,
                                                two_A_Days_Week11_WorkoutIndexArray,
                                                two_A_Days_Week12_WorkoutIndexArray,
                                                two_A_Days_Week13_WorkoutIndexArray,
                                                two_A_Days_Week14_WorkoutIndexArray,
                                                two_A_Days_Week15_WorkoutIndexArray,
                                                two_A_Days_Week16_WorkoutIndexArray,
                                                two_A_Days_Week17_WorkoutIndexArray]
            
            return two_A_Days_WorkoutIndexArray
            
        default:
            // Bulk
            let bulk_Week1_WorkoutIndexArray = [1,
                                                1,
                                                1,
                                                1,
                                                1,
                                                1,
                                                1,
                                                1]
            
            let bulk_Week2_WorkoutIndexArray = [2,
                                                2,
                                                2,
                                                2,
                                                2,
                                                2,
                                                2,
                                                2]
            
            let bulk_Week3_WorkoutIndexArray = [3,
                                                3,
                                                3,
                                                3,
                                                3,
                                                3,
                                                3,
                                                3]
            
            let bulk_Week4_WorkoutIndexArray = [1,
                                                4,
                                                1,
                                                4,
                                                4,
                                                4,
                                                5,
                                                4]
            
            let bulk_Week5_WorkoutIndexArray = [1,
                                                1,
                                                5,
                                                2,
                                                2,
                                                1,
                                                6,
                                                5]
            
            let bulk_Week6_WorkoutIndexArray = [3,
                                                3,
                                                6,
                                                4,
                                                4,
                                                2,
                                                7,
                                                6]
            
            let bulk_Week7_WorkoutIndexArray = [5,
                                                5,
                                                7,
                                                6,
                                                6,
                                                3,
                                                8,
                                                7]
            
            let bulk_Week8_WorkoutIndexArray = [2,
                                                9,
                                                2,
                                                5,
                                                1,
                                                8,
                                                10,
                                                8]
            
            let bulk_Week9_WorkoutIndexArray = [7,
                                                7,
                                                9,
                                                8,
                                                8,
                                                4,
                                                11,
                                                9]
            
            let bulk_Week10_WorkoutIndexArray = [4,
                                                 5,
                                                 10,
                                                 4,
                                                 6,
                                                 4,
                                                 12,
                                                 10]
            
            let bulk_Week11_WorkoutIndexArray = [9,
                                                 9,
                                                 11,
                                                 10,
                                                 10,
                                                 5,
                                                 13,
                                                 11]
            
            let bulk_Week12_WorkoutIndexArray = [5,
                                                 6,
                                                 12,
                                                 5,
                                                 7,
                                                 5,
                                                 14,
                                                 12]
            
            let bulk_Week13_WorkoutIndexArray = [3,
                                                 13,
                                                 2,
                                                 11,
                                                 11,
                                                 15,
                                                 13,
                                                 1]
            
            let bulk_WorkoutIndexArray = [bulk_Week1_WorkoutIndexArray,
                                          bulk_Week2_WorkoutIndexArray,
                                          bulk_Week3_WorkoutIndexArray,
                                          bulk_Week4_WorkoutIndexArray,
                                          bulk_Week5_WorkoutIndexArray,
                                          bulk_Week6_WorkoutIndexArray,
                                          bulk_Week7_WorkoutIndexArray,
                                          bulk_Week8_WorkoutIndexArray,
                                          bulk_Week9_WorkoutIndexArray,
                                          bulk_Week10_WorkoutIndexArray,
                                          bulk_Week11_WorkoutIndexArray,
                                          bulk_Week12_WorkoutIndexArray,
                                          bulk_Week13_WorkoutIndexArray]
            
            return bulk_WorkoutIndexArray
        }
    }
    
    class func allWorkoutTitleArray() -> [String] {
        
        let workoutTitleArray = ["Negative Lower",
                                 "Negative Upper",
                                 "Agility Upper",
                                 "Agility Lower",
                                 "Devastator",
                                 "Complete Fitness",
                                 "The Goal",
                                 "Cardio Resistance",
                                 "MMA",
                                 "Dexterity",
                                 "Gladiator",
                                 "Plyometrics T",
                                 "Plyometrics D",
                                 "Cardio Speed",
                                 "Yoga",
                                 "Pilates",
                                 "Core I",
                                 "Core D",
                                 "Ab Workout",
                                 "Rest",
                                 "Warm Up",
                                 "Finished"]
        
        return workoutTitleArray
    }
    
    class func allExerciseTitleArray() -> [[String]] {
        
        // Get all the exercise names for each workout
        
        let negative_Lower = ["Squat",
                              "Lunge",
                              "Wide Squat",
                              "1 Leg Squat",
                              "Side High Knee Kick",
                              "Front High Knee Kick",
                              "1 Leg Lunge",
                              "Side Lunge Raise",
                              "1 Leg Squat Punch",
                              "Side Sphinx Leg Lift",
                              "Laying Heel Raise",
                              "Pommel Horse V",
                              "Downward Dog Calf Extension"]
        
        let negative_Upper = ["Push-Ups",
                              "Pull-Ups",
                              "Shoulder Press",
                              "Military Push-Ups",
                              "Underhand Pull-Ups",
                              "Bicep Curl to Shoulder Press",
                              "Wide Push-Ups",
                              "Side to Side Pull-Ups",
                              "Upright Row to Hammer",
                              "Offset Push-Ups",
                              "Leaning Row",
                              "2 Way Shoulder Raise",
                              "Plyometric Push-Ups",
                              "Opposite Grip Pull-Ups",
                              "Leaning Shoulder Flys",
                              "Leaning Tricep Extension",
                              "2 Way Bicep Curl",
                              "Tricep Pelvis Raise",
                              "Leaning Preacher Curl",
                              "BONUS Military Push-Ups",
                              "BONUS Wide Pull-Ups"]
        
        let agility_Upper = ["Slow Underhand Pull-Ups",
                             "Rotating Plyometric Push-Ups",
                             "Plyometric Lunge Press",
                             "3 Way Pull-Ups",
                             "Push-Up Plank Cross Crunch"]
//                             "BONUS Slow Underhand Pull-Ups",
//                             "BONUS Rotating Plyometric Push-Ups",
//                             "BONUS Plyometric Lunge Press",
//                             "BONUS 3 Way Pull-Ups",
//                             "BONUS Push-Up Plank Cross Crunch"
        
        let agility_Lower = ["1 Leg Squat",
                             "Plyometric Lunge Press",
                             "Side Jump Hops",
                             "Dead Squat Lunge",
                             "Alt Side Sphinx Leg Raise"]
        
        let devastator = ["Plank Row",
                          "Pull-Ups",
                          "Laying Chest Flys",
                          "Push-Ups",
                          "Leaning Row",
                          "Underhand Pull-Ups",
                          "Laying Chest Press",
                          "Military Push-Ups",
                          "3 Way Shoulder",
                          "Decline Shoulder Press",
                          "Leaning Shoulder Flys",
                          "Sphinx to A",
                          "Hammer Curls",
                          "Leaning Curls",
                          "Laying Cross Tricep Extension",
                          "Tricep Pelvis Raise",
                          "2 Way Curl",
                          "Leaning Tricep Extension",
                          "BONUS Push-Ups Plank Sphinx"]
        
        let complete_Fitness = ["Push-Up to Arm Balance",
                                "Crescent to Chair",
                                "Pull-Up Crunch",
                                "Side Sphinx Crunch",
                                "Plyometric Runner Push-Ups",
                                "Wide Squat on Toes",
                                "Underhand Pull-Up Crunch",
                                "V to Plow",
                                "Balance Circle Press",
                                "Lateral Jump Press",
                                "Balance 2 Way Hammer",
                                "V Crunch",
                                "Balance 2 Way Arm Raise",
                                "Squat Front Back",
                                "Laying Tricep Extension Punch",
                                "3 Way Warrior"]
        
        let the_Goal = ["Wide Pull-Up",
                        "Push-Up",
                        "Underhand Pull-Up",
                        "Military Push-Up",
                        "Narrow Pull-Up",
                        "Wide Push-Up",
                        "Opposite Grip Pull-Up",
                        "Offset Push-Up",
                        "BONUS Pull-Up Push-Up"]
        
        let cardio_Resistance = [String]()
        
        let mma = [String]()
        
        let dexterity = [String]()
        
        let gladiator = [String]()
        
        let plyometrics_T = [String]()
        
        let plyometrics_D = [String]()
        
        let cardio_Speed = [String]()
        
        let yoga = [String]()
        
        let pilates = [String]()
        
        let core_I = [String]()
        
        let core_D = [String]()

        let ab_Workout = [String]()
        
        let rest = [String]()
        
        let warm_Up = [String]()
        
        let finished = [String]()
        
        let exerciseTitleArray = [negative_Lower,
                                  negative_Upper,
                                  agility_Upper,
                                  agility_Lower,
                                  devastator,
                                  complete_Fitness,
                                  the_Goal,
                                  cardio_Resistance,
                                  mma,
                                  dexterity,
                                  gladiator,
                                  plyometrics_T,
                                  plyometrics_D,
                                  cardio_Speed,
                                  yoga,
                                  pilates,
                                  core_I,
                                  core_D,
                                  ab_Workout,
                                  rest,
                                  warm_Up,
                                  finished]
        
        return exerciseTitleArray
    }
    
    // MARK: - EMAIL STRINGS
    
    class func allSessionStringForEmail() -> String {
        
        // Get Data from the database.
        let allWorkoutTitlesArray = self.allWorkoutTitleArray()
        let allExerciseTitlesArray = self.allExerciseTitleArray()
        let writeString = NSMutableString()
        
        let routineArray = ["Normal",
                            "Tone",
                            "2-A-Days",
                            "Bulk"]
        
        // Get the highest session value stored in the database
        let maxSession = Int(self.findMaxSessionValue())
        
        // For each session, list each workouts data.  Normal then tone then 2-A-Days.
        // Sessions start at 1.  Cannot have a 0 session.
        for sessionCounter in 1...maxSession! {
            
            // Get session value.
            let currentSessionString = String(sessionCounter)
            
            // Routine
            for routineIndex in 0..<routineArray.count {
                
                // Workout
                for i in 0..<allWorkoutTitlesArray.count {
                    
                    var roundHeaderCount = 0
                    
                    switch allWorkoutTitlesArray[i] {
                    case "Agility Upper":
                        roundHeaderCount = 5
                        
                    case "Agility Lower":
                        roundHeaderCount = 4
                        
                    default:
                        roundHeaderCount = 2
                    }

                    let tempExerciseTitlesArray = allExerciseTitlesArray[i]
                    
                    // Get workout data with the current session.  Sort by INDEX.
                    let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                    let sortIndex = NSSortDescriptor( key: "index", ascending: true)
                    let sortDate = NSSortDescriptor( key: "date", ascending: true)
                    request.sortDescriptors = [sortIndex, sortDate]
                    
                    let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@",
                                             currentSessionString,
                                             routineArray[routineIndex],
                                             allWorkoutTitlesArray[i])
                    
                    request.predicate = filter
                    
                    do {
                        if let workoutObjects1 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                            
                            // print("workoutObjects1.count = \(workoutObjects1.count)")
                            
                            var maxIndex = 0
                            
                            if workoutObjects1.count != 0 {
                                
                                maxIndex = Int((workoutObjects1.last?.index)!)
                                
                                var localSession = ""
                                var localRoutine = ""
                                var localWeek = ""
                                var localWorkout = ""
                                var localDate = Date()
                                var dateString = ""
                                
                                var tempExerciseName = ""
                                var tempWeightData = ""
                                var tempRepData = ""
                                var tempNotesData = ""
                                var roundConvertedToString = ""
                                
                                // Get the values for each index that was found for this workout.
                                // Workout indexes start at 1.  Cannot have a 0 index.
                                for index in 1...maxIndex {
                                    
                                    let convertedIndex = NSNumber(value: index as Int)
                                    
                                    // Get workout data with workout index
                                    let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                                    
                                    var filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index == %@",
                                                             currentSessionString,
                                                             routineArray[routineIndex],
                                                             allWorkoutTitlesArray[i],
                                                             convertedIndex)
                                    
                                    request.predicate = filter
                                    
                                    do {
                                        if let workoutObjects2 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                            
                                            //print("workoutObjects.count = \(workoutObjects.count)")
                                            
                                            // Check if there are any matches for the given index.  If none skip the index.
                                            if workoutObjects2.count == 0 {
                                                
                                                // No Matches for this workout with index
                                            }
                                            else {
                                                
                                                // Matches found
                                                
                                                // Add column headers
                                                for a in 0..<1 {
                                                    
                                                    //  Add the column headers for Routine, Month, Week, Workout, and Date to the string
                                                    writeString.append("Session,Routine,Week,Try,Workout,Date\n")
                                                    
                                                    localSession = workoutObjects2[a].session!
                                                    localRoutine = workoutObjects2[a].routine!
                                                    localWeek = workoutObjects2[a].week!
                                                    localWorkout = workoutObjects2[a].workout!
                                                    localDate = workoutObjects2[a].date! as Date
                                                    
                                                    dateString = DateFormatter.localizedString(from: localDate, dateStyle: .short, timeStyle: .none)
                                                    
                                                    // Add column headers for indivialual workouts based on workout index number
                                                    writeString.append("\(localSession),\(localRoutine),\(localWeek),\(index),\(self.trimStringForWorkoutName(localWorkout)),\(dateString)\n")
                                                }
                                                
                                                let workoutIndex = NSNumber(value: index as Int)
                                                
                                                //  Add the exercise name, reps and weight
                                                for b in 0..<tempExerciseTitlesArray.count {
                                                    
                                                    tempExerciseName = tempExerciseTitlesArray[b]
                                                    
                                                    //  Add the exercise title to the string
                                                    //  Add the exercise title to the string
                                                    switch allWorkoutTitlesArray[i] {
                                                    case "Agility Upper":
                                                        writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Round 4, Round 5, ,Notes\n")
                                                        
                                                    case "Agility Lower":
                                                        writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Round 4, ,Notes\n")
                                                        
                                                    default:
                                                        writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, ,Notes\n")
                                                    }
                                                    
                                                    // Add the "Reps" to the row
                                                    writeString.append("Reps,")
                                                    
                                                    //  Add the reps and notes to the string
                                                    for round in 0..<roundHeaderCount {
                                                        
                                                        roundConvertedToString = self.renameRoundIntToString(round)
                                                        tempRepData = ""
                                                        tempNotesData = ""
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localRoutine,
                                                                             localWorkout,
                                                                             tempExerciseName,
                                                                             roundConvertedToString,
                                                                             workoutIndex)
                                                        
                                                        request.predicate = filter
                                                        
                                                        do {
                                                            if let workoutObjects3 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                                
                                                                //print("workoutObjects.count = \(workoutObjects.count)")
                                                                
                                                                if workoutObjects3.count >= 1 {
                                                                    
                                                                    // Match found
                                                                    
                                                                    // Reps is not nil
                                                                    if workoutObjects3.last?.reps != nil {
                                                                        
                                                                        tempRepData = (workoutObjects3.last?.reps)!
                                                                        
                                                                        if round == roundHeaderCount - 1 {
                                                                            
                                                                            //  Inserts a """" into the string
                                                                            writeString.append("\(tempRepData),,")
                                                                        }
                                                                        else {
                                                                            
                                                                            //  Inserts a "" into the string
                                                                            writeString.append("\(tempRepData),")
                                                                        }
                                                                    }
                                                                    else {
                                                                        
                                                                        // There was a record found, but only had data for the weight or notes and not the reps.
                                                                        if round == roundHeaderCount - 1 {
                                                                            
                                                                            //  Inserts a """" into the string
                                                                            writeString.append("\(tempRepData),,")
                                                                        }
                                                                        else {
                                                                            
                                                                            //  Inserts a "" into the string
                                                                            writeString.append("\(tempRepData),")
                                                                        }
                                                                    }
                                                                }
                                                                else {
                                                                    // No match found
                                                                    if round == roundHeaderCount - 1 {
                                                                        
                                                                        //  Inserts a """" into the string
                                                                        writeString.append("\(tempRepData),,")
                                                                    }
                                                                    else {
                                                                        
                                                                        //  Inserts a "" into the string
                                                                        writeString.append("\(tempRepData),")
                                                                    }
                                                                }
                                                            }
                                                        } catch { print(" ERROR executing a fetch request: \( error)") }
                                                        
                                                        //  Notes
                                                        if round == roundHeaderCount - 1 {
                                                            
                                                            filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                                 currentSessionString,
                                                                                 localRoutine,
                                                                                 localWorkout,
                                                                                 tempExerciseName,
                                                                                 "Round 1",
                                                                                 workoutIndex)
                                                            
                                                            request.predicate = filter
                                                            
                                                            do {
                                                                if let workoutObjectsNotes = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                                    
                                                                    if workoutObjectsNotes.count >= 1 {
                                                                        
                                                                        //  Match found
                                                                        
                                                                        //  Weight is not nil
                                                                        if workoutObjectsNotes.last?.notes != nil {
                                                                            
                                                                            tempNotesData = (workoutObjectsNotes.last?.notes)!
                                                                            
                                                                            writeString.append("\(tempNotesData)\n")
                                                                        }
                                                                        else {
                                                                            
                                                                            writeString.append("\(tempNotesData)\n")
                                                                        }
                                                                    }
                                                                    else {
                                                                        
                                                                        //  No match found
                                                                        
                                                                        writeString.append("\(tempNotesData)\n")
                                                                    }
                                                                }
                                                            } catch { print(" ERROR executing a fetch request: \( error)") }
                                                        }
                                                    }
                                                    
                                                    // Add the "Weight" to the row
                                                    writeString.append("Weight,")
                                                    
                                                    //  Add the weight line from the database
                                                    for round in 0..<roundHeaderCount {
                                                        
                                                        roundConvertedToString = self.renameRoundIntToString(round)
                                                        tempWeightData = ""
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localRoutine,
                                                                             localWorkout,
                                                                             tempExerciseName,
                                                                             roundConvertedToString,
                                                                             workoutIndex)
                                                        
                                                        request.predicate = filter
                                                        
                                                        do {
                                                            if let workoutObjects4 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                                
                                                                //print("workoutObjects.count = \(workoutObjects.count)")
                                                                
                                                                if workoutObjects4.count >= 1 {
                                                                    
                                                                    //  Match found
                                                                    
                                                                    //  Weight is not nil
                                                                    if workoutObjects4.last?.weight != nil {
                                                                        
                                                                        tempWeightData = (workoutObjects4.last?.weight)!
                                                                        
                                                                        if round == roundHeaderCount - 1 {
                                                                            
                                                                            writeString.append("\(tempWeightData)\n")
                                                                        }
                                                                        else {
                                                                            
                                                                            writeString.append("\(tempWeightData),")
                                                                        }
                                                                    }
                                                                    else {
                                                                        
                                                                        //  There was a record found, but only had data for the reps or notes and not the weight.
                                                                        if round == roundHeaderCount - 1 {
                                                                            
                                                                            writeString.append("\(tempWeightData)\n")
                                                                        }
                                                                        else {
                                                                            
                                                                            writeString.append("\(tempWeightData),")
                                                                        }
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    //  No Weight
                                                                    //  Inserts a "" into the string
                                                                    if round == roundHeaderCount - 1 {
                                                                        
                                                                        writeString.append("\(tempWeightData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempWeightData),")
                                                                    }
                                                                }
                                                            }
                                                        } catch { print(" ERROR executing a fetch request: \( error)") }
                                                    }
                                                }
                                            }
                                            
                                            //  Ends the workout with a return mark \n before starting the next workout
                                            writeString.append(",\n")
                                            
                                        }
                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                }
                            }
                        }
                    } catch { print(" ERROR executing a fetch request: \( error)") }
                }
            }
        }
        
        //  Return the string
        return writeString as String
    }
    
    class func currentSessionStringForEmail() -> String {
        
        // Get Data from the database.
        let allWorkoutTitlesArray = self.allWorkoutTitleArray()
        let allExerciseTitlesArray = self.allExerciseTitleArray()
        let writeString = NSMutableString()
        
        let routineArray = ["Normal",
                            "Tone",
                            "2-A-Days",
                            "Bulk"]
        
        // Get the current session value stored in the database
        let currentSessionString = self.getCurrentSession()
        
        // Routine
        for routineIndex in 0..<routineArray.count {
            
            // Workout
            for i in 0..<allWorkoutTitlesArray.count {
                
                var roundHeaderCount = 0
                
                switch allWorkoutTitlesArray[i] {
                case "Agility Upper":
                    roundHeaderCount = 5
                    
                case "Agility Lower":
                    roundHeaderCount = 4
                    
                default:
                    roundHeaderCount = 2
                }

                let tempExerciseTitlesArray = allExerciseTitlesArray[i]
                
                // Get workout data with the current session.  Sort by INDEX.
                let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                let sortIndex = NSSortDescriptor( key: "index", ascending: true)
                let sortDate = NSSortDescriptor( key: "date", ascending: true)
                request.sortDescriptors = [sortIndex, sortDate]
                
                let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@",
                                         currentSessionString,
                                         routineArray[routineIndex],
                                         allWorkoutTitlesArray[i])
                
                request.predicate = filter
                
                do {
                    if let workoutObjects1 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                        
                        // print("workoutObjects1.count = \(workoutObjects1.count)")
                        
                        var maxIndex = 0
                        
                        if workoutObjects1.count != 0 {
                            
                            maxIndex = Int((workoutObjects1.last?.index)!)
                            
                            var localSession = ""
                            var localRoutine = ""
                            var localWeek = ""
                            var localWorkout = ""
                            var localDate = Date()
                            var dateString = ""
                            
                            var tempExerciseName = ""
                            var tempWeightData = ""
                            var tempRepData = ""
                            var tempNotesData = ""
                            var roundConvertedToString = ""
                            
                            // Get the values for each index that was found for this workout.
                            // Workout indexes start at 1.  Cannot have a 0 index.
                            for index in 1...maxIndex {
                                
                                let convertedIndex = NSNumber(value: index as Int)
                                
                                // Get workout data with workout index
                                let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                                
                                var filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index == %@",
                                                         currentSessionString,
                                                         routineArray[routineIndex],
                                                         allWorkoutTitlesArray[i],
                                                         convertedIndex)
                                
                                request.predicate = filter
                                
                                do {
                                    if let workoutObjects2 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                        
                                        //print("workoutObjects.count = \(workoutObjects.count)")
                                        
                                        // Check if there are any matches for the given index.  If none skip the index.
                                        if workoutObjects2.count == 0 {
                                            
                                            // No Matches for this workout with index
                                        }
                                        else {
                                            
                                            // Matches found
                                            
                                            // Add column headers
                                            for a in 0..<1 {
                                                
                                                //  Add the column headers for Routine, Month, Week, Workout, and Date to the string
                                                writeString.append("Session,Routine,Week,Try,Workout,Date\n")
                                                
                                                localSession = workoutObjects2[a].session!
                                                localRoutine = workoutObjects2[a].routine!
                                                localWeek = workoutObjects2[a].week!
                                                localWorkout = workoutObjects2[a].workout!
                                                localDate = workoutObjects2[a].date! as Date
                                                
                                                dateString = DateFormatter.localizedString(from: localDate, dateStyle: .short, timeStyle: .none)
                                                
                                                // Add column headers for indivialual workouts based on workout index number
                                                writeString.append("\(localSession),\(localRoutine),\(localWeek),\(index),\(self.trimStringForWorkoutName(localWorkout)),\(dateString)\n")
                                            }
                                            
                                            let workoutIndex = NSNumber(value: index as Int)
                                            
                                            //  Add the exercise name, reps and weight
                                            for b in 0..<tempExerciseTitlesArray.count {
                                                
                                                tempExerciseName = tempExerciseTitlesArray[b]
                                                
                                                //  Add the exercise title to the string
                                                switch allWorkoutTitlesArray[i] {
                                                case "Agility Upper":
                                                    writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Round 4, Round 5, ,Notes\n")
                                                    
                                                case "Agility Lower":
                                                    writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Round 4, ,Notes\n")
                                                    
                                                default:
                                                    writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, ,Notes\n")
                                                }
                                                
                                                // Add the "Reps" to the row
                                                writeString.append("Reps,")

                                                //  Add the reps and notes to the string
                                                for round in 0..<roundHeaderCount {
                                                    
                                                    roundConvertedToString = self.renameRoundIntToString(round)
                                                    tempRepData = ""
                                                    tempNotesData = ""
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localRoutine,
                                                                         localWorkout,
                                                                         tempExerciseName,
                                                                         roundConvertedToString,
                                                                         workoutIndex)
                                                    
                                                    request.predicate = filter
                                                    
                                                    do {
                                                        if let workoutObjects3 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                            
                                                            //print("workoutObjects.count = \(workoutObjects.count)")
                                                            
                                                            if workoutObjects3.count >= 1 {
                                                                
                                                                // Match found
                                                                
                                                                // Reps is not nil
                                                                if workoutObjects3.last?.reps != nil {
                                                                    
                                                                    tempRepData = (workoutObjects3.last?.reps)!
                                                                    
                                                                    if round == roundHeaderCount - 1 {
                                                                        
                                                                        //  Inserts a """" into the string
                                                                        writeString.append("\(tempRepData),,")
                                                                    }
                                                                    else {
                                                                        
                                                                        //  Inserts a "" into the string
                                                                        writeString.append("\(tempRepData),")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    // There was a record found, but only had data for the weight or notes and not the reps.
                                                                    if round == roundHeaderCount - 1 {
                                                                        
                                                                        //  Inserts a """" into the string
                                                                        writeString.append("\(tempRepData),,")
                                                                    }
                                                                    else {
                                                                        
                                                                        //  Inserts a "" into the string
                                                                        writeString.append("\(tempRepData),")
                                                                    }
                                                                }
                                                            }
                                                            else {
                                                                // No match found
                                                                if round == roundHeaderCount - 1 {
                                                                    
                                                                    //  Inserts a """" into the string
                                                                    writeString.append("\(tempRepData),,")
                                                                }
                                                                else {
                                                                    
                                                                    //  Inserts a "" into the string
                                                                    writeString.append("\(tempRepData),")
                                                                }
                                                            }
                                                        }
                                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                                    
                                                    //  Notes
                                                    if round == roundHeaderCount - 1 {
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localRoutine,
                                                                             localWorkout,
                                                                             tempExerciseName,
                                                                             "Round 1",
                                                                             workoutIndex)
                                                        
                                                        request.predicate = filter
                                                        
                                                        do {
                                                            if let workoutObjectsNotes = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                                
                                                                if workoutObjectsNotes.count >= 1 {
                                                                    
                                                                    //  Match found
                                                                    
                                                                    //  Weight is not nil
                                                                    if workoutObjectsNotes.last?.notes != nil {
                                                                        
                                                                        tempNotesData = (workoutObjectsNotes.last?.notes)!
                                                                        
                                                                        writeString.append("\(tempNotesData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempNotesData)\n")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    //  No match found
                                                                    
                                                                    writeString.append("\(tempNotesData)\n")
                                                                }
                                                            }
                                                        } catch { print(" ERROR executing a fetch request: \( error)") }
                                                    }
                                                }
                                                
                                                // Add the "Weight" to the row
                                                writeString.append("Weight,")
                                                
                                                //  Add the weight line from the database
                                                for round in 0..<roundHeaderCount {
                                                    
                                                    roundConvertedToString = self.renameRoundIntToString(round)
                                                    tempWeightData = ""
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localRoutine,
                                                                         localWorkout,
                                                                         tempExerciseName,
                                                                         roundConvertedToString,
                                                                         workoutIndex)
                                                    
                                                    request.predicate = filter
                                                    
                                                    do {
                                                        if let workoutObjects4 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                            
                                                            //print("workoutObjects.count = \(workoutObjects.count)")
                                                            
                                                            if workoutObjects4.count >= 1 {
                                                                
                                                                //  Match found
                                                                
                                                                //  Weight is not nil
                                                                if workoutObjects4.last?.weight != nil {
                                                                    
                                                                    tempWeightData = (workoutObjects4.last?.weight)!
                                                                    
                                                                    if round == roundHeaderCount - 1 {
                                                                        
                                                                        writeString.append("\(tempWeightData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempWeightData),")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    //  There was a record found, but only had data for the reps or notes and not the weight.
                                                                    if round == roundHeaderCount - 1 {
                                                                        
                                                                        writeString.append("\(tempWeightData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempWeightData),")
                                                                    }
                                                                }
                                                            }
                                                            else {
                                                                
                                                                //  No Weight
                                                                //  Inserts a "" into the string
                                                                if round == roundHeaderCount - 1 {
                                                                    
                                                                    writeString.append("\(tempWeightData)\n")
                                                                }
                                                                else {
                                                                    
                                                                    writeString.append("\(tempWeightData),")
                                                                }
                                                            }
                                                        }
                                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                                }
                                            }
                                        }
                                        
                                        //  Ends the workout with a return mark \n before starting the next workout
                                        writeString.append(",\n")
                                        
                                    }
                                } catch { print(" ERROR executing a fetch request: \( error)") }
                            }
                        }
                    }
                } catch { print(" ERROR executing a fetch request: \( error)") }
            }
        }
        
        //  Return the string
        return writeString as String
    }
    
    class func singleWorkoutStringForEmail(_ workoutName: String, index: Int) -> String {
        
        let writeString = NSMutableString()
        
        let localAllWorkoutTitleArray = self.allWorkoutTitleArray()
        let localAllExerciseTitleArray = self.allExerciseTitleArray()
        var exerciseTitleArray = [String]()
        
        var roundHeaderCount = 0
        
        switch workoutName {
        case "Agility Upper":
            roundHeaderCount = 5
            
        case "Agility Lower":
            roundHeaderCount = 4
            
        default:
            roundHeaderCount = 2
        }
        
        for arrayIndex in 0..<localAllWorkoutTitleArray.count {
            
            if workoutName == localAllWorkoutTitleArray[arrayIndex] {
                
                exerciseTitleArray = localAllExerciseTitleArray[arrayIndex]
            }
        }
        
        // Get the current session value stored in the database
        let currentSessionString = self.getCurrentSession()
        
        // Get the current routine value stored in the database
        let currentRoutineString = self.getCurrentRoutine()

        // Convert the index Int into an NSNumber
        let convertedIndex = NSNumber(value: index as Int)
        
        // Get workout data with workout index
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        
        var filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index == %@",
                                 currentSessionString,
                                 currentRoutineString,
                                 workoutName,
                                 convertedIndex)
        
        request.predicate = filter
        
        do {
            if let workoutObjects2 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                // Check if there are any matches for the given index.  If none skip the index.
                if workoutObjects2.count == 0 {
                    
                    // No Matches for this workout with index
                }
                else {
                    
                    // Matches found
                    
                    // Add column headers
                    for a in 0..<1 {
                        
                        //  Add the column headers for Routine, Month, Week, Workout, and Date to the string
                        writeString.append("Session,Routine,Week,Try,Workout,Date\n")
                        
                        let localSession = workoutObjects2[a].session!
                        let localRoutine = workoutObjects2[a].routine!
                        let localWeek = workoutObjects2[a].week!
                        let localWorkout = self.trimStringForWorkoutName(workoutObjects2[a].workout!) 
                        let localDate = workoutObjects2[a].date!
                        
                        let dateString = DateFormatter.localizedString(from: localDate as Date, dateStyle: .short, timeStyle: .none)
                        
                        // Add column headers for indivialual workouts based on workout index number
                        writeString.append("\(localSession),\(localRoutine),\(localWeek),\(index),\(localWorkout),\(dateString)\n")
                    }
                    
                    //  Add the exercise name, reps and weight
                    for b in 0..<exerciseTitleArray.count {
                        
                        let tempExerciseName = exerciseTitleArray[b] 
                        
                        //  Add the exercise title to the string
                        switch workoutName {
                        case "Agility Upper":
                            writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Round 4, Round 5, ,Notes\n")
                            
                        case "Agility Lower":
                            writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Round 4, ,Notes\n")
                            
                        default:
                            writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, ,Notes\n")
                        }
                        
                        // Add the "Reps" to the row
                        writeString.append("Reps,")
                        
                        //  Add the reps and notes to the string
                        for round in 0..<roundHeaderCount {
                            
                            let roundConvertedToString = self.renameRoundIntToString(round)
                            var tempRepData = ""
                            var tempNotesData = ""
                            
                            filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                 currentSessionString,
                                                 currentRoutineString,
                                                 workoutName,
                                                 tempExerciseName,
                                                 roundConvertedToString,
                                                 convertedIndex)
                            
                            request.predicate = filter
                            
                            do {
                                if let workoutObjects3 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                    
                                    //print("workoutObjects.count = \(workoutObjects.count)")
                                    
                                    if workoutObjects3.count >= 1 {
                                        
                                        // Match found
                                        
                                        // Reps is not nil
                                        if workoutObjects3.last?.reps != nil {
                                            
                                            tempRepData = (workoutObjects3.last?.reps)!
                                            
                                            if round == roundHeaderCount - 1 {
                                                
                                                //  Inserts a """" into the string
                                                writeString.append("\(tempRepData),,")
                                            }
                                            else {
                                                
                                                //  Inserts a "" into the string
                                                writeString.append("\(tempRepData),")
                                            }
                                        }
                                        else {
                                            
                                            // There was a record found, but only had data for the weight or notes and not the reps.
                                            if round == roundHeaderCount - 1 {
                                                
                                                //  Inserts a """" into the string
                                                writeString.append("\(tempRepData),,")
                                            }
                                            else {
                                                
                                                //  Inserts a "" into the string
                                                writeString.append("\(tempRepData),")
                                            }
                                        }
                                    }
                                    else {
                                        // No match found
                                        if round == roundHeaderCount - 1 {
                                            
                                            //  Inserts a """" into the string
                                            writeString.append("\(tempRepData),,")
                                        }
                                        else {
                                            
                                            //  Inserts a "" into the string
                                            writeString.append("\(tempRepData),")
                                        }
                                    }
                                }
                            } catch { print(" ERROR executing a fetch request: \( error)") }
                            
                            //  Notes
                            if round == roundHeaderCount - 1 {
                                
                                filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                     currentSessionString,
                                                     currentRoutineString,
                                                     workoutName,
                                                     tempExerciseName,
                                                     "Round 1",
                                                     convertedIndex)
                                
                                request.predicate = filter
                                
                                do {
                                    if let workoutObjectsNotes = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                        
                                        if workoutObjectsNotes.count >= 1 {
                                            
                                            //  Match found
                                            
                                            //  Weight is not nil
                                            if workoutObjectsNotes.last?.notes != nil {
                                                
                                                tempNotesData = (workoutObjectsNotes.last?.notes)!
                                                
                                                writeString.append("\(tempNotesData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempNotesData)\n")
                                            }
                                        }
                                        else {
                                            
                                            //  No match found
                                            
                                            writeString.append("\(tempNotesData)\n")
                                        }
                                    }
                                } catch { print(" ERROR executing a fetch request: \( error)") }
                            }
                        }
                        
                        // Add the "Weight" to the row
                        writeString.append("Weight,")
                        
                        //  Add the weight line from the database
                        for round in 0..<roundHeaderCount {
                            
                            let roundConvertedToString = self.renameRoundIntToString(round)
                            var tempWeightData = ""
                            
                            filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                 currentSessionString,
                                                 currentRoutineString,
                                                 workoutName,
                                                 tempExerciseName,
                                                 roundConvertedToString,
                                                 convertedIndex)
                            
                            request.predicate = filter
                            
                            do {
                                if let workoutObjects4 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                    
                                    //print("workoutObjects.count = \(workoutObjects.count)")
                                    
                                    if workoutObjects4.count >= 1 {
                                        
                                        //  Match found
                                        
                                        //  Weight is not nil
                                        if workoutObjects4.last?.weight != nil {
                                            
                                            tempWeightData = (workoutObjects4.last?.weight)!
                                            
                                            if round == roundHeaderCount - 1 {
                                                
                                                writeString.append("\(tempWeightData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempWeightData),")
                                            }
                                        }
                                        else {
                                            
                                            //  There was a record found, but only had data for the reps or notes and not the weight.
                                            if round == roundHeaderCount - 1 {
                                                
                                                writeString.append("\(tempWeightData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempWeightData),")
                                            }
                                        }
                                    }
                                    else {
                                        
                                        //  No Weight
                                        //  Inserts a "" into the string
                                        if round == roundHeaderCount - 1 {
                                            
                                            writeString.append("\(tempWeightData)\n")
                                        }
                                        else {
                                            
                                            writeString.append("\(tempWeightData),")
                                        }
                                    }
                                }
                            } catch { print(" ERROR executing a fetch request: \( error)") }
                        }
                    }
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        //  Return the string
        return writeString as String
    }

    // MARK: - UTITILYT METHODS
    
    class func findMaxSessionValue() -> String {
        
        // Workout Entity
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortSession = NSSortDescriptor( key: "session", ascending: true)
        
        request.sortDescriptors = [sortSession]
        
        var maxSessionString = "1"
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                maxSessionString = (workoutObjects.last?.session)!
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return maxSessionString
    }
    
    class func trimStringForWorkoutName(_ originalString: String) -> String {
        
        switch originalString {
            
        case originalString where originalString.hasSuffix(" & Ab Workout"):
            
            return (originalString as NSString).substring(to: (originalString as NSString).length - 13)
            
        case originalString where originalString.hasSuffix(" or Rest"):
            
            return (originalString as NSString).substring(to: (originalString as NSString).length - 8)
            
        default:
            return originalString
            
        }
    }
    
    class func renameRoundIntToString(_ roundInt: Int) -> String {
        
        switch roundInt {
        case 0:
            return "Round 1"
            
        case 1:
            return "Round 2"
            
        case 2:
            return "Round 3"
            
        case 3:
            return "Round 4"
            
        default:
            // Round 5
            return "Round 5"
        }
    }
    
    class func renameRoundStringToInt(_ roundString: String) -> Int {
        
        switch roundString {
        case "Round 1":
            return 0
            
        case "Round 2":
            return 1
            
        case "Round 3":
            return 2
            
        case "Round 4":
            return 3
            
        default:
            // Round 5
            return 4
        }
    }
    
    class func findMaxIndexForWorkout(routine: String, workoutName: String) -> Int {
        
        switch routine {
        case "Normal":
            
            switch workoutName {
            case "Negative Lower":
                return 5
                
            case "Negative Upper":
                return 5
                
            case "Agility Upper":
                return 8
                
            case "Agility Lower":
                return 8
                
            case "Devastator":
                return 3
                
            case "Complete Fitness":
                return 5
                
            case "The Goal":
                return 5

            case "Cardio Resistance":
                return 6
                
            case "MMA":
                return 5
                
            case "Dexterity":
                return 6
                
            case "Gladiator":
                return 3
                
            case "Plyometrics T":
                return 7
                
            case "Plyometrics D":
                return 4
                
            case "Cardio Speed":
                return 3
                
            case "Yoga":
                return 15
                
            case "Pilates":
                return 9
                
            case "Core I":
                return 4
                
            case "Core D":
                return 20
                
            case "Ab Workout":
                return 6
                
            case "Rest":
                return 17
                
            case "Warm Up":
                return 0
                
            case "Finished":
                return 2
                
            default:
                // No matches
                return 0
            }
            
        case "Tone":
            
            switch workoutName {
            case "Negative Lower":
                return 2
                
            case "Negative Upper":
                return 2
                
            case "Agility Upper":
                return 8
                
            case "Agility Lower":
                return 8
                
            case "Devastator":
                return 3
                
            case "Complete Fitness":
                return 0
                
            case "The Goal":
                return 0
                
            case "Cardio Resistance":
                return 9
                
            case "MMA":
                return 7
                
            case "Dexterity":
                return 6
                
            case "Gladiator":
                return 6
                
            case "Plyometrics T":
                return 7
                
            case "Plyometrics D":
                return 6
                
            case "Cardio Speed":
                return 6
                
            case "Yoga":
                return 15
                
            case "Pilates":
                return 9
                
            case "Core I":
                return 7
                
            case "Core D":
                return 20
                
            case "Ab Workout":
                return 6
                
            case "Rest":
                return 17
                
            case "Warm Up":
                return 0
                
            case "Finished":
                return 2
                
            default:
                // No matches
                return 0
            }
            
        case "2-A-Days":
            
            switch workoutName {
            case "Negative Lower":
                return 5
                
            case "Negative Upper":
                return 2
                
            case "Agility Upper":
                return 8
                
            case "Agility Lower":
                return 8
                
            case "Devastator":
                return 3
                
            case "Complete Fitness":
                return 8
                
            case "The Goal":
                return 5
                
            case "Cardio Resistance":
                return 10
                
            case "MMA":
                return 14
                
            case "Dexterity":
                return 8
                
            case "Gladiator":
                return 3
                
            case "Plyometrics T":
                return 7
                
            case "Plyometrics D":
                return 4
                
            case "Cardio Speed":
                return 13
                
            case "Yoga":
                return 20
                
            case "Pilates":
                return 14
                
            case "Core I":
                return 14
                
            case "Core D":
                return 39
                
            case "Ab Workout":
                return 10
                
            case "Rest":
                return 17
                
            case "Warm Up":
                return 6
                
            case "Finished":
                return 2
                
            default:
                // No matches
                return 0
            }
            
        default:
            
            // Bulk
            switch workoutName {
            case "Negative Lower":
                return 11
                
            case "Negative Upper":
                return 11
                
            case "Agility Upper":
                return 0
                
            case "Agility Lower":
                return 0
                
            case "Devastator":
                return 5
                
            case "Complete Fitness":
                return 5
                
            case "The Goal":
                return 5
                
            case "Cardio Resistance":
                return 0
                
            case "MMA":
                return 5
                
            case "Dexterity":
                return 6
                
            case "Gladiator":
                return 2
                
            case "Plyometrics T":
                return 0
                
            case "Plyometrics D":
                return 2
                
            case "Cardio Speed":
                return 0
                
            case "Yoga":
                return 13
                
            case "Pilates":
                return 7
                
            case "Core I":
                return 3
                
            case "Core D":
                return 15
                
            case "Ab Workout":
                return 0
                
            case "Rest":
                return 13
                
            case "Warm Up":
                return 0
                
            case "Finished":
                return 1
                
            default:
                // No matches
                return 0
            }
        }
    }
}
