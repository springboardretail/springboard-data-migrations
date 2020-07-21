# Inventory Quantity Import

This will import inventory quantities as physical counts. One count per location.

## Options

- `-f <filepath>` Set the import file to be used `required`
- `-r <reason>` Allows specifying a custom existing inventory adjustment reason code. Defaults to "Initial Import"
- `-p` Resumes existing physical count for location that is already in progress
- `-o` Leaves physical count open for edits after import

## Running import

1. Ensure your file is prepared to the exact standards set in [this guide](../../inventory_qtys.md)
2. Create a config file for the tenant you are importing into using the [instructions](../README.md)
3. From the root directory of the toolset run
   `$ ./srdm -c <config_file> import inventory_qtys -f <import_file>`

## After import

If there were any unmatched items included on the inventory qty file that were not in Heartland Retail, they will be displayed on screen. The inventory count will also be left open so you can resolve those import issues prior to completing the physical count.
