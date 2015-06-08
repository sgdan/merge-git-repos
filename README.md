# Merge Git Repositories #

Here are some scripts I'm testing out for merging one git repository into a
sub-folder of another root repository. I'm trying to find a way to reliably
merge a maven sub-project repository into a sub-folder of its parent repository.

Assumptions:

* Sub repo will be merged into root repo
* Sub repo will be discarded afterwards
* Existing sub and root contain some common branch and tag names

Goals:

* Preserve file history
* Preserve branches and tags, merge where names are the same

Code based on https://gofore.com/ohjelmistokehitys/merge-multiple-git-repositories-one-retaining-history/

Tested scripts on debian:jessie with Git version 2.1.4

* See [test/test.sh](test/test.sh) for simple test merge