//
//  NewsEntryTableViewCell.swift
//  WeRead
//
//  Created by Ian Manor on 07/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class NewsEntryCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var entryImage: UIImageView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var pubDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
