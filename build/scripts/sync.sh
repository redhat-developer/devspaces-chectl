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
	--server-tag ${DEFAULT_TAG}-xx   (instead of default ${DEFAULT_TAG})
	--operator-tag ${DEFAULT_TAG}-yy (instead of default ${DEFAULT_TAG})
	--crw-version ${DEFAULT_TAG}     (compute from MIDSTM_BRANCH if not set)
	"
	exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-b'|'--crw-branch') MIDSTM_BRANCH="$2"; shift 1;; # branch of redhat-developer/codeready-workspaces/pom.xml to check as default CHE_VERSION
	# paths to use for input and ouput
	'-s') SOURCEDIR="$2"; SOURCEDIR="${SOURCEDIR%/}"; shift 1;;
	'-t') TARGETDIR="$2"; TARGETDIR="${TARGETDIR%/}"; shift 1;;
	'--help'|'-h') usage;;
	# optional tag overrides
	'--server-tag') CRW_SERVER_TAG="$2"; shift 1;;
	'--operator-tag') CRW_OPERATOR_TAG="$2"; shift 1;;
	'--crw-version') CRW_VERSION="$2"; DEFAULT_TAG="$2"; shift 1;;
  esac
  shift 1
done

if [[ ! -d "${SOURCEDIR}" ]]; then usage; fi
if [[ -z "${TARGETDIR}" ]] || [[ ${TARGETDIR} == "." ]]; then usage; else mkdir -p "${TARGETDIR}"; fi

# if not set use crw-3.y-rhel-8 ==> 3.y as the default tag
if [[ -z "${CRW_SERVER_TAG}" ]];   then CRW_SERVER_TAG=${MIDSTM_BRANCH#*-};   CRW_SERVER_TAG=${CRW_SERVER_TAG%%-*};     fi
if [[ -z "${CRW_OPERATOR_TAG}" ]]; then CRW_OPERATOR_TAG=${MIDSTM_BRANCH#*-}; CRW_OPERATOR_TAG=${CRW_OPERATOR_TAG%%-*}; fi
if [[ -z "${CRW_VERSION}" ]];      then CRW_VERSION=${MIDSTM_BRANCH#*-};      CRW_VERSION=${CRW_VERSION%%-*};           fi

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
/RELEASE.md
/CONTRIBUTING.md
/make-release.sh
/.ci/
/hack/
/crwctl
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
			-e "s|route_names = \['che'|route_names = \['devspaces'|g" \
			-e "s|https://github.com/che-incubator/chectl|https://github.com/redhat-developer/devspaces-chectl|g" \
			-e "s|chectl|dsc|g" \
			-e "s|dsc-generated|chectl-generated|g" \
			-e "s|labelSelector=app%3Dche|labelSelector=app%devspaces|g" \
			\
			-e "s|/codeready-workspaces-dsc|/devspaces-chectl|g" \
			-e "s|app=che|app=devspaces|g" \
			-e "s|app=devspaces,component=che|app=devspaces,component=devspaces|" \
			-e "s|eclipse-che-operator|devspaces-operator|g" \
			-e "s|che-operator|devspaces-operator|g" \
			-e "s|tech-preview-stable-all-namespaces|tech-preview-latest-all-namespaces|g" \
			-e "s|/devspaces-operator/|/devspaces-operator/|g" \
			\
			-e "s|devspaces-operator-(cr.+yaml)|che-operator-\1|g" \
			-e "s|devspaces-operator-(cr.+yaml)|che-operator-\1|g" \
			-e "s|devspaces-operator-image|che-operator-image|g" \
			-e "s|CHE_CLUSTER_CR_NAME = 'eclipse-che'|CHE_CLUSTER_CR_NAME = 'devspaces'|g" \
			-e "s|Eclipse Che|Red Hat OpenShift Dev Spaces|g" \
			-e "s|Che workspaces|Red Hat OpenShift Dev Spaces workspaces|g" \
			\
			-e "s| when both minishift and OpenShift are stopped||" \
			-e "s|resource: Kubernetes/OpenShift|resource|g" \
			-e "s|(const DEFAULT_CHE_OPERATOR_IMAGE_NAME =).+|\1 'registry.redhat.io/devspaces/devspaces-rhel8-operator'|g" \
			\
			-e "s|(const CHE_CLUSTER_CR_NAME =).+|\1 'devspaces'|g" \
			\
			-e "s|(const DEFAULT_CHE_OLM_PACKAGE_NAME =).+|\1 'devspaces'|g" \
			-e "s|(const OLM_STABLE_CHANNEL_NAME =).+|\1 'latest'|g" \
			-e "s|(const CSV_PREFIX =).+|\1 'devspacesoperator'|g" \
			-e "s|(const OLM_STABLE_CHANNEL_STARTING_CSV_TEMPLATE =).+|\1 'devspacesoperator.v{{VERSION}}'|g" \
			-e "s|(const OLM_STABLE_ALL_NAMESPACES_CHANNEL_STARTING_CSV_TEMPLATE =).+|\1 'devspacesoperator.v{{VERSION}}'|g" \
			-e "s|(const CUSTOM_CATALOG_SOURCE_NAME =).+|\1 'devspaces-custom-catalog-source'|g" \
			-e "s|(const DEFAULT_CHE_OPERATOR_SUBSCRIPTION_NAME =).+|\1 'devspaces-subscription'|g" \
			-e "s|(const OPERATOR_GROUP_NAME =).+|\1 'devspaces-operator-group'|g" \
			-e "s|(const OPENSHIFT_OLM_CATALOG =).+|\1 'redhat-operators'|g" \
			-e "s|(const DEFAULT_OLM_SUGGESTED_NAMESPACE =).+|\1 'openshift-operators'|g" \
			-e "s|(const DEFAULT_CHE_NAMESPACE =).+|\1 'openshift-operators'|g" \
			-e "s|(const LEGACY_CHE_NAMESPACE =).+|\1 'openshift-workspaces'|g" \
			-e "s|(CVS_PREFIX =).+|\1 'devspacesoperator'|g" \
			\
			-e "s|\"Red Hat OpenShift Dev Spaces will be deployed in Multi-User mode.+mode.\"|'Red Hat OpenShift Dev Spaces can only be deployed in Multi-User mode.'|" \
		"$d" > "${TARGETDIR}/${d}"
	done <   <(find src test resources configs prepare-che-operator-templates.js package.json .ci/obfuscate/gnirts.js .eslintrc.js -type f -name "*" -print0) # include package.json in here too
popd >/dev/null

# Remove files
pushd "${TARGETDIR}" >/dev/null
	while IFS= read -r -d '' d; do
		echo "[INFO] Delete ${d#./}"
		rm -f "$d"
	done <   <(find . -regextype posix-extended -iregex '.+/(minikube|microk8s|k8s|docker-desktop)(.test|).ts' -print0)
popd >/dev/null

# Update prepare-che-operator-templates.js
pushd "${TARGETDIR}" >/dev/null
	while IFS= read -r -d '' d; do
		echo "[INFO] Convert ${d} - use subfolder"
		sed -i "${TARGETDIR}/${d}" -r \
			-e "s#'node_modules', 'devspaces-operator'#'node_modules', 'devspaces-operator', 'devspaces-operator'#" \
			-e "s#'templates', 'devspaces-operator'#'templates', 'devspaces-operator'#"
	done <   <(find prepare-che-operator-templates.js -print0)
popd >/dev/null

# Rename file prepare-che-operator-templates.js
mv -f "${TARGETDIR}"/prepare-che-operator-templates.js "${TARGETDIR}"/prepare-devspaces-operator-templates.js

# per-file changes:
platformString="    platform: string({\n\
      char: 'p',\n\
      description: 'Type of OpenShift platform. Valid values are \\\\\"openshift\\\\\", \\\\\"crc (for CodeReady Containers)\\\\\".',\n\
      options: ['openshift', 'crc'],\n\
      default: 'openshift',\n\
    }),"; # echo -e "$platformString"
installerString="    installer: string({\n\
      char: 'a',\n\
      description: 'Installer type. If not set, default is "olm" for OpenShift >= 4.2, and "operator" for earlier versions.',\n\
      options: ['olm', 'operator'],\n\
    }),"; # echo -e "$installerString"
clusterMonitoringString="    'cluster-monitoring': boolean({\n\
      default: false,\n\
      hidden: false,\n\
      description: \`Enable cluster monitoring to scrape Red Hat OpenShift Dev Spaces metrics in Prometheus.\n\
	                  This parameter is used only when the platform is 'openshift'.\`,\n\
    }),"; # echo -e "$clusterMonitoringString"

# set -x
pushd "${TARGETDIR}" >/dev/null
	for d in src/commands/server/update.ts src/commands/server/deploy.ts; do
		echo "[INFO] Convert ${d}"
		mkdir -p "${TARGETDIR}/${d%/*}"
		perl -0777 -p -i -e 's|(\ +platform: string\(\{.*?\}\),)| ${1} =~ /.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#INSERT-CONTENT-HERE#${platformString}#" -i "${TARGETDIR}/${d}"

		perl -0777 -p -i -e 's|(\ +installer: string\(\{.*?\}\),)| ${1} =~ /.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#INSERT-CONTENT-HERE#${installerString}#" -i "${TARGETDIR}/${d}"

		# Remove --domain flag
		sed -i '/domain: string({/,/}),/d' "${TARGETDIR}/${d}"

		# Change multi-user flag description. Code Ready Workspaces support multi-user by default. https://issues.redhat.com/browse/CRW-1174
		sed -i "s|'Starts Red Hat OpenShift Dev Spaces in multi-user mode'|\`Deploys Red Hat OpenShift Dev Spaces in multi-user mode.\n\ \
		                Note, this option is turned on by default.\`|g" "${TARGETDIR}/${d}"

		# Enable cluster monitoring description in Readme. Cluster Monitoring actually is available only for downstream
		perl -0777 -p -i -e 's|(\ +'"'cluster-monitoring'"': boolean\(\{.*?\}\),)| ${1} =~ /.+openshift.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#INSERT-CONTENT-HERE#${clusterMonitoringString}#" -i "${TARGETDIR}/${d}"

	done
popd >/dev/null
# set +x

pushd "${TARGETDIR}" >/dev/null
	d=src/common-flags.ts
	echo "[INFO] Convert ${d}"
	mkdir -p "${TARGETDIR}/${d%/*}"
	sed -r \
		`# replace line after specified one with new default` \
		-e "s|Kubernetes namespace|Openshift Project|g" \
		-e "/description: .+ deployment name.+/{n;s/.+/  default: 'devspaces',/}" \
		-i "${TARGETDIR}/${d}"
popd >/dev/null

operatorTasksString="export class OperatorTasks {\n\
  operatorServiceAccount = 'devspaces-operator'\n\
  operatorRole = 'devspaces-operator'\n\
  operatorClusterRole = 'devspaces-operator'\n\
  operatorRoleBinding = 'devspaces-operator'\n\
  operatorClusterRoleBinding = 'devspaces-operator'\n\
  cheClusterCrd = 'checlusters.org.eclipse.che'\n\
  operatorName = 'devspaces-operator'\n\
  operatorCheCluster = 'devspaces'\n\
  resourcesPath = ''"
pushd "${TARGETDIR}" >/dev/null
	d=src/tasks/installers/operator.ts
	echo "[INFO] Convert ${d}"
	mkdir -p "${TARGETDIR}/${d%/*}"
	perl -0777 -p -i -e 's|(export class OperatorTasks.*?  resourcesPath = )|  ${1} =~ /.+che-operator.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
	sed -r -e "s#INSERT-CONTENT-HERE.+#${operatorTasksString}#" -i "${TARGETDIR}/${d}"
popd >/dev/null

# remove if blocks
pushd "${TARGETDIR}" >/dev/null
	for d in src/tasks/installers/installer.ts src/tasks/platforms/platform.ts; do
		echo "[INFO] Convert ${d}"
		mkdir -p "${TARGETDIR}/${d%/*}"
		sed -i -r -e '/.+BEGIN CHE ONLY$/,/.+END CHE ONLY$/d' "${TARGETDIR}/${d}"
		sed -r -e "/.*(import|const|protected|new).+(DockerDesktop|K8s|MicroK8s|Minikube).*Tasks.*/d" -i "${TARGETDIR}/${d}"
		sed -r -e "s/(.+return).+configureApiServerForDex.+/\1 []/" -i "${TARGETDIR}/${d}"
	done
popd >/dev/null

pushd "${TARGETDIR}" >/dev/null
	d=src/constants.ts
	echo "[INFO] Convert ${d}"
	mkdir -p "${TARGETDIR}/${d%/*}"
	sed -r -e "s#DOC_LINK =.+#DOC_LINK = 'https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/${CRW_VERSION}/'#" -i "${TARGETDIR}/${d}"
	sed -r -e "s#DOC_LINK_RELEASE_NOTES.+#DOC_LINK_RELEASE_NOTES = 'https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/${CRW_VERSION}/html/release_notes_and_known_issues/index'#" -i "${TARGETDIR}/${d}"

	# Restore replaced upstream project
	sed -r -e "s#CHECTL_PROJECT_NAME =.+#CHECTL_PROJECT_NAME = 'chectl'#" -i "${TARGETDIR}/${d}"
	# Fix correct templates directory
	sed -r -e "s#OPERATOR_TEMPLATE_DIR =.+#OPERATOR_TEMPLATE_DIR = 'devspaces-operator'#" -i "${TARGETDIR}/${d}"
popd >/dev/null

# Patch eslint rules to exclude unused vars
pushd "${TARGETDIR}" >/dev/null
  d=configs/disabled.rules.json
  echo "[INFO] Convert ${d}"
  mkdir -p "${TARGETDIR}/${d%/*}"
  sed -r -e '/"rules"\: \{/ a \ \ \ \ \ \ "@typescript-eslint/no-unused-vars": 0,' -i "${TARGETDIR}/${d}"
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

# update package.json to latest branch of crw-operator
replaceFile="${TARGETDIR}/package.json"
if [[ -f ${replaceFile} ]]; then
	echo "[INFO] Convert package.json (sed #2)"
	sed -i ${replaceFile} -r \
		-e '/"eclipse-devspaces-operator": ".+"/d' \
		-e '/"e2e-minikube":/d' \
		-e 's#eclipse-devspaces-operator#devspaces-operator#g' \
		-e "s|devspaces-operator|devspaces-operator|g"

	echo "[INFO] Convert package.json (jq #1)"
	declare -A package_replacements=(
		["https://github.com/redhat-developer/devspaces-images#${MIDSTM_BRANCH}"]='.dependencies["devspaces-operator"]'
		["dsc"]='.name'
		["Red Hat OpenShift Dev Spaces CLI"]='.description'
		["${DEFAULT_TAG}.0-CI-redhat"]='.version'
		["./bin/run"]='.bin["dsc"]'
		["https://issues.jboss.org/projects/CRW/issues"]='.bugs'
		["https://developers.redhat.com/products/codeready-workspaces"]='.homepage'
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
