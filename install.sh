#!/usr/bin/env bash

DumpVars() {
  echo "Cannot install, dump follows"
  echo
  echo "DEST_PATH=$DEST_PATH"
  echo "BIN_PATH=$BIN_PATH"
  echo
  echo "GO_PATH=$GO_PATH"
  echo "TMP_PATH=$TMP_PATH"
  echo
  echo "GO_URL=$GO_URL"
  echo "IPFS_URL=$IPFS_URL"
  echo "TIPFS_URL=$TIPFS_URL"
  echo
  echo "GO_FILE=$GO_FILE"
  echo "IPFS_FILE=$IPFS_FILE"
  echo
  echo "IPFS_PORT=$IPFS_PORT"
  echo "DNS_ENDPOINT=$DNS_ENDPOINT"
  echo "NETWORK=$NETWORK"
  echo "GLOBAL=$GLOBAL"
  echo "BOOTSTRAP_ENDPOINT=$BOOTSTRAP_ENDPOINT"
  echo "SWARMKEY_ENDPOINT=$SWARMKEY_ENDPOINT"
  echo "IPFSV_ENDPOINT=$IPFSV_ENDPOINT"
  echo
  echo "BOOTSTRAP=$BOOTSTRAP"
  echo "SWARMKEY=$SWARMKEY"
  echo "IPFSV=$IPFSV"
  echo "GOLANGV=$GOLANGV"
  exit 1
}

DEST_PATH=$HOME
BIN_PATH=$HOME/bin

GLOBAL=false
GO_PATH=/usr/local
TMP_PATH=/tmp
LOG_PATH=$DEST_PATH/log

IPFS_PORT=4001
NETWORK=test

DNS_ENDPOINT=ipfs.telosfoundation.io
BOOTSTRAP_ENDPOINT=boot
SWARMKEY_ENDPOINT=key
GOLANGV_ENDPOINT=golangv
IPFSV_ENDPOINT=ipfsv

OPTS=`getopt -o '' --long ipfs-port:,dns-endpoint:,network:,global,prefix:,dns-endpoint:,bootstrap-endpoint:,swarmkey-endpoint:,ipfsv-endpoint: -n 'install.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"


while true; do
  case "$1" in
   --ipfs-port ) IPFS_PORT=$2; shift; shift ;;
   --dns-endpoint ) DNS_ENDPOINT=$2; shift; shift ;;
   --network ) NETWORK=$2; shift; shift ;;
   --global ) GLOBAL=true; shift ;;
   --prefix ) PREFIX=$2; shift; shift ;;
   --dns-endpoint ) DNS_ENDPOINT=$2; shift; shift ;;
   --bootstrap-endpoint ) BOOTSTRAP_ENDPOINT=$2; shift; shift ;;
   --swarmkey-endpoint ) SWARMKEY_ENDPOINT=$2; shift; shift ;;
   --ipfsv-endpoint ) IPFSV_ENDPOINT=$2; shift; shift ;;
   * ) break ;;
  esac
done


BOOTSTRAP=$(dig +noall +answer TXT $BOOTSTRAP_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \")
SWARMKEY=$(dig +noall +answer TXT $SWARMKEY_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \" | base64 -d | tr -d "\n" )
GOLANGV=$(dig +noall +answer TXT $GOLANGV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \" | base64 -d )
IPFSV=$(dig +noall +answer TXT $IPFSV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \" | base64 -d )
#TIPFSV=$(dig +noall +answer TXT $TIPFSV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \" | base64 -d )

# Check sanity of stuff built from TXT recofds here:
# Forcing $GOLANGV until TXT record is fixed
GOLANGV="go1.11.linux-amd64.tar.gz"

GO_URL="https://dl.google.com/go/$GOLANGV"
IPFS_URL="https://dist.ipfs.io/go-ipfs/$IPFSV"

TIPFS_URL='git@github.com:Telos-Foundation/TIPFS.git'

GO_FILE=`basename $GO_URL`
IPFS_FILE=`basename $IPFS_URL`
# TIPFS_FILE=`basename $TIPFS_URL`

# Debug
if [ "$DEBUGME" ] ; then
  DumpVars
fi

# Setup tmp space
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# Download 
if ! wget $GO_URL ; then
  echo "Cannot download Go"
  exit 1
fi
if ! wget $IPFS_URL ; then
  echo "Cannot download ipfs"
  exit 1
fi
if ! git clone $TIPFS_URL ; then
  echo "Cannot download TIPFS"
  exit 1
fi

# Extract

echo "Installing Go Language to $GO_PATH. Sudo access needed"
sudo tar -C $GO_PATH -xzf $GO_FILE
tar -C $TMP_PATH -xzf $IPFS_FILE
# tar -C $TMP_PATH -xzf $TIPFS_FILE

# Install

# Go installs on previous step, extract only

# IPFS

echo "Installing TIPFSto $BIN_PATH"
cp -r TIPFS/* $BIN_PATH

echo "Installing ipfs to $BIN_PATH"
if mv "$TMP_PATH/go-ipfs/ipfs $BIN_PATH/ipfs" 2> /dev/null; then

  echo "Moved ipfs to $HOME/bin/ipfs"
else
  if [ -d "$BIN_PATH" -a ! -w "$BIN_PATH" ]; then
    is_write_perm_missing=1
  fi
fi

echo "We cannot install $TMP_PATH/go-ipfs/ipfs in $BIN_PATH"
if [ -n "$is_write_perm_missing" ]; then
  echo "It seems that we do not have the necessary write permissions."
  echo "Perhaps try running this script as a privileged user:"
  echo
  echo "    sudo $0"
  echo
  exit 1
fi

# Clean up tmp
cd -
rm -rf $TMP_DIR

# Add stuff to bash_aliases

echo 'export GOPATH=$HOME/.go' >> ~/.bash_aliases
