#!/bin/bash

MAVEN_PROJECTS_DIR=/root/airbridge/maven/maven-projects

#for PROJECT in `ls ${MAVEN_PROJECTS_DIR}` ; do echo "[${PROJECT}]"; echo -e ; cd ${MAVEN_PROJECTS_DIR}/${PROJECT}; mvn clean -U -q; mvn -U dependency:go-offline; mvn package -Dmaven.repo.local=${MAVEN_PROJECTS_DIR}/${PROJECT}; echo -e; done
for PROJECT in `ls ${MAVEN_PROJECTS_DIR}` ; do echo "[${PROJECT}]"; echo -e ; cd ${MAVEN_PROJECTS_DIR}/${PROJECT}; mvn clean -U -q; mvn -U dependency:go-offline; echo -e; done
cd
