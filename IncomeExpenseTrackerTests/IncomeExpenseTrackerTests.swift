//
//  IncomeExpenseTrackerTests.swift
//  IncomeExpenseTrackerTests
//
//  Created by SAMIE on 16/01/2022.
//

import XCTest
import CoreData
@testable import IncomeExpenseTracker

class IncomeExpenseTrackerTests: XCTestCase {
    
    lazy var mockPersistantContainer: NSPersistentContainer! = {
            
        let container = NSPersistentContainer(name: "IncomeExpenseTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
                                        
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in memory coordinator failed \(error)")
            }
        }
        return container
    }()
    var dataService: DataService!
    
    override func setUp() {
        super.setUp()
        
        self.dataService = DataService(managedObjectContext: mockPersistantContainer.viewContext)
        self.dataService.seedTransactionTypes()
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockPersistantContainer = nil
        self.dataService = nil
    }
    
    func testManagedObjectContext() {
        XCTAssertNotNil(self.mockPersistantContainer.viewContext)
    }
    
    func testFetchAllTransactionTypes() {
        let TransactionTypeFetchRequest = NSFetchRequest<TransactionType>(entityName: TransactionType.entityName)
        
        do {
            let transactionTypes = try mockPersistantContainer.viewContext.fetch(TransactionTypeFetchRequest)
            print(transactionTypes)
        } catch {
            print("Something went wrong fetching transaction types: \(error)")
        }
    }

}
