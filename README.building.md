dsc is built in Jenkins and published to https://developers.redhat.com/products/codeready-workspaces/download

To build in Jenkins:

* https://main-jenkins-csb-crwqe.apps.ocp-c1.prod.psi.redhat.com/job/DS_CI/ (jobs)
* https://gitlab.cee.redhat.com/codeready-workspaces/crw-jenkins/-/tree/master/jobs/DS_CI (sources)
* https://github.com/redhat-developer/devspaces-images#jenkins-jobs (copied sources)

To build locally:

```
# purge local yarn cache
rm -fr $HOME/.cache/yarn/v6/

# sync from upstream chectl
./build/scripts/sync.sh -b devspaces-3-rhel-8 \
  -s ${WORKSPACE}/chectl \
  -t ${WORKSPACE}/dsc \
	--server-tag 3.y-zz --operator-tag 3.y-zzz

# build for multiple platforms
platforms="linux-x64,darwin-x64,darwin-arm64,win32-x64"
yarn && npx oclif-dev pack -t ${platforms}
```
