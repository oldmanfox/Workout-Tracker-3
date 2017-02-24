//
//  Email+CoreDataProperties.swift
//  90 DWT 3
//
//  Created by Grant, Jared on 2/21/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import Foundation
import CoreData


extension Email {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Email> {
        return NSFetchRequest<Email>(entityName: "Email");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var defaultEmail: String?

}
