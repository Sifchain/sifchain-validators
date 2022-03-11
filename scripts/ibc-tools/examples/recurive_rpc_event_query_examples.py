"""
Description: This script is an example of how to do recursive rpc event queries to get every available page of output for query.
"""

from lib.CosmosIBC import CosmosIBC

"""
Here you will pass (<binary_name>, <rpc_node>, <api_node>)
"""
cosmos_helper = CosmosIBC("akash", "http://akash.development.sifchain.finance:26657",
                          "http://akash.development.sifchain.finance:1317")

sent_packets = cosmos_helper.recursive_rpc_event_query(
    "send_packet.packet_connection=\'{connection}\'".format(connection=cosmos_helper.source_connection))
ack_packets = cosmos_helper.recursive_rpc_event_query(
    "acknowledge_packet.packet_connection=\'{connection}\'".format(connection=cosmos_helper.source_connection))
timeout_packets = cosmos_helper.recursive_rpc_event_query(
    "timeout_packet.packet_src_channel=\'{channel}\'".format(channel=cosmos_helper.source_channel))
recv_packets = cosmos_helper.recursive_rpc_event_query(
    "recv_packet.packet_connection=\'{connection}\'".format(connection=cosmos_helper.source_connection))
