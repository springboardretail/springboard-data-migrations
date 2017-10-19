# Items
Import item records


## Import File Layout
See sample file [items.csv](../examples/items.csv)

* `Item #` (unique field, can be left blank to have Springboard auto assign)
* `Description` (required field)
* `Long Description`
* `Cost` (required field, default cost of the item)
* `Original Price` (optional field, original selling price or MSRP of item)
* `Current Price` (required field, current selling price of item)
* `Primary Vendor` (optional field, can be Vendor # or Vendor Name)
* `Active?` (optional field, if present must have a true or false value)


## Import Process
1. Create a CSV file with one line per item containing the columns listed above plus any additional field values specific to this client
2. Log into clients Springboard Retail account as an Admin
3. Navigate to `Inventory => Items`
4. Click the `Import` button
5. Choose the CSV file created in step 1
6. Click `Upload` button to upload file to Springboard Retail
7. On the mapping screen we will map fields to their exact column name matches so all of the required fields listed above should have auto mapped
8. Click the `Complete Import` button to begin the item import


## Tips
* You may notice there are no attribute fields on our required field list. This is because all attribute fields in Springboard Retail are custom fields so that you are not stuck with a color field if your client does not have a color attribute. So you can create your attribute fields as custom fields and map them accordingly.

* Each item is an indvidual record. If your items in your source system are in a matrix format, you will create them as individual items containing their unique attribute. After the import, either you or the client can request for us to perform a one time free Autogridding in the account where we will grid all items in the account together to recombine them into matrix like resources called grids. During this data migration, you can also request for us to do a one time autogridding in the testing environment after your items have finished importing. Please take special note that after the autogridding is complete, any item updates must happen in the Springboard Retail UI per grid on the `Inventory => Grid` page. So only request autogridding after the customer has signed off on the content that was imported as there is no way to undo autogridding.

* If the Original Price is less than the Current Price, it is recommended to leave this field blank as it will show as a markup on POS customer receipts.

* The Description is what shows throughout the app and on the customers receipts so it is recommeneded to contain all item attributes. Such as "Derek Shoe - Black - 10.5". Our standard name attribute formatting for our grid system formats as such "style_name - attribute1 - attribute2" and if the item contains 1 or 3 attributes it is adjusted accordingly.

* Long description field is entirely optional but does support HTML tags so you can use this for web description fields in source system.

* If all items being imported are active, you do not need the Active? field present on the spreadsheet at all. If the field is present and mapped, it must have a true or false value (not case sensitive) where true designates that the item is active and false will make it inactive. Inactive items can still be sold and added to POS sales history or inventory qtys, it just makes it so the item does not show up in searches by default.