//
//  Album.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/25/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import Foundation
import CoreData

class Album: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var photo: Photos

}
