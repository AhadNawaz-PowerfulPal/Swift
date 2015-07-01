//
//  ProgramticallyAppliedConstraints.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/28/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit

class ProgramticallyAppliedConstraints: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    //    var viewsDic:Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //its necessory to set mask to false while adding views programtically
        //        self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        //        self.name.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.name.text = "test lable "
        // create dictionary of views
        let viewsDic = Dictionary(dictionaryLiteral: ("image", self.imageView),("label",self.name))
        
        //set constraints on image view
        var hconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[image(200)]", options: nil, metrics: nil, views: viewsDic)
        NSLayoutConstraint.activateConstraints(hconstraints)
        
        var vconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[image(200)]", options: nil, metrics: nil, views: viewsDic) as Array
        NSLayoutConstraint.activateConstraints(vconstraints)
        
        var positionImage = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[image](200)-10-[label]-10-|", options: nil, metrics: nil, views: viewsDic) as Array
        
        self.view.addConstraints(positionImage)
        //set constraints on lable view
//       hconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[label(100)]-30-|", options: nil, metrics: nil, views: viewsDic) as Array
//        NSLayoutConstraint.activateConstraints(hconstraints)
//        
//        
//        vconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[label(100)]-100-|", options: nil, metrics: nil, views: viewsDic) as Array
//        NSLayoutConstraint.activateConstraints(vconstraints)
        
        
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
