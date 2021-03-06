#!/bin/bash
set -x

# Get the latest OpenJDK8
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get -qq update
sudo apt-cache search openjdk
sudo apt-get install -y openjdk-8-jdk openjdk-8-source openjdk-8-doc

which java
java -version

# Get mx
git clone https://github.com/graalvm/mx.git
export PATH=$PATH:`pwd`/mx

# Get graal-jvmci-8
git clone https://github.com/graalvm/graal-jvmci-8.git
git -C graal-jvmci-8 checkout jvmci-${JVMCI_VERSION}

# Build the VM, install and test it
mx --primary-suite graal-jvmci-8 --vm=server build -DFULL_DEBUG_SYMBOLS=0
mx --primary-suite graal-jvmci-8 --vm=server -v vm -version
mx --primary-suite graal-jvmci-8 --vm=server -v unittest

# Build tar.gz archive
export JVMCI_JDK_HOME=$(mx --primary-suite graal-jvmci-8 jdkhome)
export PREFIX="$(basename $(dirname $(dirname ${JVMCI_JDK_HOME})))-jvmci-${JVMCI_VERSION}"
export CI_ARCH="amd64"
export CI_OS=${TRAVIS_OS_NAME}
if [ "${CI_OS}" != "linux" ]; then echo "Unsupported OS: ${CI_OS}"; exit 1; fi
export ARCHIVE="${PREFIX}-${CI_OS}-${CI_ARCH}.tar.gz"
python archive.py ${PREFIX} ${ARCHIVE} ${JVMCI_JDK_HOME}
ls -l
