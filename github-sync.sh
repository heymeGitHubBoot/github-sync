#!/bin/sh

set -e

UPSTREAM_REPO=$1
DEST_REPO=$2
BRANCH_MAPPING=$3

if [[ -z "$UPSTREAM_REPO" ]]; then
  echo "Missing \$UPSTREAM_REPO"
  exit 1
fi

if [[ -z "$DEST_REPO" ]]; then
  echo "Missing \$DEST_REPO"
  exit 1
fi

if [[ -z "$BRANCH_MAPPING" ]]; then
  echo "Missing \$SOURCE_BRANCH:\$DESTINATION_BRANCH"
  exit 1
fi

if ! echo $UPSTREAM_REPO | grep '\.git'
then
  UPSTREAM_REPO="https://github.com/${UPSTREAM_REPO}.git"
fi

echo "UPSTREAM_REPO=$UPSTREAM_REPO"
echo "DEST_REPO=$DEST_REPO"
echo "BRANCHES=$BRANCH_MAPPING"
echo "GITHUB_ACTOR=$GITHUB_ACTOR"
echo "GITHUB_TOKEN=$GITHUB_TOKEN"
echo "GITHUB_REPOSITORY=$GITHUB_REPOSITORY"

env

# GitHub actions v2 no longer auto set GITHUB_TOKEN
#git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git config --global --add safe.directory /github/workspace
git remote set-url origin "https://$GITHUB_ACTOR:$PASSWORD@github.com/$DEST_REPO"
git remote add tmp_upstream "$UPSTREAM_REPO"
git fetch tmp_upstream
git remote --verbose
git push origin "refs/remotes/tmp_upstream/${BRANCH_MAPPING%%:*}:refs/heads/${BRANCH_MAPPING#*:}" --force
git remote rm tmp_upstream
git remote --verbose
