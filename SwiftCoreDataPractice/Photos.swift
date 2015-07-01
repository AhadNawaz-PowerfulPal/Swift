//
//  Photos.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/25/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import Foundation
import CoreData

class Photos: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var album: Album

    var downloadTask:NSURLSessionDownloadTask?
    var taskIdentifier:Int?
}
