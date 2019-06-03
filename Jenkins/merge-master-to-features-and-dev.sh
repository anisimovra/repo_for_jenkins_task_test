#!/bin/bash
# Script for bspb-merge jenkins job - merges changes in master to all active release branches
# Job setup:
#   To fetch all remote branches, in advanced Git settings, specify Refspec: +refs/heads/*:refs/remotes/origin/*
#   Add Prune stale remote branches
#   Add Check out to specific local branch

FEATURES=`git branch -r | fgrep origin/feature | sed 's@ *origin/@@'`

echo "********************************"
echo "Current active feature branches:"
echo "$FEATURES"
echo "********************************"
read -rsp $'Press enter to continue...\n'
git submodule init

FAILURES=""

for FEATURE in $FEATURES; do
  echo $FEATURE
  echo "Merging master into $FEATURE..."
  git checkout $FEATURE
  git merge master
  git commit 
  git push origin $FEATURE
done


read -rsp $'Press enter to continue...\n'