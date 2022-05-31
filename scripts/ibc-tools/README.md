# IBC-Tools
## Author:
#### Grant Zukel

## Description:

IBC-Tools is a collection of repeatable tasks and a collection of code I have written while working with IBC.
I wrapped a lot of what I was doing as individual python scripts into a centralized python library that can be leveraged to make IBC a little bit easier.
The work is not complete but I wanted to put the tool out there for others to use in the community.

There are tools like recursive RPC event queries which will take an event query and recursively and return a python data object.

Another useful tool is the ability to look at IBC connection and channel setup between two chains and get stuck import and export transactions.
The script does this by comparing the packet commitments to packets sent. Essentially looking for packets that have been sent and not received.

There is also an example in the example's folder that utilizes the logic to look for stuck transactions inside a kubernetes pod and pushes the
results into datadog as logs to show a way of monitoring stuck IBC transactions between networks.

## Important Notes on Usage

The CLI uses a combination of CLI commands and API and RPC web requests to do what it does. Thus you will need to observe the following two pieces of information in order to utilize the library.
 * You will need the CLI of the chain you wish to run queries against installed in your go bin path. defaults to ~/.go/bin folder.
 * You will need an RPC and API endpoint for the chain you wish to look up information on.

In order to use the libary you simple import the python library CosmosIBC.py and import the Class CosmosIBC. Importing the class takes a couple arguments.



    from lib.CosmosIBC import CosmosIBC

    """
    Initialize the Python Library.
    arg1: cli binary name
    arg2: rpc endpoint
    arg3: api endpoint
    """
    cosmos_helper = CosmosIBC("akash", "http://akash.development.sifchain.finance:26657",
                              "http://akash.development.sifchain.finance:1317")


Then you can use the library to do most of the basic stuff. Please see the included examples which are well commented for how to use some advanced features.


## Examples

In the example's folder in this directory. This folder contains a collection of scripts meant to show you some ways
this python library can be used, and you will find them helpful. There is also a Kubernetes manifest to deploy a pod that utilizes the library
to analyze stuck IBC packets for a collection of networks setup on chain and pushes those stuck transactions into datadog.
This allows you to alert and monitor your IBC queues while building business metrics about at risk capital on chain.



### check_node_setup_for_ibc_and_check_account_funded_example.py

---

This example will take an account Mnemonic. This mnemonic is the mnemonic of the account you want to setup IBC on. You will also need a reachable RPC and API endpoint.

This script uses a combination of RPC, API, and CLI commands to run a series of tests to ensure you are ready to setup an ibc connection.

You will need to specify your go bin directory if its anything other than ~/.go/bin and you will have to have the CLI of whatever network you are trying to check the setup for installed and in your go bin path.

---


### datadog_stuck_packet_monitoring_example.py

---

This example is the python script that scrapes stuck IBC packets from specified channels, chains, and connections and pushes them as logs into Data Dog.

---




### fund_account_from_bank_helper.py

---

This is an example of how to use the library to fund accounts from a bank account in devnet's and testnets.

---

### lookup_chain_information.py

---

This is an example of how to look up chain information using the library tool.

---

### recurive_rpc_event_query_examples.py

---

This is an example of how to use the library to make recursive rpc event queries and return every page of information for your query.

---


### stuck_transaction_csv.py

---

This is an example of looking up stuck IBC packets and printing them in CSV format.

---
