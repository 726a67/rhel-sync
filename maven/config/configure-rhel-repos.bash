#!/bin/bash

PROXY=http://192.168.200.13:3128

REGISTER_SYSTEM()
{
	subscription-manager register --force --auto-attach --proxy=${PROXY}

	if [ ${?} != 0 ]
	then
		echo "[ERROR] Registration failed"
		exit
	fi
}

CONFIGURE_REPOS()
{
	echo "Disabling previously registered repositories"

	subscription-manager repos --proxy=${PROXY} \
	--disable='*' \
	--enable=rhel-7-server-rpms

	echo -e
}

REGISTER_SYSTEM
CONFIGURE_REPOS
