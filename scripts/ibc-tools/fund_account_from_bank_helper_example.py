"""
Description: This script takes two mnemonics and monikers one for the bank account, one for the destination account. This will then
fund the destination account form the bank with the ammount specified.
"""
from library.cosmos_ibc import CosmosIBC
import time

"""
Here you will pass (<binary_name>, <rpc_node>, <api_node>)
"""
cosmos_helper = CosmosIBC("akash", "http://akash.development.sifchain.finance:26657",
                          "http://akash.development.sifchain.finance:1317")

cosmos_helper.binary_name = "akash"
cosmos_helper.go_bin_folder = "~/go/bin"
cosmos_helper.denom_name = "uakt"

cosmos_helper.log_it(("Load Account To Fund"))
address = cosmos_helper.load_account_from_mnemonic("<ACCOUNT-MONIKER>", "<ACCOUNT TO FUND MNEMONIC>")
cosmos_helper.log_it(("Address: ", address))

cosmos_helper.log_it(("Load Bank Account"))
bank_address = cosmos_helper.load_account_from_mnemonic("<BANK-MONIKER>", "<BANK MNEMONIC>")
cosmos_helper.log_it(("Address: ", bank_address))

cosmos_helper.log_it("Send Money from moniker: bank_account, to moniker: local-test on keyring-backend test.")

"""
These are the position arguments for the send_from_bank function.
("<BANK_ADDRESS>","<DESTINATION_ADDRESS>", "<CHAIN_ID>", "<AMOUNT>", "<GAS_PRICE>")
"""
cosmos_helper.send_from_bank(bank_address, address, "akashsif-1", "100uakt", "0.5uakt")
cosmos_helper.log_it("Sleep for 30 seconds and then check to make sure account is funded.")

time.sleep(30)

"""
Check the two balances of the bank and 
destination address to ensure they have changed.
"""
account_balance = cosmos_helper.check_account_balance(address)
bank_account_balance = cosmos_helper.check_account_balance(bank_address)

cosmos_helper.log_it("Account Balance: " + str(account_balance))
cosmos_helper.log_it("Bank Balance: " + str(bank_account_balance))
