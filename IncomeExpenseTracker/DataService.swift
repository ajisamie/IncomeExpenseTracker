//
//  DataService.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 16/01/2022.
//

import Foundation
import CoreData

struct DataService: ManagedObjectContextDependentType {
    var managedObjectContext: NSManagedObjectContext!
    
    func seedTransactionTypes() {
        let transactionTypeFetchRequest = NSFetchRequest<TransactionType>(entityName: TransactionType.entityName)
        
        do {
            let transactionTypes = try self.managedObjectContext.fetch(transactionTypeFetchRequest)
            let transactionTypesAlreadySeeded = transactionTypes.count > 0
            
            if(transactionTypesAlreadySeeded == false) {
                
                let transactionType1 = NSEntityDescription.insertNewObject(forEntityName: TransactionType.entityName, into: self.managedObjectContext) as! TransactionType
                transactionType1.name = "expense"
                
                let transactionType2 = NSEntityDescription.insertNewObject(forEntityName: TransactionType.entityName, into: self.managedObjectContext) as! TransactionType
                transactionType2.name = "income"
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Something went wrong: \(error)")
                    self.managedObjectContext.rollback()
                }
            }
        } catch {}
    }
}
