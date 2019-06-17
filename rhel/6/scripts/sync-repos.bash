#!/bin/bash

DOWNLOAD_DIR="/repo/rhel6"
CACHE_DIR="/tmp"

CHECK_PREREQS()
{
	if [ `rpm -qi yum-utils --quiet; echo ${?}` != 0 ]
	then
		echo "[WARNING] yum-utils is not installed"
		echo "[INFO] Installing yum-utils"
	
		yum install -y -q yum-utils
		
		if [ ${?} -eq "0" ]
		then
			echo "[INFO] Succesfully installed yum-utils"
		else
			echo "[ERROR] Failed to install yum-utils"
			exit
		fi
	fi
	
	if [ `rpm -qi createrepo --quiet; echo ${?}` != 0 ]
	then
		echo "[WARNING] createrepo is not installed"
		echo "[INFO] Installing createrepo"
	
		yum install -y -q createrepo
		
		if [ ${?} -eq "0" ]
		then
			echo "[INFO] Succesfully installed createrepo"
		else
			echo "[ERROR] Failed to install createrepo"
			exit
		fi
	fi
}

SYNC_REPOS()
{
	RUN_STATUS=`ps -ef | grep /usr/bin/reposync | grep -v grep  &> /dev/null; echo ${?}`

	if [ ! -d ${DOWNLOAD_DIR} ]
	then
		echo "[ERROR] Repository directory (${DOWNLOAD_DIR}) is missing"
		exit
	fi

	if [ ${RUN_STATUS} -eq "0" ]
	then
		echo "[WARNING] reposync is currently running -- aborting"
		exit
	else
		echo "[INFO] Running reposync"
		reposync --plugins --download_path=${DOWNLOAD_DIR} --download-metadata --delete
		
		if [ ${?} -ne "0" ]
		then
			echo "[ERROR] reposync failed -- aborting"
			exit
		fi
	fi
}

CREATE_REPOS()
{
	for REPO_DIR in `ls -d ${DOWNLOAD_DIR}/*/`	 
	do
		REPO_NAME=`echo ${REPO_DIR} | awk  -F / '{print $(NF-1)}'`
	
		echo -e
		echo "[${REPO_NAME}]"
		echo -e

		GROUPINFO_FILE=`ls -t ${REPO_DIR}/*-comps*.bz2 2> /dev/null | head -1`

		if [[ -f ${GROUPINFO_FILE} && $? -eq 0 ]]
		then
			echo "Extracting comps.xml (bz2)"
			bzip2 -dc ${GROUPINFO_FILE} > ${REPO_DIR}/comps.xml
			
			if [[ $? -eq 0 ]]
			then
				echo "Removing comps.xml (bz2)"
				rm -rf ${GROUPINFO_FILE}
			fi
		fi

		GROUPINFO_FILE=`ls -t ${REPO_DIR}/*-comps*.gz 2> /dev/null | head -1`

		if [[ -f ${GROUPINFO_FILE} && $? -eq 0 ]]
		then
			echo "Extracting comps.xml (gz)"
			zcat ${GROUPINFO_FILE} > ${REPO_DIR}/comps.xml
			
			if [[ $? -eq 0 ]]
			then
				echo "Removing comps.xml (gz)"
				rm -rf ${GROUPINFO_FILE}
			fi
		fi

		GROUPINFO_FILE=`ls -t ${REPO_DIR}/*-comps.xml 2> /dev/null | head -1`

		if [[ -f ${GROUPINFO_FILE} && $? -eq 0 ]]
		then
			echo "Copying comps.xml (bz2)"
			cat ${GROUPINFO_FILE} > ${REPO_DIR}/comps.xml
			
			if [[ $? -eq 0 ]]
			then
				echo "Removing comps.xml (bz2)"
				rm -rf ${GROUPINFO_FILE}
			fi
		fi

		UPDATEINFO_FILE=`ls -t ${REPO_DIR}/*-updateinfo*.bz2 2> /dev/null | head -1`

		if [[ -f ${UPDATEINFO_FILE} && $? -eq 0 ]]
		then
			echo "Extracting updateinfo.xml (bz2)"
			bzip2 -dc ${UPDATEINFO_FILE} > ${REPO_DIR}/updateinfo.xml
			
			if [[ $? -eq 0 ]]
			then
				echo "Removing updateinfo.xml (bz2)"
				rm -rf ${UPDATEINFO_FILE}
			fi
		fi

		UPDATEINFO_FILE=`ls -t ${REPO_DIR}/*-updateinfo*.gz 2> /dev/null | head -1`

		if [[ -f ${UPDATEINFO_FILE} && $? -eq 0 ]]
		then
			echo "Extracting updateinfo.xml (gz)"
			zcat ${UPDATEINFO_FILE} > ${REPO_DIR}/updateinfo.xml
			
			if [[ $? -eq 0 ]]
			then
				echo "Removing updateinfo.xml (gz)"
				rm -rf ${UPDATEINFO_FILE}
			fi
		fi

		if [ -f ${REPO_DIR}/comps.xml ]
		then
			echo "Creating repository with group information"
			createrepo ${REPO_DIR} --cachedir ${CACHE_DIR} --groupfile comps.xml --workers 4 --update &> /dev/null
		else
			echo "No group information available"
			createrepo ${REPO_DIR} --cachedir ${CACHE_DIR} --workers 4 --update &> /dev/null
		fi

		if [ -f ${REPO_DIR}/updateinfo.xml ]
		then
			echo "Modifying repository with update information"
			modifyrepo ${REPO_DIR}/updateinfo.xml ${REPO_DIR}/repodata/ &> /dev/null
		else
			echo "No update information available"
		fi
	done
}

CHECK_PREREQS
SYNC_REPOS
CREATE_REPOS
