# SRDM Toolset
The `srdm` import tool was created to give you a single program that can be used to import certain resources more efficiently into Springboard Retail using the API. Support for this tool will continue to grow and new features will be added over time. All tools below must be run from the root directory of the toolset.

## Help
At any time you can add the flag `-h` or `--help` for documentation of valid commands and arguments for the toolset

## Configuration
Each tenant requires their own config file to store their subdomain and login token. This config file is a YAML file so an example file was provided [/examples/config.yaml](../../examples/config.yaml)

1. Create a new file for this config. A good naming structure would be `<subdomain>.yaml`
2. Copy the contents of `config.yaml` and paste them in your newly created file
3. Change the subdomain in your config file to the subdomain that you are importing into
4. Log into the Springboard Retail account you are importing into and click on your username in the top right corner of the dashboard. From there, select My Account, then choose the API Tokens tab.
5. Generate a new token and give it a description such as "Data Migration"
6. Paste this newly created token in your config file and you are good to go!

## Imports
The import toolset allows you to load data into a Springboard Retail account using the API for maximum speed and efficiency.

#### [Imports => Sales History](./imports/sales_history.md)
#### [Imports => Inventory Quantities](./imports/inventory_qtys.md)
#### [Imports => Attach Store Credits](./imports/attach_store_credits.md)