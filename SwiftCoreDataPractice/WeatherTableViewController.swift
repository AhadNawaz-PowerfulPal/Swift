//
//  WeatherTableViewController.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/3/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit
import CoreData

class WeatherTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {

    var city:NSManagedObject?
//    var dataSource = [NSManagedObject]()
    var context:NSManagedObjectContext?
    var fetchController:NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchController = nil
        var cityName = city?.valueForKey("name") as! String
        self.title = "\(cityName) Weather"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.context = appDelegate.managedObjectContext!
        // display already stored weather info
        self.createFetchController(city?.valueForKey("id") as! Int)
//        self.preloadCityWeather()
        // fetch update from url
        self.loadCityWeather(cityName)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NSFetch Controller
    func createFetchController(cityId:Int)-> NSFetchedResultsController
    {
        if self.fetchController != nil
        {
            return self.fetchController!
        }
        //Entity
        let entity = NSEntityDescription.entityForName("Weather", inManagedObjectContext: self.context!)
        //sort descriptor
        let sortDiscriptor = NSSortDescriptor(key: "date", ascending: false)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = [sortDiscriptor]
        fetchRequest.predicate = NSPredicate(format: "cityId=\(cityId)", argumentArray: nil)
        fetchRequest.fetchBatchSize = 20
        //********* set expressions
//        let expressionKeyPath = NSExpression(expressionType: "date");
//        let expressionFunction = NSExpression(forFunction: "", arguments: <#[AnyObject]#>)
        
        // create fetch controller
        self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchController?.delegate = self
        
        var error:NSError?
        if let results = self.fetchController?.performFetch(&error)
        {
//            print("successfully setup fetchedResult controller")
        }
        return self.fetchController!
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
            switch (type)
            {
            case .Insert:
                    self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            default:
                print("")
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    // MARK: - fetch weather from api
    func loadCityWeather(city:String)
    {
        var urlStr = "http://api.openweathermap.org/data/2.5/weather?q=\(city)"
        var url:NSURL = NSURL(string: urlStr)!
        var request:NSURLRequest = NSURLRequest(URL: url)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                 var err:NSError?
                if data != nil
                {
                    let res = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: &err)
                    let weather = res["weather"]
                    var interval  = res["dt"]
                    let date = NSDate(timeIntervalSince1970:interval.doubleValue)
                    let des = weather[0]["description"].string
                    let icon = weather[0]["icon"].string
                    self.storeCityWeather(des!, icon: icon!, date: date)
                }
        }
        
    }

    // MARK: -  Core data
    func storeCityWeather(des:String,icon:String, date:NSDate)
    {
        let weatherEntity = NSEntityDescription.entityForName("Weather", inManagedObjectContext: self.context!)
        let w = NSManagedObject(entity: weatherEntity!, insertIntoManagedObjectContext: context)
        w.setValue(date, forKey: "date")
        w.setValue(des, forKey: "desc")
        w.setValue(icon, forKey: "icon")
        w.setValue(city?.valueForKey("id"), forKey: "cityId")
        w.setValue(city, forKey: "city")
        var error:NSError?
        if !context!.save(&error)
        {
            println("Unable add weather ")
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchController?.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.fetchController?.sections?.count > 0
        {
            let sectionInfo = self.fetchController?.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        else
        {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("weatherCell", forIndexPath: indexPath) as? UITableViewCell
        if(cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "weathercell")
        }
        
        let cityWeather = self.fetchController?.objectAtIndexPath(indexPath) as! NSManagedObject//dataSource[indexPath.row]
        let weather =  cityWeather.valueForKey("desc") as? String
        let date = cityWeather.valueForKey("date") as? NSDate
        let urlStr = cityWeather.valueForKey("icon") as? String
        let fm = NSDateFormatter()
        fm.dateFormat = "dd MMM HH:mm"
        let dateStr = fm.stringFromDate(date!)
            if cell != nil{
                cell!.textLabel!.text = weather
                cell!.detailTextLabel!.text = dateStr
            }
            // lazy load weather icons
            let url:NSURL = NSURL(string: "http://openweathermap.org/img/w/\(urlStr!).png")!
            let request:NSURLRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                cell?.imageView?.image = UIImage(data: data)
                cell?.setNeedsDisplay()
              }
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cityWeather = self.fetchController?.objectAtIndexPath(indexPath) as! NSManagedObject
         if let s = cityWeather.valueForKey("city") as? NSManagedObject
        {
            var cityName = s.valueForKey("name") as! String
         println("==================" + cityName)
        }
        
        /*if let weatherscity = city!.mutableSetValueForKey("weather") as? NSMutableSet
        {
            println(weatherscity.allObjects)

        }*/
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let city = fetchController?.objectAtIndexPath(indexPath) as! NSManagedObject
            self.context?.deleteObject(city)
        } else if editingStyle == .Insert {
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
