#!/bin/bash
# Script for bspb-merge jenkins job - merges changes in master to all active release branches
# Job setup:
#   To fetch all remote branches, in advanced Git settings, specify Refspec: +refs/heads/*:refs/remotes/origin/*
#   Add Prune stale remote branches
#   Add Check out to specific local branch
# Real talk, think about it.

RELEASES=`git branch -r | fgrep origin/release | sed 's@ *origin/@@'`

echo "********************************"
echo "Current active release branches:"
echo "$RELEASES"
echo "********************************"

git submodule init

FAILURES=""

for RELEASE in $RELEASES; do
  echo
  echo "Merging master into $RELEASE..."

  git checkout $RELEASE && \
  git reset --hard origin/$RELEASE && \
  git submodule update && \
  git merge master --no-edit && \
  git push origin $RELEASE

  if [ $? != 0 ]; then
    FAILURES="$FAILURES
    $RELEASE"
    git reset --hard
  fi
done

if [ ! -z "$FAILURES" ]; then
  echo
  echo "*************************"
  echo "Failed to merge branches:"
  echo "$FAILURES"
  exit 1
fi
