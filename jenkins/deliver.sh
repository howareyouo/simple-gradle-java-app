#!/usr/bin/env bash

SERVERS=(
    129.204.139.198
)

PORT=8000

echo 'The following Maven command installs your Maven-built Java application'
echo 'into the local Maven repository, which will ultimately be stored in'
echo 'Jenkins''s local Maven repository (and the "maven-repository" Docker data'
echo 'volume).'
set -x
mvn jar:jar install:install help:evaluate -Dexpression=project.name

echo 'The following complex command extracts the value of the <name/> element'
echo 'within <project/> of your Java/Maven project''s "pom.xml" file.'
NAME=`mvn help:evaluate -Dexpression=project.name | grep "^[^\[]"`

echo 'The following complex command behaves similarly to the previous one but'
echo 'extracts the value of the <version/> element within <project/> instead.'
VERSION=`mvn help:evaluate -Dexpression=project.version | grep "^[^\[]"`
set +x

echo 'The following command runs and outputs the execution of your Java'
echo 'application (which Jenkins built using Maven) to the Jenkins UI.'
JARFILE=${NAME}-${VERSION}.jar

echo "----------------------------------------------"
for server in "${SERVERS[@]}"
do
    echo "Copy jar to remote server: ${server}..."
    scp "target/${JARFILE}" root@${server}:/opt
    echo "Done copying."

    echo "SSH login to remote server and start a new process."
    ssh root@${server} 'bash -s' -- < ./jenkins/deploy.sh ${JARFILE} ${PORT} 2>&1
    echo "----------------------------------------------"
done


