#!/bin/bash

# Create test repositories, then run merge scripts and test results
set -e
rm -rf work
mkdir work
WORK=`pwd`/work
cd $WORK

# Create a repository for test purposes
createRepo() {
    mkdir $1-create
    cd $1-create
    git init
    echo "one" > one.txt
    git add one.txt
    git commit -m "Added one"
    
    # add repo-only branch and tag
    git checkout -b $1-only-branch
    echo "two" > two.txt
    git add two.txt
    git commit -m "Added two ($1 only)"
    git tag -a $1-only-tag -m "Tagging $1 only branch"
    echo "more" >> two.txt
    git add two.txt
    git commit -m "Added more to two"
    
    # add common branch and tag
    git checkout -b common-branch master
    mkdir folder
    echo "three" > folder/three.txt
    git add folder/three.txt
    git commit -m "Added three (common)"
    git tag -a common-tag -m "Tagging common branch"
    echo "more" >> folder/three.txt
    git add folder/three.txt
    git commit -m "Added more to three"
    
    # change master
    git checkout master
    echo "more" >> one.txt
    git add one.txt
    git commit -m "Added more to one"
    cd ..
    
    # now turn it into a bare repo to mimic a remote repo
    git clone --bare $1-create $1/.git
    cd $1
    git remote rm origin
    cd ..
    rm -rf $1-create
}

# Create repositories called "dst" and "src" that will be used to test merging.
# Aim is for "src" contents to be merged into a sub-folder of "dst" with all
# file history included. Any branches and tags will be merged too.
createRepo src
createRepo dst

# Create copy of dst to check against afterwards
cp -r dst dst-original

# Run script to move repo contents to subfolder (creates src-mirror repo)
bash -e ../../move-to-subfolder.sh $WORK/src $WORK/src-mirror path/to/files

# Check the resulting repo against the original
bash -e ../compare-repos.sh $WORK/src $WORK/src-mirror path/to/files ""

# Clone dst to mimic local clone of remote repo
git clone dst dst-clone

# Run script to merge src-mirror repo into dst-clone
bash -e ../../merge.sh src-mirror dst-clone

# Check that contents of src repo are in dst
bash -e ../compare-repos.sh $WORK/src $WORK/dst path/to/files

# Check that the updated dst still includes content from dst-original
bash -e ../compare-repos.sh $WORK/dst-original $WORK/dst "" path

