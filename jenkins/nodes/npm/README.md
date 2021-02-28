# jenkins-node-npm

Provides a docker image of the nodejs v10 runtime with npm for use as a Jenkins node.

## Build local

```bash
docker build -t jenkins-node-npm .
```

## Run local

For local running and experimentation run `docker run -i -t jenkins-node-npm /bin/bash` and have a play once inside the container.

## Build in OpenShift

```bash
oc -n 01a527-tools process -f ../jenkins-node-generic-template.yaml \
    -p NAME=jenkins-node-npm \
    -p SOURCE_CONTEXT_DIR=jenkins/nodes/npm \
    | oc apply -f -
```

For all params see the list in the `../jenkins-node-generic-template.yaml` or run `oc process --parameters -f ../jenkins-node-generic-template.yaml`.

## Jenkins

If you followed the directions above and used the `../jenkins-node-generic-template.yaml` template to publish the resources, a configmap containing a Kubernetes Container template will be registered for you and it should be automatically detected by Jenkins based on the `role:` label so all you have to do is reference the node by it's label in either a `node` or `agent` section within your pipeline.

Otherwise you may need to follow some manual steps in Jenkins:

Add a new Kubernetes Container template called `jenkins-node-npm` and specify this as the node when running builds.

Further instructions can be found [here](https://docs.openshift.com/container-platform/3.11/using_images/other_images/jenkins.html#using-the-jenkins-kubernetes-plug-in).