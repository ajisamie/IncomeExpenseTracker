//
//  Transaction.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 16/01/2022.
//

import Foundation
import CoreData

class Transaction: NSManagedObject{
    @NSManaged var amount: Double
    @NSManaged var createdAt: Date?
    @NSManaged var desc: String
    @NSManaged var ofType: TransactionType
    
    @objc var formattedDateString: String{
        
        // add st, nd, th, to the day
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        numberFormatter.locale = Locale.current
        
        // day formatter
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let dayString = dayFormatter.string(from: self.createdAt!)
        // Add the suffix to the day
        let dayNumber = NSNumber(value: Int(dayString)!)
        let day = numberFormatter.string(from: dayNumber)!
        
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMM, y"
        let monthYearString = monthYearFormatter.string(from: self.createdAt!)

        let dateString = "\(day) \(monthYearString)"
        
        return dateString
    }
    
    static var entityName: String {return "Transaction"}
}
