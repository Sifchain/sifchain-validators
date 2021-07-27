#!/bin/sh
#
# ./upgrade.sh
#

case $CHAINNET in
  *"devnet"*)
    PREFIX="devnet"
    ;;
  *"testnet"*)
    PREFIX="testnet"
    ;;
  *)
    PREFIX="mainnet"
    ;;
esac

# Download the upgrade.
mkdir -p ${HOME}/.sifnoded/cosmovisor/upgrades/${VERSION}/bin
cd ${HOME}/.sifnoded/cosmovisor/upgrades/${VERSION}/bin
wget -O sifnoded.zip https://github.com/Sifchain/sifnode/releases/download/${PREFIX}-${VERSION}/sifnoded-${PREFIX}-${VERSION}-linux-amd64.zip
unzip sifnoded.zip

# Check current version.
if [ ! -d ${HOME}/.sifnoded/cosmovisor/upgrades/${CURRENT_VERSION} ]; then
  mkdir -p ${HOME}/.sifnoded/cosmovisor/upgrades/${CURRENT_VERSION}/bin
  cd ${HOME}/.sifnoded/cosmovisor/upgrades/${CURRENT_VERSION}/bin

  wget -O sifnoded.zip https://github.com/Sifchain/sifnode/releases/download/${PREFIX}-${CURRENT_VERSION}/sifnoded-${PREFIX}-${CURRENT_VERSION}-linux-amd64.zip
  unzip sifnoded.zip
fi

wget -O /usr/local/bin/migrate.sh https://raw.githubusercontent.com/Sifchain/networks/master/scripts/migrate_with_oracle.sh
chmod +x /usr/local/bin/migrate.sh
/usr/local/bin/migrate.sh -b ${INITIAL_HEIGHT} -c ${CHAINNET} -s ${COSMOS_SDK_VERSION} -t ${GENESIS_TIME} -v ${VERSION} -w ${CURRENT_VERSION} -z ${DATA_MIGRATE_VERSION}
