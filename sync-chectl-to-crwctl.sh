#!/bin/bash
#
# Copyright (c) 2020 Red Hat, Inc.
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

if [[ $# -lt 3 ]]; then
	echo "Usage:   $0 SOURCEDIR TARGETDIR CRW_TAG"
	echo "Example: $0 /path/to/chectl /path/to/crwctl 2.1"
	echo ""
	echo "Note: CRW_TAG = default image tags (eg., server-rhel8:2.1 and crw-2-rhel8-operator:2.1)"
	exit 1
fi

SOURCEDIR=$1; SOURCEDIR=${SOURCEDIR%/}
TARGETDIR=$2; TARGETDIR=${TARGETDIR%/}
CRW_TAG="$3" # eg., 2.1 as in server-rhel8:2.1 to set as default

# global / generic changes
pushd "${SOURCEDIR}" >/dev/null
	while IFS= read -r -d '' d; do
		echo "Convert ${d}"
		mkdir -p "${TARGETDIR}"/"${d%/*}"
		sed -r \
			-e "s|route_names = \['che'|route_names = \['codeready'|g" \
			-e "s|https://github.com/che-incubator/chectl|https://github.com/redhat-developer/codeready-workspaces-chectl|g" \
			-e "s|chectl|crwctl|g" \
			-e "s|crwctl-generated|chectl-generated|g" \
			-e "s|ide/che/crwctl|ide/che/chectl|g" \
			\
			-e "s|/codeready-workspaces-crwctl|/codeready-workspaces-chectl|g" \
			-e "s|app=che|app=codeready|g" \
			-e "s|app=codeready,component=che|app=codeready,component=codeready|" \
			-e "s|che-operator|codeready-operator|g" \
			-e "s|/che-operator/|/codeready-workspaces-operator/|g" \
			\
			-e "s|codeready-operator-(cr.+yaml)|che-operator-\1|g" \
			-e "s|codeready-operator-(cr.+yaml)|che-operator-\1|g" \
			-e "s|codeready-operator-image|che-operator-image|g" \
			-e "s|operatorCheCluster = 'eclipse-che'|operatorCheCluster = 'codeready-workspaces'|g" \
			-e "s|Eclipse Che|CodeReady Workspaces|g" \
			\
			-e "s| when both minishift and OpenShift are stopped||" \
			-e "s|resource: Kubernetes/OpenShift/Helm|resource|g" \
			-e "s|import \{ HelmTasks \} from '../../tasks/installers/helm'||g" \
			-e "s|import \{ MinishiftAddonTasks \} from '../../tasks/installers/minishift-addon'||g" \
			-e "s|    const helmTasks = new HelmTasks\(\)||g" \
			\
			-e "s#    const (minishiftAddonTasks|msAddonTasks) = new MinishiftAddonTasks\(\)##g" \
			-e "s|.+tasks.add\(helmTasks.+||g" \
			-e "s#.+tasks.add\((minishiftAddonTasks|msAddonTasks).+##g" \
			-e "s|(const DEFAULT_CHE_IMAGE =).+|\1 'registry.redhat.io/codeready-workspaces/server-rhel8:${CRW_TAG}'|g" \
			-e "s|(const DEFAULT_CHE_OPERATOR_IMAGE =).+|\1 'registry.redhat.io/codeready-workspaces/crw-2-rhel8-operator:${CRW_TAG}'|g" \
			\
			-e "s|CodeReady Workspaces will be deployed in Multi-User mode.+mode.|CodeReady Workspaces can only be deployed in Multi-User mode.|" \
			-e "s|che-incubator/crwctl|redhat-developer/codeready-workspaces-chectl|g" \
		"$d" > "${TARGETDIR}/${d}"
	done <   <(find src test -type f -name "*" -print0)
popd >/dev/null

# Remove files
pushd "${TARGETDIR}" >/dev/null
	while IFS= read -r -d '' d; do
		echo "Delete ${d#./}"
		rm -f "$d"
		# 
	done <   <(find . -regextype posix-extended -iregex '.+/(helm|minishift|minishift-addon|minikube|microk8s|k8s|docker-desktop)(.test|).ts' -print0)
popd >/dev/null

# per-file changes:
platformString="    platform: string({\n\
      char: 'p',\n\
      description: 'Type of OpenShift platform. Valid values are \\\\\"openshift\\\\\", \\\\\"crc (for CodeReady Containers)\\\\\".',\n\
      options: ['openshift', 'crc'],\n\
      default: 'openshift'\n\
    }),"; # echo -e "$platformString"
installerString="    installer: string({\n\
      char: 'a',\n\
      description: 'Installer type',\n\
      options: ['operator'],\n\
      default: 'operator'\n\
    }),"; # echo -e "$installerString"
setPlaformDefaultsString="  static setPlaformDefaults(flags: any) {\n\
    flags.installer = 'operator'\n\
  }\n\
\n\
  checkPlatformCompatibility(flags: any) {\n\
    // matrix checks\n\
    if (flags.installer === 'operator' \&\& flags['che-operator-cr-yaml']) {\n\
      const ignoredFlags = []\n\
      flags['plugin-registry-url'] \&\& ignoredFlags.push('--plugin-registry-urlomain')\n\
      flags['devfile-registry-url'] \&\& ignoredFlags.push('--devfile-registry-url')\n\
      flags['postgres-pvc-storage-class-name'] \&\& ignoredFlags.push('--postgres-pvc-storage-class-name')\n\
      flags['workspace-pvc-storage-class-name'] \&\& ignoredFlags.push('--workspace-pvc-storage-class-name')\n\
      flags['self-signed-cert'] \&\& ignoredFlags.push('--self-signed-cert')\n\
      flags['os-oauth'] \&\& ignoredFlags.push('--os-oauth')\n\
      flags.tls \&\& ignoredFlags.push('--tls')\n\
      flags.cheimage \&\& ignoredFlags.push('--cheimage')\n\
      flags.debug \&\& ignoredFlags.push('--debug')\n\
      flags.domain \&\& ignoredFlags.push('--domain')\n\
\n\
      if (ignoredFlags.length) {\n\
        this.warn(\`--che-operator-cr-yaml is used. The following flag(s) will be ignored: \${ignoredFlags.join('\\\t')}\`)\n\
      }\n\
    }\n\
"
pushd "${TARGETDIR}" >/dev/null
	for d in src/commands/server/update.ts src/commands/server/start.ts; do
		echo "Convert ${d}"
		mkdir -p "${TARGETDIR}/${d%/*}"
		perl -0777 -p -i -e 's|(\ +platform: string\({.*?}\),)| ${1} =~ /.+minishift.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#INSERT-CONTENT-HERE#${platformString}#" -i "${TARGETDIR}/${d}"

		perl -0777 -p -i -e 's|(\ +installer: string\({.*?}\),)| ${1} =~ /.+minishift.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#INSERT-CONTENT-HERE#${installerString}#" -i "${TARGETDIR}/${d}"

		perl -0777 -p -i -e 's|(\ +static setPlaformDefaults.+ \{.*?.+matrix checks)|  ${1} =~ /.+minishift.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#INSERT-CONTENT-HERE#${setPlaformDefaultsString}#" -i "${TARGETDIR}/${d}"
	done
popd >/dev/null

pushd "${TARGETDIR}" >/dev/null
	d=src/common-flags.ts
	echo "Convert ${d}"
	mkdir -p "${TARGETDIR}/${d%/*}"
	sed -r \
		`# replace line after specified one with new default` \
		-e "/description: 'Kubernetes namespace/{n;s/.+/  default: 'workspaces',/}" \
		-e "/description: .+ deployment name.+/{n;s/.+/  default: 'codeready',/}" \
		-i "${TARGETDIR}/${d}" 
popd >/dev/null

operatorTasksString="export class OperatorTasks {\n\
  operatorServiceAccount = 'codeready-operator'\n\
  operatorRole = 'codeready-operator'\n\
  operatorClusterRole = 'codeready-operator'\n\
  operatorRoleBinding = 'codeready-operator'\n\
  operatorClusterRoleBinding = 'codeready-operator'\n\
  cheClusterCrd = 'checlusters.org.eclipse.che'\n\
  operatorName = 'codeready-operator'\n\
  operatorCheCluster = 'codeready-workspaces'\n\
  resourcesPath = ''"
pushd "${TARGETDIR}" >/dev/null
	d=src/tasks/installers/operator.ts
	echo "Convert ${d}"
	mkdir -p "${TARGETDIR}/${d%/*}"
	perl -0777 -p -i -e 's|(export class OperatorTasks.*?  resourcesPath = )|  ${1} =~ /.+che-operator.+/?"INSERT-CONTENT-HERE":${1}|gse' "${TARGETDIR}/${d}"
	sed -r -e "s#INSERT-CONTENT-HERE.+#${operatorTasksString}#" -i "${TARGETDIR}/${d}"
popd >/dev/null

# remove if blocks
pushd "${TARGETDIR}" >/dev/null
	for d in src/tasks/installers/installer.ts src/tasks/platforms/platform.ts; do
		echo "Convert ${d}"
		mkdir -p "${TARGETDIR}/${d%/*}"
		perl -0777 -p -i -e 's|(\/\* .+ BEGIN CHE ONLY \*\/?/.+ END CHE ONLY \*\/)|  ${1} =~ /.+else if.+/?"":${1}|gse' "${TARGETDIR}/${d}"
		sed -r -e "s#.*(import|const).+(Helm|Minishift|DockerDesktop|K8s|MicroK8s|Minikube).*Tasks.*##g" -i "${TARGETDIR}/${d}"
	done
popd >/dev/null
