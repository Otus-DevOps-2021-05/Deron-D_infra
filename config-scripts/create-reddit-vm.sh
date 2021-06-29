#!/bin/bash
IMAGE_ID=$(yc compute image list | grep reddit-full | awk '{print $2}')
yc compute instance create \
	--name reddit-app \
	--hostname reddit-app \
	--memory=4  \
	--create-boot-disk name=reddit-full,image-id=$IMAGE_ID,size=10GB \
        --network-interface subnet-name=my-net-ru-central1-a,nat-ip-version=ipv4 \
	--metadata serial-port-enable=1 \
	--ssh-key ~/.ssh/appuser.pub
