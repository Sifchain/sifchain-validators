#!/bin/sh
#
# ./import.sh <import_url>
#

IMPORT_URL=$1

if [ ! -d $HOME/.sifnoded/imports ]; then
  mkdir $HOME/.sifnoded/imports
fi

cd $HOME/.sifnoded/imports
wget -O latest.json.gz ${IMPORT_URL}
gunzip latest.json.gz

# Fixes to bring across the pool and oracle data.
jq '.app_state.clp.pool_list = [] | .app_state.clp.liquidity_provider_list = [] | .app_state.oracle.prophecies = []' $HOME/.sifnoded/config/genesis.json > genesis.json
mv genesis.json $HOME/.sifnoded/config/genesis.json

jq -s 'def deepmerge(a;b):
     reduce b[] as $item (a;
       reduce ($item | keys_unsorted[]) as $key (.;
         $item[$key] as $val | ($val | type) as $type | .[$key] = if ($type == "object") then
           deepmerge({}; [if .[$key] == null then {} else .[$key] end, $val])
         elif ($type == "array") then
           (.[$key] + $val | unique)
         else
           $val
         end)
       );
     deepmerge({}; .)' latest.json $HOME/.sifnoded/config/genesis.json > genesis.json

mv genesis.json $HOME/.sifnoded/config/genesis.json
