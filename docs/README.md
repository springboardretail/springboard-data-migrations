# Tutorials
Each tutorial will provide you with the desired layout for the import file as well as import instructions and tips.

### [Vendors](vendors.md)
### [Items](items.md)
### [Customers](customers.md)
### [Gift Cards](gift_cards.md)
### [Purchase Orders](purchase_orders.md)
### [Inventory Qtys](inventory_qtys.md)
### [Sales History](sales_history.md)


## Recommended Import Order
To ensure there are no failures or issues, you will want to import resources in the following order (if there are multiple on one line, you can import them simultaneously or in either order)

1. `Vendors`
2. `Items` and `Customers`
3. `Store Creidts` (and run script to match credits to customers)
4. `Gift Cards` and `Purchase Orders`
5. `Inventory Qtys` and `Sales History`


## Resolving Import Errors
After an import finishes, you may be brought to a screen showing you that certain rows failed to import due to invalid/missing data. You are able to resolve those issues right on this page to finish the import. Click the resolve button and enter the correct value for the invalid field. Certain invalid values such as invalid vendor will give you the ability to search for or create a vendor right on the resolution page.

Warning: Clicking the Skip Line link or Skip All Remaining Lines button on the import resolution screen will cause those lines to not be imported at all! Every import error must be resolved to complete the import with all lines from the spreadsheet.


## Tips
* All files in this guide are in CSV format, however, our Imports UI in Springboard Retail will accept CSV or XLSX files.

* If the resource # field is left blank to auto-assign a number by Springboard Retail, it will always create a new record and will never update an existing record. For instance if you import a customer and leave the Customer # field blank, importing the same spreadsheet a second time would cause duplicate customer records. The assigned resource # would need to be specified on subsequent imports in order to update the record. So it is not recommended to leave the resource # fields blank unless absolutely necessary.

* Zip codes and other resource # fields often contain leading zero's which Excel and other popular spreadsheet software will drop automatically when opening a CSV. So make sure not to lose these leading zero's by opening the CSV in this software to make edits and then saving the file. There are different ways to ensure those leading zero's are preserved, we recommend checking the support docs for the software you are using.