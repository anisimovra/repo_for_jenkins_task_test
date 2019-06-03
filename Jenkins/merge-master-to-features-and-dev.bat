
echo "********************************"
echo "Update develop branch"
echo "********************************"

	git checkout --track origin/develop
	git pull .
	git merge origin/master
	git push origin develop

pause



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
  git push origin $FEATURE
done


read -rsp $'Press enter to continue...\n'