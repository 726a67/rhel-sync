#!/bin/bash

PROXY=http://192.168.200.13:3128
POOL_ID=8a85f99b6ae5e42a016b48a935e05b13

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
	subscription-manager repos --proxy=${PROXY} \
	--disable='*' \
	--enable=jb-eap-6-for-rhel-6-server-rpms \
	--enable=jb-eap-7-for-rhel-6-server-rpms \
	--enable=rhel-6-server-optional-rpms \
	--enable=rhel-6-server-rpms \
	--enable=rhel-6-server-supplementary-rpms \
	--enable=rhel-6-server-rhv-4-agent-rpms \
	--enable=rhel-server-rhscl-6-rpms

	echo -e
}

REGISTER_SYSTEM
CONFIGURE_REPOS
