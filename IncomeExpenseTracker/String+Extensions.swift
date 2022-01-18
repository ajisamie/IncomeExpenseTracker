//
//  String+Extensions.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 18/01/2022.
//

import Foundation

//Extension to capitalize first letter of string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
