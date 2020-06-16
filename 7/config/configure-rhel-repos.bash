#!/bin/bash

PROXY=http://192.168.200.13:3128
POOL_ID=8a85f99b727637b20172b9c6e5144cc2

REGISTER_SYSTEM()
{
	subscription-manager remove --all
	subscription-manager unregister
	subscription-manager clean
	subscription-manager register --force --proxy=${PROXY}
	subscription-manager refresh
	subscription-manager attach --pool=${POOL_ID}

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
	--enable=rhel-7-server-rpms \
	--enable=rhel-7-server-supplementary-rpms \
	--enable=rhel-7-server-rhv-4.3-manager-rpms \
	--enable=rhel-7-server-rhv-4-manager-tools-rpms \
	--enable=rhel-7-server-ansible-2-rpms \
	--enable=jb-eap-7.2-for-rhel-7-server-rpms \
	--enable=rhel-7-server-rhv-4-mgmt-agent-rpms \
	--enable=rhel-7-server-rh-common-rpms \
	--enable=rhel-7-server-extras-rpms \
	--enable=rhel-7-server-optional-rpms \
	--enable=rhel-server-rhscl-7-rpms

	echo -e
}

REGISTER_SYSTEM
CONFIGURE_REPOS
