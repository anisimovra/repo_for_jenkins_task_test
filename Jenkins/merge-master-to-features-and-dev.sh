
cd "E:\Anisimovra\workspace\repo_for_jenkins_task_test"

echo "********************************"
echo "Update develop branch"
echo "********************************"
	
	git checkout --track origin/develop 
	git pull .
	git merge master
	git push develop

read -rsp $'Press enter to continue...\n'


FEATURES=`git branch -r | fgrep origin/feature | sed 's@ *origin/@@'`

echo "********************************"
echo "Current active feature branches:"
echo "$FEATURES"
echo "********************************"
git submodule init

FAILURES=""

for FEATURE in $FEATURES; do
  echo $FEATURE
  echo "Merging master into $FEATURE..."
  git checkout $FEATURE && \
  git reset --hard origin/$FEATURE && \
  git submodule update && \
  git merge master --no-edit && \
  git push origin $FEATURE
done

if [ ! -z "$FAILURES" ]; then
  echo
  echo "*************************"
  echo "Failed to merge branches:"
  echo "$FAILURES"
fi

read -rsp $'Press enter to continue...\n'