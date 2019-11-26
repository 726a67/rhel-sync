#!/bin/bash

MAVEN_PROJECTS_DIR=/root/airbridge/maven/maven-projects

for PROJECT in `ls ${MAVEN_PROJECTS_DIR}` ; do echo "[${PROJECT}]"; echo -e ; cd ${MAVEN_PROJECTS_DIR}/${PROJECT}; mvn -U clean dependency:go-offline package; echo -e; done

cd ~
