//
//  NetworkModel.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/11/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit

class NetworkModel: NSObject, NSURLSessionDelegate,NSURLSessionDownloadDelegate
{
    var directoryPath:String = NSHomeDirectory()
    var fm:NSFileManager = NSFileManager.defaultManager()
    var error:NSError?
    var networkSharedInstance:NetworkModel?
    var configuration:NSURLSessionConfiguration?
    var session:NSURLSession?
    var filesDataSource:[NSURLSessionDownloadTask] = [NSURLSessionDownloadTask]()
    
    // MARK:- Configrations
    func sharedInstance()->NetworkModel
    {
        if networkSharedInstance == nil
        {
            self.networkSharedInstance = NetworkModel()
            self.configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            self.session = NSURLSession(configuration: self.configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
            
        }
        return self.networkSharedInstance!
    }
    
    func setDirPath(dirPath:String)
    {
        // set content directory path
        self.directoryPath.stringByAppendingPathComponent(dirPath)
        
        if(!fm.fileExistsAtPath(self.directoryPath))
        {
            fm.createDirectoryAtPath(self.directoryPath, withIntermediateDirectories: true, attributes:nil , error:&error)
        }
        else
        {
            // Will call delegates later here
            println("unable to create directroy")
        }
    }
    
//    // MARK:- Callbacks
//    typealias CallbackBlock = (cell:BookCell,error:String?,progress:Float)->()
//    var callBack:CallbackBlock = {
//        (cell,error,progress)-> Void in
//        if error == ""
//        {
//            var curretnCell:BookCell = cell as BookCell
//            curretnCell.progressBar.progress = progress
//        }
//        else
//        {
//            println(error)
//        }
//    
//    }
   
    // MARK :- Supoorting funcions
    func getTaskWithId(taskIdentifier:Int)->Int
    {
        var index = 0
        for var i = 0; i<self.filesDataSource.count; i++ {
            var fileInfo = self.filesDataSource[i] as NSURLSessionDownloadTask
            if (fileInfo.taskIdentifier == taskIdentifier) {
                index = i
                break;
            }
        }
        
        return index;
        
    }

    func parseNSData(data:NSData,newPath:String) -> NSData
    {
        var error:NSError?
        var dictionary: Dictionary = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.MutableContainersAndLeaves.rawValue), format:nil , error: &error) as! [String:AnyObject]
        
        if(dictionary.count > 0)
        {
            dictionary["NSURLSessionResumeInfoLocalPath"] = newPath
            var newData = NSPropertyListSerialization.dataWithPropertyList(dictionary, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: &error)
            
            return newData!
        }
        else
        {
            println("******_________ Unable to create new DATA file _______**********");
        }
        return data;
        
    }

    // MARK: Session delegates
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        var newRequest:NSURLRequest = request
//        println("URLSession-url-type \(newRequest)")
        completionHandler(newRequest)
    }
    
    // MARK:- Download Tasks
    func dowloadFile(url:NSURL, callBack:(String,String)->Void)->Int
    {
        var request = NSURLRequest(URL: url)
        var downloadTask = self.session?.downloadTaskWithRequest(request)
        if(downloadTask != nil){
            downloadTask!.resume()
        }
        else{
            println("Somthing went wrong")
        }
        
        self.filesDataSource.append(downloadTask!)
        return downloadTask!.taskIdentifier
    }
    
    func pauseDownloadTask(taskId:Int)
    {
        var index = self.getTaskWithId(taskId)
        var downloadTask = self.filesDataSource[index]
        downloadTask.cancelByProducingResumeData({ (data:NSData!) -> Void in
            // manipulate data
        })
    }
    
    func resumeTask(taskId:Int,resumePath:String)
    {
        var index = self.getTaskWithId(taskId)
        var downloadTask = self.filesDataSource[index]
        
        var dataPath = NSTemporaryDirectory() + resumePath
        if let data:NSData = NSData(contentsOfFile: dataPath){
            var taskIdentifier:Int = downloadTask.taskIdentifier
            // reusme downloading becuase file was unexpectedly stoped
            downloadTask = self.session!.downloadTaskWithResumeData(self.parseNSData(data,newPath: dataPath))
            //            downloadTask.taskIdentifier = 1
            self.filesDataSource[index] = downloadTask
            downloadTask.resume()
        }
        else
        {
            println("******_________ Unable to Resueme Task _______**********");
            
        }
    }
    
    // MARK: - Session - Download Delegates
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        var progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
//        self.callBack(result: "downloaded", error: "no error", progress: progress)
        if(progress % 10 == 0){
            println("******_________\((Int)(progress * 100)) %_______**********");
        }
        
    }
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if(error == nil)
        {
            // copy file to permanent location
            println("******_________ Downloading Complete _______**********");
        }
        else
        {
            // store file downloaded data for resume purpose
            println("******_____*____ error in downloading file___*____**********");
        }

    }
    
    
    
}
