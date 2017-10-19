# Store Credits
Import store credit records as gift cards.

Springboard Retail does not have an official store credit resource, so we use gift cards to store customer store credits. The typical process is to use the customers unique Customer # as their gift card number to allow for an easy lookup of the store credit balance.


## Import File Layout
See sample file [store_credits.csv](../examples/store_credits.csv)

* `Number` (required field, unique value, alphanumeric code used to look up gift card)
* `Balance` (required field, total current balance of gift card)
* `Reason` (required field, gift card adjustment reason code)


## Import Process
1. Create a CSV file with one line per total customer store credit containing the columns listed above
2. Log into clients Springboard Retail account as an Admin
3. Navigate to `Sales => Gift Cards`
4. Click the `Import` button
5. Choose the CSV file created in step 1
6. Click `Upload` button to upload file to Springboard Retail
7. On the mapping screen we will map fields to their exact column name matches so all of the required fields listed above should have auto mapped
8. Click the `Complete Import` button to begin the gift card import


## Tips
* Since store credits and gift cards are one resource in Springboard Retail, make sure that there are no conflicting numbers between the two lists.

* During a typical data migration, we will create a custom field on the Customer record called Store Credit # that will store the customers store credit gift card number if they have a store credit balance. This custom field is then enabled to be visible on the customer list which provides the clients sales reps with the easy ability to view if a customer has a store credit or not and then gives them access to the number to look it up.

* Some systems allow a single customer to have multiple store credits. You will want to combine those credits and import just the total balance.

* Gift card numbers can be alphanumeric but can not contain spaces or special characters. Spaces will be automatically removed during import, for example "123 456" would import as "123456"

* For data migrations, we typically use a reason code called Initial Import. You can create a new reason code from `Settings => Reason Codes => Gift Card Adjustments`. If a reason code does not exist during the import, all rows will fail to import, but it will then give you the ability to resolve those failures and create the reason code from the import screen.