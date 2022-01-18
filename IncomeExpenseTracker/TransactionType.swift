//
//  TransactionType.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 16/01/2022.
//

import Foundation
import CoreData

class TransactionType: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var transactions: Transaction
    
    static var entityName: String {return "TransactionType"}
}
