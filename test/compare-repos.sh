#!/bin/bash

# Given two git repository folders, check that the content of each tag and
# branch in repo1 is also present in repo2.
#
# If an "offset" path is provided, the contents of repo1 will be compared with
# contents of the offset path in repo2.
#
# If an "ignore" path is provided, files in repo2 at that path will be excluded
# from any comparison.

if [ -z $1 ] || [ -z $2 ] ; then
    echo "usage: `basename $0` <repo1> <repo2> <offset> <ignore>"; exit 1;
fi

REPO1=$1
REPO2=$2
OFFSET=$3
IGNORE=$4

# Will be used as a temporary working directory
TEMP=`pwd`/temp

# Compare the file contents of the given reference in the two repositories
compareRefs() {
    REF=$1
    DESC="$REF, $REPO1/ vs $REPO2/$OFFSET"
    
    # clear temp directory where the files will be extracted
	rm -rf $TEMP
	mkdir -p $TEMP/dir1 $TEMP/dir2
	
    # extract reference files to temp dirs
	cd $REPO1
	git archive $REF | tar -x -C $TEMP/dir1
	cd $REPO2
	git archive $REF | tar -x -C $TEMP/dir2
	
	# remove files to be ignored from repo2
    if [ -n "$IGNORE" ]; then
        DESC+=", ignoring $IGNORE"
        rm -rf $TEMP/dir2/$IGNORE
    fi
	
    # will return exit code 1 and display differences if they don't match
	diff -qr $TEMP/dir1 $TEMP/dir2/$OFFSET ||
            (echo Check failed: $DESC, see errors above && exit 1)
    echo Check passed: $DESC
}


# Get the list of branches and tags from repo1
cd $REPO1
BRANCHES=`git for-each-ref --format='%(refname:short)' refs/heads/`
echo BRANCHES: "$BRANCHES"
TAGS=`git for-each-ref --format='%(refname:short)' refs/tags/`
echo TAGS: "$TAGS"

# run compare for all branches and tags
for branch in $BRANCHES; do
    compareRefs $branch
done
for tag in $TAGS; do
    compareRefs $tag
done






