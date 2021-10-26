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

MIDSTM_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_TAG=${MIDSTM_BRANCH#*-}; DEFAULT_TAG=${DEFAULT_TAG%%-*};

# default value for Jenkins builds
if [[ -d ${WORKSPACE}/sources ]]; then
    SOURCE_DIR=${WORKSPACE}/sources # path to where chectl is checked out
fi
if [[ -d "${WORKSPACE}/codeready-workspaces-images" ]]; then 
    CRWCTL_DIR="${WORKSPACE}/codeready-workspaces-images" 
fi
if [[ -d "${WORKSPACE}/codeready-workspaces-chectl" ]]; then 
    CRWCTL_DIR="${WORKSPACE}/codeready-workspaces-chectl" 
else 
    CRWCTL_DIR=`pwd`
fi

usageSegKey() {
	echo "Setup:

  First, export your segment write key to inject it into src/hooks/analytics/analytics.ts

  export SEGMENT_WRITE_KEY=\"...segment-write-key...\"
"
    usage
}
usage () {
	echo "Usage:

  $0 -b MIDSTM_BRANCH -s /path/to/chectl -i /path/to/crw-images/ [-t /path/to/crwctl/] [--suffix RC_or_GA]

Example: 

  $0 -b ${MIDSTM_BRANCH} -s /path/to/chectl/ -i /path/to/crw-images/ -t ${CRWCTL_DIR} --suffix RC"
	echo ""
	echo "Options:
    --suffix [RC or GA]  optionally, build an RC (copy to quay) or GA (copy to quay and RCM guest)
    --crw-version ${DEFAULT_TAG}   compute from MIDSTM_BRANCH if not set
	"
	exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-b'|'--crw-branch') MIDSTM_BRANCH="$2"; shift 1;; # branch of redhat-developer/codeready-workspaces/pom.xml to check as default CHE_VERSION
	# paths to use for input and ouput
	'-s') SOURCE_DIR="$2"; SOURCE_DIR="${SOURCE_DIR%/}"; shift 1;;
	'-t') CRWCTL_DIR="$2"; CRWCTL_DIR="${CRWCTL_DIR%/}"; shift 1;;
	'-i') CRWIMG_DIR="$2"; CRWIMG_DIR="${CRWIMG_DIR%/}"; shift 1;;
	'--help'|'-h') usageSegKey;;
	# optional tag overrides
    '--suffix') versionSuffix="$2"; shift 1;;
	'--crw-version') CRW_VERSION="$2"; DEFAULT_TAG="$2"; shift 1;;
  esac
  shift 1
done

if [[ ! "${SEGMENT_WRITE_KEY}" ]]; then usageSegKey; fi
if [[ ! -d "${SOURCE_DIR}" ]] || [[ ! -d "${CRWCTL_DIR}" ]] || [[ ! -d "${CRWIMG_DIR}" ]]; then usage; fi
if [[ ${CRWCTL_DIR} == "." ]]; then usage; fi

# compute branch from already-checked out sources dir
SOURCE_BRANCH=$(cd "$SOURCE_DIR"; git rev-parse --abbrev-ref HEAD)

# TODO pass in as script params or compute
CSV_VERSION="2.13.0"

###############################################################

set -x

pushd $CRWCTL_DIR >/dev/null

CURRENT_DAY=$(date +'%Y%m%d-%H%M')
SHORT_SHA1=$(git rev-parse --short=4 HEAD)

if [[ "${versionSuffix}" ]]; then
    CHECTL_VERSION="${CSV_VERSION}-${versionSuffix}"
    GITHUB_RELEASE_NAME="${CSV_VERSION}-${versionSuffix}-${SHORT_SHA1}"
else
    CHECTL_VERSION="${CSV_VERSION}-$CURRENT_DAY"
    GITHUB_RELEASE_NAME="${CSV_VERSION}-$CURRENT_DAY-${SHORT_SHA1}"
fi
# TODO refactor - don't need both vars
CUSTOM_TAG="${GITHUB_RELEASE_NAME}"

# RENAME artifacts to include version in the tarball: codeready-workspaces-2.1.0-crwctl-*.tar.gz
TARBALL_PREFIX="codeready-workspaces-${CHECTL_VERSION}"

# TODO refactor - don't need both SHA_CTL and SHORT_SHA1
SHA_CTL=$(git rev-parse --short=4 HEAD)

########
# compute latest tags for server and operator from quay
########
if [[ $versionSuffix == "GA" ]]; then
    repoFlag="--stage"
    repoOrg="codeready-workspaces"
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

########
#
########

echo "[INFO] Sync from upstream chectl"

git checkout ${MIDSTM_BRANCH}

# CRW-1579 change yamls to use :2.y tag, not :latest or :nightly - use that only for quay version of crwctl
pushd ${CRWIMG_DIR} >/dev/null
  FILES="codeready-workspaces-operator/config/manager/manager.yaml codeready-workspaces-operator-metadata/manifests/codeready-workspaces.csv.yaml"
  for d in ${FILES}; do
    sed -i ${d} -r -e "s#registry.redhat.io/codeready-workspaces/(.+):(.+)#registry.redhat.io/codeready-workspaces/\\1:${CRW_VERSION}#g"
  done
popd >/dev/null

./build/scripts/sync-chectl-to-crwctl.sh -b ${MIDSTM_BRANCH} -s ${SOURCE_DIR} -t ${CRWCTL_DIR} \
  --crw-version ${CRW_VERSION} --server-tag ${CRW_SERVER_TAG} --operator-tag ${CRW_OPERATOR_TAG}
# commit changes
set -x
git add .
git commit -s -m "ci: [sync] Push chectl @ ${SOURCE_BRANCH} to codeready-workspaces-chectl @ ${MIDSTM_BRANCH}" . || true
git push origin ${MIDSTM_BRANCH} || true


echo "[INFO] Build crwctl using -redhat suffix and registry.redhat.io/codeready-workspaces/ URLs"
cd ${CRWCTL_DIR}

# clean up from previous build if applicable
jq -M --arg CHECTL_VERSION \"${CHECTL_VERSION}-redhat\" '.version = $CHECTL_VERSION' package.json > package.json2; mv -f package.json2 package.json
git diff -u package.json
git tag -f "${CUSTOM_TAG}-redhat"
rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo dist/
echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts (redhat version)"
sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts
yarn && npx oclif-dev pack -t ${platforms}
mv dist/channels/*redhat dist/channels/redhat
# copy from generic name specific name, so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
while IFS= read -r -d '' d; do
  e=${d/redhat\\/crwctl/redhat\\/${TARBALL_PREFIX}-crwctl}
  cp ${d} ${e}
done <   <(find dist/channels/redhat -type f -name "*gz" -print0)
pwd; du ./dist/channels/*/*gz

git commit -s -m "ci: [update] package.json + README.md" package.json README.md || true
git push origin ${MIDSTM_BRANCH} || true

popd >/dev/null