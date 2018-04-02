# Inventory Quantities
Import inventory quantities per location

There are two methods of importing inventory quantities into Springboard Retail. The first would be to use our built in Imports UI which allows one single physical count import at a time. For multiple locations, there is a tool that allows you to create the physical counts via our API with a single file.


## Import File Layout
See sample file [inventory_qtys.csv](../examples/inventory_qtys.csv) and [inventory_qtys_multiple_locations.csv](../examples/inventory_qtys_multiple_locations.csv)

* `Item #` (require field, can be left blank to have Springboard auto assign)
* `Qty` (required field, does not currently support fractional quantities)
* `Location` (this is only required if using the import tool, the Import UI does not require this field)


## Import Process
### Single Location Import UI
1. Create a CSV file per location with one line per item containing the columns listed above
2. Log into clients Springboard Retail account as an Admin
3. Navigate to `Inventory => Counts`
4. Click the `New` button
5. Set the `Location`, `Reason`, and add a `Description`
6. Set the `Count Scope` to `Full Count`
7. Click `Save` button to create the count
8. Click the `New` button on the Batches tab
9. Add a `Description` and click the `Create Batch` button
10. Click the `Start Counting` button to begin allowing inventory quantities to be added
11. Click the Batch ID for the newly created batch
12. Click the `Import` button on the right 
13. Choose the CSV file created in step 1
14. Click `Upload` button to upload file to Springboard Retail
15. On the mapping screen we will map fields to their exact column name matches so all of the required fields listed above should have auto mapped
16. Click the `Complete Import` button to begin the physical count import
17. After the import has successfully completed, go back to the count page and click the `Done Counting` button
18. Click the `Yes, I am done` button to confirm that all inventory quantities for this location have been added
19. Click the `Accept Count` button to finalize the count and begin making adjustments. The adjustments can take up to an hour to complete depending on the number of items.

### Multiple Location Import Tool
Import completed using the SRDM import tool. Inventory qty import tool options can be found [here](../docs/srdm/imports/inventory_qtys.md)


## Tips
* A physical count will always overwrite the entire locations inventory. The values should be treated as the locations absolute values and require all items in stock to be present on the physical count.

* The import tool was designed to be run once per tenant. If there is a failure, it is not recommended to run it a second time.

* Physical counts must be completed before the Springboard Retail account is open for business. If the counts are imported after sales have been rang through or adjustments have been made, it would overwrite those quantities and they would be lost.

* If it failed to add an item to the count with the import tool, the count is left in the "Counting" state to allow you to manually find and add the item. Once you finish adding the items to the count, you can follow steps 17-19 on hte tutorial above.