//
//  AttributesCell.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 04.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class AttributeCell: UITableViewCell {

    @IBOutlet weak var keyTextFieled: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
