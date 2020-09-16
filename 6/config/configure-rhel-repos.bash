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
        subscription-manager repos --proxy=${PROXY} \
        --disable='*' \
        --enable=jb-eap-6-for-rhel-6-server-rpms \
        --enable=jb-eap-7-for-rhel-6-server-rpms \
        --enable=rhel-6-server-optional-rpms \
        --enable=rhel-6-server-rpms \
        --enable=rhel-6-server-supplementary-rpms \
        --enable=rhel-6-server-rhv-4-agent-rpms \
        --enable=rhel-server-rhscl-6-rpms

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
