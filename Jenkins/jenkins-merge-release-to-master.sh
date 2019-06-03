#!/usr/bin/env bash
# New row on this reppo
cd `dirname $0`

JSON=`curl -s https://i.bspb.ru/version.json || exit $?`
BRANCH=`echo "$JSON" | jq -r .branch`
START_TIME=`echo "$JSON" | jq -r .startTime`

STARTED_SEC_AGO=$(expr `date +%s` - `date -d "$START_TIME" +%s`)

if [ $STARTED_SEC_AGO -ge 3600 ]; then
  echo "$BRANCH started in prod more than 1 hour ago"
  git tag | fgrep -q $BRANCH
  if [ $? != 0 ]; then
    echo "Trying to merge $BRANCH to master..."
    git checkout $BRANCH
    ./merge-to-master-after-release.sh
  else
    echo "$BRANCH is already a tag, skipping"
  fi
else
  echo "$BRANCH started less than 1 hour ago, not merging"
fi
