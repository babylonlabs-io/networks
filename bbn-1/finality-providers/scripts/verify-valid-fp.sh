#!/bin/bash -eu

# USAGE:
# ./verify-new-fp.sh [nickname]

# checks if the finality provider located at bbn-1/finality-providers/registry/${nickname}.json has a
# valid finality provider registration.

CWD="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
regexEmail="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

NICKNAME=${1:-""}
EOTSD_BIN="${EOTSD_BIN:-eotsd}"

if [ ${#NICKNAME} -lt 2 ]; then
  echo $NICKNAME "should have more than 2 characters"
  exit 1
fi

fpFilePath="$CWD/../registry/${NICKNAME}.json"
if [ ! -f $fpFilePath ]; then
  echo "$fpFilePath does not exist. Check whether you passed a valid finality provider nickname and stored the files in the correct locations."
  exit 1
fi

signatureFilePath=$CWD/../sigs/$NICKNAME.sig
if [ ! -f $signatureFilePath ]; then
  echo "$signatureFilePath does not exist. Check whether you passed a valid finality provider nickname and stored the files in the correct locations."
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "⚠️ jq command could not be found!"
  echo "Install it by following the instructions here https://stedolan.github.io/jq/download/"
  exit 1
fi

if ! command -v $EOTSD_BIN &> /dev/null; then
  echo "⚠️ $EOTSD_BIN command could not be found!"
  echo "Install it by following the instructions here https://github.com/babylonlabs-io/finality-provider/blob/v0.3.0"
  exit 1
fi

echo "Verifying $fpFilePath"

moniker=$(cat "$fpFilePath" | jq -r '.description.moniker')
echo "Finality Provider Moniker: $moniker"
if [ ${#moniker} -lt 3 ]; then
  echo "$moniker has less than 3 characters"
  exit 1
fi

securityContact=$(cat "$fpFilePath" | jq -r '.description.security_contact')
echo "Finality Provider Security Contact: $securityContact"
if [ ${#securityContact} -lt 4 ]; then
  echo "$securityContact has less than 4 characters"
  exit 1
fi

if ! [[ $securityContact =~ $regexEmail ]]; then
  echo "$securityContact is not a valid email. Check whether you passed a valid finality provider email."
fi

commission=$(cat "$fpFilePath" | jq -r '.commission')
echo "Finality Provider Commission: $commission"
if ! [[ "$commission" =~ ^0\.[0-9]+$ ]]; then
  echo "$commission is not valid commission decimal."
  exit 1
fi

eots_pk=$(cat "$fpFilePath" | jq -r '.eots_pk')
echo "Finality Provider EOTS Public Key: $eots_pk"

signature=$(cat "$signatureFilePath" | xargs)
echo "Finality Provider Signature: $signature"

echo "Verifying signature with eotsd..."

$EOTSD_BIN verify-schnorr-sig "$fpFilePath" --eots-pk $eots_pk --signature $signature
