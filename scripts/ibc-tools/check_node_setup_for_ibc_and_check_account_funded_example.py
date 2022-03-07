"""
Description: This is an example of checking to see if you have everything setup for starting a relay channel for IBC.
This will check your RPC node is up to date and active and in sync. This will also check your API node is available as well.
This will take an account mnemonic to check to ensure the account has a balance greater than 0.

These tools are designed to provide a helping hand to automating what it takes for setting up and operating IBC connections
for a network.
"""

from library.cosmos_ibc import CosmosIBC

"""
Initialize the Python Library.
arg1: cli binary name
arg2: rpc endpoint
arg3: api endpoint
"""
cosmos_helper = CosmosIBC("akash", "http://akash.development.sifchain.finance:26657",
                          "http://akash.development.sifchain.finance:1317")

"""
Set the GO Bin folder so the script knows where to run the cli from.
"""
cosmos_helper.go_bin_folder = "~/go/bin"

cosmos_helper.log_it(("Load Account To Check"))
"""
This will load the mnemonic. It will try to delete it as well that way you can run the script over and over.
arg1: moniker <moniker you want to use, or already use for the mnemonic
arg2: mnemonic
This returns the account address it loads from the mnemonic with the cli binary speicfied during init.
"""
address = cosmos_helper.load_account_from_mnemonic("<MONIKER>", "<MNEMONIC>")
cosmos_helper.log_it(("Address: ", address))

"""
This checks the RPC node specified at init are active and up to date with syncing to the latest block.
"""
rpc_active, up_to_date = cosmos_helper.check_rpc_node_in_sync()

"""
This uses the API provided to check to ensure that its active and responding. 
"""
api_active = cosmos_helper.check_api_active()

"""
This checks the account balance is greater than 0 and ready for relaying.
arg1: account address to check.
"""
account_balance = cosmos_helper.check_account_balance(address)

cosmos_helper.log_it("RPC Active: " + str(rpc_active))
cosmos_helper.log_it("API Active: " + str(api_active))
cosmos_helper.log_it("Node In Sync: " + str(up_to_date))
cosmos_helper.log_it("Account Balance: " + str(account_balance))
