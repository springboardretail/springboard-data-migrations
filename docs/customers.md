# Customers
Import customer records


## Import File Layout
See sample file [customers.csv](../examples/customers.csv)

* `Customer #` (unique value, can be left blank to have Springboard auto assign)
* `First Name` (required field, if no value is present in source system recommend entering value of "?")
* `Last Name` (required field, if no value is present in source system recommend entering value of "?")
* `Address First Name` (required field, can be same value as First Name field)
* `Address Last Name` (required field, can be same value as Last Name field)
* `Address Line 1`
* `Address Line 2`
* `Address City`
* `Address State` (accepts state name or state abbreviation for US states)
* `Address Postal Code`
* `Address Country` (accepts 2 character country code of full country name)
* `Address Phone`
* `Email` (enforces email formatting of single address in standard format name@domain.com)
* any required custom customer fields


## Import Process
1. Create a CSV file with one line per customer containing the columns listed above plus any additional field values specific to this client
2. Log into clients Springboard Retail account as an Admin
3. Navigate to `Sales => Customers`
4. Click the `Import` button
5. Choose the CSV file created in step 1
6. Click `Upload` button to upload file to Springboard Retail
7. On the mapping screen we will map fields to their exact column name matches so all of the required fields listed above should have auto mapped
8. Click the `Complete Import` button to begin the customer import


## Tips
* If you are performing a sales history import, the Customer # field must be specified with the Customer # you will be providing on the ticket from your source system.

* Phone numbers are stored per address, we recommend creating custom fields to store additional phone numbers. If using this method such as to store a Phone 2 field, we would recommend also creating a Phone 1 field that contains the same value as the Address Phone field just so that the main number is displayed prominently at the top of the customer record instead of below.