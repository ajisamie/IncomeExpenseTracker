//
//  TransactionFormViewController.swift
//  IncomeExpenseTracker
//
//  Created by SAMIE on 17/01/2022.
//

import UIKit
import CoreData

class TransactionFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, ManagedObjectContextDependentType {

    @IBOutlet weak var textFieldTransactionType: UITextField!
    @IBOutlet weak var textFieldTransactionDescription: UITextField!
    @IBOutlet weak var textFieldStepperValue: UITextField!
    @IBOutlet weak var textFieldDescription: UITextField!
    @IBOutlet weak var stepperAmount: UIStepper!
    var pickerView = UIPickerView()
    
    var transaction: Transaction!
    var managedObjectContext: NSManagedObjectContext!
    var transactionTypes: [TransactionType]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Configure picker view and set it as inputview for transaction types textview
        configurePickerView()
        
        //Fetch transaction types ie., income and expense
        fetchTransactionTypes()
    }
    
    func configurePickerView(){
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.tag = 0
        self.stepperAmount.maximumValue = .infinity
        textFieldTransactionType.inputView = pickerView
        configureAccessoryView()
    }
    
    func configureAccessoryView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.items = [button]
        toolBar.sizeToFit()
        textFieldTransactionType.inputAccessoryView = toolBar
    }
    
    func fetchTransactionTypes() {
        //Create request to fetch transactions, ordering by name in ascending order
        let transactionTypeFetchRequest = NSFetchRequest<TransactionType>(entityName: TransactionType.entityName)
        let primarySortDescriptor = NSSortDescriptor(key: #keyPath(TransactionType.name), ascending: true)
        transactionTypeFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        //Fetch transactions and update the transaction types array property
        do {
            self.transactionTypes = try self.managedObjectContext.fetch(transactionTypeFetchRequest)
        } catch {
            self.transactionTypes = []
        }
    }
    
    @IBAction func stepperUpdated(_ sender: UIStepper) {
        self.textFieldStepperValue.text = Int(sender.value).description
    }
    
    @IBAction func buttonAddClicked(_ sender: Any) {
        
        //Validate input fields
        if self.textFieldTransactionType.text == "" {
            self.textFieldTransactionType.layer.borderWidth = 1
            self.textFieldTransactionType.layer.borderColor = UIColor.systemRed.cgColor
            self.textFieldTransactionType.becomeFirstResponder()
            return
        }else{
            self.textFieldTransactionType.layer.borderWidth = 0
        }
        
        if self.textFieldDescription.text == "" {
            self.textFieldDescription.layer.borderWidth = 1
            self.textFieldDescription.layer.borderColor = UIColor.systemRed.cgColor
            self.textFieldDescription.becomeFirstResponder()
            return
        }else{
            self.textFieldDescription.layer.borderWidth = 0
        }
        
        if self.textFieldStepperValue.text == "" {
            self.textFieldStepperValue.layer.borderWidth = 1
            self.textFieldStepperValue.layer.borderColor = UIColor.systemRed.cgColor
            self.textFieldStepperValue.becomeFirstResponder()
            return
        }else{
            self.textFieldStepperValue.layer.borderWidth = 0
        }
        
        //Initialize a new transaction in managedObjectContext
        self.transaction = self.transaction ?? NSEntityDescription.insertNewObject(forEntityName: Transaction.entityName, into: self.managedObjectContext) as! Transaction
        
        //Get the transaction type the user selected
        let selectedTransactionTypeIndex = self.pickerView.selectedRow(inComponent: 0)
        let selectedTransactionType = self.transactionTypes[selectedTransactionTypeIndex]
        
        //Set transaction model properties
        self.transaction.ofType = selectedTransactionType
        self.transaction.amount = Double(self.textFieldStepperValue.text!) ?? 0
        self.transaction.desc = self.textFieldDescription.text ?? "N/A"
        self.transaction.createdAt = Date()

        do {
            //Save new transaction
            try self.managedObjectContext.save()
        } catch {
            //Notify user of failure
            let alert = UIAlertController(title: "Trouble Saving", message: "Something went wrong when trying to save the Transaction. Please try again...", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                
                self.managedObjectContext.rollback()
                self.transaction = (NSEntityDescription.insertNewObject(forEntityName: Transaction.entityName, into: self.managedObjectContext) as! Transaction)

            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        //Dismiss modal
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonCancelClicked(_ sender: Any) {
        //Rollback any changes to the managedObjectContext and close modal
        self.managedObjectContext.rollback()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldAmountEdited(_ sender: UITextField) {
        if sender.text != nil {
            self.stepperAmount.value = Double(sender.text!) ?? 0
        }
    }
    
    //Function that is called when pickerview done button is clicked
    @objc func action(){
        view.endEditing(true)
        //If no row was selected in pickerview, select the first one and set in transaction type textfield
        if self.pickerView.selectedRow(inComponent: 0) == 0 {
            textFieldTransactionType.text = self.transactionTypes[0].name.capitalizingFirstLetter()
        }
    }
    
    //MARK: PickerView Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return transactionTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let transactionType = self.transactionTypes[row]
        return "\(transactionType.name.capitalizingFirstLetter())"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Update transaction type textfield with selected value of pickerview
        let transactionType = self.transactionTypes[row]
        textFieldTransactionType.text = transactionType.name.capitalizingFirstLetter()
    }

}
