#!/bin/sh
# A script to use with GIT_ASKPASS in Jenkins
# To make it work, in your job config:
# 1. Enable Use secret text(s) or file(s)
# 2. Add Binding for Username and password (separated)
# 3. Specify GIT_USER and GIT_PASSWORD as variable names

call-ssh-agent
case $1 in
 Username*) echo $GIT_USER;;
 Password*) echo $GIT_PASSWORD;;
esac

# Let's use this row for change
