#!/usr/bin/env python3

import sdk
import argparse
import git
import os
import pprint
import shutil
import subprocess
import sys
import tarfile
import time
from os.path import expanduser, join

parser = argparse.ArgumentParser(description='Install SDKs according to the configuration, either some default or override with a commit hash / local mount.')

# Environment config.
parser.add_argument('--algod-config', required=True, help='Path to algod config file.')
parser.add_argument('--network-dir', required=True, help='Path to create network.')

def copy_files(src, dst):
    """
    Recursively copy the contents of a directory into another directory.
    """
    if not os.path.exists(dst):
        os.makedirs(dst)

    src_files = os.listdir(src)
    for file_name in src_files:
        full_file_name = join(src, file_name)
        if os.path.isfile(full_file_name):
            shutil.copy(full_file_name, dst)
        elif os.path.isdir(full_file_name):
            new_dst = join(dst, file_name)
            os.mkdir(new_dst)
            copy_files(full_file_name, new_dst)


def cleanup_network(bin_dir, network_dir):
    """
    Stop the network and remove the data directories.
    """
    if os.path.exists(args.network_dir):
        for filename in os.listdir(network_dir):
            full_path = join(network_dir, filename)
            # Directories are data directories.
            if os.path.isdir(full_path):
                print('Shutting down node at "%s"' % full_path)
                subprocess.check_call(['%s/goal node stop -d %s' % (bin_dir, full_path)], shell=True)
        shutil.rmtree(args.network_dir)


def start_network(bin_dir, network_dir, config, template):
    """
    Create and start a private network, sets NODE_DIR and KMD_DIR environment variables.
    """
    # Reset network dir before creating a new one.
    if os.path.exists(args.network_dir):
        shutil.rmtree(args.network_dir)


    # $BIN_DIR/goal network create -n testnetwork -r $NETWORK_DIR -t network_config/$TEMPLATE
    subprocess.check_call(['%s/goal network create -n testnetwork -r %s -t %s' % (bin_dir, network_dir, template)], shell=True)
    # INDEXER_DIR=$(ls -d $NETWORK_DIR/Node/testnetwork*)
    node_dir=join(network_dir, 'Node')
    os.environ['NODE_DIR'] = node_dir
    indexer_dir = [join(node_dir, filename) for filename in os.listdir(node_dir) if filename.startswith('testnetwork')][0]
    # KMD_DIR=$(ls -d $NETWORK_DIR/Node/kmd*)
    kmd_dir = [filename for filename in os.listdir(node_dir) if filename.startswith('kmd')][0]
    # export KMD_DIR=$(basename $KMD_DIR)
    os.environ['KMD_DIR'] = kmd_dir
    # cp network_config/config.json $NODE_DIR
    shutil.copy(config, join(node_dir, 'config.json'))
    # $BIN_DIR/goal network start -r $NETWORK_DIR
    subprocess.check_call(['%s/goal network start -r %s' % (bin_dir, network_dir)], shell=True)

    # if $cross
    # then
    #     mkdir temp
    # fi




if __name__ == '__main__':
    args = parser.parse_args()

    # Parse config file...
    with open(args.algod_config) as f:
        l = [line.split("=") for line in f.readlines()]
        d = {key.strip(): value.strip().strip('\"') for key, value in l}

    # Setup the environment, used by the cucumber test implementations
    for k,v in d.items():
        os.environ[k] = v
    os.environ['NETWORK_DIR'] = args.network_dir

    template = join(sdk.default_dirs['temp'], 'network_config', d['TEMPLATE'])
    config = join(sdk.default_dirs['temp'], 'network_config', 'config.json')

    try:
        start_network(d['BIN_DIR'], args.network_dir, config, template)

        sdk.test_sdk()
    except subprocess.CalledProcessError as e:
        print('An error occurred while running tests!')
        print(e)

    cleanup_network(d['BIN_DIR'], args.network_dir)
