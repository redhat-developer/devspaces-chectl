#!/usr/bin/env groovy

// PARAMETERS for this pipeline:
// PUBLISH_ARTIFACTS = check box for true, uncheck for false
// branchToBuild     = refs/tags/20190401211444 or master
// version           = if set, use as version prefix before commitSHA, eg., 2.1.0-RC1 --> 2.1.0-RC1-commitSHA;
// 			           if unset, version is 0.0.YYYYmmdd-next.commitSHA
//                  :: NOTE: yarn will fail for version = x.y.z.a but works with x.y.z-a

def installNPM(){
	def yarnVersion="1.17.3"
	def nodeHome = tool 'nodejs-10.14.1'
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

def platforms = "linux-x64,darwin-x64,win32-x64"
def CTL_path = "codeready-workspaces-chectl"
def SHA_CTL = "SHA_CTL"
def GITHUB_RELEASE_NAME=""
def slackLink=""

timeout(180) {
	node("rhel7-releng"){ 
	  try {
		currentBuild.description="Running..."
		notifyBuild('STARTED', '')

		withCredentials([string(credentialsId:'devstudio-release.token', variable: 'GITHUB_TOKEN')]) {
			stage "Build ${CTL_path}"
			cleanWs()
			checkout([$class: 'GitSCM', 
				branches: [[name: "${branchToBuild}"]],
				doGenerateSubmoduleConfigurations: false, 
				poll: true,
				extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "${CTL_path}"]], 
				submoduleCfg: [], 
				userRemoteConfigs: [[url: "https://github.com/redhat-developer/${CTL_path}.git"]]])
			installNPM()
			def CURRENT_DAY=sh(returnStdout:true,script:"date +'%Y%m%d'").trim()
			def SHORT_SHA1=sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short HEAD").trim()
			def CHECTL_VERSION=""
			if ("${version}") {
				CHECTL_VERSION="${version}"
				GITHUB_RELEASE_NAME="${version}-${SHORT_SHA1}"
			} else {
				CHECTL_VERSION="0.0.$CURRENT_DAY-next"
				GITHUB_RELEASE_NAME="0.0.$CURRENT_DAY-next-${SHORT_SHA1}"
			}
			def CUSTOM_TAG=GITHUB_RELEASE_NAME // OLD way: sh(returnStdout:true,script:"date +'%Y%m%d%H%M%S'").trim()
			SHA_CTL = sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short=4 HEAD").trim()
			sh '''#!/bin/bash -xe
			cd ''' + CTL_path + '''
			# clean up from previous build if applicable
			rm -fr dist/channels/
			jq -M --arg CHECTL_VERSION \"''' + CHECTL_VERSION + '''\" '.version = $CHECTL_VERSION' package.json > package.json2
			diff -u package.json* || true
			mv -f package.json2 package.json
			git tag -f "''' + CUSTOM_TAG + '''"
			rm yarn.lock
			yarn && npx oclif-dev pack -t ''' + platforms + ''' && find ./dist/ -name "*.tar*"
			'''
			def RELEASE_DESCRIPTION=""
			if ("${version}") {
				RELEASE_DESCRIPTION="Stable release ${GITHUB_RELEASE_NAME}"
			} else {
				RELEASE_DESCRIPTION="CI release ${GITHUB_RELEASE_NAME}"
			}
			// RENAME artifacts to include version in the tarball: codeready-workspaces-2.1.0-crwctl-*.tar.gz
			def TARBALL_PREFIX="codeready-workspaces-${CHECTL_VERSION}"

			// Upload the artifacts and rename them on the fly to add ${TARBALL_PREFIX}-
			if (PUBLISH_ARTIFACTS.equals("true"))
			{
				sh "curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' --data '{\"tag_name\": \"${CUSTOM_TAG}\", \"target_commitish\": \"master\", \"name\": \"${GITHUB_RELEASE_NAME}\", \"body\": \"${RELEASE_DESCRIPTION}\", \"draft\": false, \"prerelease\": true}' https://api.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases > /tmp/${CUSTOM_TAG}"
				// Extract the id of the release from the creation response
				def RELEASE_ID=sh(returnStdout:true,script:"jq -r .id /tmp/${CUSTOM_TAG}").trim()

				sh "cd ${CTL_path}/dist/channels/*/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @crwctl-linux-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-linux-x64.tar.gz"
				sh "cd ${CTL_path}/dist/channels/*/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @crwctl-win32-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-win32-x64.tar.gz"
				sh "cd ${CTL_path}/dist/channels/*/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @crwctl-darwin-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=${TARBALL_PREFIX}-crwctl-darwin-x64.tar.gz"
				// refresh github pages
				sh "cd ${CTL_path}/ && git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/codeready-workspaces-chectl -b gh-pages --single-branch gh-pages"
				sh "cd ${CTL_path}/ && echo \$(date +%s) > gh-pages/update"
				sh "cd ${CTL_path}/gh-pages && git add update && git commit -m \"Update github pages\" && git push origin gh-pages"
				currentBuild.description = "<a href=https://github.com/redhat-developer/codeready-workspaces-chectl/releases/tag/" + GITHUB_RELEASE_NAME + ">" + GITHUB_RELEASE_NAME + "</a>"
				// slackLink="https://github.com/redhat-developer/codeready-workspaces-chectl/releases/tag/" + GITHUB_RELEASE_NAME
			} else {
				echo 'PUBLISH_ARTIFACTS != true, so nothing published to github.'
				currentBuild.description = GITHUB_RELEASE_NAME + " not published"
			}
			sh "cd ${CTL_path}/dist/channels/ && mv `find . -type d -not -name '.'` latest"
			archiveArtifacts fingerprint: false, artifacts:"**/*.log, **/*logs/**, **/dist/**/*.tar.gz, **/dist/*.json, **/dist/linux-x64, **/dist/win32-x64, **/dist/darwin-x64"
		}

	  } catch (e) {
		// If there was an exception thrown, the build failed
		currentBuild.result = "FAILED"
		throw e
	  } finally {
		// If success or failure, send notifications
		notifyBuild(currentBuild.result, " :: " + (slackLink ? slackLink : "${currentBuild.description}"))
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

  // always send slack message
  // disabled as slackSend plugin is incompatible with Kerberos SSO plugin on our Jenkins
  // slackSend (color: colorCode, message: summary)
}
