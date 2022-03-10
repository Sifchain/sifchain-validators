import sys

"""
This will install the required python libraries if they are not alreaady installed.
"""


def install_package(package_name):
    try:
        __import__, package_name
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package_name])
    finally:
        try:
            __import__, package_name
        except ImportError:
            subprocess.check_call([sys.executable, "-m", "pip3", "install", package_name])
        finally:
            __import__, package_name


install_package("requests")
install_package("datadog-api-client")

"""
import the rest of our libraries needed for the sdk.
"""
import logging
import json
import subprocess
import requests
from datadog_api_client.v2 import ApiClient, ApiException, Configuration
from datadog_api_client.v2.api import logs_api
from datadog_api_client.v2.models import *


class CosmosIBC:
    def __init__(self, binary_name, rpc_node, api_node):
        self.binary_name = binary_name
        self.rpc_node = rpc_node
        self.api_node = api_node
        self.go_bin_folder = "~/go/bin"
        self.destination_channel = ""
        self.source_channel = ""
        formatter_normal = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        streamHandler = logging.StreamHandler(sys.stdout)
        streamHandler.setFormatter(formatter_normal)
        self.logger = logging.getLogger('logger')
        self.logger.addHandler(streamHandler)
        self.logger.setLevel(logging.INFO)

    """
    Description:
        This method will execute a cli command and set the go path.
    arg1: command
    arg2: go path
    """

    def cli_command(self, command, gopath):
        command_eddition = "export PATH={go_path}:$PATH &&".format(go_path=gopath)
        command = command_eddition + command
        result = subprocess.run(command, stdout=subprocess.PIPE, shell=True)
        result = result.stdout.decode('utf-8')
        return result

    """
    Description:
        This method will execute an api quest with the api set as self.api_node. This will return a json/python 
    object of the data returned by api
    arg1: api /node_info path you want to use.
    """

    def api_request(self, api_path):
        connection_url = "{api_url}{api_path}".format(api_url=self.api_node, api_path=api_path)
        try:
            request = requests.get(connection_url)
        except Exception as e:
            self.log_it(str(e))
            return None

        if request.status_code == 200 or request.status_code == 201:
            request_data_object = request.json()
            return request_data_object
        else:
            self.log_it(request.status_code)
            self.log_it(request.content)
            return None

    """
    Description:
        This method will execute a cosmosation api request with the api to get transaction details.
    object of the data returned by api
    arg1: api /node_info path you want to use.
    """

    def cosmosation_api_request(self, api_path):
        connection_url = "{api_url}{api_path}".format(api_url=self.cosmosation_api, api_path=api_path)
        try:
            request = requests.get(connection_url)
        except Exception as e:
            self.log_it(str(e))
            return None

        if request.status_code == 200 or request.status_code == 201:
            request_data_object = request.json()
            return request_data_object
        else:
            self.log_it(request.status_code)
            self.log_it(request.content)
            return None

    """
    Description:
        This method will send a message to a slack webhook channel.
    arg1: message: the message you want to send to the channel.
    arg2: the webhook channel you want to send message to.
    """

    def send_slack_message(self, message, ibc_alert_channel_webhook):
        slack_post_requests = requests.post(ibc_alert_channel_webhook, headers={"Content-type": "application/json"},
                                            json=message)
        return slack_post_requests.status_code, slack_post_requests.text

    """
    Description:
        This method will use the class logger object to log the message passed.
    arg1: message: the message you want to log using the logger.
    """

    def log_it(self, message):
        self.logger.info(str(message))

    """
    Description:
        This method uses the api to check the account balance for a passed account.
    arg1: account: the account you want to check the balance of.
    """

    def check_account_balance(self, account):
        try:
            account_balance = 0
            check_api_status_request = requests.get(self.api_node + "/node_info").json()
            if check_api_status_request:
                if account:
                    query_balance = requests.get(self.api_node + "/cosmos/bank/v1beta1/balances/" + account)
                    if query_balance.status_code == 200 or query_balance.status_code == 201:
                        query_balance_json = query_balance.json()
                        if "balances" in query_balance_json:
                            if query_balance_json["balances"]:
                                account_balance = query_balance_json["balances"][0]["amount"]
        except Exception as e:
            self.log_it(self.binary_name, "api not active", e)
        return account_balance

    """
    Description:
        This method checks to see if the api is responding on the api set at self.api_node on init of the class or override.
    """

    def check_api_active(self):
        try:
            api_active = False
            check_api_status_request = requests.get(self.api_node + "/node_info")
            if check_api_status_request.status_code == 200:
                api_active = True
        except Exception as e:
            self.log_it(self.binary_name + "api not active" + str(e))
        return api_active

    """
    Description:
        This method checks to see if the rpc is responding and insync with the rpc set at self.rpc_node on init of the class or override. 
    """

    def check_rpc_node_in_sync(self):
        try:
            rpc_active = False
            up_to_date = False
            check_status_request = requests.get(self.rpc_node + "/status")
            check_status_response = json.loads(check_status_request.text)
            if check_status_request.status_code == 200:
                rpc_active = True
                if not check_status_response["result"]["sync_info"]["catching_up"]:
                    up_to_date = True
        except Exception as e:
            self.log_it(self.binary_name + "rpc not active" + str(e))
        return rpc_active, up_to_date

    """
    Description:
        This method loads an account from mnemonic locally using the CLI. It takes a moniker and mnemonic. It will delete and reload the account if one exists.
    arg1. moniker of the account you want to load, if you have loaded already use same moniker as you have already used.
    arg2. mnemonic of the account you want to load. 
    """

    def load_account_from_mnemonic(self, moniker, mnemonic):
        self.cli_command(
            """{binary_name} keys delete {moniker} --keyring-backend test -y || echo "not present" """.format(
                binary_name=self.binary_name, rpc_node=self.rpc_node, moniker=moniker, mnemonic=mnemonic),
            self.go_bin_folder)
        load_mnemonic = self.cli_command(
            """echo "{mnemonic}" | {binary_name} keys add {moniker} --keyring-backend test --recover""".format(
                binary_name=self.binary_name, rpc_node=self.rpc_node, moniker=moniker, mnemonic=mnemonic),
            self.go_bin_folder)
        address = load_mnemonic.split("address:")[1].split("\n")[0].strip()
        return address

    """
    Description:
        This command takes two loaded mnemonics a bank mnemonic and a destination mnemonic 
        and will utilize the go cli to execute the transaction to fund the account.
    arg1. Account address of the bank
    arg2. Account address you want to fund
    arg3. Chain id of the chain you are funding on
    arg4. the ammount you want to fund.
    arg5. The gas price you want to pay for the tx.
    """

    def send_from_bank(self, from_account, to_account, chain_id, ammount, gas_price):
        send_money_transaction = self.cli_command(
            """{binary_name} tx bank send {from_account} {to_account} {ammount} -y --node {rpc_node} --gas-prices {gas_price} --keyring-backend test --chain-id {chain_id}""".format(
                binary_name=self.binary_name,
                rpc_node=self.rpc_node,
                from_account=from_account,
                to_account=to_account,
                ammount=ammount,
                gas_price=gas_price,
                chain_id=chain_id), self.go_bin_folder)
        return send_money_transaction

    """
    Description:
        This method will get the IBC connections of the rpc node specified using the binary specified during init.
    """

    def retrieve_ibc_connections(self):
        page = 1
        connections = []
        while True:
            client_query = json.loads(self.cli_command(
                "{binary_name} query ibc connection connections --node {rpc_node} --output json".format(
                    binary_name=self.binary_name,
                    rpc_node=self.rpc_node),
                self.go_bin_folder))
            connections.extend(client_query['connections'])
            if not client_query['pagination']['next_key']:
                break
            page += 1
        return connections

    """
    Description:
        This method will get the IBC channels of the rpc node specified using the binary specified during init.
    """

    def retrieve_ibc_channels(self):
        page = 1
        channels = []
        while True:
            client_query = json.loads(self.cli_command(
                "{binary_name} query ibc channel channels --node {rpc_node} --output json".format(
                    binary_name=self.binary_name,
                    rpc_node=self.rpc_node),
                self.go_bin_folder))
            channels.extend(client_query['channels'])
            if not client_query['pagination']['next_key']:
                break
            page += 1
        return channels

    """
    Description:
        This method will get the IBC Client States of the rpc node specified using the binary specified during init.
    """

    def retrieve_ibc_client_states(self):
        page = 1
        clients = []
        while True:
            client_query = json.loads(self.cli_command(
                "{binary_name} query ibc client states --node {rpc_node} --output json".format(
                    binary_name=self.binary_name,
                    rpc_node=self.rpc_node),
                self.go_bin_folder))
            clients.extend(client_query['client_states'])
            if not client_query['pagination']['next_key']:
                break
            page += 1
        return clients

    """
    Description:
        This method will get the current block height with the self.rpc_node.
    """

    def get_current_block_height(self):
        try:
            current_height_request = requests.get(self.rpc_node + "/status").json()["result"]["sync_info"][
                "latest_block_height"]
            return current_height_request
        except Exception as e:
            self.log_it("RPC Is having issues did not return a json response for status" + e)

    """
    Description:
        This method will parse a tx returned as json from the cli to pull out the values needed for tracing IBC connections.
    arg1: the tx has you want to parse out the data for.
    """

    def parse_transaction(self, transaction):
        txhash = transaction["hash"]
        height = transaction["height"]
        gas_wanted = transaction["tx_result"]["gas_wanted"]
        gas_used = transaction["tx_result"]["gas_used"]
        found_transaction = False
        logs = json.loads(transaction["tx_result"]["log"])
        found_transaction_dict = {}
        for log in logs:
            if not found_transaction:
                for event in log["events"]:
                    if "type" in event:
                        type = event["type"]
                        if "attributes" in event:
                            for attribute in event["attributes"]:
                                if attribute["key"] == "packet_data":
                                    packet_data = json.loads(attribute["value"])
                                    if "denom" in packet_data:
                                        found_transaction = True
                                if attribute["key"] == "packet_sequence" and found_transaction:
                                    packet_id = attribute["value"]
                                if attribute["key"] == "packet_src_channel" and found_transaction:
                                    packet_src_channel = attribute["value"]
                                if attribute["key"] == "packet_dst_channel" and found_transaction:
                                    packet_dst_channel = attribute["value"]
                                if attribute["key"] == "packet_connection" and found_transaction:
                                    packet_connection = attribute["value"]
        amount = float(packet_data["amount"])
        denom = packet_data["denom"]
        receiver = packet_data["receiver"]
        sender = packet_data["sender"]
        found_transaction_dict = {"packet_sequence": packet_id,
                                  "packet_source_channel": packet_src_channel,
                                  "packet_dst_channel": packet_dst_channel,
                                  "packet_connection": packet_connection,
                                  "txhash": txhash,
                                  "type": type,
                                  "height": height,
                                  "gas_wanted": gas_wanted,
                                  "gas_used": gas_used,
                                  "amount": amount,
                                  "denom": denom,
                                  "receiver": receiver,
                                  "sender": sender
                                  }
        return found_transaction_dict

    """
    Description:
        This method will utilize the CLI to get the IBC packet commitments for the channel specified. Tried this with the API first but it was inconsistent at returning commitments.
        arg1: the channel you want to check commitments on
        arg2. the binary you want to use to check commitments
        arg3. the rpc node you want to use to check commitments.
    """

    def get_packet_commitments_with_cli(self, channel, binary_name, rpc_node):
        page = 1
        commitments = []
        while True:
            try:
                client_query = json.loads(self.cli_command(
                    "{binary_name} q ibc channel packet-commitments transfer {from_channel} --node {rpc_node} --output json --page {page}".format(
                        binary_name=binary_name, rpc_node=rpc_node, from_channel=channel, page=page),
                    self.go_bin_folder))
                commitments.extend(client_query['commitments'])
                if not client_query['pagination']['next_key']:
                    break
                page += 1
            except Exception as e:
                self.log_it(str(e))
                return commitments
        return commitments

    """
    Description:
        This method will utilize the CLI to get the IBC packet unreceived transactions for the channel specified. Tried this with the API first but it was inconsistent at returning unreceived transactions.
        arg1: the channel you want to check unreceived transactions on
        arg2. the binary you want to use to check unreceived transactions
        arg3. the rpc node you want to use to check unreceived transactions.
        arg4. string seperated list of packet sequence commitments.
    """

    def get_packet_unreceived_with_cli_and_return_stuck_transactions(self, channel, binary_name, rpc_node,
                                                                     commitment_sequences):
        try:
            stuck_transactions = json.loads(self.cli_command(
                '{binary_name} q ibc channel unreceived-packets transfer {from_channel} --sequences="{sequences}" --node {rpc_node} --output json '.format(
                    binary_name=binary_name, rpc_node=rpc_node, from_channel=channel, sequences=commitment_sequences),
                self.go_bin_folder))
        except Exception as e:
            self.log_it(str(e))
            stuck_transactions = []

        return stuck_transactions

    """
    Description:
        This method will utilze the rpc node specified at self.rpc_node to do a recursive event query on the
        event query passed as an argument and retrieve all data for all envs.
        arg 1. the event query you want to run.
    """

    def recursive_rpc_event_query(self, event_query):
        packets_list = []
        page = 1
        while True:
            connection_url = '{rpc_url}/tx_search?query="{event_query}"&page={page}'.format(rpc_url=self.rpc_node,
                                                                                            event_query=event_query,
                                                                                            page=page)
            try:
                request = requests.get(connection_url)
            except Exception as e:
                self.log_it(str(e))
                return packets_list

            if request.status_code == 200 or request.status_code == 201:
                request_data_object = request.json()
                if "result" in request_data_object:
                    pages_total = int(request_data_object["result"]["total_count"]) / 30 + 1
                    pages_total = str(int(round(pages_total, 0)))
                    if page > int(pages_total):
                        break
                    self.log_it("Building packet list: current page: {current_page} of {pages} total pages.".format(
                        current_page=page, pages=pages_total))
                    packets_list += request_data_object["result"]["txs"]
                    page += 1
                else:
                    self.log_it(request.status_code)
                    self.log_it(request.content)
                    break
            else:
                self.log_it(request.status_code)
                self.log_it(request.content)
                break
        self.log_it("Return Packet Lists" + str(packets_list))
        return packets_list

    """
    Description:
        This method will build the proper data object to parse for sent packets and their tx hash data.
        arg 1. build data object for sent packets.
    """

    def build_sent_packets_data_structure(self, sent_packets):
        parsed_transactions = []
        for tx in sent_packets:
            parsed_transactions.append(self.parse_transaction(tx))
        return parsed_transactions

    """
    Description:
        This method takes a list of packet commitment sequences and builds a comma seperated string.
        arg 1. list of packet commitment sequences.
    """

    def build_string_comma_list_of_sequences_from_object(self, commitments):
        sequences = ""
        for commit in commitments:
            sequences = sequences + commit["sequence"] + ","
        sequences = sequences[:-1]
        return sequences

    """
    Description:
        This method parses the sent transactions and matches the sequences to see if the import is stuck.
        arg 1. stucket import packets, list of sent transactions with data.
    """

    def parse_sent_transactions_and_match_stuck_packet_sequences(self, import_stuck_packets, parsed_transactions):
        stuck_import_transactions = []
        for packet in import_stuck_packets["sequences"]:
            for sequence in parsed_transactions:
                if packet == sequence["packet_sequence"]:
                    packet_data = sequence
                    stuck_import_transactions.append(packet_data)
                    break
        return stuck_import_transactions

    """
    Description:
        This method looks for and parses a data object for stuck transactions.
        arg 1. destination rpc node you want to look at.
        arg 2. source rpc node you want to use
        arg 3. destination channel of your IBC queue
        arg 4. destination connection of your IBC queue
        arg 5. source channel of your IBC queue
        arg 6. source connection of your IBC queue
        arg 7. binary name you want to run queries with
    """

    def look_for_stuck_transactions(self, external_node_rpc, import_node_rpc, destination_channel,
                                    destination_connection, source_channel, source_connection, binary_name):
        # This is to make it more dynamic because I want to loop over a list of these values so I set it in the class as a whole for each call so it will overwrite always the init.

        self.destination_channel = destination_channel
        self.destination_connection = destination_connection
        self.source_channel = source_channel
        self.source_connection = source_connection
        self.binary_name = binary_name
        self.rpc_node = import_node_rpc
        stuck_import_transactions = {}
        stuck_export_transactions = {}
        commitments = self.get_packet_commitments_with_cli(self.destination_channel, self.binary_name, import_node_rpc)
        sequences = self.build_string_comma_list_of_sequences_from_object(commitments)
        if sequences:
            export_stuck_packets = self.get_packet_unreceived_with_cli_and_return_stuck_transactions(
                self.source_channel,
                self.binary_name,
                external_node_rpc,
                sequences)

            self.rpc_node = import_node_rpc
            sent_packets = self.recursive_rpc_event_query(
                "send_packet.packet_connection=\'{connection}\'".format(connection=self.source_connection))
            send_transactions_data_object = self.build_sent_packets_data_structure(sent_packets)
            stuck_export_transactions = self.parse_sent_transactions_and_match_stuck_packet_sequences(
                export_stuck_packets,
                send_transactions_data_object)

        commitments = self.get_packet_commitments_with_cli(self.source_channel, self.binary_name, external_node_rpc)
        sequences = self.build_string_comma_list_of_sequences_from_object(commitments)
        if sequences:
            import_stuck_packets = self.get_packet_unreceived_with_cli_and_return_stuck_transactions(
                self.destination_channel, self.binary_name, import_node_rpc, sequences)

            self.rpc_node = external_node_rpc
            sent_packets = self.recursive_rpc_event_query(
                "send_packet.packet_connection=\'{connection}\'".format(connection=self.destination_connection))
            send_transactions_data_object = self.build_sent_packets_data_structure(sent_packets)
            stuck_import_transactions = self.parse_sent_transactions_and_match_stuck_packet_sequences(
                import_stuck_packets,
                send_transactions_data_object)

        return stuck_import_transactions, stuck_export_transactions

    """
    Description:
        This method takes the list of stuck transactions, and chain info and the type IMPORT or EXPORT and pushes a log into datadog from
        the list of parsed transactions.
        arg 1. list of json dictionary's representing the stuck transactions.
        arg 2. Information about the chains ex. "source_chain_id/destination_chain_id"
        arg 3. tx type you are logging for i.e. EXPORT or IMPORT
    """

    def send_datadog_log(self, stuck_txs, chains, type_tx):
        configuration = Configuration()
        for stuck_tx in stuck_txs:
            dd_tags = 'cluster_name:chainops,env:betanet,tx_type:{tx_type},chains:{chains}'.format(tx_type=type_tx,
                                                                                                   chains=chains)
            message = {"packet_sequence": str(stuck_tx["packet_sequence"]),
                       "packet_source_channel": str(stuck_tx["packet_source_channel"]),
                       "packet_dst_channel": str(stuck_tx["packet_dst_channel"]),
                       "packet_connection": str(stuck_tx["packet_connection"]),
                       "txhash": str(stuck_tx["txhash"]),
                       "height": str(stuck_tx["height"]),
                       "gas_wanted": str(stuck_tx["gas_wanted"]),
                       "gas_used": str(stuck_tx["gas_used"]),
                       "amount": str(stuck_tx["amount"]),
                       "denom": str(stuck_tx["denom"]),
                       "reciever": str(stuck_tx["receiver"]),
                       "sender": str(stuck_tx["sender"]),
                       "chains": chains,
                       "type_tx": type_tx}
            message = json.dumps(message)

            with ApiClient(configuration) as api_client:
                api_instance = logs_api.LogsApi(api_client)
                body = HTTPLog([
                    HTTPLogItem(
                        ddsource="ibc-stuck-transactions",
                        ddtags=dd_tags,
                        service="ibc-stuck-transactions",
                        hostname=chains,
                        message=message
                    ),
                ])
                try:
                    api_response = api_instance.submit_log(body)
                    self.log_it(api_response)
                except ApiException as e:
                    self.log_it("Exception when calling LogsApi->submit_log: %s\n" % e)
