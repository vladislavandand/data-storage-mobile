//
//  DocumentCell.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 11.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {

    @IBOutlet weak var documentImageView: UIImageView!
    @IBOutlet weak var documentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
