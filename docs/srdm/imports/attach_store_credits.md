# Attach Store Credits
This will take store credits already imported as gift cards and match them to customers with the same number

## Options
* `-f <custom_field_name>` Set the custom field name that should store the gift card number. Default value is "Store Credit #"
* `-s <system_name>` Set the system that the store credits were generated in. Useful if the system has special rules such as Lightspeed where the customer numbers have a special character that the store credits(gift cards) do not have
* `-i <import_set_id>` Allows you to set an import set ID so you can choose only the specific batch of imported gift cards that are actually store credits

## Running import

1. Ensure your file is prepared to the exact standards set in [this guide](../../store_credits.md)
2. Create a config file for the tenant you are importing into using the [instructions](../README.md)
3. From the root directory of the toolset run
`$ ./srdm -c <config_file> import store_credits <options>`