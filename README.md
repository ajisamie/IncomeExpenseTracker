# IncomeExpenseTracker

The app was built using native iOS tools:

1. XCode
2. Swift
3. CoreData Framework (with sqlite local persistence storage)

The provided wireframe was adapted to iOS look and feel and implemented to adhere to Apple's Human Interface Guidelines.

Data is persisted locally using Apple's data persistence framework (CoreData).

For deleting records, the native iOS UITableView "swipe to delete" feature was implemented (using it's delegate methods), 
so records can easily be deleted by swiping from right to left on the scrollable list of expenses/income.
