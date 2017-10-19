# Purchase Orders
Import open purchase orders only. Can not import purchasing history or closed/recieved orders.


## Import File Layout
PO imports typically require all item and order information to be present in order to complete the import. A workaround has been built into the import system for data migrations where you can specify just the `Item #` since the items have already been imported. Adding any additional fields to the list below or changing options in the import process will cause the import to require full item details.

See sample file [po.csv](../examples/po.csv) and [po_with_item_details.csv](../examples/po_with_item_details.csv)

* `PO #` (unique per order, can be left blank to have Springboard auto assign)
* `PO Vendor` (required field, can be Vendor # or Vendor Name)
* `PO Received at Location` (required field, can be Location # or Location Name)
* `PO Start Ship` (require field, date format MM/DD/YYYY)
* `PO End Ship` (require field, date format MM/DD/YYYY)
* `Item #` (required field)
* `PO Line Qty` (required field, total unrecieved qty for this PO line)
* `PO Line Unit Cost` (required field, invidicual unit cost for this PO line)

## Import Process
1. Create a CSV file with one line per item on purchase order containing the columns listed above
2. Log into clients Springboard Retail account as an Admin
3. Navigate to `Purchasing => Orders`
4. Click the `Import` button
5. Choose the CSV file created in step 1
6. Click `Upload` button to upload file to Springboard Retail
7. On the mapping screen we will map fields to their exact column name matches so all of the required fields listed above should have auto mapped
8. Change the dropdown at the top to `Import PO` as `Open`
9. Uncheck box to overwrite existing lines
10. Click the Complete Import button to begin the purchase order import


## Tips
* A single PO # can only go to a single location and be for a single vendor. If the order is allocated in the source system, it is recommended to split it up into multiple Purchase Orders for this import where you append the Location # to the PO # such as "123-1", "123-2", "123-3" to have PO 123 go to 3 different locations.

* During the import process all orders will import in the Pending state even if Open was selected during import step 8. Once the import completes, the last step is for it to Open the orders.

* Any PO's imported with a PO End Ship in the past, will show up immediately as past due. This does not hurt anything, it just allows the customer to know what PO's are late.

* It is recommended to use the PO Vendor # as the PO Vendor value as certain systems store the names as of the time the PO was created, so any recent name changes to the PO Name could cause them to not be matched where the Vendor # rarely changes.