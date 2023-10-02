#!/bin/bash -e
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# for a given build of quay.io/devspaces/dsc:next, extract and install for the current OS
container="quay.io/devspaces/dsc:next"
TARGETDIR=/tmp
QUIET="-q"

if [[ "$#" -le 0 ]]; then
  echo "
Usage: $0 repo/org/container@tag -t /path/to/install [-v|--verbose]
  
Example: $0 $container -t \$WORKSPACE -v
"; exit
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-t') TARGETDIR="$2"; shift 2;;
    '-v'|'--verbose') QUIET=""; shift;;
    *) container="$1"; shift;;
  esac
done

# create the install folder or die trying
mkdir -p "${TARGETDIR}" || { echo "Could not create $TARGETDIR !"; exit 1; }

if [[ $container == *"@"* ]]; then
  tmpcontainer="$(echo "$container" | tr "/:@" "--")"
else 
  tmpcontainer="$(echo "$container" | tr "/:" "--")-$(date +%s)"
fi
unpackdir="/tmp/${tmpcontainer}"

cd "$TARGETDIR" || exit
if [[ ! -f $TARGETDIR/containerExtract.sh ]]; then 
  curl -sSLko "$TARGETDIR/containerExtract.sh" https://raw.githubusercontent.com/redhat-developer/devspaces/devspaces-3-rhel-8/product/containerExtract.sh && chmod +x $TARGETDIR/containerExtract.sh
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
rm -fr "$TARGETDIR/dsc/" "$unpackdir"
# shellcheck disable=SC2086
"$TARGETDIR/containerExtract.sh" ${QUIET} --delete-before --delete-after --TARGETDIR "$unpackdir" "$container" --tar-flags dsc/*${SUFFIX} 
# shellcheck disable=SC2046
cd "$unpackdir"/ || exit
# shellcheck disable=SC2086
tar xzf dsc/devspaces-*${SUFFIX} -C $TARGETDIR
cd "$TARGETDIR" || exit 
if [[ $QUIET != "-q" ]]; then
  echo;echo "[INFO] dsc installed as $TARGETDIR/dsc/bin/dsc";echo
  "$TARGETDIR/dsc/bin/dsc" --help
fi
rm -fr "$unpackdir" "$TARGETDIR/containerExtract.sh"
