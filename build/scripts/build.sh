#!/bin/bash
#
# Copyright (c) 2021-2022 Red Hat, Inc.
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
# * push artifacts to github (GA only)
# * push artifacts to rcm-guest (GA only)

set -e

# defaults
platforms="linux-x64,darwin-x64,darwin-arm64,win32-x64"
versionSuffix=""

# five steps
DO_SYNC=1
DO_REDHAT_BUILD=1
DO_QUAY_BUILD=1
PUBLISH_ARTIFACTS_TO_GITHUB=0
PUBLISH_ARTIFACTS_TO_RCM=0

# for publishing to RCM only
RCMGHOST="rcm-guest.hosts.prod.psi.bos.redhat.com"
DESTHOST="devspaces-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@${RCMGHOST}"
KERBEROS_USER="devspaces-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@REDHAT.COM"

MIDSTM_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_TAG=${MIDSTM_BRANCH#*-}; DEFAULT_TAG=${DEFAULT_TAG%%-*}
if [[ $DEFAULT_TAG == "2" ]]; then latestNext="next"; else latestNext="latest"; fi

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
    DSC_DIR=`pwd`
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

  $0 -v ${DEFAULT_TAG}.0 -b ${MIDSTM_BRANCH} -s /path/to/chectl/ -i /path/to/devspaces-images/ -t ${DSC_DIR} --suffix RC"
	echo ""
	echo "Options:
    --suffix [RC or GA]  optionally, build an RC (copy to quay) or GA (copy to quay and RCM guest)
    --crw-version ${DEFAULT_TAG}   compute from MIDSTM_BRANCH if not set
	"
	exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
	'-v') CSV_VERSION="$2"; shift 1;;
    '-b'|'--crw-branch') MIDSTM_BRANCH="$2"; shift 1;; # branch of redhat-developer/devspaces/pom.xml to check as default CHE_VERSION
	# paths to use for input and ouput
	'-s') SOURCE_DIR="$2"; SOURCE_DIR="${SOURCE_DIR%/}"; shift 1;;
	'-t') DSC_DIR="$2"; DSC_DIR="${DSC_DIR%/}"; shift 1;;
	'-i') DSIMG_DIR="$2"; DSIMG_DIR="${DSIMG_DIR%/}"; shift 1;;
	'--help'|'-h') usageSegKey;;
	# optional tag overrides
    '--suffix') versionSuffix="$2"; shift 1;;
	'--crw-version') DS_VERSION="$2"; DEFAULT_TAG="$2"; shift 1;;
    '--gh') PUBLISH_ARTIFACTS_TO_GITHUB=1;;
    '--rcm') PUBLISH_ARTIFACTS_TO_RCM=1;;
    '--desthost') DESTHOST="$2"; shift 1;;
    '--kerbuser') KERBEROS_USER="$2"; shift 1;;
    '--no-sync') DO_SYNC=0;;
    '--no-redhat') DO_REDHAT_BUILD=0;;
    '--no-quay') DO_QUAY_BUILD=0;;
  esac
  shift 1
done

if [[ ! "${SEGMENT_WRITE_KEY}" ]]; then usageSegKey; fi
if [[ $PUBLISH_ARTIFACTS_TO_GITHUB -eq 1 ]] && [[ ! "${GITHUB_TOKEN}" ]]; then usageSegKey; fi
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

# RENAME artifacts to include version in the tarball: devspaces-3.0.0-dsc-*.tar.gz
# do not include SHA1 so that the tar can be used in QE CI processes without wildcard
TARBALL_PREFIX="devspaces-${CSV_VERSION}"

# compute latest tags for server and operator from quay; also set prerelease=false for GA
repoFlag="--quay"
repoOrg="devspaces"
if [[ $versionSuffix == "GA" ]]; then
    DSC_TAG="${CSV_VERSION}-${versionSuffix}"
    repoFlag="--stage"
    repoOrg="devspaces"
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
            --crw-version ${DS_VERSION}
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
        git diff -u package.json
        git tag -f "${DSC_TAG}-redhat"
        rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo dist/
        echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts (redhat version)"
        sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts
        yarn && npx oclif-dev pack -t ${platforms}
        mv dist/channels/*redhat dist/channels/redhat
        # copy from generic name specific name, so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
        while IFS= read -r -d '' d; do
            e=${d/redhat\/dsc/redhat\/${TARBALL_PREFIX}-dsc}
            cp ${d} ${e}
        done <   <(find dist/channels/redhat -type f -name "*gz" -print0)

        # purge generated binaries and temp files
        rm -fr coverage/ lib/ node_modules/ templates/ tmp/

        # create sources tarball in the same dir where we have the per-arch binaries
        tar czf /tmp/${TARBALL_PREFIX}-dsc-sources.tar.gz --exclude=./dist/channels/*/* ./* && \
        mv /tmp/${TARBALL_PREFIX}-dsc-sources.tar.gz ${DSC_DIR}/dist/channels/redhat/

        pwd; du ./dist/channels/*/*gz

        git commit -s -m "ci: [update] package.json + README.md" package.json README.md || true
        git push origin ${MIDSTM_BRANCH} || true
    popd >/dev/null
fi

if [[ $DO_QUAY_BUILD -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 3a. Prepare ${MIDSTM_BRANCH}-quay branch of devspaces operator repo"
    ########################################################################
    # check out from MIDSTM_BRANCH
    pushd ${DSIMG_DIR} >/dev/null
        git branch ${MIDSTM_BRANCH}-quay -f
        git checkout ${MIDSTM_BRANCH}-quay
        # CRW-1579 change yamls to use quay image, and :latest or :next
        # do not use :3.y to allow stable builds to be auto-updated via dsc on ocp3.11 - :latest tag triggers always-update (?)
        FILES="devspaces-operator/config/manager/manager.yaml devspaces-operator-bundle/manifests/devspaces.csv.yaml"
        for d in ${FILES}; do
            sed -i ${d} -r -e "s#registry.redhat.io/devspaces/(.+):(.+)#quay.io/devspaces/\1:${latestNext}#g"
        done

        # push to ${MIDSTM_BRANCH}-quay branch
        git commit -s -m "ci: [update] Push ${MIDSTM_BRANCH} to ${MIDSTM_BRANCH}-quay branch" ${FILES}
        git push origin ${MIDSTM_BRANCH}-quay -f
    popd >/dev/null

    ########################################################################
    echo "[INFO] 3b. Build dsc using ${MIDSTM_BRANCH}-quay branch, -quay suffix and quay.io/devspaces/ URLs"
    ########################################################################
    pushd ${DSC_DIR} >/dev/null
        YAML_REPO="`cat package.json | jq -r '.dependencies["devspaces-operator"]'`-quay"
        jq -M --arg YAML_REPO "${YAML_REPO}" '.dependencies["devspaces-operator"] = $YAML_REPO' package.json > package.json2
        jq -M --arg DSC_TAG "${DSC_TAG}-quay" '.version = $DSC_TAG' package.json2 > package.json
        rm -f package.json2
        git diff -u package.json
        git tag -f "${DSC_TAG}-quay"
        rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo
        echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts (quay version)"
        sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts
        yarn && npx oclif-dev pack -t ${platforms}
        mv dist/channels/*quay dist/channels/quay
        # copy from generic name specific name, so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
        while IFS= read -r -d '' d; do
            e=${d/quay\/dsc/quay\/${TARBALL_PREFIX}-quay-dsc}
            cp ${d} ${e}
        done <   <(find dist/channels/quay -type f -name "*gz" -print0)
        pwd; du ./dist/channels/*/*gz

        # purge generated binaries and temp files
        rm -fr coverage/ lib/ node_modules/ templates/ tmp/

        # create sources tarball in the same dir where we have the per-arch binaries
        tar czf /tmp/${TARBALL_PREFIX}-quay-dsc-sources.tar.gz --exclude=./dist/channels/*/* ./* && \
        mv /tmp/${TARBALL_PREFIX}-quay-dsc-sources.tar.gz ${DSC_DIR}/dist/channels/quay/
    popd >/dev/null
fi

########################################################################
echo "[INFO] 4. include crwctl binary/readme"
########################################################################
pushd $DSC_DIR >/dev/null
    ./build/scripts/add-crwctl.sh
popd >/dev/null

if [[ $PUBLISH_ARTIFACTS_TO_GITHUB -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 5. Publish to GH"
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
    for channel in quay redhat; do
        pushd ${DSC_DIR}/dist/channels/${channel}/
            echo "[INFO] Publish $channel assets to ${CSV_VERSION}-${VERSION_SUFFIX}-dsc-assets GH release"
            /tmp/uploadAssetsToGHRelease.sh ${PRE_RELEASE} --publish-assets -b "${MIDSTM_BRANCH}" -v "${CSV_VERSION}-${VERSION_SUFFIX}" --asset-name "dsc" "devspaces-*tar.gz" --asset-type "Installer binaries and sources"
        popd >/dev/null
        echo "[INFO] Published assets: https://github.com/redhat-developer/devspaces-chectl/releases/tag/${CSV_VERSION}-${VERSION_SUFFIX}-dsc-assets"
    done

    # cleanup
    rm -f /tmp/uploadAssetsToGHRelease.sh

    echo "[INFO] Refresh GH pages"
    pushd ${DSC_DIR} >/dev/null
        git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/devspaces-chectl -b gh-pages --single-branch gh-pages && cd gh-pages
        echo $(date +%s) > update && git add update && git commit -m "ci: [update] add $RELEASE_ID to github pages" && git push origin gh-pages
    popd >/dev/null
fi

if [[ $PUBLISH_ARTIFACTS_TO_RCM -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 6. Publish to RCM"
    ########################################################################
    if [[ ! ${WORKSPACE} ]] || [[ ! -d ${WORKSPACE} ]]; then
        WORKSPACE=/tmp
    fi

    # TODO CRW-1919 remove this when we no longer need it
    export KRB5CCNAME=/var/tmp/devspaces-build_ccache

    # accept host key
    echo "${RCMGHOST},10.19.166.58 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApd6cnyFVRnS2EFf4qeNvav0o+xwd7g7AYeR9dxzJmCR3nSoVHA4Q/kV0qvWkyuslvdA41wziMgSpwq6H/DPLt41RPGDgJ5iGB5/EDo3HAKfnFmVAXzYUrJSrYd25A1eUDYHLeObtcL/sC/5bGPp/0deohUxLtgyLya4NjZoYPQY8vZE6fW56/CTyTdCEWohDRUqX76sgKlVBkYVbZ3uj92GZ9M88NgdlZk74lOsy5QiMJsFQ6cpNw+IPW3MBCd5NHVYFv/nbA3cTJHy25akvAwzk8Oi3o9Vo0Z4PSs2SsD9K9+UvCfP1TUTI4PXS8WpJV6cxknprk0PSIkDdNODzjw==
" >> ~/.ssh/known_hosts

    # if no kerb ticket for devspaces-build user, attempt to create one
    if [[ ! $(klist | grep devspaces-build) ]]; then
        cat /etc/redhat-release
        keytab=$(find /mnt/hudson_workspace/ $HOME $WORKSPACE -name "*devspaces-build*keytab*" 2>/dev/null | head -1)
        kinit "${KERBEROS_USER}" -kt $keytab || true
        klist
    fi

    # set up sshfs mount
    RCMG="${DESTHOST}:/mnt/rcm-guest/staging/devspaces"
    sshfs --version
    for mnt in RCMG; do
        mkdir -p ${WORKSPACE}/${mnt}-ssh;
        if [[ $(file ${WORKSPACE}/${mnt}-ssh 2>&1) == *"Transport endpoint is not connected"* ]]; then fusermount -uz ${WORKSPACE}/${mnt}-ssh; fi
        if [[ ! -d ${WORKSPACE}/${mnt}-ssh/devspaces ]]; then sshfs ${!mnt} ${WORKSPACE}/${mnt}-ssh || true; fi
    done

    # copy files to rcm-guest
    ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/devspaces && mkdir -p devspaces-${CSV_VERSION}/ && ls -la . "
    rsync -zrlt --rsh=ssh --protocol=28 --exclude "dsc*.tar.gz" --exclude "*-quay-*.tar.gz" \
    ${DSC_DIR}/dist/channels/redhat/*gz \
    ${WORKSPACE}/${mnt}-ssh/devspaces-${CSV_VERSION}/

    # echo what we have on disk
    ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/devspaces/devspaces-${CSV_VERSION}/ && ls -la ${TARBALL_PREFIX}*" || true

    # trigger release
    ssh "${DESTHOST}" "kinit -k -t ~/devspaces-build-keytab ${KERBEROS_USER}; /mnt/redhat/scripts/rel-eng/utility/bus-clients/stage-mw-release devspaces-${CSV_VERSION}"

    # drop connection to remote host so Jenkins cleanup won't delete files we just created
    fusermount -uz ${WORKSPACE}/RCMG-ssh || true
fi
