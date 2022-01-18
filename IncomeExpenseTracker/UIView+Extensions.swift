//
//  UIView+Extensions.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 18/01/2022.
//

import Foundation
import UIKit

//Extension for views to enable editing of corner radius editing in story board
extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
