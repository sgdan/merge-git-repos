#!/bin/bash

# Create a mirror of the specified repository and then move its contents to a
# sub-folder, rewriting the history to make it look as if the files were always
# in that location.

if [ -z $1 ] || [ -z $2 ]; then echo "usage: `basename $0` <repo-url> <repo-dir>  <sub-directory>"; exit 1; fi
REPO_URL=$1
REPO_DIR=$2
SUB_DIR=$3

# get mirror of repository so all branches are included
git clone --bare $REPO_URL $REPO_DIR/.git
cd $REPO_DIR
git config --bool core.bare false
git checkout master

# prevent any changes going back to repository
git remote rm origin

# create move command used by filter-branch
UPDATE='GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info'
MOVE='mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"'
COMMAND="git ls-files -s | sed 's-\t\"*-&$SUB_DIR/-' | $UPDATE && $MOVE"

# rewrite history so files appear to have always been in the new location
git filter-branch --index-filter "$COMMAND" --tag-name-filter cat -- --all