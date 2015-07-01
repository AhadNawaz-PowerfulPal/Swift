//
//  PhotosController.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/11/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit
import CoreData

let photoReuseIdentifier = "photoCell"

class PhotosController: UICollectionViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    enum status:Int
    {
        case stop = 0
        case pause
        case downloading
        case complete
        case resume
        case interrupted
        
    }

    var dataSource = [String]()
    var moc:NSManagedObjectContext!
    var imagePicker:UIImagePickerController?
    var fileStatus:Int = status.stop.rawValue
    var taskId:Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // fetch multimedia content from server
        
        self.dataSource.append("test")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = appDelegate.managedObjectContext
        self.loadPhotos()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPhoto")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            imagePicker = UIImagePickerController()
            imagePicker?.delegate = self
            imagePicker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
       // MARK: - Coredata
    func addingPhotosInCD(name:String,url:String)
    {
        var photos = NSEntityDescription.entityForName("Photos", inManagedObjectContext: self.moc)
        var newPhoto = NSManagedObject(entity: photos!, insertIntoManagedObjectContext: self.moc) as! Photos
        
        newPhoto.name = name;
        newPhoto.url = url
        newPhoto.date = NSDate()
        newPhoto.taskIdentifier = -1
        
        var error:NSError?
        println("unable to add file")
        // store values in array and refresh table view
        
        if self.moc.save(&error){
//            self.dataSource += [newPhoto]
            self.collectionView!.reloadData()
        }
    }
    
    // MARK: Image Picker
    
    func addPhoto()
    {
        if imagePicker != nil
        {
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if image != nil
        {
            let imageName = "\(NSDate()).jpg"
            //store image in local dir
            self.storeImageInLocalDirecory(image, name:imageName )
            //store image info in datastore
            let photos = NSEntityDescription.entityForName("Photos", inManagedObjectContext: self.moc)
            var photo = NSManagedObject(entity: photos!, insertIntoManagedObjectContext: self.moc) as NSManagedObject
            photo.setValue("", forKey: "name")
            photo.setValue(NSDate(), forKey: "date")
            photo.setValue(imageName, forKey: "url")
            var error:NSError?
            if !self.moc.save(&error)
            {
                let alert = UIAlertController(title: "Something went wrong", message: "Unable to add Photo", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                self.presentViewController(alert, animated: true, completion: nil)
   
            }
        }
        
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        println("photo inofo \(info)")
//    }
    func storeImageInLocalDirecory(image:UIImage, name:String)
    {
//        let url= [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
        
        let homeDir = NSHomeDirectory() + "/Documents/" + name
        let imageData = UIImageJPEGRepresentation(image, 0.7) as NSData
        imageData.writeToFile(homeDir, atomically: true);
        
//        println("dirc paht \(homeDir)")
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Coredata - Photo CRUD
    func loadPhotos()
    {
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let photos = moc?.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        if let result = photos
        {
//            self.dataSource = result;
            self.collectionView?.reloadData()
            self.collectionView?.setNeedsDisplay()
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
       return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoReuseIdentifier, forIndexPath: indexPath) as! GalleryViewCell
        
        // Configure the cell
//        let photo = self.dataSource[indexPath.row] as NSManagedObject
//        let url = photo.valueForKey("url") as! String
//        let imagePath = NSHomeDirectory() + "/Documents/" + url
//        let image = UIImage(contentsOfFile: imagePath)
//        cell.imgView.image = image    
        let networkObj = NetworkModel().sharedInstance()
       
        if(self.fileStatus  == status.stop.rawValue){
            cell.title.text = "Start download"
            var urlStr = "https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"
            var url:NSURL = NSURL(string: urlStr)!
            self.fileStatus = networkObj.dowloadFile(url, callBack: { (result, error) -> Void in
                println("********_______Callback is called_______**********")
            })

        }
        else if(self.fileStatus  == status.pause.rawValue){
            cell.title.text = "Pause download"
            networkObj.pauseDownloadTask(self.taskId!)
        }
        else //if(self.fileStatus  == status.resume)
        {
            cell.title.text = "Pause download"
            networkObj.pauseDownloadTask(self.taskId!)
        }
        
        
        return cell
    }

    // donwload task
    // MARK:- CoreData
    func addNewPhotos()
    {
        var baseUrl = "https://developer.apple.com/library/ios/documentation/"
        addingPhotosInCD("iOS Programming Guide", url: "\(baseUrl)iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf")
        addingPhotosInCD("Networking Overview", url: "\(baseUrl)NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf")
        addingPhotosInCD("AV Foundation", url: "\(baseUrl)AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf")
        addingPhotosInCD("iPhone User Guide", url: "http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf")
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
