#!/bin/sh

REPOSITORY="https://github.com/Open-Web-Analytics/Open-Web-Analytics.git"
TEMP_DIR="./build/"
DESTINATION_DIR="."
TARBALL_PREFIX="owa"
#TAR_VERSION="1_0_0"
#TAG="1.0"

case $1 in
        -t) REPOS_PATH="/tags/"
            VERSION="$2" ;;

        *) echo Unknown Argument
           exit 1;;
esac

echo Prepaing to package  ${VERSION} branch from Git...

echo Cloning repo
git clone ${REPOSITORY} ${TEMP_DIR}

echo Checking out master branch...
git -C ${TEMP_DIR} checkout master

echo Pulling changes for origin...
git -C ${TEMP_DIR} pull

echo Creating release-${VERSION} branch
git -C ${TEMP_DIR} checkout -b release-${VERSION}

echo Merging master into release branch...
#git -C ${TEMP_DIR} merge master

echo changing version string in owa_env.php
sed -i "" "s/master/${VERSION}/g" ${TEMP_DIR}owa_env.php
sed -i "" "s/master/${VERSION}/" ${TEMP_DIR}wp_plugin.php
echo Committing local changes
git -C ${TEMP_DIR} status
git -C ${TEMP_DIR} add owa_env.php
git -C ${TEMP_DIR} add wp_plugin.php
git -C ${TEMP_DIR} commit -m "Updating version string."
echo Pushing change into Branch
git -C ${TEMP_DIR} push --set-upstream origin release-${VERSION}

echo Running composer to fetch dependancies...
composer install -d ${TEMP_DIR} --no-dev --optimize-autoloader --prefer-dist --no-interaction

echo Creating Tarball...
#chmod -R 750 ${TEMP_DIR}
#find "${TEMP_DIR}" -type d -print0 | xargs -0 chmod 751
#find "${TEMP_DIR}" -type f -print0 | xargs -0 chmod 644
#find "${TEMP_DIR}" -iname "*.php" -print0 | xargs -0 chmod 600

tar --directory ${TEMP_DIR} --exclude='./.gitignore' --exclude='./.github' --exclude='./.git' -pcvf ./${TARBALL_PREFIX}_${VERSION}_packaged.tar ./
echo tarball created.
echo Switching back to the master branch.
git -C ${TEMP_DIR} checkout master
echo Cleaning up local release branch
git -C ${TEMP_DIR} branch -d release-${VERSION}

echo Deployment Complete.
