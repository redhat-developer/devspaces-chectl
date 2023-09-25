dsc is built in Jenkins and published to https://developers.redhat.com/products/codeready-workspaces/download

To build in Jenkins:

* https://main-jenkins-csb-crwqe.apps.ocp-c1.prod.psi.redhat.com/job/DS_CI/ (jobs)
* https://gitlab.cee.redhat.com/codeready-workspaces/crw-jenkins/-/tree/master/jobs/DS_CI (sources)
* https://github.com/redhat-developer/devspaces-images#jenkins-jobs (copied sources)

To sync from upstream and build:

```
pushd /tmp >/dev/null || exit
git clone https://github.com/redhat-developer/devspaces-images.git
git clone https://github.com/che-incubator/chectl.git
popd >/dev/null || exit

./build/scripts/build.sh -v 3.10.0 -s /tmp/chectl/ -i /tmp/devspaces_images -t `pwd` -b devspaces-3-rhel-8 --ds-version 3.10 --suffix CI
```

Or, to build a container locally including binary and source tarballs:

```
podman build . -t quay.io/devspaces/dsc:next -f build/dockerfiles/Dockerfile 
```

To extract dsc from the container built in the previous step, and install it under /tmp/dsc:

```
./build/scripts/installDscFromContainer.sh quay.io/devspaces/dsc:next -v
```

To build in Dev Sandbox:

1. Launch a workspace from the [devfile.yaml](devfile.yaml) in this repo.
2. See `To build locally` commands above, or check the commands in the [devfile.yaml](devfile.yaml).
