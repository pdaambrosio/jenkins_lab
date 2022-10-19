#!/bin/bash

path="/var/lib/docker/volumes/jenkins_backup/_data/"
backup_file=$(ls /var/lib/docker/volumes/jenkins_backup/_data/ |egrep "^FULL-2022")
config_jenkins="config_jenkins"

# Copy config files
cp -rf $path/$backup_file .

# Delete old config files
if [ -d $backup_file ]; then
    rm -rf $config_jenkins
fi

# Rename config files
mv $backup_file $config_jenkins

# Set user
chown -R $USER: $config_jenkins