//
//  UploadMediaController.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/29/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit

class UploadMediaController: UIViewController, UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate  {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = [UIImage]()
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPhoto")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            imagePicker = UIImagePickerController()
            imagePicker?.delegate = self
            imagePicker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPhoto()
    {
        if imagePicker != nil
        {
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
    }
    //MARK:- UIImage delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if image != nil
        {
            self.dataSource.append(image)
            self.tableView.reloadData()
        }
        
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }
   
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }

    
  //MARK:- TableView dataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("uploadCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = "uploading task"
        cell.imageView?.image = self.dataSource[indexPath.row];
        return cell

    }
    

}
