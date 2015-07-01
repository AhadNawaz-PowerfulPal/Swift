//
//  AutoLayoutExampleViewController.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/24/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit

class AutoLayoutExampleViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.text = "Eagle \u{1234}"

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
