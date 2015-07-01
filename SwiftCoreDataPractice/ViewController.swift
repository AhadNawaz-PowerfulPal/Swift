//
//  ViewController.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/3/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UISearchControllerDelegate {

    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [NSManagedObject]()
    var context:NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityTF.becomeFirstResponder()
        self.edgesForExtendedLayout = UIRectEdge.None
        self.title = "Cities"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelegate.managedObjectContext
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cityCell")
        // display existing data from coredata
        preloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func editCities(sender: UIBarButtonItem) {
        self.tableView.editing = !self.tableView.editing
    }
    
    // MARK:- CoreData
    @IBAction func addCity(sender: UIButton) {
        self.cityTF.resignFirstResponder()
        let isCityExist = self.dataSource.filter { (city:NSManagedObject) -> Bool in
            return (city.valueForKey("name") as! String).lowercaseString == self.cityTF.text.lowercaseString
        }
        if isCityExist.count > 0
        {
            // display error if city already exists
            let alertController = UIAlertController(title: "Already Exist", message: "\(cityTF.text) can't be stored again.", preferredStyle: .Alert)
            let actionOK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(actionOK)
            let actionCancel = UIAlertAction(title: "Details", style: UIAlertActionStyle.Destructive, handler: { (Action:UIAlertAction!) -> Void in
                println("The city name must be unique.")
          })
            alertController.addAction(actionCancel)
            presentViewController(alertController, animated: true, completion: nil)
            
        }
        else if cityTF.text != ""
        {
            // adding city info
            let cities = NSEntityDescription.entityForName("Cities", inManagedObjectContext: context!)
            let city = NSManagedObject(entity: cities!, insertIntoManagedObjectContext: context)
            city .setValue(self.cityTF.text, forKey: "name")
            city .setValue(self.dataSource.count+1, forKey: "id")
            
            var error:NSError?
            if !context!.save(&error)
            {
                println("unable to store city \(error) \(error?.userInfo)")
            }
            else
            {
                self.dataSource.insert(city, atIndex: 0)
                self.tableView.reloadData()
                self.cityTF.text = ""
            }

        }
    }
    func preloadData()
    {
        // fetching data from backend
        let fetchRequest = NSFetchRequest(entityName: "Cities")
        var error:NSError?
        let fetchResults = context?.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        if let result = fetchResults
        {
            self.dataSource = result
        }
        else
        {
            println("Unable to load data \(error!.userInfo)")
        }
        
    }
    
  
    // MARK:- TextField Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.cityTF.resignFirstResponder()
        return true;
    }
    
    // MARK:- Tableview DataSource & Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
         let cell = tableView.dequeueReusableCellWithIdentifier("cityCell") as! UITableViewCell
            let city = self.dataSource[indexPath.row]
         cell.textLabel?.text = city.valueForKey("name") as? String
        return cell
    }
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            let city = self.dataSource[indexPath.row] as NSManagedObject
            context?.deleteObject(city)
            var error:NSError?
            if (context?.save(&error) != nil){
                self.dataSource.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
            }
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self .performSegueWithIdentifier("weatherSegue", sender: indexPath)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
      var vc = segue.destinationViewController as! WeatherTableViewController
    // selected row 
        var indexPath = sender as! NSIndexPath
         vc.city = self.dataSource[indexPath.row]
    }
    
    
}

