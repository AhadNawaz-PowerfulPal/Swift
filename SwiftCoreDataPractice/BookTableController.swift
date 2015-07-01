//
//  BookTableController.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/14/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit
import CoreData

class BookTableController: UITableViewController,NSURLSessionDelegate,NSURLSessionDownloadDelegate, NSURLSessionDataDelegate,NSURLSessionTaskDelegate
{
    
    var books = [NSManagedObject]()
    var session:NSURLSession?
    var moc:NSManagedObjectContext!
    var fm:NSFileManager = NSFileManager.defaultManager()
    var completeCashePath:String?
    
    enum status:Int
    {
        case stop = 0
        case pause
        case downloading
        case complete
        case resume
        case interrupted
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = delegate.managedObjectContext!
        //        moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        //        moc.persistentStoreCoordinator = delegate.persistentStoreCoordinator
        
        //        self.tempMOC = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        //        self.tempMOC.parentContext = moc
        
        // intialize session
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // setting custom cache for default session
        //        var cachePaths:[String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as! [String]
        //        var basePath:String = cachePaths.first!
        //        completeCashePath = basePath.stringByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
        //        completeCashePath =  completeCashePath!.stringByAppendingPathComponent("/BooksCache")
        //        if !fm.fileExistsAtPath(completeCashePath!)
        //        {
        //            fm.createDirectoryAtPath(completeCashePath!, withIntermediateDirectories: false, attributes: nil, error: nil)
        //        }
        //        var myCache = NSURLCache(memoryCapacity: 16*1024, diskCapacity: 268435456, diskPath: completeCashePath)
        //        println("cache path \(completeCashePath)")
        //        config.URLCache = myCache
        //        config.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        self.getOldTaskInSession()
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        var addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewFiles")
        self.navigationItem.rightBarButtonItem = addButton
        self.getOldTaskInSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNewFiles()
    {
        var baseUrl = "https://developer.apple.com/library/ios/documentation/"
        addBookInCD("iOS Programming Guide", source: "\(baseUrl)iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf", status: 0)
        addBookInCD("Networking Overview", source: "\(baseUrl)NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf", status: 0)
        addBookInCD("AV Foundation", source: "\(baseUrl)AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf", status: 0)
        addBookInCD("iPhone User Guide", source: "http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf", status: 0)
    }
    
    // MARK: - Coredata
    func addBookInCD(name:String,source:String,status:Int)
    {
        var books = NSEntityDescription.entityForName("Books", inManagedObjectContext: self.moc)
        var book = NSManagedObject(entity: books!, insertIntoManagedObjectContext: self.moc) as! Books
        
        book.name = name;
        book.source_path = source
        book.status = status
        book.taskIdentifier = -1
        
        var error:NSError?
        println("unable to add file")
        // store values in array and refresh table view
        
        if self.moc.save(&error){
            self.books += [book]
            self.tableView.reloadData()
        }
    }
    func updateDownloadStatus(book:Books,status:Int,progress:NSNumber)
    {
        var error:NSError?
        book.status = status
        book.progress = progress
        if !self.moc.save(&error)
        {
            println("unable to update status")
        }
        
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:BookCell = tableView.dequeueReusableCellWithIdentifier("bookCell2", forIndexPath: indexPath) as! BookCell
        var file:Books = self.books[indexPath.row] as! Books
        cell.title.text = file.name
        cell.progressBar.progress = file.progress.floatValue
        cell.percentage.text = "\(Int(file.progress.floatValue * 100)) %"
        cell.downloadBtn.tag = indexPath.row
        cell.downloadBtn.addTarget(self, action: "downloadContent:", forControlEvents: UIControlEvents.TouchUpInside)
        println("Status=== \(file.status )")
        if file.status == status.complete.rawValue
        {
            cell.downloadBtn.hidden = true
            cell.progressBar.hidden = true
        }
        else if file.status == status.resume.rawValue
        {
            cell.downloadBtn.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
        else if file.status == status.pause.rawValue
        {
            cell.downloadBtn.setImage(UIImage(named: "resume"), forState: UIControlState.Normal)
            
        }
        else if file.status == status.interrupted.rawValue //&& file.isDownloading == false
        {
            // auto start downloading task because it was inturrepted without user interaction
            cell.downloadBtn.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            // reusme downloading becuase file was unexpectedly stoped
            self.resumeTask(file)
        }
        // Configure the cell...
        return cell
    }
    
    func resumeTask(file:Books)
    {
        var dataPath = NSHomeDirectory() + "/Documents/" + file.source_path.lastPathComponent
        if let data:NSData = NSData(contentsOfFile: dataPath){

        // reusme downloading becuase file was unexpectedly stoped
        file.downloadTask = self.session?.downloadTaskWithResumeData(self.parseNSData(data,path: dataPath))
        file.taskIdentifier = file.downloadTask?.taskIdentifier
        file.downloadTask?.resume()
        self.updateDownloadStatus(file, status: status.downloading.rawValue,progress:file.progress)
        }
        else
        {
            println("unablet to resume task")
        }
    }
    
    // MARK: -  Initialze session download requests
    func downloadContent(sender:UIButton)
    {
        var file = self.books[sender.tag] as! Books
        var fileStatus = file.status as Int
        
        if(file.status == status.pause.rawValue)
        {
            sender.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            self.resumeTask(file)
        }
        else if(file.status == status.downloading.rawValue)
        {
            self.updateDownloadStatus(file, status: status.pause.rawValue,progress:file.progress)
            file.downloadTask?.cancelByProducingResumeData({ (data:NSData!) -> Void in
                //store data to file
//                file.fileData = data
            })
            sender.setImage(UIImage(named: "resume"), forState: UIControlState.Normal)
        }
        else {
            // start downloading
            var cell:BookCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! BookCell
            cell.downloadBtn.setImage(UIImage(named:"pause"), forState: UIControlState.Normal)
            var url = file.source_path
            var request = NSURLRequest(URL: NSURL(string: url)!)
            file.downloadTask = self.session?.downloadTaskWithRequest(request)
            file.downloadTask!.resume()
            file.taskIdentifier = file.downloadTask?.taskIdentifier
            self.updateDownloadStatus(file, status: status.downloading.rawValue,progress:0)
        }
    }
    
    func getOldTaskInSession()
    {
        var error:NSError?
        var fetchRequest = NSFetchRequest(entityName: "Books")
        let fetchResult = moc.executeFetchRequest(fetchRequest, error: &error) as? [Books]
        
        if let result = fetchResult
        {
            self.books = result
            self.tableView.reloadData()
        }
    }
    
    func taskWithId(taskIdentifier:Int)->Int
    {
        var index = 0
        for var i = 0; i<self.books.count; i++ {
            var fileInfo = self.books[i] as! Books
            if (fileInfo.taskIdentifier == taskIdentifier) {
                index = i
                break;
            }
        }
        
        return index;
        
    }
    
    func parseNSData(data:NSData,path:String) -> NSData
    {
        var error:NSError?
        var dictionary: Dictionary = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.MutableContainersAndLeaves.rawValue), format:nil , error: &error) as! [String:AnyObject]
        
        if(dictionary.count > 0)
        {
            dictionary["NSURLSessionResumeInfoLocalPath"] = path
            var newData = NSPropertyListSerialization.dataWithPropertyList(dictionary, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: &error)
            
            return newData!
        }
        return data;
        
    }
    
    //MARK: Session delegates
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        var index = self.taskWithId(task.taskIdentifier)
        var file:Books = self.books[index] as! Books
        //        file.isDownloading = false
        println("error \(error?.localizedDescription) \n url")
        if(error == nil)
        {
            println("\u{2022} File Downloaded")
            self.updateDownloadStatus(file, status: status.complete.rawValue,progress:1)
            file.status = status.complete.rawValue
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        else //if(file.status != status.pause.rawValue)
        {
            // make sure this user has not paused it
            var info : NSDictionary = error?.userInfo as NSDictionary!
            if let data : NSData = info[NSURLSessionDownloadTaskResumeData] as? NSData
            {
                // must update file status
                if(file.status != status.pause.rawValue){
                    self.updateDownloadStatus(file, status: status.interrupted.rawValue,progress:file.progress)
                    // file.status = status.interrupted.rawValue
                }
                
                //store incomplete file in separate dir e.g /interruptedFiles
                let url = NSHomeDirectory() + "/Documents/" + file.source_path.lastPathComponent
                var err:NSError?
                if fm.fileExistsAtPath(url)
                {
                    fm.removeItemAtPath(url, error: &err)
                    if(err != nil){
                        println("unable to remvoe previous file \(err)")
                    }
                }
                data.writeToFile(url, atomically: false)
            }
            
        }
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    {
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        var progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        var index = self.taskWithId(downloadTask.taskIdentifier)
        var file = self.books[index]  as! Books
        file.progress = progress
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            var cell:BookCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! BookCell
            cell.progressBar.progress = progress
            cell.percentage.text = "\(Int(progress * 100)) %"
            
        }
        //      self.callBack(result: "downloaded", error: "no error", progress: progress)
        
    }
    
    
    
}
