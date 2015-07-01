//
//  FileInfo.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/14/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit

class FileInfo: NSObject {
    
    var downloadTask:NSURLSessionDownloadTask?
    var taskResumeData:NSData?
    var downloadProgress:Float?
    var isDownloading:Bool?
    var taskIdentifier:Int?
    var resumePath:String?
    
//    var fileTitle:String?
//    var downloadSource:String?
//    var downloadTask:NSURLSessionDownloadTask?
//    var taskResumeData:NSData?
//    var downloadProgress:Float?
//    var isDownloading:Bool?
//    var downloadComplete:Bool?
//    var taskIdentifier:Int?
//    
//    init(title:String, andDownloadSource source:String)
//    {
//        self.fileTitle = title
//        self.downloadSource = source
//        self.downloadProgress = 0.0
//        self.isDownloading = false
//        self.downloadComplete = false
//        self.taskIdentifier = -1
//    }
    
}
