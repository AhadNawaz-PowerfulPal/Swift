//
//  Books.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/22/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import Foundation
import CoreData

class Books: NSManagedObject {

    @NSManaged var data: NSData
    @NSManaged var dest_path: String
    @NSManaged var name: String
    @NSManaged var progress: NSNumber
    @NSManaged var source_path: String
    @NSManaged var status: NSNumber
    
    var downloadTask:NSURLSessionDownloadTask?
    var taskIdentifier:Int?
//    var fileData:NSData?
    

}
