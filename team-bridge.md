# Nsc Team Bridge Service

Transfer organization-specific live traffic from one NSC3 instance to another.

Release tag: release-3.14

## Setting up

All IP addresses, ports and image tags are examples and can vary between deployments.
Named `nsc-network` -docker network is expected to exist, but if not, it can be created with:

``` bash
sudo docker network create --subnet 172.18.0.0/24 nsc-network
```

Configure docker registry token:



### General instructions

Steps are mostly the same on both client and server side. Runtime configuration is done in
the `.env` file.

1. Load the team-bridge container to local registry:

   ``` bash
   sudo docker pull nsc-team-bridge-service:<release>
   ```

3. Configure necessary environment variables into an ```nsc-team-bridge-service.env``` -file.

   Sample ```nsc-team-bridge-service.env```-file with default values:

    ```properties
   # In which mode the service is operating, has to be one of UDP_CLIENT, UDP_SERVER, TCP_CLIENT or TCP_SERVER
   NSC3_TEAM_BRIDGE_SERVICE_OPERATE_MODE=UDP_SERVER
   # Client: Address the packets are sent to
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_ADDRESS=nsc-team-bridge-service-server
   # Port used for traffic, has to match the container port given to docker run
   NSC3_TEAM_BRIDGE_SERVICE_SOCKET_PORT=64660
   # Client: Comma-separated list of organization ID strings as live traffic sources
   NSC3_TEAM_BRIDGE_SERVICE_CLIENT_ORG_SRC_LIST=
   # Server: Comma-separated key>value -map of organization ID source>destination pairs
   # for mapping incoming live traffic into existing local organizations, for example:
   # NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=sourceOrgId>destinationOrgId
   NSC3_TEAM_BRIDGE_SERVICE_SERVER_ORG_DEST_MAP=
   # Byte amount the payload is split into. Only effective for client in UDP mode
   NSC3_TEAM_BRIDGE_SERVICE_DATAGRAM_CHUNK_SIZE_BYTES=1200
   ```

4. Run the app based on the image, with environment variables from `nsc-team-bridge-service.env`. Server side has to have the configured listen port mapped.

   ``` bash
   sudo docker run -d --env-file nsc-team-bridge-service.env -p 64660:64660 --net nsc-network --restart unless-stopped --name nsc-bridge-service nsc-team-bridge-service:latest
   ```

### TCP mode and key management

Secure communication using TCP requires generating unique asymmetric key pairs for both client and server sides and pre-sharing their public keys for symmetric key negotiation.

`scripts`-folder contains a script `generateTeamBridgeRSAKeyPairs.sh` for generating a set of RSA key pairs in the correct structure and format the application expects them to be present in the volume:

- `-v /deploy-files/bridgekeys:/opt/nsc3/bridgekeys`

Run the script with `./generateTeamBridgeRSAKeyPairs.sh` and it should generate the following folder and file structure:

```bash
bridgekeys
bridgekeys/server
bridgekeys/server/bridge_public_key.der
bridgekeys/server/bridge_client_public_key.der
bridgekeys/server/bridge_private_key.der
bridgekeys/client
bridgekeys/client/bridge_public_key.der
bridgekeys/client/bridge_server_public_key.der
bridgekeys/client/bridge_private_key.der
```

Only one of the `client` or `server` folders needs to be present, depending on the launch mode. Also note that the script requires `openssl` binary on the host PATH and there might be some untested differences if they are generated on different openssl versions.

## Additional server side configuration step

`nsc-stream-in-service` has to be re-run with an extra flag for enabling team bridge traffic processing:

``` bash
sudo docker run -d -v /dev/urandom:/dev/random -e MEMORY=8g -e NSC3_STREAM_IN_SERVICE_TEAM_BRIDGE_ENABLED=true --net nsc-network --restart unless-stopped --name nsc-stream-in-service nsc-stream-in-service:latest
```

## Environment variables

If environment are later adjusted, the app container has to be stopped and re-created:

```sh
sudo docker stop nsc-team-bridge-service
sudo docker rm nsc-team-bridge-service
```

Tweak the environment variables in the .env-file and execute the `docker run` -command in step 3
of `Setting up` again.

## Troubleshooting UDP

To test if the server is running and can be connected to, linux command line utility `netcat` can be
used to write something into it.

``` bash
sudo netcat localhost 64660 -u
```

Type something into the terminal, press enter to send and observe server container logs from another
terminal with `docker logs -f nsc-team-bridge-service`. A protobuf exception should get logged as the
plain text message is unexpected format.
