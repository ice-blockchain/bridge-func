#!/bin/bash

if [[ -z "${EXEC_PATH}" ]]; then
  EXEC_PATH=/usr/bin/ion
fi

if [[ -z "${SRC_PATH}" ]]; then
  SRC_PATH=/usr/src/ion
fi

CRYPTO_EXEC_PATH=${EXEC_PATH}/crypto
CRYPTO_SRC_PATH=${SRC_PATH}/crypto

fift=${CRYPTO_EXEC_PATH}/fift
func=${CRYPTO_EXEC_PATH}/func

inc=${CRYPTO_SRC_PATH}/fift/lib/:${CRYPTO_SRC_PATH}/smartcont/

# multisig addr
$func -o multisig-code.fif -SPA stdlib.fc multisig-code.fc
multisig_addr=$($fift -I ${inc} -s new-multisig.fif -1 97 1733748500 testnet-bsc-wallet 7 uf_public_keys_testnet)

# collector addr
$func -o votes-collector.fif -SPA stdlib.fc message_utils.fc bridge-config.fc votes-collector.fc
collector_addr=$($fift -I ${inc} -s new-collector.fif)

# bridge addr
$func -o bridge_code2.fif -SPA stdlib.fc text_utils.fc message_utils.fc bridge-config.fc bridge_code.fc
bridge_addr=$($fift -I ${inc} -s new-bridge.fif)

# config72
readarray -d ":" -t array_addr_bridge <<< "$bridge_addr"
readarray -d ":" -t array_addr_multisig <<< "$multisig_addr"
readarray -t oracles < testnet-bsc-oracles.txt

$fift -I ${inc} -s build-config71.fif \
                    ${array_addr_bridge[-1]:0:49} \
                    ${array_addr_multisig[-1]:0:49} \
                    ${oracles[@]} \
                    -o testnet-bsc-config72
