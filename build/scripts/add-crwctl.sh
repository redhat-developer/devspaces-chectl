#!/bin/bash

# add crwctl binary to dsc tarballs
# run as ./build/scripts/add-crwctl.sh
WORKSPACE=`pwd`

TMPDIR=`mktemp -d`
mkdir -p $TMPDIR/dsc/bin
cp crwctl $TMPDIR/dsc/bin/
cd $TMPDIR

for gz in $(find $WORKSPACE/dist/channels/*/ -name "devspaces-*.gz" | grep -v "sources"); do
    echo "Add crwctl binary to $gz"
    tar=${gz/.gz/} # echo "tar: $tar"
    # unpack, add file, repack
    gunzip $gz
    tar rf $tar dsc/bin/crwctl
    gzip $tar
    # verify added
    tar tvzf $gz | grep dsc/bin/crwctl
done

rm -fr $TMPDIR
