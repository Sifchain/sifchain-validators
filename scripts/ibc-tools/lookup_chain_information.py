"""
Description: This script looks up information about a chain with a basic init of the class.
"""
from library.cosmos_ibc import CosmosIBC

"""
Here you will pass (<binary_name>, <rpc_node>, <api_node>)
"""
cosmos_helper = CosmosIBC("akash", "http://akash.development.sifchain.finance:26657", "http://akash.development.sifchain.finance:1317")

rpc_active, up_to_date = cosmos_helper.check_rpc_node_in_sync()

api_active = cosmos_helper.check_api_active()

cosmos_helper.log_it("RPC Active: " + str(rpc_active))
cosmos_helper.log_it("API Active: " + str(api_active))
cosmos_helper.log_it("Node In Sync: " + str(up_to_date))

#GETTING NOE INFO WITH API HELPER
cosmos_helper.log_it("\n-----Node Info-----")

"""
The argument you pass here is the api path you want ot query and it will return a python/json object of the output.
"""
node_info = cosmos_helper.api_request("/node_info")
cosmos_helper.log_it("network: " + str(node_info["node_info"]["network"]))
cosmos_helper.log_it("listen_addr: " + str(node_info["node_info"]["listen_addr"]))
cosmos_helper.log_it("version: " + str(node_info["node_info"]["version"]))
cosmos_helper.log_it("moniker: " + str(node_info["node_info"]["moniker"]))
cosmos_helper.log_it("id: " + str(node_info["node_info"]["id"]))
cosmos_helper.log_it("cosmos_sdk_version: " + str(node_info["application_version"]))
cosmos_helper.log_it("go_version: " + str(node_info["application_version"]["go"]))

#GET SYNC INFO
cosmos_helper.log_it("\n-----Syncing Info-----")
syncing_info = cosmos_helper.api_request("/syncing")
cosmos_helper.log_it("Syncing: " + str(syncing_info["syncing"]))

#GET LATEST BLOCKS
cosmos_helper.log_it("\n-----Blocks Latest-----")
blocks_latest = cosmos_helper.api_request("/blocks/latest")
cosmos_helper.log_it("latest_block_height: " + str(blocks_latest["block"]["header"]["height"]))
cosmos_helper.log_it("latest_block_hash: " + str(blocks_latest["block"]["header"]["last_block_id"]["hash"]))
cosmos_helper.log_it("latest_commit_hash: " + str(blocks_latest["block"]["header"]["last_commit_hash"]))
cosmos_helper.log_it("latest_block_time: " + str(blocks_latest["block"]["header"]["time"]))

#GET VALIDATOR SETS
cosmos_helper.log_it("\n-----Validator Sets-----")
validator_sets = cosmos_helper.api_request("/validatorsets/latest")
for validator in validator_sets["result"]["validators"]:
    cosmos_helper.log_it("validator_address: " + str(validator["address"]))
    cosmos_helper.log_it("validator_voting_power: " + str(validator["voting_power"]))

#GET IBC CONNECTIONS
ibc_connections = cosmos_helper.retrieve_ibc_connections()
for connection in ibc_connections:
    cosmos_helper.log_it("connection: " + str(connection))

#GET IBC CHANNELS
ibc_channels = cosmos_helper.retrieve_ibc_channels()
for channel in ibc_channels:
    cosmos_helper.log_it("channel: " + str(channel))

#GET IBC CLIENTS
ibc_clients = cosmos_helper.retrieve_ibc_client_states()
for client in ibc_clients:
    cosmos_helper.log_it("client: " + str(client))
