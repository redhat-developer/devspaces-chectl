dsc is built in Jenkins and published to https://developers.redhat.com/products/codeready-workspaces/download

To build in Jenkins:

* https://main-jenkins-csb-crwqe.apps.ocp-c1.prod.psi.redhat.com/job/DS_CI/ (jobs)
* https://gitlab.cee.redhat.com/codeready-workspaces/crw-jenkins/-/tree/master/jobs/DS_CI (sources)
* https://github.com/redhat-developer/devspaces-images#jenkins-jobs (copied sources)

To build locally:

```
podman build . -t localhost/dsc:next -f build/dockerfiles/Dockerfile 
```

To extract dsc from the container and install it under /tmp/dsc:

```
./build/scripts/installDscFromContainer.sh
```

To build in Dev Sandbox:

1. Launch a workspace from the [devfile.yaml](devfile.yaml) in this repo.
2. See `To build locally` commands above, or check the commands in the [devfile.yaml](devfile.yaml).
