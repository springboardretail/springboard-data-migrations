# Sales History Import
This will import sales history as completed POS tickets

## Options
* `-f <filepath>` Set the import file to be used `required`
* `-t` Skip downloading existing tickets. Use only if there is existing tickets in Springboard and no conflicts on the spreadsheet
* `-r` Refresh downloaded cache for customers and items. Use if data has been updated in the account since last run
* `-s` Start time for scheduled imports. Only use if customer is live and has required POS fields
* `-e` End time for scheduled imports. Use only if `-s` is specified
* `-c` Specifies the import to happen in chronological order. By default newest tickets are imported first

## Running import

1. Ensure your file is prepared to the exact standards set in [this guide](../../sales_history.md)
2. Create a config file for the tenant you are importing into using the [instructions](../README.md)
3. From the root directory of the toolset run
`$ ./srdm -c <config_file> import sales_history -f <import_file> <options>`