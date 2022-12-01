#!/usr/bin/env bash

echo fs.inotify.max_user_watches=655360 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_instances=1280 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

