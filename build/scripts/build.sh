#!/bin/bash
#
# Copyright (c) 2021-2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#
# script to build 1 or two versions of dsc (RH and Quay flavours), then optionally:
# * push artifacts to github
# * push artifacts to spmm-util (GA only)

set -e

# today's date in yyyy-mm-dd format to use to ensure each GA push is a unique folder
today=$(date +%Y-%m-%d)

# defaults
platforms="linux-x64,darwin-x64,darwin-arm64,win32-x64"
versionSuffix=""

# five steps
DO_SYNC=1
DO_REDHAT_BUILD=1
CACHEFLAG="--no-cache" # always build a fresh container; use --cache flag to null this string
PUBLISH_TO_GITHUB=0
PUBLISH_TO_QUAY=0
PUBLISH=0 # by default don't publish sources to spmm-util
REMOTE_USER_AND_HOST="devspaces-build@spmm-util.hosts.stage.psi.bos.redhat.com"

MIDSTM_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_TAG=${MIDSTM_BRANCH#*-}; DEFAULT_TAG=${DEFAULT_TAG%%-*}
if [[ $DEFAULT_TAG == "3" ]]; then DEFAULT_TAG="3.yy"; fi

if [[ ! ${WORKSPACE} ]] || [[ ! -d ${WORKSPACE} ]]; then WORKSPACE=/tmp; fi

# default value for Jenkins builds
if [[ -d ${WORKSPACE}/sources ]]; then
    SOURCE_DIR=${WORKSPACE}/sources # path to where chectl is checked out
fi
if [[ -d "${WORKSPACE}/devspaces-images" ]]; then
    DSIMG_DIR="${WORKSPACE}/devspaces-images"
fi
if [[ -d "${WORKSPACE}/devspaces-chectl" ]]; then
    DSC_DIR="${WORKSPACE}/devspaces-chectl"
else
    DSC_DIR=$(pwd)
fi

usageSegKey() {
    echo 'Setup:

First, export your segment write key to inject it into src/hooks/analytics/analytics.ts

  export SEGMENT_WRITE_KEY="...segment-write-key..."

If pushing to Github, export your GITHUB_TOKEN:

  export GITHUB_TOKEN="...github-token..."
'
    usage
}
usage () {
    echo "Usage:

  $0 -v 3.yy.z -b MIDSTM_BRANCH -s /path/to/chectl -i /path/to/devspaces-images/ [-t /path/to/dsc/]  [--suffix RC_or_GA]

Example:

  $0 -v ${DEFAULT_TAG}.0 -b ${MIDSTM_BRANCH} -s /path/to/chectl/ -i /path/to/devspaces-images/ -t ${DSC_DIR} --suffix RC

Options:
    --suffix [RC or GA]       optionally, build an RC (copy to quay) or GA (copy to quay and spmm-util)
    --ds-version ${DEFAULT_TAG}         compute from MIDSTM_BRANCH if not set
    --quay                    publish containers to quay  
    --publish                 publish GA tarballs for a release to $REMOTE_USER_AND_HOST
    --cache                   use local podman layer cache for a faster build
    --desthost user@desthost  specific an alternate destination host for publishing
"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-v') CSV_VERSION="$2"; shift 1;;
    '-b'|'--ds-branch') MIDSTM_BRANCH="$2"; shift 1;; # branch of redhat-developer/devspaces/pom.xml to check as default CHE_VERSION
    # paths to use for input and ouput
    '-s') SOURCE_DIR="$2"; SOURCE_DIR="${SOURCE_DIR%/}"; shift 1;;
    '-t') DSC_DIR="$2"; DSC_DIR="${DSC_DIR%/}"; shift 1;;
    '-i') DSIMG_DIR="$2"; DSIMG_DIR="${DSIMG_DIR%/}"; shift 1;;
    '--help'|'-h') usageSegKey;;
    # optional tag overrides
    '--suffix') versionSuffix="$2"; shift 1;;
    '--ds-version') DS_VERSION="$2"; DEFAULT_TAG="$2"; shift 1;;
    '--gh') PUBLISH_TO_GITHUB=1;;
    '--quay') PUBLISH_TO_QUAY=1;;
    '--publish') PUBLISH=1;;
    '--desthost') REMOTE_USER_AND_HOST="$2"; shift 1;;
    '--no-sync') DO_SYNC=0;;
    '--no-redhat') DO_REDHAT_BUILD=0;;
    '--cache') CACHEFLAG="";;
  esac
  shift 1
done

if [[ ! "${SEGMENT_WRITE_KEY}" ]]; then usageSegKey; fi
if [[ $PUBLISH_TO_GITHUB -eq 1 ]] && [[ ! "${GITHUB_TOKEN}" ]]; then usageSegKey; fi
if [[ ! -d "${SOURCE_DIR}" ]] || [[ ! -d "${DSC_DIR}" ]] || [[ ! -d "${DSIMG_DIR}" ]]; then usage; fi
if [[ ${DSC_DIR} == "." ]]; then usage; fi
if [[ ! ${DS_VERSION} ]]; then DS_VERSION="${CSV_VERSION%.*}"; fi
if [[ ! ${CSV_VERSION} ]]; then usage; fi

# compute branch from already-checked out sources dir
SOURCE_BRANCH=$(cd "$SOURCE_DIR"; git rev-parse --abbrev-ref HEAD)

###############################################################

pushd $DSC_DIR >/dev/null

CURRENT_DAY=$(date +'%Y%m%d-%H%M')
SHORT_SHA1=$(git rev-parse --short=4 HEAD)

# for RC and CI, prerelease=true
PRE_RELEASE="--prerelease"
VERSION_SUFFIX="CI"
DSC_TAG="${CSV_VERSION}-$CURRENT_DAY-${SHORT_SHA1}"
if [[ "${versionSuffix}" ]]; then
    VERSION_SUFFIX="${versionSuffix}"
    DSC_TAG="${CSV_VERSION}-${versionSuffix}-${SHORT_SHA1}"
fi

# RENAME artifacts to include version in the tarball: devspaces-3.10.0-dsc-*.tar.gz
# do not include SHA1 so that the tar can be used in QE CI processes without wildcard
TARBALL_PREFIX="devspaces-${CSV_VERSION}"
TODAY_DIR="${WORKSPACE}/${TARBALL_PREFIX}.${today}"

# set prerelease=false for GA
if [[ $versionSuffix == "GA" ]]; then
    DSC_TAG="${CSV_VERSION}-${versionSuffix}"
    PRE_RELEASE="--release" # not a --prerelease
fi

popd >/dev/null

set -x

if [[ $DO_SYNC -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 1. Sync from upstream chectl"
    ########################################################################
    # CRW-1579 change yamls to use :3.y tag, not :latest or :next - use that only for quay version of dsc
    pushd ${DSIMG_DIR} >/dev/null
        FILES="devspaces-operator/config/manager/manager.yaml devspaces-operator-bundle/manifests/devspaces.csv.yaml"
        for d in ${FILES}; do
            sed -i ${d} -r -e "s#registry.redhat.io/devspaces/(.+):(.+)#registry.redhat.io/devspaces/\1:${DS_VERSION}#g"
        done
    popd >/dev/null

    pushd $DSC_DIR >/dev/null
        ./build/scripts/sync.sh -b ${MIDSTM_BRANCH} -s ${SOURCE_DIR} -t ${DSC_DIR} \
            --ds-version ${DS_VERSION}
        # commit changes
        set -x
        git add .
        git commit -s -m "ci: [sync] Push chectl @ ${SOURCE_BRANCH} to devspaces-chectl @ ${MIDSTM_BRANCH}" . || true
        git push origin ${MIDSTM_BRANCH} || true
    popd >/dev/null
fi

if [[ $DO_REDHAT_BUILD -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 2. Build dsc using -redhat suffix and registry.redhat.io/devspaces/ URLs"
    ########################################################################
    pushd $DSC_DIR >/dev/null
        # clean up from previous build if applicable
        jq -M --arg DSC_TAG "${DSC_TAG}-redhat" '.version = $DSC_TAG' package.json > package.json2; mv -f package.json2 package.json

        podman rmi quay.io/devspaces/dsc:${CSV_VERSION} -f
        podman build . -t quay.io/devspaces/dsc:${CSV_VERSION} -f build/dockerfiles/Dockerfile $CACHEFLAG \
            --build-arg SEGMENT_WRITE_KEY=${SEGMENT_WRITE_KEY} \
            --build-arg CSV_VERSION=${CSV_VERSION} \
            --build=arg DSC_PLATFORMS=${platforms}
        ./build/scripts/installDscFromContainer.sh quay.io/devspaces/dsc:${CSV_VERSION} -v
        cp /tmp/dsc/package.json /tmp/dsc/README.md /tmp/dsc/yarn.lock .
        git diff -u
        git tag -f "${DSC_TAG}-redhat"
        git commit -s -m "ci: [update] package.json, yarn.lock + README.md" package.json yarn.lock README.md || true
        git push origin ${MIDSTM_BRANCH} || true
    popd >/dev/null
fi

if [[ $PUBLISH_TO_QUAY -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 4. Publish container with tarballs and sources to Quay"
    ########################################################################
    # copy container to quay
    skopeo --insecure-policy copy --all docker://quay.io/devspaces/dsc:next docker://quay.io/devspaces/dsc:${DSC_TAG}
    skopeo --insecure-policy copy --all docker://quay.io/devspaces/dsc:next docker://quay.io/devspaces/dsc:${DS_VERSION}
    if [[ $MIDSTM_BRANCH == "devspaces-3-rhel-8" ]]; then
        skopeo --insecure-policy copy --all docker://quay.io/devspaces/dsc:next docker://quay.io/devspaces/dsc:next
    elif [[ $MIDSTM_BRANCH == "devspaces-3."*"-rhel-8" ]]; then
        skopeo --insecure-policy copy --all docker://quay.io/devspaces/dsc:next docker://quay.io/devspaces/dsc:latest
    fi
fi

# deprecated
if [[ $PUBLISH_TO_GITHUB -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 4b. Publish tarballs to GH"
    ########################################################################

    # requires hub cli
    if [[ ! -x /tmp/uploadAssetsToGHRelease.sh ]]; then
        pushd /tmp/ >/dev/null
        curl -sSLO "https://raw.githubusercontent.com/redhat-developer/devspaces/${MIDSTM_BRANCH}/product/uploadAssetsToGHRelease.sh" && \
        chmod +x uploadAssetsToGHRelease.sh
        popd >/dev/null
    fi

    # delete existing CI pre-release and replace it, so timestamp is fresh
    if [[ "${VERSION_SUFFIX}" == "CI" ]] || [[ $PRE_RELEASE == "--prerelease" ]]; then # CI build
        /tmp/uploadAssetsToGHRelease.sh ${PRE_RELEASE} --delete-assets -b "${MIDSTM_BRANCH}" -v "${CSV_VERSION}-${VERSION_SUFFIX}" --asset-name "dsc"
    fi

    # in case API is running slow, sleep for a bit before trying to push files into the freshly created release
    sleep 10s

    # upload artifacts for each platform + sources tarball
    countToUpload=0
    for channel in quay redhat; do
        if [[ -d "${DSC_DIR}/dist/channels/${channel}/" ]]; then
            pushd "${DSC_DIR}/dist/channels/${channel}/" || exit 1
                echo "[INFO] Publish $channel assets to ${CSV_VERSION}-${VERSION_SUFFIX}-dsc-assets GH release"
                /tmp/uploadAssetsToGHRelease.sh ${PRE_RELEASE} --publish-assets -b "${MIDSTM_BRANCH}" -v "${CSV_VERSION}-${VERSION_SUFFIX}" --asset-name "dsc" "devspaces-*tar.gz" --asset-type "Installer binaries and sources"
            popd >/dev/null || exit 1
            channelFiles=$(find "${DSC_DIR}/dist/channels/${channel}/" -name "devspaces-*tar.gz" | wc -l)
            countToUpload=$(( countToUpload + channelFiles ))
            # check if upload was successful by checking the release for the same # of assets
            assetsUploaded=$(cd "${DSC_DIR}/dist/channels/${channel}/"; hub release show ${CSV_VERSION}-${VERSION_SUFFIX}-dsc-assets -f %as; echo)
            countAssetsUploaded=$(echo "$assetsUploaded" | wc -l)
            echo "[INFO] Published assets: https://github.com/redhat-developer/devspaces-chectl/releases/tag/${CSV_VERSION}-${VERSION_SUFFIX}-dsc-assets"
            if [[ $countToUpload -ne $countAssetsUploaded ]]; then
                echo " + Assets to upload: $countToUpload"
                echo " - Assets uploaded:  $countAssetsUploaded"
                echo "=====================================================>"
                echo "$assetsUploaded"
                echo "<====================================================="
                exit 1
            fi
        fi
    done

    # cleanup
    rm -f /tmp/uploadAssetsToGHRelease.sh

    echo "[INFO] Refresh GH pages"
    pushd ${DSC_DIR} >/dev/null
        git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/devspaces-chectl -b gh-pages --single-branch gh-pages && cd gh-pages
        echo $(date +%s) > update && git add update && git commit -m "ci: [update] add $RELEASE_ID to github pages" && git push origin gh-pages
    popd >/dev/null
fi

# optionally, push files to spmm-util server as part of a GA release
if [[ $PUBLISH -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 5. Publish tarballs to spmm-util and stage MW release (for GA builds)"
    ########################################################################

    set -x
    # create an empty dir into which we will make subfolders
    empty_dir=$(mktemp -d)

    # delete old releases before pushing latest one, to keep disk usage low: DO NOT delete 'build-requirements' folder as we use that for storing binaries we can't yet build ourselves in OSBS
    # note that this operation will only REMOVE old versions
    rsync -rlP --delete --exclude=build-requirements --exclude="${TARBALL_PREFIX}.${today}" "$empty_dir"/ "${REMOTE_USER_AND_HOST}:staging/devspaces/"

    # move files we want to rsync into the correct folder name
    mkdir -p "${TODAY_DIR}/"
    mv "${DSC_DIR}"/dist/channels/redhat/*gz "${TODAY_DIR}/"

    # next, update existing ${TARBALL_PREFIX}.${today} folder (or create it not exist)
    rsync -rlP --exclude "dsc*.tar.gz" --exclude "*-quay-*.tar.gz" "${TODAY_DIR}" "${REMOTE_USER_AND_HOST}:staging/devspaces/"

    # trigger staging 
    ssh "${REMOTE_USER_AND_HOST}" "stage-mw-release ${TARBALL_PREFIX}.${today}"

    # cleanup 
    rm -fr "$empty_dir"
    set +x
fi
