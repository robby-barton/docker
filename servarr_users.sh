#! /usr/bin/env bash
sudo groupadd mediacenter -g 13000
sudo useradd -r jellyfin -u 13000 -g mediacenter
sudo useradd -r sonarr -u 13001 -g mediacenter
sudo useradd -r radarr -u 13002 -g mediacenter
sudo useradd -r bazarr -u 13003 -g mediacenter
sudo useradd -r sabnzbd -u 13004 -g mediacenter
sudo useradd -r qbittorrent -u 13005 -g mediacenter
sudo useradd -r prowlarr -u 13006 -g mediacenter
