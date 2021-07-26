#!/bin/bash
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt update
sleep 30s
apt install -y ruby-full ruby-bundler build-essential
