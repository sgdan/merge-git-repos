#!/bin/bash

# Given src and dst local repository folders, merge src into dst and push
# updated branches and tags to remote origin of dst.

if [ -z $1 ] || [ -z $2 ]; then echo "usage: `basename $0` <src> <dst>"; exit 1; fi

HOME=`pwd`
SRC_DIR=$HOME/$1
DST_DIR=$HOME/$2
SRC=`basename $1`
DST=`basename $2`

echo SRC: $SRC
echo DST: $DST
echo SRC_DIR: $SRC_DIR
echo DST_DIR: $DST_DIR

# Get lists of branches and tags from src repo
cd $SRC_DIR
BRANCHES=`git for-each-ref --format='%(refname:short)' refs/heads/`
echo BRANCHES: "$BRANCHES"
TAGS=`git for-each-ref --format='%(refname:short)' refs/tags/`
echo TAGS: "$TAGS"

# fetch commits and branch info from src repo
cd $DST_DIR
git remote add $SRC $SRC_DIR
git fetch --all

# merge branches
for branch in $BRANCHES; do
    echo Merging branch: $branch
    if [ "$branch" == "master" ]; then
        git checkout master
    elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        # branch already exists in origin 
        git checkout -b $branch remotes/origin/$branch
    else
        # branch only exists in src
        git checkout -b $branch remotes/$SRC/$branch
    fi
    git merge remotes/$SRC/$branch -m "Merging $SRC/$branch into $DST/$branch"
done

# push merged branches
git push --all origin

# merge tags, push individually
git fetch $SRC +refs/tags/*:refs/rtags/$SRC/*
for tag in $TAGS; do
    echo Merging tag $tag
    git checkout refs/rtags/$SRC/$tag
    if git show-ref --verify --quiet "refs/tags/$tag"; then 
        # tag already exists in dst
        git merge --no-edit tags/$tag
    fi
    git tag -a --force $tag -m "Merged tag $tag from $SRC into $DST"
    git push --force origin tags/$tag
done
