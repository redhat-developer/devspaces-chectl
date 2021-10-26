#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#
# script to build 1 or two versions of crwctl (RH and Quay flavours), then optionally:
# * push artifacts to github (GA only)
# * push artifacts to rcm-guest (GA only)

set -e

# defaults
platforms="linux-x64,darwin-x64,win32-x64"
versionSuffix="" 

PUBLISH_ARTIFACTS_TO_GITHUB=0
PUBLISH_ARTIFACTS_TO_RCM=0

MIDSTM_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_TAG=${MIDSTM_BRANCH#*-}; DEFAULT_TAG=${DEFAULT_TAG%%-*}
if [[ $DEFAULT_TAG == "2" ]]; then latestNext="next"; else latestNext="latest"; fi

# default value for Jenkins builds
if [[ -d ${WORKSPACE}/sources ]]; then
    SOURCE_DIR=${WORKSPACE}/sources # path to where chectl is checked out
fi
if [[ -d "${WORKSPACE}/codeready-workspaces-images" ]]; then 
    CRWIMG_DIR="${WORKSPACE}/codeready-workspaces-images" 
fi
if [[ -d "${WORKSPACE}/codeready-workspaces-chectl" ]]; then 
    CRWCTL_DIR="${WORKSPACE}/codeready-workspaces-chectl" 
else 
    CRWCTL_DIR=`pwd`
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

  $0 -v 2.yy.z -b MIDSTM_BRANCH -s /path/to/chectl -i /path/to/crw-images/ [-t /path/to/crwctl/]  [--suffix RC_or_GA]

Example: 

  $0 -v ${DEFAULT_TAG}.0 -b ${MIDSTM_BRANCH} -s /path/to/chectl/ -i /path/to/crw-images/ -t ${CRWCTL_DIR} --suffix RC"
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
    '-b'|'--crw-branch') MIDSTM_BRANCH="$2"; shift 1;; # branch of redhat-developer/codeready-workspaces/pom.xml to check as default CHE_VERSION
	# paths to use for input and ouput
	'-s') SOURCE_DIR="$2"; SOURCE_DIR="${SOURCE_DIR%/}"; shift 1;;
	'-t') CRWCTL_DIR="$2"; CRWCTL_DIR="${CRWCTL_DIR%/}"; shift 1;;
	'-i') CRWIMG_DIR="$2"; CRWIMG_DIR="${CRWIMG_DIR%/}"; shift 1;;
	'--help'|'-h') usageSegKey;;
	# optional tag overrides
    '--suffix') versionSuffix="$2"; shift 1;;
	'--crw-version') CRW_VERSION="$2"; DEFAULT_TAG="$2"; shift 1;;
    '--gh') PUBLISH_ARTIFACTS_TO_GITHUB=1;;
    '--rcm') PUBLISH_ARTIFACTS_TO_RCM=1;;
  esac
  shift 1
done

if [[ ! "${SEGMENT_WRITE_KEY}" ]]; then usageSegKey; fi
if [[ $PUBLISH_ARTIFACTS_TO_GITHUB -eq 1 ]] && [[ ! "${GITHUB_TOKEN}" ]]; then usageSegKey; fi
if [[ ! -d "${SOURCE_DIR}" ]] || [[ ! -d "${CRWCTL_DIR}" ]] || [[ ! -d "${CRWIMG_DIR}" ]]; then usage; fi
if [[ ${CRWCTL_DIR} == "." ]]; then usage; fi

if [[ ! ${CSV_VERSION} ]]; then usage; fi

# compute branch from already-checked out sources dir
SOURCE_BRANCH=$(cd "$SOURCE_DIR"; git rev-parse --abbrev-ref HEAD)

###############################################################

set -x

pushd $CRWCTL_DIR >/dev/null

CURRENT_DAY=$(date +'%Y%m%d-%H%M')
SHORT_SHA1=$(git rev-parse --short=4 HEAD)

# for RC and CI, prerelease=true
isPreRelease="true"

if [[ "${versionSuffix}" ]]; then
    CHECTL_VERSION="${CSV_VERSION}-${versionSuffix}"
    CUSTOM_TAG="${CSV_VERSION}-${versionSuffix}-${SHORT_SHA1}"
else
    # TODO replace multiple CI releases with a single reusable CI pre-release for each CSV version
    CHECTL_VERSION="${CSV_VERSION}-$CURRENT_DAY"
    CUSTOM_TAG="${CSV_VERSION}-$CURRENT_DAY-${SHORT_SHA1}"
fi

# RENAME artifacts to include version in the tarball: codeready-workspaces-2.1.0-crwctl-*.tar.gz
TARBALL_PREFIX="codeready-workspaces-${CHECTL_VERSION}"

# compute latest tags for server and operator from quay; also set prerelease=false for GA
if [[ $versionSuffix == "GA" ]]; then
    repoFlag="--stage"
    repoOrg="codeready-workspaces"
    isPreRelease="false"
elif [[ $versionSuffix == "RC" ]]; then
    repoFlag="--quay"
    repoOrg="crw"
else
    # for CI, use simple floating tag 2.yy
    CRW_SERVER_TAG=${CRW_VERSION}
    CRW_OPERATOR_TAG=${CRW_VERSION}
fi
# for RC or GA, compute a 2.yy-zzz tag (not floating tag 2.yy)
if [[ ! $CRW_SERVER_TAG ]] && [[ ! $CRW_OPERATOR_TAG ]]; then 
    pushd /tmp  >/dev/null
        curl -sSLO https://raw.githubusercontent.com/redhat-developer/codeready-workspaces/${MIDSTM_BRANCH}/product/getLatestImageTags.sh && \
        chmod +x getLatestImageTags.sh
    popd >/dev/null
    CRW_SERVER_TAG=$(/tmp/getLatestImageTags.sh -b ${MIDSTM_BRANCH} -c "${repoOrg}/server-rhel8" --tag "${CRW_VERSION}-" ${repoFlag})
    CRW_SERVER_TAG=${CRW_SERVER_TAG##*:}
    CRW_OPERATOR_TAG=$(/tmp/getLatestImageTags.sh -b ${MIDSTM_BRANCH} -c "${repoOrg}/crw-2-rhel8-operator" --tag "${CRW_VERSION}-" ${repoFlag})
    CRW_OPERATOR_TAG=${CRW_OPERATOR_TAG##*:}
fi
echo "Using server:${CRW_SERVER_TAG} + operator:${CRW_OPERATOR_TAG}"
popd >/dev/null

########################################################################
echo "[INFO] 0. Sync from upstream chectl"
########################################################################
# CRW-1579 change yamls to use :2.y tag, not :latest or :next - use that only for quay version of crwctl
pushd ${CRWIMG_DIR} >/dev/null
  FILES="codeready-workspaces-operator/config/manager/manager.yaml codeready-workspaces-operator-metadata/manifests/codeready-workspaces.csv.yaml"
  for d in ${FILES}; do
    sed -i ${d} -r -e "s#registry.redhat.io/codeready-workspaces/(.+):(.+)#registry.redhat.io/codeready-workspaces/\1:${CRW_VERSION}#g"
  done
popd >/dev/null

pushd $CRWCTL_DIR >/dev/null
./build/scripts/sync-chectl-to-crwctl.sh -b ${MIDSTM_BRANCH} -s ${SOURCE_DIR} -t ${CRWCTL_DIR} \
  --crw-version ${CRW_VERSION} --server-tag ${CRW_SERVER_TAG} --operator-tag ${CRW_OPERATOR_TAG}
# commit changes
set -x
git add .
git commit -s -m "ci: [sync] Push chectl @ ${SOURCE_BRANCH} to codeready-workspaces-chectl @ ${MIDSTM_BRANCH}" . || true
git push origin ${MIDSTM_BRANCH} || true
popd >/dev/null

########################################################################
echo "[INFO] 1. Build crwctl using -redhat suffix and registry.redhat.io/codeready-workspaces/ URLs"
########################################################################
pushd $CRWCTL_DIR >/dev/null
    # clean up from previous build if applicable
    jq -M --arg CHECTL_VERSION "${CHECTL_VERSION}-redhat" '.version = $CHECTL_VERSION' package.json > package.json2; mv -f package.json2 package.json
    git diff -u package.json
    git tag -f "${CUSTOM_TAG}-redhat"
    rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo dist/
    echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts (redhat version)"
    sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts
    yarn && npx oclif-dev pack -t ${platforms}
    mv dist/channels/*redhat dist/channels/redhat
    # copy from generic name specific name, so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
    while IFS= read -r -d '' d; do
    e=${d/redhat\/crwctl/redhat\/${TARBALL_PREFIX}-crwctl}
    cp ${d} ${e}
    done <   <(find dist/channels/redhat -type f -name "*gz" -print0)

    # purge generated binaries and temp files
    rm -fr coverage/ lib/ node_modules/ templates/ tmp/

    # create sources tarball in the same dir where we have the per-arch binaries 
    tar czf /tmp/${TARBALL_PREFIX}-crwctl-sources.tar.gz --exclude=dist/ ./* && \
    mv /tmp/${TARBALL_PREFIX}-crwctl-sources.tar.gz ${CRWCTL_DIR}/dist/channels/redhat/

    pwd; du ./dist/channels/*/*gz

    git commit -s -m "ci: [update] package.json + README.md" package.json README.md || true
    git push origin ${MIDSTM_BRANCH} || true
popd >/dev/null

########################################################################
echo "[INFO] 2. Prepare ${MIDSTM_BRANCH}-quay branch of crw operator repo"
########################################################################
# check out from MIDSTM_BRANCH
pushd ${CRWIMG_DIR} >/dev/null
    git branch ${MIDSTM_BRANCH}-quay -f
    git checkout ${MIDSTM_BRANCH}-quay
    # CRW-1579 change yamls to use quay image, and :latest or :nightly
    # do not use :2.y to allow stable builds to be auto-updated via crwctl on ocp3.11 - :latest tag triggers always-update (?)
    FILES="codeready-workspaces-operator/config/manager/manager.yaml codeready-workspaces-operator-metadata/manifests/codeready-workspaces.csv.yaml"
    for d in ${FILES}; do
        sed -i ${d} -r -e "s#registry.redhat.io/codeready-workspaces/(.+):(.+)#quay.io/crw/\1:${latestNext}#g"
    done

    # push to ${MIDSTM_BRANCH}-quay branch
    git commit -s -m "ci: [update] Push ${MIDSTM_BRANCH} to ${MIDSTM_BRANCH}-quay branch" ${FILES}
    git push origin ${MIDSTM_BRANCH}-quay -f
popd >/dev/null

########################################################################
echo "[INFO] 3. Build crwctl using ${MIDSTM_BRANCH}-quay branch, -quay suffix and quay.io/crw/ URLs"
########################################################################
pushd ${CRWCTL_DIR} >/dev/null
    YAML_REPO="`cat package.json | jq -r '.dependencies["codeready-workspaces-operator"]'`-quay"
    jq -M --arg YAML_REPO "${YAML_REPO}" '.dependencies["codeready-workspaces-operator"] = $YAML_REPO' package.json > package.json2
    jq -M --arg CHECTL_VERSION "${CHECTL_VERSION}-quay" '.version = $CHECTL_VERSION' package.json2 > package.json
    rm -f package.json2
    git diff -u package.json
    git tag -f "${CUSTOM_TAG}-quay"
    rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo
    echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts (quay version)"
    sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts
    yarn && npx oclif-dev pack -t ${platforms}
    mv dist/channels/*quay dist/channels/quay
    # copy from generic name specific name, so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
    while IFS= read -r -d '' d; do
    e=${d/quay\/crwctl/quay\/'''+TARBALL_PREFIX+'''-crwctl}
    cp ${d} ${e}
    done <   <(find dist/channels/quay -type f -name "*gz" -print0)
    pwd; du ./dist/channels/*/*gz

    # purge generated binaries and temp files
    rm -fr coverage/ lib/ node_modules/ templates/ tmp/

    # create sources tarball in the same dir where we have the per-arch binaries 
    tar czf /tmp/${TARBALL_PREFIX}-crwctl-sources.tar.gz --exclude=dist/ ./* && \
    mv /tmp/${TARBALL_PREFIX}-crwctl-sources.tar.gz ${CRWCTL_DIR}/dist/channels/quay/
popd >/dev/null 

if [[ $PUBLISH_ARTIFACTS_TO_GITHUB -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 4. Publish to GH"
    ########################################################################

    # TODO use gh cli instead of curling? See https://github.com/redhat-developer/codeready-workspaces/blob/crw-2-rhel-8/product/uploadAssetsToGHRelease.sh

    # Create new release
    curl -XPOST -H "Authorization:token ${GITHUB_TOKEN}" \
        --data '{"tag_name": "'${CUSTOM_TAG}'", "target_commitish": "'${MIDSTM_BRANCH}'", "name": "'${CUSTOM_TAG}'", "body": "Release '${CUSTOM_TAG}'", "draft": false, "prerelease": '${isPreRelease}'}' \
        https://api.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases > /tmp/${CUSTOM_TAG}
    # Extract the id of the release from the creation response
    RELEASE_ID=$(jq -r .id /tmp/${CUSTOM_TAG}); rm -f /tmp/${CUSTOM_TAG}

    if [[ "${RELEASE_ID}" == "null" ]]; then
        echo "[ERROR] Could not load release id for new GH release"
        exit 1
    fi

    # upload artifacts for each platform + sources tarball
    pushd ${CRWCTL_DIR}/dist/channels/quay/ 
        for platform in ${platforms//,/ } sources; do
        curl -XPOST -H "Authorization:token ${GITHUB_TOKEN}" -H 'Content-Type:application/octet-stream' \
            --data-binary @${TARBALL_PREFIX}-crwctl-${platform}.tar.gz \
            https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-${platform}.tar.gz
        done
    popd >/dev/null

    # refresh github pages
    pushd ${CRWCTL_DIR} >/dev/null
        git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/codeready-workspaces-chectl -b gh-pages --single-branch gh-pages && cd gh-pages
        echo $(date +%s) > update && git add update && git commit -m "ci: [update] add $RELEASE_ID to github pages" && git push origin gh-pages
    popd >/dev/null
fi

if [[ $PUBLISH_ARTIFACTS_TO_RCM -eq 1 ]]; then
    ########################################################################
    echo "[INFO] 5. Publish to RCM"
    ########################################################################
    if [[ ! ${WORKSPACE} ]] || [[ ! -d ${WORKSPACE} ]]; then
        WORKSPACE=/tmp
    fi

    # accept host key
    echo "rcm-guest.app.eng.bos.redhat.com,10.16.101.129 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApd6cnyFVRnS2EFf4qeNvav0o+xwd7g7AYeR9dxzJmCR3nSoVHA4Q/kV0qvWkyuslvdA41wziMgSpwq6H/DPLt41RPGDgJ5iGB5/EDo3HAKfnFmVAXzYUrJSrYd25A1eUDYHLeObtcL/sC/5bGPp/0deohUxLtgyLya4NjZoYPQY8vZE6fW56/CTyTdCEWohDRUqX76sgKlVBkYVbZ3uj92GZ9M88NgdlZk74lOsy5QiMJsFQ6cpNw+IPW3MBCd5NHVYFv/nbA3cTJHy25akvAwzk8Oi3o9Vo0Z4PSs2SsD9K9+UvCfP1TUTI4PXS8WpJV6cxknprk0PSIkDdNODzjw==
    " >> ~/.ssh/known_hosts

    # set up sshfs mount
    DESTHOST="crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@rcm-guest.app.eng.bos.redhat.com"
    RCMG="${DESTHOST}:/mnt/rcm-guest/staging/crw"
    sshfs --version
    for mnt in RCMG; do 
    mkdir -p ${WORKSPACE}/${mnt}-ssh; 
    if [[ $(file ${WORKSPACE}/${mnt}-ssh 2>&1) == *"Transport endpoint is not connected"* ]]; then fusermount -uz ${WORKSPACE}/${mnt}-ssh; fi
    if [[ ! -d ${WORKSPACE}/${mnt}-ssh/crw ]]; then sshfs ${!mnt} ${WORKSPACE}/${mnt}-ssh; fi
    done

    # copy files to rcm-guest
    ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/crw && mkdir -p CRW-${CSV_VERSION}/ && ls -la . "
    rsync -zrlt --rsh=ssh --protocol=28 --exclude "crwctl*.tar.gz" \
    ${CRWCTL_DIR}/dist/channels/redhat/*gz \
    ${WORKSPACE}/${mnt}-ssh/CRW-${CSV_VERSION}/

    # clone files so we have a crwctl3 version too
    # codeready-workspaces-2.y.z-GA-crwctl-linux-x64.tar.gz -> codeready-workspaces-2.y.z-GA-crwctl3-linux-x64.tar.gz
    ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/crw/CRW-${CSV_VERSION}/ && for d in ${TARBALL_PREFIX}-crwctl-*; do cp \$d \${d/crwctl-/crwctl3-}; done" || true

    # echo what we have on disk
    ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/crw/CRW-${CSV_VERSION}/ && ls -la ${TARBALL_PREFIX}*" || true

    # trigger release
    ssh "${DESTHOST}" "/mnt/redhat/scripts/rel-eng/utility/bus-clients/stage-mw-release CRW-${CSV_VERSION}" || true
fi
