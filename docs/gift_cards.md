# Gift Cards

Import gift card records

## Import File Layout

See sample file [gift_cards.csv](../examples/gift_cards.csv)

- `Number` (required field, unique value, alphanumeric code used to look up gift card)
- `Balance` (required field, total current balance of gift card)
- `Reason` (required field, gift card adjustment reason code)

## Import Process

1. Create a CSV file with one line per gift card containing the columns listed above
2. Log into clients Heartland Retail account as an Admin
3. Navigate to `Sales => Gift Cards`
4. Click the `Import` button
5. Choose the CSV file created in step 1
6. Click `Upload` button to upload file to Heartland Retail
7. On the mapping screen we will map fields to their exact column name matches so all of the required fields listed above should have auto mapped
8. Click the `Complete Import` button to begin the gift card import

## Tips

- Gift card numbers can be alphanumeric but can not contain spaces or special characters. Spaces will be automatically removed during import, for example "123 456" would import as "123456"

- For data migrations, we typically use a reason code called Initial Import. You can create a new reason code from `Settings => Reason Codes => Gift Card Adjustments`. If a reason code does not exist during the import, all rows will fail to import, but it will then give you the ability to resolve those failures and create the reason code from the import screen.
