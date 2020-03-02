#!/usr/bin/env groovy

// PARAMETERS for this pipeline:
// branchToBuildCTL = refs/tags/20190401211444 or master
// version = if set, use as version prefix before commitSHA, eg., 2.1.0.RC1 --> 2.1.0.RC1-commitSHA; 
// 			 if unset, version is 0.0.YYYYmmdd-next.commitSHA

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

timeout(180) {
	node("rhel7-releng"){ 
		withCredentials([string(credentialsId: 'codeready-bot', variable: 'GITHUB_TOKEN')]) { 
			stage "Build ${CTL_path}"
			cleanWs()
			checkout([$class: 'GitSCM', 
				branches: [[name: "${branchToBuildCTL}"]], 
				doGenerateSubmoduleConfigurations: false, 
				poll: true,
				extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "${CTL_path}"]], 
				submoduleCfg: [], 
				userRemoteConfigs: [[url: "https://github.com/redhat-developer/${CTL_path}.git"]]])
			installNPM()
			def CURRENT_DAY=sh(returnStdout:true,script:"date +'%Y%m%d'").trim()
			def SHORT_SHA1=sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short HEAD").trim()
			def CHECTL_VERSION=""
			def GITHUB_RELEASE_NAME=""
			if ("${version}") {
				CHECTL_VERSION="${version}"
				GITHUB_RELEASE_NAME="${version}-${SHORT_SHA1}"
			} else {
				CHECTL_VERSION="0.0.$CURRENT_DAY-next"
				GITHUB_RELEASE_NAME="0.0.$CURRENT_DAY-next.${SHORT_SHA1}"
			}
			def CUSTOM_TAG=GITHUB_RELEASE_NAME // OLD way: sh(returnStdout:true,script:"date +'%Y%m%d%H%M%S'").trim()
			SHA_CTL = sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short=4 HEAD").trim()
			sh '''#!/bin/bash -xe
			cd ''' + CTL_path + '''
			jq -M --arg CHECTL_VERSION \"''' + CHECTL_VERSION + '''\" '.version = $CHECTL_VERSION' package.json > package.json2
			diff -u package.json* || true
			mv -f package.json2 package.json
			git tag "''' + CUSTOM_TAG + '''"
			rm yarn.lock
			yarn && npx oclif-dev pack -t ''' + platforms + ''' && find ./dist/ -name "*.tar*"
			'''
			def RELEASE_DESCRIPTION="CI release ${GITHUB_RELEASE_NAME}"
			sh "curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' --data '{\"tag_name\": \"${CUSTOM_TAG}\", \"target_commitish\": \"master\", \"name\": \"${GITHUB_RELEASE_NAME}\", \"body\": \"${RELEASE_DESCRIPTION}\", \"draft\": false, \"prerelease\": true}' https://api.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases > /tmp/${CUSTOM_TAG}"
			// Extract the id of the release from the creation response
			def RELEASE_ID=sh(returnStdout:true,script:"jq -r .id /tmp/${CUSTOM_TAG}").trim()
			// Upload the artifacts
			sh "cd ${CTL_path}/dist/channels/next/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @crwctl-linux-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=crwctl-linux-x64.tar.gz"
			sh "cd ${CTL_path}/dist/channels/next/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @crwctl-win32-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=crwctl-win32-x64.tar.gz"
			sh "cd ${CTL_path}/dist/channels/next/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @crwctl-darwin-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=crwctl-darwin-x64.tar.gz"
			// refresh github pages
			sh "cd ${CTL_path}/ && git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/codeready-workspaces-chectl -b gh-pages --single-branch gh-pages"
			sh "cd ${CTL_path}/ && echo \$(date +%s) > gh-pages/update"
			sh "cd ${CTL_path}/gh-pages && git add update && git commit -m \"Update github pages\" && git push origin gh-pages"
			archiveArtifacts fingerprint: false, artifacts:"**/*.log, **/*logs/**, **/dist/**/*.tar.gz, **/dist/*.json, **/dist/linux-x64, **/dist/win32-x64, **/dist/darwin-x64"
		}
	}
}
