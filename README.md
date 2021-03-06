# Docker Image Example

This is an example on how you could create your own Docker Image For Apache 
ActiveMQ Artemis based on CentOS (JDK 8).

# Preparing

Use the script ./prepare-docker.sh as it will copy the docker files under the 
binary distribution.

Below is shown the command to prepare the build of the Docker Image starting 
from the local distribution (from the source codes of ActiveMQ Artemis)
```
# Prepare for build the Docker Image from the release version. Replace the
# {release-version} with the version that you want 
$ ./prepare-docker.sh --from-release --artemis-version {release-version}
```

The output of the previous command is shown below.

```
$ ./prepare-docker.sh --from-release --artemis-version 2.16.0

Downloading apache-artemis-2.16.0-bin.tar.gz from https://downloads.apache.org/activemq/activemq-artemis/2.16.0/...
################################################################################################################################################################################################################################ 100,0%
Expanding _TMP_/artemis/2.16.0/apache-artemis-2.16.0-bin.tar.gz...
Removing _TMP_/artemis/2.16.0/apache-artemis-2.16.0-bin.tar.gz...
Using Artemis dist: _TMP_/artemis/2.16.0
Docker file support files at : _TMP_/artemis/2.16.0/docker
_TMP_/artemis/2.16.0/docker
├── Dockerfile-centos
└── docker-run.sh

0 directories, 4 files

Well done! Now you can continue with the Docker image build.
Building the Docker Image:

  # Build for CentOS
  $ ./build-docker.sh --from-release --artemis-version 2.16.0

For more info read the README.md
```

# Building for CentOS

```
$ ./build-docker.sh --from-release --artemis-version 2.16.0
```

# Environment Variables

Environment variables determine the options sent to `artemis create` on first execution of the Docker
container. The available options are: 

**`ARTEMIS_USER`**

The administrator username. The default is `artemis`.

**`ARTEMIS_PASSWORD`**

The administrator password. The default is `artemis`.

**`ANONYMOUS_LOGIN`**

Set to `true` to allow anonymous logins. The default is `false`.

**`EXTRA_ARGS`**

Additional arguments sent to the `artemis create` command. The default is `--http-host 0.0.0.0 --relax-jolokia`.
Setting this value will override the default. See the documentation on `artemis create` for available options.

**Final broker creation command:**

The combination of the above environment variables results in the `docker-run.sh` script calling
the following command to create the broker instance the first time the Docker container runs:

    ${ARTEMIS_HOME}/bin/artemis create --user ${ARTEMIS_USER} --password ${ARTEMIS_PASSWORD} --silent ${LOGIN_OPTION} ${EXTRA_ARGS}

Note: `LOGIN_OPTION` is either `--allow-anonymous` or `--require-login` depending on the value of `ANONYMOUS_LOGIN`.

# Mapping point

- `/var/lib/artemis-instance`

It's possible to map a folder as the instance broker.
This will hold the configuration and the data of the running broker. This is useful for when you want the data persisted outside of a container.


# Lifecycle of the execution

A broker instance will be created during the execution of the instance. If you pass a mapped folder for `/var/lib/artemis-instance` an image will be created or reused depending on the contents of the folder.

## Running an Artemis image

The image just created in the previous step allows both stateless or stateful runs.
The stateless run is achieved by:

```
docker rm -f artemis
docker run --detach \
  --name=artemis \
  -p 61616:61616 \
  -p 8161:8161 \
  -e ANONYMOUS_LOGIN=true \
  nessusio/activemq-artemis

docker logs -n 200 -f artemis 
```

The image will also support mapped folders and mapped ports. To run the image with the instance persisted on the host:

```
docker run -it -p 61616:61616 -p 8161:8161 -v <broker folder on host>:/var/lib/artemis-instance nessusio/activemq-artemis 
```

where `<broker folder on host>` is a folder where the broker instance is supposed to 
be saved and reused on each run.
