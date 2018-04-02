# Sales History
Imports ticket records


## Import File Layout
See sample file [sales_history.csv](../examples/sales_history.csv)

* `ticket_number` (unique value, this is the tickets main identifier repeated on each ticket line)
* `customer_public_id` (required field, customer # repeated on each ticket line)
* `local_completed_at` (required field, timestamp for ticket completion in iso8601 format repeated on each ticket line)
* `sales_rep` (optional value to designate the sales rep for this ticket for reporting repeated on each ticket line)
* `location_public_id` (required field, location # repeated on each ticket line)
* `tax` (required field, total amount of tax for the ticket repeated on each ticket line)
* `item_lookup` (required field, item ID or item #)
* `original_price` (optional value to show an exact markdown from the items original price at the time of sale)
* `unit_price` (required field, current selling price per unit)
* `qty` (required field, positive or negative number for qty sold or returned on this ticket)


## Import Process
Import completed using the SRDM import tool. Sales history import tool options can be found [here](../docs/srdm/imports/sales_history.md)


## Tips
* Ensure the correct time zone is set for each location before beginning the sales history import to ensure the tickets show up for the proper hour on reports/dashboards.

* Some systems reuse ticket numbers, so to ensure they are unique, certain systems may require you to modify the ticket number. In certain cases we have had to append the location # to the ticket number like "12345-1" and "12345-2". In other systems the ticket number was unique by year so we needed to append the year like "12345-2016" and "12345-2017".

* Qtys can be positive or negative to show a sale or return/exchange. Returns can be created the same way as sales by just using the negative qtys.

* Taxes should be the total amount of tax colected for the ticket. Certain systems break tax up into state and county taxes, those should be combined to a single tax value. The tax value should not be specified per item line, but rather the total tax collected on the ticket repeated for each line on your file.