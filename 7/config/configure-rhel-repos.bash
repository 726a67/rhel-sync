#!/bin/bash

PROXY=http://192.168.200.13:3128
PRODUCT="Red Hat Enterprise Linux with Smart Virtualization, Premium (2-socket)"

REGISTER_SYSTEM()
{
	subscription-manager remove --all
	subscription-manager unregister
	subscription-manager clean
	subscription-manager register --force --proxy=${PROXY}
	subscription-manager refresh

	if [ ${?} != 0 ]
	then
		echo "[ERROR] Registration failed"
		exit
	fi
}

ATTACH_POOL()
{
	POOL_ID=$(subscription-manager list --available --pool-only --matches="${PRODUCT}" | sort | tail -1)

	subscription-manager attach --pool=${POOL_ID}

	if [ ${?} != 0 ]
	then
		echo "[ERROR] Pool attach failed"
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
	--enable=rhel-7-server-ansible-2.9-rpms \
	--enable=jb-eap-7.2-for-rhel-7-server-rpms \
	--enable=rhel-7-server-rhv-4-mgmt-agent-rpms \
	--enable=rhel-7-server-rh-common-rpms \
	--enable=rhel-7-server-extras-rpms \
	--enable=rhel-7-server-optional-rpms \
	--enable=rhel-server-rhscl-7-rpms

	if [ ${?} != 0 ]
        then
                echo "[ERROR] Repo configuration failed"
                exit
        fi

	echo -e
}

REGISTER_SYSTEM && \
ATTACH_POOL && \
CONFIGURE_REPOS
