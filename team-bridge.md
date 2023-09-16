# NSC3 Team-Bridge Service

Release tag: `release-3.15`

## Team-Bridge Service description:

NSC3 Team-Bridge Service is designed to broadcast live-stream between independent NSC3 servers.
Team-Bridge commication pipe is linking NSC3 Servers organisations together. Pipes can be one-directional or bi-directional.
Team-Bridge service will handle only device level live-stream broadcasting by remaning original device identifications at destination organisation.

### One-Directional pipe:

One-Directional pipe contains two elements client and server. Dataflow point of view client is defining source organisation  and server node is defining the destination organisation. Communication protocol can be TCP or UDP.

Pre-requisites for installation:
- 2 x NSC3 servers installed
- admin credentials for NSC3
- IP address for both servers
- Organisation ID for source and destination NSC3 organisations -> Org ID is visible via NSC3 Admin panel
- Team-Bridge specific port 64660 open for Team-Bridge server

### Bi-Directional pipe:

Bi-Directional pipe combines both elements client and server that need to installed to both end. Dataflow point is similar as in case of One-Directional link but but along two pipes, outbound and inbound. Communication protocol can be TCP or UDP.
In order to get this concept working accordingly, Bi-Directional pipe requires two organizations to be created on both servers. Inside of NSC3 server organisations can be link together via JontOps tasks. Note that Joint Operations functionality in NSC3 requires dedicated license.

Pre-requisites for installation:
- 2 x NSC3 servers installed
- admin credentials for NSC3
- IP address for both servers
- 2 x NSC3 organisations defined at both server
- Organisation ID for source and destination NSC3 organisations for both directions -> Org ID is visible via NSC3 Admin panel
- Team-Bridge specific port 64660 is open for both servers

## Setting up Team-Bridge One-Directional link:

### Reference dataflow with example values.

![One-Directional-link](https://github.com/NSION/nsc3/blob/team-bridge-dev/One-directional-TB-link.png)

### Team-Bridge One-Directional link - Client:

Login to Client node:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:

```properties

```

### Team-Bridge One-Directional link - Server:

Login to Client node:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:

```properties

```

## Setting up Team-Bridge Bi-Directional link:

### Reference dataflow with example values.

![Bi-Directional-link](https://github.com/NSION/nsc3/blob/team-bridge-dev/Bi-directional-TB-link.png)

### Team-Bridge Bi-Directional link - Server1:

Login to Server1:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:

```properties

```

### Team-Bridge Bi-Directional link - Server2:

Login to Server2:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:
 
```properties

```
## TCP key-pairs:

Installation process will take case of TCP key-pair creation.
It is mandatory manual step to do in order to ensure that server side and client side is paired accordingly.
Copy the keypair file bundle directory only once from the server where the bundle is created in the first place.
Installation process will remind that separately.

After first TCP mode installation the key-pair bundle is located to folder:

``` bash
$HOME/nsc3/bridgekeys
```

Copy them to corresponding folder on other end server.
e.g with scp command

``` bash
scp -r $HOME/nsc3/bridgekeys <username>@<server2>:./nsc3/.
```

Key-pairs can be generated separately by command
``` bash
generateTeamBridgeRSAKeyPairs.sh
```

## Troubleshooting UDP

To test if the server is running and can be connected to, linux command line utility `netcat` can be
used to write something into it.

``` bash
sudo netcat localhost 64660 -u
```

Type something into the terminal, press enter to send and observe server container logs from another
terminal with `docker logs -f nsc-team-bridge-service`. A protobuf exception should get logged as the
plain text message is unexpected format.
