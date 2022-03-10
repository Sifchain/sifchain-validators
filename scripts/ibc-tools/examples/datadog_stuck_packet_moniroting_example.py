"""
Data Dog IBC Queue Monitoring and Logging
Description: This script takes a list of external RPC nodes, internal RPC and API nodes, src connections and channels,
and destination channels and connections and monitors the IBC queues for stuck transactions and pushes them into datadog.
"""

from lib.CosmosIBC import CosmosIBC
import os
import datetime
import time

"""
This is the list of IBC Connections to Check
    ("DESTINATION_CHAIN_RPC", "SOURCE_CHAIN_RPC", "SOURCE_CHAIN_API", "DESTINATION_CHANNEL", "DESTINATION_CONNECTION", "SOURCE_CHANNEL", "SOURCE_CONNECTION", "LOCAL_BINARY_NAME_TO_USE", "SOURCE_CHAIN_ID/DESTINATION_CHAIN_ID"),
Add a list entry for each IBC Queue you want to monitor and any stuck transaction found will be pushed into datadog.
"""
ibc_connections_to_check = [
    ("http://public-node.terra.dev:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-18", "connection-19", "channel-7", "connection-21", "sifnoded", "sifchain/terra"),
    ("http://emoney.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-14", "connection-19", "channel-19", "connection-22", "sifnoded", "sifchain/emoney"),
    ("http://osmosis.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-47", "connection-1159", "channel-17", "connection-20", "sifnoded", "sifchain/osmosis"),
    ("http://ixo.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-11", "connection-25", "channel-15", "connection-18", "sifnoded", "sifchain/ixo"),
    ("http://juno.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-5", "connection-8", "channel-14", "connection-17", "sifnoded", "sifchain/juno"),
    ("http://sentinel.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-36", "connection-58", "channel-1", "connection-1", "sifnoded", "sifchain/sentinel"),
    ("http://akash.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-24", "connection-36", "channel-2", "connection-2", "sifnoded", "sifchain/akash"),
    ("http://gaia.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-192", "connection-347", "channel-0", "connection-0", "sifnoded", "sifchain/gaia"),
    ("http://iris.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-8", "connection-9", "channel-19", "connection-30", "sifnoded", "sifchain/iris"),
    ("http://persistence.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-7", "connection-8", "channel-26", "connection-32", "sifnoded", "sifchain/persistence"),
    ("http://regen.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-10", "connection-13", "channel-28", "connection-60", "sifnoded", "sifchain/regen"),
    ("http://crypto-org.sifchain.finance:26657", "https://rpc.sifchain.finance:443", "https://api.sifchain.finance","channel-9", "connection-10", "channel-33", "connection-239", "sifnoded", "sifchain/crypto-org")
]

os.environ["DD_SITE"]="datadoghq.com"
os.environ["DD_API_KEY"]="<YOUR DATADOG API KEY HERE>"

while True:
    now_time = datetime.datetime.now()
    try:
        print("Starting Check # {check_time}".format(check_time=str(datetime.datetime.now())))
        for connection in ibc_connections_to_check:
            run_time = datetime.datetime.now()
            external_rpc_node = connection[0]
            sifnode_rpc_node = connection[1]
            sifnode_api_node = connection[2]
            destination_channel = connection[3]
            destination_connection = connection[4]
            source_channel = connection[5]
            source_connection = connection[6]
            binary_name = connection[7]
            chains = connection[8]

            cosmos_helper = CosmosIBC(binary_name, sifnode_rpc_node, sifnode_api_node)
            stuck_import_transactions, stuck_export_transactions = cosmos_helper.look_for_stuck_transactions(external_rpc_node,
                                                                                                             sifnode_rpc_node,
                                                                                                             destination_channel,
                                                                                                             destination_connection,
                                                                                                             source_channel,
                                                                                                             source_connection,
                                                                                                             binary_name)

            if stuck_import_transactions:
                cosmos_helper.send_datadog_log(stuck_import_transactions, chains, "Import")
            if stuck_export_transactions:
                cosmos_helper.send_datadog_log(stuck_export_transactions, chains, "Export")

            run_end_time = datetime.datetime.now()
            run_total_time_to_complete = run_end_time - now_time
            cosmos_helper.log_it("Run Total Time: {time_spent}".format(time_spent=str(run_total_time_to_complete)))

        end_time = datetime.datetime.now()
        total_time_to_complete = end_time - now_time
        cosmos_helper.log_it("Total Time: {time_spent}".format(time_spent=str(total_time_to_complete)))
        """
        We sleep for 1200 seconds to not push too many metrics into data dog to keep costs down.
        """
        time.sleep(1200)
    except Exception as e:
        print(str(e))
