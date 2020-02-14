#!/usr/bin/env python3

import argparse
import git
import os
import pprint
import shutil
import subprocess
import tarfile
import time
import urllib.request
from os.path import expanduser

parser = argparse.ArgumentParser(description='Install SDKs according to the configuration, either some default or override with a commit hash / local mount.')

parser.add_argument('--algod-config', required=True, help='Path to algod config file.')

parser.add_argument('--java-dir', required=False, help='Local path to java sdk source directory.')
parser.add_argument('--javascript-dir', required=False, help='Local path to javascript sdk source directory.')
parser.add_argument('--python-dir', required=False, help='Local path to python sdk source directory.')
parser.add_argument('--go-dir', required=False, help='Local path to go sdk source directory.')

parser.add_argument('--java-hash', required=False, help='Commit hash for java SDK.')
parser.add_argument('--javascript-hash', required=False, help='Commit hash for javascript SDK.')
parser.add_argument('--python-hash', required=False, help='Commit hash for python SDK.')
parser.add_argument('--go-hash', required=False, help='Commit hash for go SDK.')

# Parameters to override defaults
parser.add_argument('--java-url', required=False, help='Override default git url for java SDK.')
parser.add_argument('--javascript-url', required=False, help='Override default git url for javascript SDK.')
parser.add_argument('--python-url', required=False, help='Override default git url for python SDK.')
parser.add_argument('--go-url', required=False, help='Override default git url for go SDK.')

parser.add_argument('--java-source-dir', required=False, help='Override java sdk source directory.')
parser.add_argument('--javascript-source-dir', required=False, help='Override javascript sdk source directory.')
parser.add_argument('--python-source-dir', required=False, help='Override python sdk source directory.')
parser.add_argument('--go-source-dir', required=False, help='Override go sdk source directory.')


JAVA = { 
    'cucumber': '/opt/sdk-testing/java_cucumber',
    'url': 'https://github.com/algorand/java-algorand-sdk.git',
    'source': '/opt/sdk_java'
}

JAVASCRIPT = {
    'cucumber': '/opt/sdk-testing/js_cucumber',
    'url': 'https://github.com/algorand/js-algorand-sdk.git',
    'source': '/opt/sdk_javascript'
}

PYTHON = {
    'cucumber': '/opt/sdk-testing/py_behave',
    'url': 'https://github.com/algorand/py-algorand-sdk.git',
    'source': '/opt/sdk_python'
}

GO = {
    'cucumber': '/opt/sdk-testing/go_godog',
    'url': 'https://github.com/algorand/go-algorand-sdk.git',
    'source': '/opt/go/src/github.com/algorand/go-algorand-sdk'
}

pp = pprint.PrettyPrinter(indent=4)


class IllegalArgumentError(ValueError):
    pass


def setup_directory(source_dir, url, local_dir, commit_hash):
    """
    Load the appropriate code to the source directory.
    """
    if local_dir != None and commit_hash != None:
        raise IllegalArgumentError("Must provide only one of --sdk-dir and --sdk-hash-url, not both.")

    # Make sure the path to the source_dir exists.
    os.makedirs(source_dir, exist_ok=True)
    # But not source_dir itself.
    shutil.rmtree(source_dir, ignore_errors=True)

    if local_dir != None:
        print('Copying "%s" <- "%s"' % (source_dir, local_dir))
        shutil.copytree(local_dir, source_dir)
        return

    print('Cloning into "%s" <- "%s"' % (source_dir, url))
    repo = git.Repo.clone_from(url, source_dir)

    # Checkout commit hash if specified.
    if commit_hash != None:
        print('Checking out commit hash: %s' % commit_hash)
        repo.git.checkout(commit_hash)

def apply_overrides(sdk_tuple, url, source_dir):
    """
    Helper to override the sdk defaults.
    """
    if url is not None:
        sdk_tuple['url'] = url
    if source_dir is not None:
        sdk_tuple['source'] = source_dir


def setup_go(config):
    """
    Setup go cucumber environment.
    """
    # go get github.com/DATA-DOG/godog/cmd/godog
    # if ! $go
    # then
    #     go get -u github.com/algorand/go-algorand-sdk/...
    #     go generate github.com/algorand/go-algorand-sdk/...
    # fi
    subprocess.check_call(['go get github.com/DATA-DOG/godog/cmd/godog'], shell=True)
    #subprocess.check_call(['go get -u %s/...' % config['source']], shell=True)
    #subprocess.check_call(['go generate %s/...' % config['source']], shell=True)
    pass


def setup_javascript(config):
    """
    Setup javascript cucumber environment.
    """
    # pushd js_cucumber
    # npm install --silent
    # if $js
    # then
    #     npm install $TRAVIS_BUILD_DIR --silent
    # fi
    # popd
    subprocess.check_call(['npm install --silent'], shell=True, cwd=config['cucumber'])
    subprocess.check_call(['npm install %s --silent' % config['source']], shell=True)
    pass


def setup_python(config):
    """
    Setup python cucumber environment.
    """
    os.system('pip3 install ' + config['source'] + ' -q')


def setup_java(config):
    """
    Setup java cucumber environment.
    """
    # cd $TRAVIS_BUILD_DIR
    # mvn package -q -DskipTests
    # ALGOSDK_VERSION=$(mvn -q -Dexec.executable=echo  -Dexec.args='${project.version}' --non-recursive exec:exec)
    # cd - # back to 'java_cucumber'
    # find "${TRAVIS_BUILD_DIR}/target" -type f -name "*.jar" -exec mvn install:install-file -q -Dfile={} -DpomFile="${TRAVIS_BUILD_DIR}/pom.xml" \;
    # mvn versions:use-dep-version -DdepVersion=$ALGOSDK_VERSION -Dincludes=com.algorand:algosdk -DforceVersion=true -q
    subprocess.check_call(['mvn package install -q -DskipTests'], shell=True, cwd=config['source'])
    proc = subprocess.Popen(['mvn -q -Dexec.executable=echo  -Dexec.args=\'${project.version}\' --non-recursive exec:exec'], shell=True, cwd=config['source'], stdout=subprocess.PIPE)
    version = proc.stdout.read().decode("utf-8").strip()
    subprocess.check_call(['find "%s/target" -type f -name "*.jar" -exec mvn install:install-file -q -Dfile={} -DpomFile="%s/pom.xml" \;' % (config['source'], config['source'])], shell=True, cwd=config['cucumber'])
    subprocess.check_call(['mvn versions:use-dep-version -DdepVersion=%s -Dincludes=com.algorand:algosdk -DforceVersion=true -q' % version], shell=True, cwd=config['cucumber'])


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

    # Optionally override the defaults
    apply_overrides(JAVA      , args.java_url      , args.java_source_dir)
    apply_overrides(JAVASCRIPT, args.javascript_url, args.javascript_source_dir)
    apply_overrides(PYTHON    , args.python_url    , args.python_source_dir)
    apply_overrides(GO        , args.go_url        , args.go_source_dir)

    # Setup source directories
    setup_directory(JAVA['source']      , JAVA['url']      , args.java_dir      , args.java_hash      )
    setup_directory(JAVASCRIPT['source'], JAVASCRIPT['url'], args.javascript_dir, args.javascript_hash)
    setup_directory(PYTHON['source']    , PYTHON['url']    , args.python_dir    , args.python_hash    )
    setup_directory(GO['source']        , GO['url']        , args.go_dir        , args.go_hash        )

    # Setup each SDK
    setup_go(GO)
    setup_java(JAVA)
    setup_javascript(JAVASCRIPT)
    setup_python(PYTHON)

    # Setup algod
    setup_algod(args.algod_config)
