//
//  GalleryCollection.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/8/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "albumCell"

class GalleryCollection: UICollectionViewController {

    var dataSource = [NSManagedObject]()
    var moc:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addAlbum")
        self.navigationItem.rightBarButtonItem = addBtn
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
         moc = appDelegate.managedObjectContext!
        self.loadAlbums()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(GalleryViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //setup collection view
//        let screen = UIScreen.mainScreen().bounds
//        var flowLayout = UICollectionViewFlowLayout()
//        flowLayout.itemSize = CGSize(width: screen.width/2, height: 150)
//        self.collectionView.add
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    func addAlbum()
    {
        let alertController = UIAlertController(title: "Album Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
       // adding textfield
        alertController.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
            textField.placeholder  = ""
        }
        var addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            let nameField = alertController.textFields![0] as! UITextField
            // add Album to Database
            self.storeAlbum(nameField.text)
        })
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        self .presentViewController(alertController, animated: true, completion: nil)
    }
    // MARK:- CoreData - Album CRUD
    func loadAlbums()
    {
        var fetchReq =  NSFetchRequest(entityName: "Album")
        let result = moc.executeFetchRequest(fetchReq, error: nil) as? [NSManagedObject]
        if let albums = result
        {
            self.dataSource = albums
            self.collectionView?.reloadData()
        }
    }
    func storeAlbum(name:String)
    {
        let albums = NSEntityDescription.entityForName("Album", inManagedObjectContext: self.moc)
        let album = NSManagedObject(entity: albums!, insertIntoManagedObjectContext: moc) as NSManagedObject
        album.setValue(name, forKey: "name")
        album.setValue(NSDate(), forKey: "date")
        var error:NSError?
        if !self.moc.save(&error)
        {
            let alert = UIAlertController(title: "Something went wrong", message: "Unable to add Album", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
  
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GalleryViewCell
    
        // Configure the cell
        let album = self.dataSource[indexPath.row] as NSManagedObject
        cell.imgView.image = UIImage(named: "eagle_\(indexPath.row+1).jpg")
        cell.title.text = album.valueForKey("name") as? String
        self.addEffect(cell.imgView)
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("uplaodSegue", sender: self)
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! GalleryViewCell
//    
//        if cell.selected
//        {
//            cell.imgView.viewWithTag(999)?.removeFromSuperview()
//            cell.selected = false
//        }
//        else
//        {
//            self.addEffect(cell.imgView)
//            cell.selected = true
//        }
       
    }
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    }
    
    // MARK:-  add blur effect on image
    func addEffect(imageView:UIImageView)
    {
        let effet = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: effet)
        blurView.frame = imageView.frame
        blurView.tag = 999
        imageView.addSubview(blurView)
        
    }

}
