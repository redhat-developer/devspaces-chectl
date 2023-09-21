#!/bin/bash
#
# Copyright (c) 2020-2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#
# convert chectl upstream to downstream using sed & perl transforms, and deleting files

set -e

MIDSTM_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_TAG=${MIDSTM_BRANCH#*-}; DEFAULT_TAG=${DEFAULT_TAG%%-*};

usage () {
	echo "Usage:   $0 -b MIDSTM_BRANCH -s SOURCEDIR -t TARGETDIR"
	echo "Example: $0 -b ${MIDSTM_BRANCH} -s /absolute/path/to/chectl -t /absolute/path/to/dsc"
	echo ""
	echo "Options:
	--ds-version ${DEFAULT_TAG}     (compute from MIDSTM_BRANCH if not set)
	"
	exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-b'|'--ds-branch') MIDSTM_BRANCH="$2"; shift 1;;
	# paths to use for input and ouput
	'-s') SOURCEDIR="$2"; SOURCEDIR="${SOURCEDIR%/}"; shift 1;;
	'-t') TARGETDIR="$2"; TARGETDIR="${TARGETDIR%/}"; shift 1;;
	'--help'|'-h') usage;;
	# optional tag overrides
	'--ds-version') DS_VERSION="$2"; DEFAULT_TAG="$2"; shift 1;;
  esac
  shift 1
done

if [[ ! -d "${SOURCEDIR}" ]]; then usage; fi
if [[ -z "${TARGETDIR}" ]] || [[ ${TARGETDIR} == "." ]]; then usage; else mkdir -p "${TARGETDIR}"; fi

# if not set use devspaces-3.y-rhel-8 ==> 3.y as the default tag
if [[ -z "${DS_VERSION}" ]]; then DS_VERSION=${MIDSTM_BRANCH#*-}; DS_VERSION=${DS_VERSION%%-*}; fi

# ignore changes in these files
echo "/.github/
/.git/
/.gitignore
/.dockerignore
/.eslint*
/build/
/devfile.yaml
/README.building.md
/README.md
/tsconfig.tsbuildinfo
/templates/
/docs/
/dist/
/bin/
run-script-in-docker.sh
/RELEASE.md
/CONTRIBUTING.md
/make-release.sh
/.ci/
/hack/
" > /tmp/rsync-excludes
echo "Rsync ${SOURCEDIR} to ${TARGETDIR}"
rsync -azrlt --checksum --exclude-from /tmp/rsync-excludes --delete "${SOURCEDIR}"/ "${TARGETDIR}"/
rm -f /tmp/rsync-excludes

# ensure shell scripts are executable
find "${TARGETDIR}"/ -name "*.sh" -exec chmod +x {} \;

# global / generic changes
pushd "${SOURCEDIR}" >/dev/null
	while IFS= read -r -d '' d; do
		echo "[INFO] Convert ${d}"
		if [[ -d "${SOURCEDIR}/${d%/*}" ]]; then mkdir -p "${TARGETDIR}"/"${d%/*}"; fi
		sed -r \
			-e "s|https://github.com/che-incubator/chectl|https://github.com/redhat-developer/devspaces-chectl|g" \
			-e "s|chectl|dsc|g" \
			-e "s|dsc-version|chectl-version|g" \
		"$d" > "${TARGETDIR}/${d}"
	done <   <(find src test resources configs package.json .ci/obfuscate/gnirts.js .eslintrc.js -type f -name "*" -print0) # include package.json in here too
popd >/dev/null

# Productization
pushd "${TARGETDIR}" >/dev/null
  d=src/tasks/installers/eclipse-che/eclipse-che.ts
  echo "[INFO] Convert ${d}"
  sed -i "${TARGETDIR}/${d}" -r \
    -e "s|(const CHE_FLAVOR =).+|\1 'devspaces'|g" \
    -e "s|(const PRODUCT_ID =).+|\1 'devspaces'|g" \
    -e "s|(const PRODUCT_NAME =).+|\1 'Red Hat OpenShift Dev Spaces'|g" \
    -e "s|(const STABLE_CHANNEL_CATALOG_SOURCE =).+|\1 'redhat-operators'|g" \
    -e "s|(const CSV_PREFIX =).+|\1 'devspacesoperator'|g" \
    -e "s|(const NEXT_CHANNEL =).+|\1 'fast'|g" \
    -e "s|(const SUBSCRIPTION =).+|\1 'devspaces-subscription'|g" \
    -e "s|(const NAMESPACE =).+|\1 'openshift-devspaces'|g" \
    -e "s|(const NEXT_CHANNEL_CATALOG_SOURCE =).+|\1 'devspaces-fast'|g" \
    -e "s|(const DOC_LINK =).+|\1 'https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/${DS_VERSION}/'|g" \
    -e "s|(const DOC_LINK_RELEASE_NOTES =).+|\1 'https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/${DS_VERSION}/html/release_notes_and_known_issues/index'|g"

  d=src/tasks/installers/dev-workspace/dev-workspace.ts
  echo "[INFO] Convert ${d}"
  sed -i "${TARGETDIR}/${d}" -r \
    -e "s|(const NEXT_CHANNEL =).+|\1 'fast'|g" \
    -e "s|(const STABLE_CHANNEL_CATALOG_SOURCE =).+|\1 'redhat-operators'|g" \
    -e "s|(const STABLE_CHANNEL =).+|\1 'fast'|g"
popd >/dev/null

# Update prepare-templates.js
pushd "${TARGETDIR}" >/dev/null
	while IFS= read -r -d '' d; do
		echo "[INFO] Convert ${d} - use subfolder"
		sed -i "${TARGETDIR}/${d}" -r \
			-e "s#'node_modules', 'eclipse-che-operator'#'node_modules', 'devspaces-operator', 'devspaces-operator'#" \
			-e "s#'templates', 'che-operator'#'templates', 'devspaces-operator'#"
	done <   <(find prepare-templates.js -print0)
popd >/dev/null

domainString="export const DOMAIN = string({\n\
  description: '',\n\
  hidden: true,\n\
})"

platformString="export const PLATFORM = string({\n\
  char: 'p',\n\
  description: 'Type of OpenShift platform. Valid values are \\\\\"openshift\\\\\", \\\\\"crc (for OpenShift Local)\\\\\".',\n\
  options: ['openshift', 'crc'],\n\
  default: 'openshift',\n\
  required: true,\n\
})"

channelString="export const OLM_CHANNEL = string({\n\
  description: \`Olm channel to install \${EclipseChe.PRODUCT_NAME}.\n\
     The default 'stable' value will deploy the latest supported stable version of \${EclipseChe.PRODUCT_NAME} from the Red Hat Ecosystem Catalog.'\n\
     'latest' allows to deploy the latest unreleased version from quay.io.\n\
     'fast' or 'next' will deploy the next unreleased, unsupported, CI version of \${EclipseChe.PRODUCT_NAME} from quay.io.\`,\n\
  options: ['stable', 'latest', 'fast', 'next'],\n\
  default: 'stable',\n\
})"

# Patch flags
pushd "${TARGETDIR}" >/dev/null
	d=src/flags.ts
  echo "[INFO] Convert ${d}"

  # Hide domain flag
  perl -0777 -p -i -e 's|(export const DOMAIN = string\(\{.*?\}\))| ${1} =~ /.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
  sed -r -e "s#INSERT-CONTENT-HERE#${domainString}#" -i "${TARGETDIR}/${d}"

  # Update platform flag
  perl -0777 -p -i -e 's|(export const PLATFORM = string\(\{.*?\}\))| ${1} =~ /.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
  sed -r -e "s#INSERT-CONTENT-HERE#${platformString}#" -i "${TARGETDIR}/${d}"

  # Update channel flag
  perl -0777 -p -i -e 's|(export const OLM_CHANNEL = string\(\{.*?\}\))| ${1} =~ /.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
  sed -r -e "s#INSERT-CONTENT-HERE#${channelString}#" -i "${TARGETDIR}/${d}"

  # Convert
  sed -r \
		-e "s|Kubernetes namespace|Openshift Project|g" \
		-i "${TARGETDIR}/${d}"
popd >/dev/null

# Patch eslint rules to exclude unused vars
pushd "${TARGETDIR}" >/dev/null
  d=configs/disabled.rules.json
  echo "[INFO] Convert ${d}"
  mkdir -p "${TARGETDIR}/${d%/*}"
  sed -r -e '/"rules"\: \{/ a \ \ \ \ \ \ "@typescript-eslint/no-unused-vars": 0,' -i "${TARGETDIR}/${d}"
popd >/dev/null

# Fix compilation error
pushd "${TARGETDIR}" >/dev/null
  d=src/utils/utls.ts
  echo "[INFO] Convert ${d}"
  sed -i "${TARGETDIR}/${d}" -r -e "s|return EclipseChe.CHE_FLAVOR === CHE|// @ts-expect-error Make compilable\n  return EclipseChe.CHE_FLAVOR === CHE|g"
popd >/dev/null

replaceVar()
{
  cat ${replaceFile} | jq --arg updateName "${updateName}" --arg updateVal "${updateVal}" ''${updateName}'="'"${updateVal}"'"' > ${replaceFile}.2
  if [[ $(cat ${replaceFile}) != $(cat ${replaceFile}.2) ]]; then
    echo -n " * $updateName: "
    cat "${replaceFile}.2" | jq --arg updateName "${updateName}" ''${updateName}'' 2>/dev/null
  fi
  mv "${replaceFile}.2" "${replaceFile}"
}

# update package.json to latest branch of operator
replaceFile="${TARGETDIR}/package.json"
if [[ -f ${replaceFile} ]]; then
	echo "[INFO] Convert package.json (sed)"
	sed -i ${replaceFile} -r \
		-e 's#Eclipse Che#Red Hat OpenShift Dev Spaces#g' \
		-e 's#eclipse-che-operator#devspaces-operator#g' \

	echo "[INFO] Convert package.json - switch to oclif 3"
	sed -i ${replaceFile} -r \
		-e 's#"@oclif/dev-cli": "\^1"#"@oclif": "^3"#g' \
    -e 's#oclif-dev pack#oclif pack tarballs --no-xz --parallel#g' \
		-e 's#oclif-dev #oclif #g'

	echo "[INFO] Convert package.json (jq)"
	declare -A package_replacements=(
		["https://github.com/redhat-developer/devspaces-images#${MIDSTM_BRANCH}"]='.dependencies["devspaces-operator"]'
		["dsc"]='.name'
		["Red Hat OpenShift Dev Spaces CLI"]='.description'
		["${DEFAULT_TAG}.0-CI"]='.version'
		["./bin/run"]='.bin["dsc"]'
		["https://issues.jboss.org/projects/CRW/issues"]='.bugs'
		["https://developers.redhat.com/products/openshift-dev-spaces"]='.homepage'
		["redhat-developer/devspaces-chectl"]='.repository'
		["redhat-developer.dsc"]='.oclif["macos"]["identifier"]'
		["https://redhat-developer.github.io/devspaces-chectl/"]='.oclif["update"]["s3"]["host"]'
	)
	for updateVal in "${!package_replacements[@]}"; do
		updateName="${package_replacements[$updateVal]}"
		replaceVar
	done
	echo -n "[INFO] Sort package.json (to avoid nuissance commits): "
	pushd ${TARGETDIR} >/dev/null
  	npx -q sort-package-json
	popd >/dev/null
fi

# update yarn.lock and package.json; report any problems
yarn && yarn check || true
