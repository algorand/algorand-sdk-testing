#!/usr/bin/env python3

import argparse
import git
import os
import pprint
import shutil
import subprocess
import sys
import tarfile
import time
import urllib.request
from os.path import expanduser, join

parser = argparse.ArgumentParser(description='Install SDKs according to the configuration, either some default or override with a commit hash / local mount.')

# Environment config.
parser.add_argument('--algod-config', required=True, help='Path to algod config file.')
parser.add_argument('--sdk-testing', required=True, help='Path to SDK Testing repo root.')
parser.add_argument('--network-dir', required=True, help='Path to create network.')

# Tests.
parser.add_argument('--java', dest='java', required=False, action='store_true', help='Flag to enable java tests.')
parser.add_argument('--javascript', dest='javascript', required=False, action='store_true', help='Flag to enable javascript tests.')
parser.add_argument('--python', dest='python', required=False, action='store_true', help='Flag to enable python tests.')
parser.add_argument('--go', dest='go', required=False, action='store_true', help='Flag to enable go tests.')

parser.set_defaults(java=False)
parser.set_defaults(javascript=False)
parser.set_defaults(python=False)
parser.set_defaults(go=False)

JAVA = { 
    'features_dir': '/opt/sdk-testing/java_cucumber/src/test/resources/java_cucumber',
    'cucumber': '/opt/sdk-testing/java_cucumber',
    'url': 'https://github.com/algorand/java-algorand-sdk.git',
    'source': '/opt/sdk_java'
}

JAVASCRIPT = {
    'features_dir': '/opt/sdk-testing/js_cucumber/features',
    'cucumber': '/opt/sdk-testing/js_cucumber'
}

GO = {
    'features_dir': '/opt/sdk-testing/go_godoc/src/features',
    'cucumber': '/opt/sdk-testing/go_godog'
}

PYTHON = {
    'features_dir': '/opt/sdk-testing/py_behave',
    'cucumber': '/opt/sdk-testing/py_behave'
}


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


def start_network(sdk_dir, bin_dir, network_dir, config, template):
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


def run_java_tests(JAVA):
    sys.stdout.flush()
    #subprocess.check_call(['mvn test -Dcucumber.options="--tags \\"not @crosstest\\""'], shell=True, cwd=JAVA['cucumber'])
    #subprocess.check_call(['mvn test -Dcucumber.options="--tags @template"'], shell=True, cwd=JAVA['cucumber'])
    subprocess.check_call(['mvn test -Dcucumber.options="/opt/sdk-testing/features/template.feature"'], shell=True, cwd=JAVA['cucumber'])


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

    features_dir = join(args.sdk_testing, 'features')

    copy_files(features_dir, JAVA['features_dir'])
    copy_files(features_dir, JAVASCRIPT['features_dir'])
    copy_files(features_dir, PYTHON['features_dir'])
    copy_files(features_dir, GO['features_dir'])

    template = join(args.sdk_testing, 'network_config', d['TEMPLATE'])
    config = join(args.sdk_testing, 'network_config', 'config.json')

    try:
        start_network(args.sdk_testing, d['BIN_DIR'], args.network_dir, config, template)

        run_java_tests(JAVA)
    except subprocess.CalledProcessError as e:
        print('An error occurred while running tests!')
        print(e)

    cleanup_network(d['BIN_DIR'], args.network_dir)
