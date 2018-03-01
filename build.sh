#!/usr/bin/env sh
set -e

# Generate a build UUID
UUID=$(cat /proc/sys/kernel/random/uuid)

# How many builds do we keep in the history volume, defaults to 3
if [ -z "$KEEP_HISTORY" ]; then
  KEEP_HISTORY=3
fi

# What branch do we build (defaults to "master")
if [ -z "$GIT_BRANCH" ]; then
  GIT_BRANCH="master"
fi

# The history folder
HISTORY_FOLDER=$PWD/history

# Make sure the private key is secure
# (Should be the responsibility of the mounting config, but just in case)
if [ ! -e /root/.ssh/id_rsa ]; then
  echo $SSH_KEY > /root/.ssh/id_rsa
fi
chmod 700 /root/.ssh/id_rsa

# Go to the project folder
cd project

# If we have a history volume mounted, we copy the last build
if [ -d $HISTORY_FOLDER ] && [ -e $HISTORY_FOLDER/latest ]; then
  echo "History folder found, reusing latest build folder"
  PREVIOUS_BUILD=`realpath $HISTORY_FOLDER/latest`
  cp -r $HISTORY_FOLDER/latest/ app
else
  # If we don't have history, we clone for the first time
  echo "No history folder found, cloning the repository"
  git clone $GIT_REPO app
fi

#
cd app
echo "Updating folder, using branch $GIT_BRANCH"
git remote update
git fetch
git checkout $GIT_BRANCH
git reset --hard origin/$GIT_BRANCH

# login to the private registry
if [ ! -z "$DOCKER_USER" ]; then
  echo "Logging in to docker registry $DOCKER_REGISTRY, using user $DOCKER_USER"
  docker -D login -u $DOCKER_USER -p $DOCKER_PWD $DOCKER_REGISTRY
fi

# Die handler
die () {
  echo "$0: $@" >&2
  exit 1;
}

# Build!
echo "Starting the build. Make target $MAKE_TARGET"
make $MAKE_TARGET | tee make.log || die "'make $MAKE_TARGET' failed"

echo "Make finished"

# If we have a history volume mounted, we save this successfull build
if [ -d $HISTORY_FOLDER ]; then
  echo "Backing up the build folder"
  cd ..
  cp -r app $HISTORY_FOLDER/$UUID
  ln -sf $HISTORY_FOLDER/$UUID $HISTORY_FOLDER/latest
fi

# We check if we have too many builds in history
HISTORY_COUNT=$(ls -1t $HISTORY_FOLDER | grep -v latest | wc -l)
if [[ $HISTORY_COUNT -gt $KEEP_HISTORY ]]; then
  echo "Keeping only $KEEP_HISTORY builds, cleaning old ones..."
  ls -1tr $HISTORY_FOLDER | grep -v latest | head -n -$KEEP_HISTORY | while IFS= read -r f; do
    rm -rf "$f"
  done
fi

echo "Builder is done... bye!"

# Used to notify the sidecars container we are done
touch /builder/project/build.terminated
