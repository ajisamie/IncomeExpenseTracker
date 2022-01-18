//
//  ViewController.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 16/01/2022.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, ManagedObjectContextDependentType {

    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Transaction>!
    var currencyString = "$"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelExpenses: UILabel!
    @IBOutlet weak var labelIncome: UILabel!
    @IBOutlet weak var labelBalance: UILabel!
    @IBOutlet weak var progressViewRatio: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.scrollView.delegate = self
        
        configureFetchedResultsController()
        
        do {
            try self.fetchedResultsController.performFetch()
            //Update dashboard card info
            updateDashboard()
        } catch {
            //Alert user of loading error
            let alertController = UIAlertController(title: "Loading Transactions Failed", message: "There was a problem loading the list of Transactions. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        //Adjust tableview height to fit its content using constraint from storyboard
        tableViewHeight.constant = self.tableView.contentSize.height
        //Since tableview size equals content size, disable tableview scrolling and let only scrollview scroll
        self.tableView.isScrollEnabled = false
        self.scrollView.isScrollEnabled = true
    }
    
    func configureFetchedResultsController() {
        //Create transaction fetch request with sorting
        let transactionsFetchRequest = NSFetchRequest<Transaction>(entityName: Transaction.entityName)
        let dateSortDescriptor = NSSortDescriptor(key: #keyPath(Transaction.createdAt), ascending: false)
        transactionsFetchRequest.sortDescriptors = [dateSortDescriptor]
        
        //Initialize fetchedResultsController using request and managed object with section header using formatted date string
        self.fetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: transactionsFetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: #keyPath(Transaction.formattedDateString), cacheName: nil)
        
        //set its delegate
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: UITableView Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        //Return number of sections in fetchedResultsController first
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of rows in each section of fetchedResultsController
        if let sections = self.fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        return self.fetchedResultsController.fetchedObjects!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return title for each section of tableview from fetchedResultsController
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Using a reuseable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        let transaction = self.fetchedResultsController.object(at: indexPath)
        cell.labelDesc.text = transaction.desc
        
        //Set the sign depending on expense or income
        var sign:String?
        switch transaction.ofType.name.lowercased() {
        case "expense":
            sign = "-"
        default:
            sign = ""
        }
        cell.labelAmount.text = sign! + currencyString + String(Int(transaction.amount))
        
        return cell
    }
    
    //Adds swipe to delete feature to the tableview
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //If the user swiped to delete a row
        if editingStyle == .delete {
            //Get the object at that row
            let transaction = self.fetchedResultsController.object(at: indexPath)
            
            //Delete the object from the managedObjectContext of coredata
            self.managedObjectContext.delete(transaction)
            //Save the delete operation to execute it
            do {
                try self.managedObjectContext.save()
            } catch {
                self.managedObjectContext.rollback()
                print("Something went wrong: \(error)")
            }
        }
    }
    
    // MARK: NSFetchedResultsController Delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        //If the controller was updated, check which operation was performed and implement same to tableview
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath {
                let cell = self.tableView.cellForRow(at: updateIndexPath) as! TransactionTableViewCell
                let updatedTransaction = self.fetchedResultsController.object(at: updateIndexPath)
                
                cell.labelDesc.text = updatedTransaction.desc
                
                //Set the sign depending on expense or income
                var sign:String?
                switch updatedTransaction.ofType.name.lowercased() {
                case "expense":
                    sign = "-"
                default:
                    sign = ""
                }
                cell.labelAmount.text = sign! + currencyString + String(Int(updatedTransaction.amount))
            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
        
        //Update dashboard card info
        updateDashboard()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        //return section name for each section
        return sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //Update tableview sections if controller section did change
        let sectionIndexSet = NSIndexSet(index: sectionIndex) as IndexSet
        switch type {
        case .insert:
            self.tableView.insertSections(sectionIndexSet, with: .fade)
        case .delete:
            self.tableView.deleteSections(sectionIndexSet, with: .fade)
        default:
            break
        }
    }
    
    // MARK: - ScrollView Delegate method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //when user scrolls, enable or disable tableview scrolling depending on where the user scrolled to
        if scrollView == self.scrollView {
            self.tableView.isScrollEnabled = (self.scrollView.contentOffset.y >= 200)
        }

        if scrollView == self.tableView {
            self.tableView.isScrollEnabled = (self.tableView.contentOffset.y > 0)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Inject coredata managedObjectContext into next view
        switch segue.identifier! {
        case "addTransaction":
            let destinationVC = segue.destination as! TransactionFormViewController
            destinationVC.managedObjectContext = self.managedObjectContext
        default:
            break
        }
    }
    
    func updateDashboard(){
        
        //Sum total expense and imcome each time dashboard is to be updated
        var totalExpense = 0.0, totalIncome = 0.0
        for object in self.fetchedResultsController.fetchedObjects! {
            if object.ofType.name.lowercased() == "expense" {
                totalExpense += object.amount
            }
            
            if object.ofType.name.lowercased() == "income" {
                totalIncome += object.amount
            }
            
        }
        
        //Calculate expense income ratio for progress view
        let expenseIncomeRatio = totalExpense/totalIncome
        
        //Update dashboard card values
        self.labelExpenses.text = currencyString + String(Int(totalExpense))
        self.labelIncome.text = currencyString + String(Int(totalIncome))
        self.labelBalance.text = currencyString + String(Int(totalIncome - totalExpense))
        self.progressViewRatio.progress = Float(expenseIncomeRatio)
        
        //Change progress view color depending on user expenses
        switch expenseIncomeRatio {
        case 0.5..<0.8:
            self.progressViewRatio.progressTintColor = .systemOrange
        case 0.8...1:
            self.progressViewRatio.progressTintColor = .systemRed
        default:
            self.progressViewRatio.progressTintColor = .systemBlue
        }
        
        //Update table view height depending on if there are objects
        if self.fetchedResultsController.fetchedObjects?.count == 0 {
            tableViewHeight.constant = 0
        }else{
            tableViewHeight.constant = self.tableView.contentSize.height
        }
        
    }

}
