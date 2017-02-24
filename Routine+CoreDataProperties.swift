//
//  Routine+CoreDataProperties.swift
//  90 DWT 3
//
//  Created by Grant, Jared on 2/21/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import Foundation
import CoreData


extension Routine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Routine> {
        return NSFetchRequest<Routine>(entityName: "Routine");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var defaultRoutine: String?

}
