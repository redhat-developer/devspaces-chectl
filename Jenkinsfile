#!/usr/bin/env groovy

// PARAMETERS for this pipeline:
// branchToBuildCTL = refs/tags/20190401211444 or master
// DESTINATION = user@host_or_ip:/path/to/che-incubator/chectl
// BASE_URL = https://host_or_ip/path/to/che-incubator/chectl

def installNPM(){
	def nodeHome = tool 'nodejs-10.15.3'
	env.PATH="${nodeHome}/bin:${env.PATH}"
	sh "node --version && npm version && yarn -v"
}

// TODO: re-add win-x64; fails due to missing 7zip: "Error: install 7-zip to package windows tarball"
def platforms = "linux-x64,darwin-x64,linux-arm"
def CTL_path = "codeready-workspaces-chectl"
def SHA_CTL = "SHA_CTL"

timeout(180) {
	node("rhel7-releng"){ withCredentials([string(credentialsId: 'codeready-bot', variable: 'GITHUB_TOKEN')]) { stage "Build ${CTL_path}"
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
        def CHECTL_VERSION="0.0.$CURRENT_DAY-next"
        def GITHUB_RELEASE_NAME="0.0.$CURRENT_DAY-next.${SHORT_SHA1}"
		def CUSTOM_TAG=sh(returnStdout:true,script:"date +'%Y%m%d%H%M%S'").trim()
		SHA_CTL = sh(returnStdout:true,script:"cd ${CTL_path}/ && git rev-parse --short=4 HEAD").trim()
		sh "cd ${CTL_path}/ && sed -i -e 's#version\": \"\\(.*\\)\",#version\": \"'${CHECTL_VERSION}'\",#' package.json"
		sh "cd ${CTL_path}/ && egrep -v 'versioned|oclif' package.json | grep -e version"
        sh "cd ${CTL_path}/ && git tag '${CUSTOM_TAG}'"
		sh "cd ${CTL_path}/ && yarn && npx oclif-dev pack -t ${platforms} && find ./dist/ -name \"*.tar*\""
        def RELEASE_NAME="${CUSTOM_TAG}"
        def RELEASE_DESCRIPTION="CI release ${RELEASE_NAME} ${SHA_CTL}"
		sh "curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' --data '{\"tag_name\": \"${CUSTOM_TAG}\", \"target_commitish\": \"master\", \"name\": \"${RELEASE_NAME}\", \"body\": \"${RELEASE_DESCRIPTION}\", \"draft\": false, \"prerelease\": true}' https://api.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases > /tmp/${CUSTOM_TAG}"
		// Extract the id of the release from the creation response
        def RELEASE_ID=sh(returnStdout:true,script:"jq -r .id /tmp/${CUSTOM_TAG}").trim()
		// Upload the artifacts
        sh "cd ${CTL_path}/dist/channels/next/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @chectl-linux-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=chectl-linux-x64.tar.gz"
        sh "cd ${CTL_path}/dist/channels/next/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @chectl-linux-arm.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=chectl-linux-arm.tar.gz"
        sh "cd ${CTL_path}/dist/channels/next/ && curl -XPOST -H 'Authorization:token ${GITHUB_TOKEN}' -H 'Content-Type:application/octet-stream' --data-binary @chectl-darwin-x64.tar.gz https://uploads.github.com/repos/redhat-developer/codeready-workspaces-chectl/releases/${RELEASE_ID}/assets?name=chectl-darwin-x64.tar.gz"
        // refresh github pages
		sh "cd ${CTL_path}/ && git clone https://devstudio-release:${GITHUB_TOKEN}@github.com/redhat-developer/codeready-workspaces-chectl -b gh-pages --single-branch gh-pages"
		sh "cd ${CTL_path}/ && echo \$(date +%s) > gh-pages/update"
		sh "cd ${CTL_path}/gh-pages && git add update && git commit -m \"Update github pages\" && git push origin gh-pages"
		stash name: 'stashDist', includes: findFiles(glob: "${CTL_path}/dist/").join(", ")
	}}
}
timeout(180) {
	node("rhel7-releng"){ stage "Publish ${CTL_path}"
		unstash 'stashDist'
		archiveArtifacts fingerprint: false, artifacts:"**/*.log, **/*logs/**, **/dist/**/*.tar.gz, **/dist/*.json, **/dist/linux-x64, **/dist/linux-arm, **/dist/darwin-x64"
	}
}
