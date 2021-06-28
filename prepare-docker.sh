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
set -e

#This is a script to Prepare an artemis folder to generate the Release.


usage () {
  cat <<HERE

$@

Usage:
  # Prepare for build the Docker Image from the release version
  ./prepare-docker.sh --from-release --artemis-version {release-version}

  # Show the usage command
  ./prepare-docker.sh --help

Example:
  ./prepare-docker.sh --from-release --artemis-version 2.16.0  

HERE
  exit 1
}

next_step () {
  cat <<HERE

Well done! Now you can continue with the Docker image build.
Building the Docker Image:

  # Build for CentOS
  $ ./build-docker.sh --from-release --artemis-version $ARTEMIS_VERSION

For more info read the README.md

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
    --from-local-dist)
    FROM_LOCAL="true"
    ;;
    --from-release)
    FROM_RELEASE="true"
    ;;
    --local-dist-path)
    LOCAL_DIST_PATH="$2"
    shift
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

cleanup() {
  if [ -d "${BASE_TMPDIR}/${ARTEMIS_VERSION}" ]
  then
    echo "Clean up the ${BASE_TMPDIR}/${ARTEMIS_VERSION} directory"
    find "${BASE_TMPDIR}" -name "${ARTEMIS_VERSION}" -type d -mmin +60 -exec rm -rf "{}" \;
  else
    mkdir -p "${BASE_TMPDIR}/${ARTEMIS_VERSION}"
  fi
}

if [ -n "${FROM_RELEASE}" ]; then
  [ -n "${ARTEMIS_VERSION}" ] || usage "You must specify the release version (es.: --artemis-version 2.16.0)"

  cleanup
  
  ARTEMIS_BASE_URL="$(curl -s https://www.apache.org/dyn/closer.cgi\?preferred=true)activemq/activemq-artemis/${ARTEMIS_VERSION}/"
  ARTEMIS_DIST_FILE_NAME="apache-artemis-${ARTEMIS_VERSION}-bin.tar.gz"
  CURL_OUTPUT="${BASE_TMPDIR}/${ARTEMIS_VERSION}/${ARTEMIS_DIST_FILE_NAME}"

  if [ -z "$(ls -A ${BASE_TMPDIR}/${ARTEMIS_VERSION})" ]
  then
    echo "Downloading ${ARTEMIS_DIST_FILE_NAME} from ${ARTEMIS_BASE_URL}..."
    curl --progress-bar "${ARTEMIS_BASE_URL}${ARTEMIS_DIST_FILE_NAME}" --output "${CURL_OUTPUT}"

    echo "Expanding ${BASE_TMPDIR}/${ARTEMIS_VERSION}/${ARTEMIS_DIST_FILE_NAME}..."
    tar xzf "$CURL_OUTPUT" --directory "${BASE_TMPDIR}/${ARTEMIS_VERSION}" --strip 1

    echo "Removing ${BASE_TMPDIR}/${ARTEMIS_VERSION}/${ARTEMIS_DIST_FILE_NAME}..."
    rm -rf "${BASE_TMPDIR}/${ARTEMIS_VERSION}"/"${ARTEMIS_DIST_FILE_NAME}"
  fi

  ARTEMIS_DIST="${BASE_TMPDIR}/${ARTEMIS_VERSION}"
  
  echo "Using Artemis dist: ${ARTEMIS_DIST}"

else

  usage

fi

if [ ! -d "${ARTEMIS_DIST}/docker" ]
then
  mkdir "${ARTEMIS_DIST}/docker"
fi

cp ./context/Dockerfile-* "$ARTEMIS_DIST/docker"
cp ./context/docker-run.sh "$ARTEMIS_DIST/docker"

echo "Docker file support files at : $ARTEMIS_DIST/docker"
tree "$ARTEMIS_DIST/docker"

next_step