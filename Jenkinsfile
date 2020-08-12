#!/usr/bin/env groovy

// PARAMETERS for this pipeline:
// branchCHECTL      = branch or tag of https://github.com/che-incubator/chectl - 7.17.x or master
// branchCRWCTL      = branch or tag of https://redhat-developer/codeready-workspaces-chectl - crw-2.4-rhel-8
// CSV_VERSION       = Full version (x.y.z), used in CSV and crwctl version
// CRW_SERVER_TAG    = default to 2.3, but can override and set 2.3-zz for GA release
// CRW_OPERATOR_TAG  = default to 2.3, but can override and set 2.3-zz for GA release
// versionSuffix     = if set, use as version suffix before commitSHA, eg., RC --> 2.3.0-RC-commitSHA;
//                     if unset, version is CSV_VERSION-YYYYmmdd-commitSHA
//                  :: NOTE: yarn will fail for version = x.y.z.a but works with x.y.z-a
// PUBLISH_ARTIFACTS_TO_GITHUB = default false; check box to publish to GH releases
// PUBLISH_ARTIFACTS_TO_RCM    = default false; check box to upload sources + binaries to RCM for a GA release ONLY

def CRW_OPERATOR_DEPLOY_BRANCH=branchCRWCTL // eg., "crw-2.4-rhel-8"

def installNPM(){
	def yarnVersion="1.17.3"
	def nodeHome = tool 'nodejs-10.19.0'
	env.PATH="${nodeHome}/bin:${env.PATH}"
	// remove windows 7z if installed
	sh "rm -fr ${nodeHome}/lib/node_modules/7zip"
	// link to rpm-installed p7zip
	sh "if [[ -x /usr/bin/7za ]]; then pushd ${nodeHome}/bin >/dev/null; rm -f 7z*; ln -s /usr/bin/7za 7z; popd >/dev/null; fi"
		sh '''#!/bin/bash -xe
rm -f ${HOME}/.npmrc ${HOME}/.yarnrc
npm install --global yarn@''' + yarnVersion + '''
node --version && npm --version; yarn --version
'''
	// sh "whereis node" // /mnt/hudson_workspace/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs-10.15.3/
}

def buildNode = "rhel7-releng" // slave label
def platforms = "linux-x64,darwin-x64,win32-x64"
def CTL_path = "codeready-workspaces-chectl"
def SHA_CTL = "SHA_CTL"
def GITHUB_RELEASE_NAME=""

timeout(20) {
    node("${buildNode}"){
        stage "Checkout crw-operator deploy"
        // check out crw-operator so we can use it as a poll trigger: will reuse sources later
        checkout([$class: 'GitSCM', 
          branches: [[name: "${CRW_OPERATOR_DEPLOY_BRANCH}"]], 
          doGenerateSubmoduleConfigurations: false, 
          poll: true,
          extensions: [
            [$class: 'RelativeTargetDirectory', relativeTargetDir: "codeready-workspaces-operator"],
            [$class: 'PathRestriction', excludedRegions: '', includedRegions: 'controller-manifests/.*, deploy/.*, manifests/.*, metadata/.*'],
            [$class: 'DisableRemotePoll']
          ],
          submoduleCfg: [], 
          userRemoteConfigs: [[url: "https://github.com/redhat-developer/codeready-workspaces-operator.git"]]])
    }
}

timeout(20) {
	node("${buildNode}"){ 
	  try {
		currentBuild.description="Running..."
		notifyBuild('STARTED', '')

	    withCredentials([string(credentialsId:'devstudio-release.token', variable: 'GITHUB_TOKEN'), 
          file(credentialsId: 'crw-build.keytab', variable: 'CRW_KEYTAB')]) {
			stage "Build ${CTL_path}"
			cleanWs()
			checkout([$class: 'GitSCM', 
				branches: [[name: "${branchCRWCTL}"]],
				doGenerateSubmoduleConfigurations: false, 
				// disable polling since every build pushes a commit, which triggers a new build ad infinitum
				poll: false,
				extensions: [
					[$class: 'RelativeTargetDirectory', relativeTargetDir: "${CTL_path}"],
					[$class: 'PathRestriction', excludedRegions: 'README.md, package.json', includedRegions: 'src/.*, test/.*'],
					[$class: 'DisableRemotePoll']
				],
				submoduleCfg: [], 
				userRemoteConfigs: [[url: "https://github.com/redhat-developer/${CTL_path}.git"]]])
			installNPM()
			def CURRENT_DAY=sh(returnStdout:true,script:"date +'%Y%m%d-%H%M'").trim()
			def SHORT_SHA1=sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short HEAD").trim()
			def CHECTL_VERSION=""
			if ("${versionSuffix}") {
				CHECTL_VERSION="${CSV_VERSION}-${versionSuffix}"
				GITHUB_RELEASE_NAME="${CSV_VERSION}-${versionSuffix}-${SHORT_SHA1}"
			} else {
				CHECTL_VERSION="${CSV_VERSION}-$CURRENT_DAY"
				GITHUB_RELEASE_NAME="${CSV_VERSION}-$CURRENT_DAY-${SHORT_SHA1}"
			}
			def CUSTOM_TAG=GITHUB_RELEASE_NAME // OLD way: sh(returnStdout:true,script:"date +'%Y%m%d%H%M%S'").trim()

			// RENAME artifacts to include version in the tarball: codeready-workspaces-2.1.0-crwctl-*.tar.gz
			def TARBALL_PREFIX="codeready-workspaces-${CHECTL_VERSION}"

			SHA_CTL = sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short=4 HEAD").trim()
			sh '''#!/bin/bash -xe
			cd ''' + CTL_path + '''

			# 0. sync from upstream chectl
			pushd ${WORKSPACE} >/dev/null
				git clone https://github.com/che-incubator/chectl
				cd chectl
				git checkout ''' + branchCHECTL + '''
			popd >/dev/null
			git checkout ''' + branchCRWCTL + '''
			# OLD WAY: CRW_TAG="''' + CSV_VERSION + '''"; CRW_TAG=${CRW_TAG%.*} # for 2.1.0 -> 2.1
			# ./sync-chectl-to-crwctl.sh ${WORKSPACE}/chectl ${WORKSPACE}/crwctl_generated ${CRW_TAG} ${CRW_TAG}
			./sync-chectl-to-crwctl.sh ${WORKSPACE}/chectl ${WORKSPACE}/crwctl_generated ${CRW_SERVER_TAG} ${CRW_OPERATOR_TAG}
			# check for differences
			set +x
			for d in $(cd ${WORKSPACE}/crwctl_generated/; find src test -type f); do diff -u ${d} ${WORKSPACE}/crwctl_generated/${d} || true; done
			# apply differences
			rsync -aqrz ${WORKSPACE}/crwctl_generated/* .
			git config user.email "nickboldt+devstudio-release@gmail.com"
			git config user.name "Red Hat Devstudio Release Bot"
			git config --global push.default matching

			# SOLVED :: Fatal: Could not read Username for "https://github.com", No such device or address :: https://github.com/github/hub/issues/1644
			git remote -v
			git config --global hub.protocol https
			git remote set-url origin https://\$GITHUB_TOKEN:x-oauth-basic@github.com/redhat-developer/''' + CTL_path + '''.git
			git remote -v

			# ls -la
			set -x
			git add src/ test/ docs/
			git commit -s -m "[sync] Push latest in chectl @ ''' + branchCHECTL + ''' to codeready-workspaces-chectl @ '''+branchCRWCTL+'''" . || true
			git push origin '''+branchCRWCTL+''' || true

			#### 1. build using -redhat suffix and registry.redhat.io/codeready-workspaces/ URLs

			# clean up from previous build if applicable
			jq -M --arg CHECTL_VERSION \"''' + CHECTL_VERSION + '''-redhat\" '.version = $CHECTL_VERSION' package.json > package.json2; mv -f package.json2 package.json
			git diff -u package.json
			git tag -f "''' + CUSTOM_TAG + '''-redhat"
			rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo dist/
			yarn && npx oclif-dev pack -t ''' + platforms + '''
			# move from *-redhat/ (specific folder, generic name) to redhat/ (generic folder, specific name)
			mv dist/channels/*redhat dist/channels/redhat
			while IFS= read -r -d '' d; do
				e=${d/redhat\\/crwctl/redhat\\/'''+TARBALL_PREFIX+'''-crwctl}
 				mv ${d} ${e}
			done <   <(find dist/channels/redhat -type f -name "*gz" -print0)
			pwd; du ./dist/channels/*/*gz

			git commit -s -m "[update] commit latest package.json + README.md" package.json README.md || true
			git push origin '''+branchCRWCTL+''' || true

			#### 2. prepare branchCRWCTL-quay branch of crw operator repo

			# check out from branchCRWCTL
			pushd ${WORKSPACE} >/dev/null
				if [[ ! -d codeready-workspaces-operator/ ]]; then 
					git clone https://github.com/redhat-developer/codeready-workspaces-operator.git
				fi
				cd codeready-workspaces-operator/
				git config user.email "nickboldt+devstudio-release@gmail.com"
				git config user.name "Red Hat Devstudio Release Bot"
				git config --global push.default matching
				# SOLVED :: Fatal: Could not read Username for "https://github.com", No such device or address :: https://github.com/github/hub/issues/1644
				git remote -v
				git config --global hub.protocol https
				git remote set-url origin https://\$GITHUB_TOKEN:x-oauth-basic@github.com/redhat-developer/codeready-workspaces-operator.git
				git remote -v
				git branch '''+branchCRWCTL+'''-quay -f
				git checkout '''+branchCRWCTL+'''-quay
				# change files
				# TODO when we move to OCP 4.6 bundle format, must switch to manifests/ folder & new path structure
				FILES="deploy/operator.yaml deploy/operator-local.yaml controller-manifests/v''' + CSV_VERSION + '''/codeready-workspaces.csv.yaml"
				for d in ${FILES}; do
					# point to quay image, and use :latest instead of :2.x tag
					sed -i ${d} -r -e "s#registry.redhat.io/codeready-workspaces/(.+):(.+)#quay.io/crw/\\1:latest#g"
				done
				# push to '''+branchCRWCTL+'''-quay branch
				git commit -s -m "[update] Push latest in '''+branchCRWCTL+''' to '''+branchCRWCTL+'''-quay branch" ${FILES}
				git push origin '''+branchCRWCTL+'''-quay -f
			popd >/dev/null
			# cleanup
			rm -fr ${WORKSPACE}/codeready-workspaces-operator/
 
			#### 3. now build using '''+branchCRWCTL+'''-quay branch, -quay suffix and quay.io/crw/ URLs

			YAML_REPO="`cat package.json | jq -r '.dependencies["codeready-workspaces-operator"]'`-quay"
			jq -M --arg YAML_REPO \"${YAML_REPO}\" '.dependencies["codeready-workspaces-operator"] = $YAML_REPO' package.json > package.json2
			jq -M --arg CHECTL_VERSION \"''' + CHECTL_VERSION + '''-quay\" '.version = $CHECTL_VERSION' package.json2 > package.json
			git diff -u package.json
			git tag -f "''' + CUSTOM_TAG + '''-quay"
			rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo
			yarn && npx oclif-dev pack -t ''' + platforms + '''
			mv dist/channels/*quay dist/channels/latest
			rm -fr dist/channels/quay; mkdir -p dist/channels/quay
			# copy from latest/ (generic folder, generic name) to quay/ (generic folder, specific name)
			# need this so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
			while IFS= read -r -d '' d; do
				e=${d/latest\\/crwctl/quay\\/'''+TARBALL_PREFIX+'''-crwctl}
 				cp ${d} ${e}
			done <   <(find dist/channels/latest -type f -name "*gz" -print0)
			pwd; du ./dist/channels/*/*gz
			'''
			def RELEASE_DESCRIPTION=""
			if ("${versionSuffix}") {
				RELEASE_DESCRIPTION="Stable release ${GITHUB_RELEASE_NAME}"
			} else {
				RELEASE_DESCRIPTION="CI release ${GITHUB_RELEASE_NAME}"
			}

			// Upload the artifacts and rename them on the fly to add ${TARBALL_PREFIX}-
			if (PUBLISH_ARTIFACTS_TO_GITHUB.equals("true"))
			{
				def isPreRelease="true"; if ( "${versionSuffix}" == "GA" ) { isPreRelease="false"; }
				sh "curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' --data '{\"tag_name\": \"${CUSTOM_TAG}\", \"target_commitish\": \"${branchCRWCTL}\", \"name\": \"${GITHUB_RELEASE_NAME}\", \"body\": \"${RELEASE_DESCRIPTION}\", \"draft\": false, \"prerelease\": ${isPreRelease}}' https://api.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases > /tmp/${CUSTOM_TAG}"

				// Extract the id of the release from the creation response
				def RELEASE_ID=sh(returnStdout:true,script:"jq -r .id /tmp/${CUSTOM_TAG}").trim()

				sh "cd ${CTL_path}/dist/channels/quay/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @${TARBALL_PREFIX}-crwctl-linux-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-linux-x64.tar.gz"
				sh "cd ${CTL_path}/dist/channels/quay/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @${TARBALL_PREFIX}-crwctl-win32-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-win32-x64.tar.gz"
				sh "cd ${CTL_path}/dist/channels/quay/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @${TARBALL_PREFIX}-crwctl-darwin-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-darwin-x64.tar.gz"
				// refresh github pages
				sh "cd ${CTL_path}/ && git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/codeready-workspaces-chectl -b gh-pages --single-branch gh-pages"
				sh "cd ${CTL_path}/ && echo \$(date +%s) > gh-pages/update"
				sh "cd ${CTL_path}/gh-pages && git add update && git commit -m \"Update github pages\" && git push origin gh-pages"
			}

			archiveArtifacts fingerprint: false, artifacts:"**/*.log, **/*logs/**, **/dist/**/*.tar.gz, **/dist/*.json, **/dist/linux-x64, **/dist/win32-x64, **/dist/darwin-x64"

			// Upload the artifacts and sources to RCM_GUEST server
			if (PUBLISH_ARTIFACTS_TO_RCM.equals("true"))
			{
            	sh '''#!/bin/bash -xe

# bootstrapping: if keytab is lost, upload to 
# https://codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/credentials/store/system/domain/_/
# then set Use secret text above and set Bindings > Variable (path to the file) as ''' + CRW_KEYTAB + '''
chmod 700 ''' + CRW_KEYTAB + ''' && chown ''' + USER + ''' ''' + CRW_KEYTAB + '''
# create .k5login file
echo "crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@REDHAT.COM" > ~/.k5login
chmod 644 ~/.k5login && chown ''' + USER + ''' ~/.k5login
echo "pkgs.devel.redhat.com,10.19.208.80 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAplqWKs26qsoaTxvWn3DFcdbiBxqRLhFngGiMYhbudnAj4li9/VwAJqLm1M6YfjOoJrj9dlmuXhNzkSzvyoQODaRgsjCG5FaRjuN8CSM/y+glgCYsWX1HFZSnAasLDuW0ifNLPR2RBkmWx61QKq+TxFDjASBbBywtupJcCsA5ktkjLILS+1eWndPJeSUJiOtzhoN8KIigkYveHSetnxauxv1abqwQTk5PmxRgRt20kZEFSRqZOJUlcl85sZYzNC/G7mneptJtHlcNrPgImuOdus5CW+7W49Z/1xqqWI/iRjwipgEMGusPMlSzdxDX4JzIx6R53pDpAwSAQVGDz4F9eQ==
rcm-guest.app.eng.bos.redhat.com,10.16.101.129 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApd6cnyFVRnS2EFf4qeNvav0o+xwd7g7AYeR9dxzJmCR3nSoVHA4Q/kV0qvWkyuslvdA41wziMgSpwq6H/DPLt41RPGDgJ5iGB5/EDo3HAKfnFmVAXzYUrJSrYd25A1eUDYHLeObtcL/sC/5bGPp/0deohUxLtgyLya4NjZoYPQY8vZE6fW56/CTyTdCEWohDRUqX76sgKlVBkYVbZ3uj92GZ9M88NgdlZk74lOsy5QiMJsFQ6cpNw+IPW3MBCd5NHVYFv/nbA3cTJHy25akvAwzk8Oi3o9Vo0Z4PSs2SsD9K9+UvCfP1TUTI4PXS8WpJV6cxknprk0PSIkDdNODzjw==
" >> ~/.ssh/known_hosts

ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# see https://mojo.redhat.com/docs/DOC-1071739
if [[ -f ~/.ssh/config ]]; then mv -f ~/.ssh/config{,.BAK}; fi
echo "
GSSAPIAuthentication yes
GSSAPIDelegateCredentials yes

Host pkgs.devel.redhat.com
User crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@REDHAT.COM
" > ~/.ssh/config
chmod 600 ~/.ssh/config

# initialize kerberos
export KRB5CCNAME=/var/tmp/crw-build_ccache
kinit "crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@REDHAT.COM" -kt ''' + CRW_KEYTAB + '''
klist # verify working

# generate source tarball
pushd ${WORKSPACE}/''' + CTL_path + ''' >/dev/null
	# purge generated binaries and temp files
	rm -fr coverage/ lib/ node_modules/ templates/ tmp/ 
	tar czf ${WORKSPACE}/''' + TARBALL_PREFIX + '''-crwctl-sources.tar.gz --exclude=dist/ ./*
popd >/dev/null 

# set up sshfs mount
DESTHOST="crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@rcm-guest.app.eng.bos.redhat.com"
RCMG="${DESTHOST}:/mnt/rcm-guest/staging/crw"
sshfs --version
for mnt in RCMG; do 
  mkdir -p ${WORKSPACE}/${mnt}-ssh; 
  if [[ $(file ${WORKSPACE}/${mnt}-ssh 2>&1) == *"Transport endpoint is not connected"* ]]; then fusermount -uz ${WORKSPACE}/${mnt}-ssh; fi
  if [[ ! -d ${WORKSPACE}/${mnt}-ssh/crw ]]; then  sshfs ${!mnt} ${WORKSPACE}/${mnt}-ssh; fi
done

# copy files to rcm-guest
ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/crw && mkdir -p CRW-''' + CSV_VERSION + '''/ && ls -la . "
rsync -Pzrlt --rsh=ssh --protocol=28 \
    ${WORKSPACE}/''' + TARBALL_PREFIX + '''-crwctl-sources.tar.gz \
    ${WORKSPACE}/''' + CTL_path + '''/dist/channels/redhat/*gz \
    ${WORKSPACE}/${mnt}-ssh/CRW-''' + CSV_VERSION + '''/
ssh "${DESTHOST}" "cd /mnt/rcm-guest/staging/crw/CRW-''' + CSV_VERSION + '''/ && ls -la ''' + TARBALL_PREFIX + '''*"
ssh "${DESTHOST}" "/mnt/redhat/scripts/rel-eng/utility/bus-clients/stage-mw-release CRW-''' + CSV_VERSION + '''"
'''
			}

			if (!PUBLISH_ARTIFACTS_TO_GITHUB.equals("true") && !PUBLISH_ARTIFACTS_TO_RCM.equals("true")) {
				echo 'PUBLISH_ARTIFACTS_TO_GITHUB != true, so nothing published to github.'
				echo 'PUBLISH_ARTIFACTS_TO_RCM != true, so nothing published to RCM_GUEST.'
				currentBuild.description = GITHUB_RELEASE_NAME + " not published"
			} else if (!PUBLISH_ARTIFACTS_TO_GITHUB.equals("true") && PUBLISH_ARTIFACTS_TO_RCM.equals("true")) {
				currentBuild.description = "Published to RCM: " + GITHUB_RELEASE_NAME
			} else if (PUBLISH_ARTIFACTS_TO_GITHUB.equals("true") && !PUBLISH_ARTIFACTS_TO_RCM.equals("true")) {
				currentBuild.description = "<a href=https://github.com/redhat-developer/codeready-workspaces-chectl/releases/tag/" + GITHUB_RELEASE_NAME + ">" + GITHUB_RELEASE_NAME + "</a>"
			} else if (PUBLISH_ARTIFACTS_TO_GITHUB.equals("true") && PUBLISH_ARTIFACTS_TO_RCM.equals("true")) {
				currentBuild.description = "<a href=https://github.com/redhat-developer/codeready-workspaces-chectl/releases/tag/" + GITHUB_RELEASE_NAME + ">" + GITHUB_RELEASE_NAME + "</a>; published to RCM"
			}
		}
	  } catch (e) {
		// If there was an exception thrown, the build failed
		currentBuild.result = "FAILED"
		throw e
	  } finally {
		// If success or failure, send notifications
		notifyBuild(currentBuild.result, " :: " + "${currentBuild.description}")
	  }
	}
}

def notifyBuild(String buildStatus = 'STARTED', String buildDesc = '') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "Build ${buildStatus} in Jenkins: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
  // def summary = "${subject} :: ${env.BUILD_URL}${buildDesc}"
  // NOTE: ${env.BUILD_URL} = ${env.JENKINS_URL}/job/${env.JOB_NAME}/${env.BUILD_NUMBER}
  def details = """
Build ${buildStatus} in Jenkins for ${env.JOB_NAME} #${env.BUILD_NUMBER} !

Build:

${env.BUILD_URL} or
${env.BUILD_URL}/display/redirect

Changes & parameters:

${env.BUILD_URL}/changes
${env.BUILD_URL}/parameters

Console & steps:

${env.BUILD_URL}/console
${env.BUILD_URL}/flowGraphTable

 """

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send emails only for failure
  if (currentBuild.result.equals("FAILED")) {
	currentBuild.description="${GITHUB_RELEASE_NAME} failed!"
	emailext (
		subject: subject,
		body: details,
		recipientProviders: [[$class: 'DevelopersRecipientProvider']]
		)
  }

  // NOTE: slackSend plugin is incompatible with Kerberos SSO plugin on our Jenkins
}
