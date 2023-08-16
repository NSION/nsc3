# Nsc Team Bridge Service

Transfer organization-specific live traffic from one NSC3 instance to another.

Release tag: `release-3.15`

## Setting up

All IP addresses, ports and image tags are examples and can vary between deployments.
Named `nsc-network` -docker network is expected to exist, but if not, it can be created with:

``` bash
sudo docker network create --subnet 172.18.0.0/24 nsc-network
```

#### Login to NSION docker registry:

If NSC3 is recently installed or upgraded then you could skip this step. 

    cd $HOME/nsc3
    sudo docker login registrynsion.azurecr.io
    
    <Registry crentials will be delivered separately>


### General instructions for configuring

Steps are mostly the same on both client and server side. Runtime configuration is done in
the `.env` file.

1. Load the team-bridge container to local registry:

   ``` bash
   sudo docker pull registrynsion.azurecr.io/nsc-team-bridge-service:release-3.15
   ```

3. Configure necessary environment variables into an ```nsc-team-bridge-service.env``` -file.

   UDP Server example ```nsc-team-bridge-service.env```-file with default values:

    ```properties
   # In which mode the service is operating, has to be one of UDP_CLIENT, UDP_SERVER, TCP_CLIENT or TCP_SERVER
   NSC3_TEAM_BRIDGE_SERVICE_OPERATE_MODE=UDP_SERVER
   # Address where the packets are assigned to ...
   ## Client: Public IP address of team-bridge server
   ## Server: Docker container name of team-bridge server e.g nsc-team-bridge-service
   # NSC3_TEAM_BRIDGE_SERVICE_SOCKET_ADDRESS=192.168.1.100
   # Port used for traffic, has to match the container port given to docker run
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_PORT=64660
   # Client: Comma-separated list of organization ID strings as live traffic sources
   # NSC3_TEAM_BRIDGE_SERVICE_CLIENT_ORG_SRC_LIST=
   # Server: Comma-separated key>value -map of organization ID source>destination pairs
   # for mapping incoming live traffic into existing local organizations, for example:
   # NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=sourceOrgId>destinationOrgId
   NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=aslkdhalks233423423r54>dklsase53948wfdkgls
   # Byte amount the payload is split into. Only effective for client in UDP mode
   NSC3_TEAM_BRIDGE_SERVICE_DATAGRAM_CHUNK_SIZE_BYTES=1200
   ```
   TCP Server example ```nsc-team-bridge-service.env```-file with default values:

    ```properties
   # In which mode the service is operating, has to be one of UDP_CLIENT, UDP_SERVER, TCP_CLIENT or TCP_SERVER
   NSC3_TEAM_BRIDGE_SERVICE_OPERATE_MODE=TCP_SERVER
   # Address where the packets are assigned to ...
   ## Client: Public IP address of team-bridge server
   ## Server: Docker container name of team-bridge server e.g nsc-team-bridge-service
   # NSC3_TEAM_BRIDGE_SERVICE_SOCKET_ADDRESS=nsc-team-bridge-service
   # Port used for traffic, has to match the container port given to docker run
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_PORT=64660
   # Client: Comma-separated list of organization ID strings as live traffic sources
   # NSC3_TEAM_BRIDGE_SERVICE_CLIENT_ORG_SRC_LIST=
   # Server: Comma-separated key>value -map of organization ID source>destination pairs
   # for mapping incoming live traffic into existing local organizations, for example:
   # NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=sourceOrgId>destinationOrgId
   NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=aslkdhalks233423423r54>dklsase53948wfdkgls
   # Byte amount the payload is split into. Only effective for client in UDP mode
   # NSC3_TEAM_BRIDGE_SERVICE_DATAGRAM_CHUNK_SIZE_BYTES=1200
   ```
    
   UDP Client example ```nsc-team-bridge-service.env```-file with default values:

    ```properties
   # In which mode the service is operating, has to be one of UDP_CLIENT, UDP_SERVER, TCP_CLIENT or TCP_SERVER
   NSC3_TEAM_BRIDGE_SERVICE_OPERATE_MODE=UDP_CLIENT
   # Address where the packets are assigned to ...
   ## Client: Public IP address of team-bridge server
   ## Server: Docker container name of team-bridge server e.g nsc-team-bridge-service
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_ADDRESS=192.168.1.100
   # Port used for traffic, has to match the container port given to docker run
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_PORT=64660
   # Client: Comma-separated list of organization ID strings as live traffic sources
   NSC3_TEAM_BRIDGE_SERVICE_CLIENT_ORG_SRC_LIST=aslkdhalks233423423r54
   # Server: Comma-separated key>value -map of organization ID source>destination pairs
   # for mapping incoming live traffic into existing local organizations, for example:
   # NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=sourceOrgId>destinationOrgId
   # Byte amount the payload is split into. Only effective for client in UDP mode
   NSC3_TEAM_BRIDGE_SERVICE_DATAGRAM_CHUNK_SIZE_BYTES=1200
   ```
   TCP Client example ```nsc-team-bridge-service.env```-file with default values:

    ```properties
   # In which mode the service is operating, has to be one of UDP_CLIENT, UDP_SERVER, TCP_CLIENT or TCP_SERVER
   NSC3_TEAM_BRIDGE_SERVICE_OPERATE_MODE=TCP_CLIENT
   # Address where the packets are assigned to ...
   ## Client: Public IP address of team-bridge server
   ## Server: Docker container name of team-bridge server e.g nsc-team-bridge-service
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_ADDRESS=nsc-team-bridge-service
   # Port used for traffic, has to match the container port given to docker run
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_PORT=64660
   # Client: Comma-separated list of organization ID strings as live traffic sources
   NSC3_TEAM_BRIDGE_SERVICE_CLIENT_ORG_SRC_LIST=aslkdhalks233423423r54
   # Server: Comma-separated key>value -map of organization ID source>destination pairs
   # for mapping incoming live traffic into existing local organizations, for example:
   # NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=sourceOrgId>destinationOrgId
   # Byte amount the payload is split into. Only effective for client in UDP mode
   # NSC3_TEAM_BRIDGE_SERVICE_DATAGRAM_CHUNK_SIZE_BYTES=1200
   ```
4. Locate the configuration file to the folder where you are going run docker services.

### UDP mode start services

Run the app based on the image, with environment variables from `nsc-team-bridge-service.env`. Server side has to have the configured listen port mapped.

UDP Server:

   ``` bash
   sudo docker run -d --env-file nsc-team-bridge-service.env -p 64660:64660 --net nsc-network --restart unless-stopped --name nsc-team-bridge-service registrynsion.azurecr.io/nsc-team-bridge-service:release-3.15
   ```
UDP Client: 

   ``` bash
   sudo docker run -d --env-file nsc-team-bridge-service.env --net nsc-network --restart unless-stopped --name nsc-team-bridge-service registrynsion.azurecr.io/nsc-team-bridge-service:release-3.15
   ```

### TCP mode and key management

Secure communication using TCP requires generating unique asymmetric key pairs for both client and server sides and pre-sharing their public keys for symmetric key negotiation.

`scripts`-folder contains a script `generateTeamBridgeRSAKeyPairs.sh` for generating a set of RSA key pairs in the correct structure and format the application expects them to be present in the volume:

- `-v <host path>/bridgekeys:/opt/nsc3/bridgekeys`

1. Run the script with `./generateTeamBridgeRSAKeyPairs.sh` and it should generate the following folder and file structure:

TCP/IP Server:

```bash
bridgekeys
bridgekeys/server
bridgekeys/server/bridge_public_key.der
bridgekeys/server/bridge_client_public_key.der
bridgekeys/server/bridge_private_key.der
```

TCP/IP Client:
```bash
bridgekeys/client
bridgekeys/client/bridge_public_key.der
bridgekeys/client/bridge_server_public_key.der
bridgekeys/client/bridge_private_key.der
```
2. Copy the key bundle to both hosts (Client and Server)

3. Change permission for key files at Client and server host: 
```bash
cd <host path to bridgekeys folder>
chmod a+rw bridgekeys/client/*
chmod a+rw bridgekeys/server/*
```

Only one of the `client` or `server` folders needs to be present, depending on the launch mode. Also note that the script requires `openssl` binary on the host PATH and there might be some untested differences if they are generated on different openssl versions.

TCP Server, start services:

   ``` bash
   sudo docker run -d -v <host path>/bridgekeys:/opt/nsc3/bridgekeys --env-file nsc-team-bridge-service.env -p 64660:64660 --net nsc-network --restart unless-stopped --name nsc-team-bridge-service registrynsion.azurecr.io/nsc-team-bridge-service:release-3.15
   ```
TCP Client, start services: 

   ``` bash
   sudo docker run -d -v <host path>/bridgekeys:/opt/nsc3/bridgekeys --env-file nsc-team-bridge-service.env -p 64660:64660 --net nsc-network --restart unless-stopped --name nsc-team-bridge-service registrynsion.azurecr.io/nsc-team-bridge-service:release-3.15
   ```

## Additional server side configuration step (Mandatory)

`nsc-stream-in-service` has to be re-run with an extra flag for enabling team bridge traffic processing:

``` bash
sudo nano docker-compose.yml
```

Add following environment variable parameters `NSC3_STREAM_IN_SERVICE_TEAM_BRIDGE_ENABLED=true` section of nsc-stream-in-service 

Example:
```yaml

  nsc-stream-in-service:
    container_name: nsc-stream-in-service
    image: registrynsion.azurecr.io/nsc-stream-in-service:release-3.15
    logging:
      driver: "json-file"
      options: {}    
    volumes:
      - /dev/urandom:/dev/random:rw
    networks:
      nsc-network:
        ipv4_address: "172.18.0.6"
    restart: unless-stopped
    environment:
      - MEMORY=8g
      - NSC3_STREAM_IN_SERVICE_TEAM_BRIDGE_ENABLED=true
    working_dir: /root

```

Restart NSC streaming services:

``` bash
sudo docker-compose restart nsc-stream-in-service
```


## Environment variables

If environment are later adjusted, the app container has to be stopped and re-created:

```sh
sudo docker stop nsc-team-bridge-service
sudo docker rm nsc-team-bridge-service
```

Tweak the environment variables in the .env-file and execute the `docker run` -command as described in above instructions.

## Troubleshooting UDP

To test if the server is running and can be connected to, linux command line utility `netcat` can be
used to write something into it.

``` bash
sudo netcat localhost 64660 -u
```

Type something into the terminal, press enter to send and observe server container logs from another
terminal with `docker logs -f nsc-team-bridge-service`. A protobuf exception should get logged as the
plain text message is unexpected format.
