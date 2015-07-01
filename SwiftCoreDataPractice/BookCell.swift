//
//  BookCell.swift
//  SwiftCoreDataPractice
//
//  Created by AhadNawaz on 6/14/15.
//  Copyright (c) 2015 AhadNawaz. All rights reserved.
//

import UIKit

class BookCell: UITableViewCell {
    
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
