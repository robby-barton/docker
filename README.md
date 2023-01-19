# Docker setup
This is my personal config for the docker containers I run, they may be helpful to others but is mainly for my own sake. I make no guarantees that it will work for anyone else.

## Setup
Environment variables in `docker-compose.yml` should be set in a `.env` file. Required variables will be explained in the relevant sections for the containers.

### General Env Vars
This set of environment variables are generally used by all or multiple of my containers:

| Var | Description |
| --- | --- |
| `TZ` | Timezone to use (e.g. `America/New_York`) |
| `VOLUME_PATH` | Path to where docker volumes are stored (should be repo path) |

## Containers

### plex
Container to run my [plex](https://www.plex.tv/) media server.

#### Requirements
If using NVIDIA hardware acceleration then make sure to install the [NVIDIA docker runtime](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

#### Env Vars
| Var | Description |
| --- | --- |
| `CLAIM_ID` | Used for setting up plex server. Only needed the first time. |
| `ADVERTISE_IP` | Should be just `"<host_ip>:32400/"` |
| `MEDIA_DIR` | Directory with the media for plex to use. |

### kitana
Container to run [kitana](https://github.com/pannal/Kitana) for Plex.

### pihole
Container to run [pi-hole](https://pi-hole.net/) for the network. The container being used additionally has [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) installed to allow my pi-hole to be its own recursive resolver instead of needing external DNS. The [container repo](https://github.com/chriscrowe/docker-pihole-unbound) has an example of using both in a [single container](https://github.com/chriscrowe/docker-pihole-unbound/blob/main/one-container/docker-compose.yaml) which I used as a base for my setup.

#### Setup
`systemd-resolved` is most likely listening on port 53 so it needs to be freed. Open `/etc/systemd/resolved.conf`, uncomment `DNSStubListener` and set it to `no`. Then restart the service: `sudo systemctl restart systemd-resolved`.

If the pihole will also be acting as the DHCP server for the network then follow the setup for [dhcphelper](#dhcp-helper). Additionally make sure to update the IP in [07-dhcp-options.conf](pihole/dnsmasq.d/07-dhcp-options.conf) to reflect the IP of the pihole. This makes sure the pihole's IP is given to the client as the DNS server during the IP assignment.

#### Env Vars
| Var | Description |
| --- | --- |
| `FTLCONF_LOCAL_IPV4` | Set to the IP of the host. |
| `WEBPASSWORD` | Can set the password for pi-hole here, or leave blank and let pi-hole generate a random one. |
| `REV_SERVER` | Boolean for enabling conditional forwarding, if using the pi-hole as DHCP then this can be `false` |
| `REV_SERVER_DOMAIN` | Domain of the local network |
| `REV_SERVER_TARGET` | IP of local network router |
| `REV_SERVER_CIDR` | Reverse DNS zone |
| `HOSTNAME` | Hostname for the pi-hole server |
| `DOMAIN_NAME` | Domain name for the pi-hole server |
| `PIHOLE_WEBPORT` | Port for the pi-hole admin page |
| `WEBTHEME` | Theme for the pi-hole admin page |

### dhcphelper
DHCP relay used by `pihole` that allows it to stay in `network_mode: "bridged"` and still be the dhcp server for the network.

The [`Dockerfile`](dhcp-helper/Dockerfile) builds a container that installs [`dhcp-helper`](https://manpages.ubuntu.com/manpages/trusty/man8/dhcp-helper.8.html) and runs it on startup.

May need to open port 67 on the host: `sudo ufw allow 67`.
