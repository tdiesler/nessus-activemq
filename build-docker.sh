#!/bin/sh
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Setting the script to fail if anything goes wrong
set -ex

# This is a script to build artemis docker image previously prepared with `./prepare-docker.sh`.


usage () {
  cat <<HERE

$@

Usage:
  # Build the Docker Image from the release version
  ./build-docker.sh --from-release --artemis-version {release-version}

  # Show the usage command
  ./build-docker.sh --help

Example:
  ./build-docker.sh --from-release --artemis-version 2.16.0  

HERE
  exit 1
}

while [ "$#" -ge 1 ]
do
key="$1"
  case $key in
    --help)
    usage
    ;;
    --from-release)
    FROM_RELEASE="true"
    ;;
    --artemis-version)
    ARTEMIS_VERSION="$2"
    shift
    ;;
    *)
    # unknown option
    usage "Unknown option"
    ;;
  esac
  shift
done

# TMPDIR must be contained within the working directory so it is part of the
# Docker context. (i.e. it can't be mktemp'd in /tmp)
BASE_TMPDIR="_TMP_/artemis"
ARTEMIS_DIST="$BASE_TMPDIR/$ARTEMIS_VERSION"

# Build for CentOS
docker build -f "$ARTEMIS_DIST/docker/Dockerfile-centos" -t nessusio/activemq-artemis:$ARTEMIS_VERSION $ARTEMIS_DIST
docker tag nessusio/activemq-artemis:$ARTEMIS_VERSION nessusio/activemq-artemis:latest