#!/usr/bin/env python3

import argparse
import os
import pprint
import shutil
import subprocess
import tarfile
import time
import json
import urllib.request
from os.path import expanduser, join

parser = argparse.ArgumentParser(description='Install, configure, and start algod.')

# Shared parameters
base_parser = argparse.ArgumentParser(add_help=False)
base_parser.add_argument('--bin-dir', required=True, help='Location to install algod binaries.')
base_parser.add_argument('--channel', required=True, help='Channel to install, nightly is a good option.')
base_parser.add_argument('--network-dir', required=True, help='Path to create network.')

subparsers = parser.add_subparsers()

install = subparsers.add_parser('install', parents=[base_parser], help='Install the network.')
install.add_argument('--network-template', required=True, help='Path to private network template file.')
install.add_argument('--network-token', required=True, help='Valid token to use for algod/kmd.')
install.add_argument('--algod-port', required=True, help='Port to use for algod.')
install.add_argument('--kmd-port', required=True, help='Port to use for kmd.')

start = subparsers.add_parser('start', parents=[base_parser], help='Start the network.')

pp = pprint.PrettyPrinter(indent=4)

def setup_algod(bin_dir, channel):
    """
    Download and install algod.
    """
    home = expanduser('~')
    os.makedirs("%s/inst" % home, exist_ok=True)
    print('downloading updater...')
    url='https://algorand-releases.s3.amazonaws.com/channel/stable/install_stable_linux-amd64_2.0.4.tar.gz'
    updater_tar='%s/inst/installer.tar.gz' % home
    filedata = urllib.request.urlretrieve(url, updater_tar)
    tar = tarfile.open(updater_tar)
    tar.extractall(path='%s/inst' % home)
    subprocess.check_call(['%s/inst/update.sh -i -c %s -p %s -d %s/data -n' % (home, channel, bin_dir, bin_dir)], shell=True)


def algod_directories(network_dir):
    """
    Compute data/kmd directories.
    """
    data_dir=join(network_dir, 'Node')

    kmd_dir = [filename for filename in os.listdir(data_dir) if filename.startswith('kmd')][0]
    kmd_dir=join(data_dir, kmd_dir)

    return data_dir, kmd_dir


def create_network(bin_dir, network_dir, template, token, algod_port, kmd_port):
    """
    Create a private network.
    """
    # Reset network dir before creating a new one.
    if os.path.exists(args.network_dir):
        shutil.rmtree(args.network_dir)

    # $BIN_DIR/goal network create -n testnetwork -r $NETWORK_DIR -t network_config/$TEMPLATE
    subprocess.check_call(['%s/goal network create -n testnetwork -r %s -t %s' % (bin_dir, network_dir, template)], shell=True)
    node_dir, kmd_dir = algod_directories(network_dir)

    # Set tokens
    with open(join(node_dir, 'algod.token'), 'w') as f:
        f.write(token)
    with open(join(kmd_dir, 'kmd.token'), 'w') as f:
        f.write(token)

    # Setup config, inject port
    with open(join(node_dir, 'config.json'), 'w') as f:
        f.write('{ "GossipFanout": 1, "EndpointAddress": "0.0.0.0:%s", "DNSBootstrapID": "", "IncomingConnectionsLimit": 0, "Archival":true, "isIndexerActive":true}' % algod_port)
    with open(join(kmd_dir, 'kmd_config.json'), 'w') as f:
        f.write('{  "address":"0.0.0.0:%s",  "allowed_origins":["*"]}' % kmd_port)


def start_network(bin_dir, network_dir):
    """ 
    # $BIN_DIR/goal network start -r $NETWORK_DIR

    kmd start runs forever, so this command never returns.
    """
    data_dir, kmd_dir = algod_directories(network_dir)
    subprocess.check_call(['%s/goal network start -r %s' % (bin_dir, network_dir)], shell=True)
    subprocess.check_call(['%s/kmd start -t 0 -d %s' % (bin_dir, kmd_dir)], shell=True)


def install_handler(args):
    """ 
    install subcommand - create and configure the network.
    """
    setup_algod(args.bin_dir, args.channel)
    create_network(args.bin_dir, args.network_dir, args.network_template, args.network_token, args.algod_port, args.kmd_port)


def start_handler(args):
    """
    start subcommand - start algod + kmd
    """
    start_network(args.bin_dir, args.network_dir)


if __name__ == '__main__':
    install.set_defaults(func=install_handler)
    start.set_defaults(func=start_handler)

    args = parser.parse_args()
    args.func(args)
