//
//  NodeCell.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 11.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

protocol NodeCellDelegate: class {
    func moreActionAtIndexPath(_ indexPath: IndexPath)
}

class NodeCell: UITableViewCell {

    weak var delegate: NodeCellDelegate?
    var indexPath: IndexPath!
    
    @IBOutlet weak var nodeNameLabel: UILabel!
    @IBOutlet weak var nodeDetailLabel: UILabel!
    @IBOutlet weak var nodeTypeImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //moreButton.imageView?.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        self.delegate?.moreActionAtIndexPath(self.indexPath)
    }
    

}
