#!/bin/bash -e
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# for a given build of localhost/dsc:next, extract and install for the current OS
container="localhost/dsc:next"
QUIET="-q"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-v') QUIET="";;
    *) container="$1";;
  esac
  shift 1
done

TMPDIR="/tmp"
if [[ $container == *"@"* ]]; then
  tmpcontainer="$(echo "$container" | tr "/:@" "--")"
else 
  tmpcontainer="$(echo "$container" | tr "/:" "--")-$(date +%s)"
fi
unpackdir="$TMPDIR/${tmpcontainer}"

cd $TMPDIR || exit
if [[ ! -f $TMPDIR/containerExtract.sh ]]; then 
  curl -sSLko $TMPDIR/containerExtract.sh https://raw.githubusercontent.com/redhat-developer/devspaces/devspaces-3-rhel-8/product/containerExtract.sh && chmod +x $TMPDIR/containerExtract.sh
fi
UNAME=$(uname)
UNAMEM=$(uname -m)
if [[ $UNAME == "Linux" ]]; then
  if [[ $UNAMEM == "x86_64" ]] || [[ $UNAMEM == "amd64" ]]; then 
    SUFFIX=linux-x64.tar.gz
  fi
elif [[ $UNAME == "Darwin" ]]; then
  if [[ $UNAMEM == "x86_64" ]] || [[ $UNAMEM == "amd64" ]]; then 
    SUFFIX=darwin-x64.tar.gz
  elif [[ $UNAMEM == "aarch64" ]] || [[ $UNAMEM == "arm64" ]]; then
    SUFFIX=darwin-arm64.tar.gz
  fi
else
  SUFFIX=win32-x64.tar.gz
fi
rm -fr $TMPDIR/dsc/ "$unpackdir"
/tmp/containerExtract.sh ${QUIET} "$container" --tar-flags dsc/*${SUFFIX}
cd "$unpackdir" || exit
# shellcheck disable=SC2086
tar xzf dsc/dsc-*${SUFFIX} -C $TMPDIR
cd $TMPDIR || exit 
echo;echo "[INFO] dsc installed as $TMPDIR/dsc/bin/dsc";echo
$TMPDIR/dsc/bin/dsc --help
rm -fr "$unpackdir"
