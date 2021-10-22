# TempNet

TempNet is designed to be an ephemeral deployment of the major components that constitute a Sifchain stack.

The components that are deployed are as follows:

* `block-explorer` (with `mongodb`, running the latest version as deployed into BetaNet).
* `sifnoded` (the main Sifchain application)
* `gaiad` (A private Cosmoshub testnet).
* `ts-relayer` (to connect `sifnoded` and `gaiad` via IBC).
* `ganache` (with our existing smart contracts deployed).
* `ebrelayer` (to connect `sifnoded` with `ganache`)

## Caveats

* All deployments are Ephemeral; your deployment will remain active for 7 days only.
* Only *one* deployment of a branch may be deployed at any one time.
* Should the pipeline fail, then you'll need to delete the namespace of your deployment from the cluster (See "Clean up" Below).

## Deployment

Use the TempNet pipeline [here](https://github.com/Sifchain/chainOps/actions/workflows/tempnet.yml) to deploy a complete stack.

1. Go to the [pipeline](https://github.com/Sifchain/chainOps/actions/workflows/tempnet.yml).
2. Click on `Run workflow` to expand the run options.
3. Enter the target [sifnode](https://github.com/Sifchain/sifnode/branches) branch.
4. Click on `Run workflow` to execute the job.
5. Open your running pipeline [here](https://github.com/Sifchain/chainOps/actions).
6. Let the pipeline run to completion.
7. Obtain the relevant information from the ```Deploy services to kubernetes``` section inside the job ```deploy (ubuntu-latest)```

## Usage

All connection information, such as URLs, keys and addresses, are provided in the output of the pipeline run (in the ```Deploy services to kubernetes``` section).

## Clean up

To delete your deployment, you can run the deletion pipeline [here](https://github.com/Sifchain/chainOps/actions/workflows/tempnet-delete.yml).
