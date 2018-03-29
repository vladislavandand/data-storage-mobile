//
//  RoundUIButton.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 11.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

@IBDesignable
class RoundUIButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}
