#!/usr/bin/env python3

import sdk
import argparse
import git
import os
import pprint
import shutil
import subprocess
import tarfile
import time
import json
import urllib.request
from os.path import expanduser

parser = argparse.ArgumentParser(description='Install SDKs according to the configuration, either some default or override with a commit hash / local mount.')

parser.add_argument('--algod-config', required=True, help='Path to algod config file.')

pp = pprint.PrettyPrinter(indent=4)


class IllegalArgumentError(ValueError):
    pass

def setup_algod(config_file):
    """
    Download and install algod.
    """
    # Parse config file...
    with open(config_file) as f:
        l = [line.split("=") for line in f.readlines()]
        d = {key.strip(): value.strip().strip('\"') for key, value in l}
    home = expanduser('~')
    os.makedirs("%s/inst" % home, exist_ok=True)
    print('downloading updater...')
    url='https://algorand-releases.s3.amazonaws.com/channel/stable/install_stable_linux-amd64_2.0.4.tar.gz'
    updater_tar='%s/inst/installer.tar.gz' % home
    filedata = urllib.request.urlretrieve(url, updater_tar)
    tar = tarfile.open(updater_tar)
    tar.extractall(path='%s/inst' % home)
    subprocess.check_call(['%s/inst/update.sh -i -c %s -p %s -d %s/data -n' % (home, d['CHANNEL'], d['BIN_DIR'], d['BIN_DIR'])], shell=True)


if __name__ == '__main__':
    args = parser.parse_args()
    sdk.setup_sdk()
    setup_algod(args.algod_config)
