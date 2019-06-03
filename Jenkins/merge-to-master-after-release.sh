#!/bin/bash
# Changes in master branch
set -e

BRANCH=`git rev-parse --abbrev-ref HEAD`

if [[ $BRANCH != release-* ]]; then
  echo "Current branch is not a release" && exit 1
fi

git pull origin $BRANCH
git tag $BRANCH

git checkout master
git pull origin master
git tag before-$BRANCH

git merge $BRANCH --no-edit
git push origin master

git branch -d $BRANCH
git push origin --delete $BRANCH
git push --tags

echo "" | mail -r bspb@codeborne.com -s "FYI: Merged $BRANCH to master" OTPP_AUTO@bspb.ru
