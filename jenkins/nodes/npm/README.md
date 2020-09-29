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
oc process -f ../jenkins-node-generic-template.yaml \
    -p NAME=jenkins-node-npm \
    -p SOURCE_CONTEXT_DIR=jenkins/nodes/npm \
    | oc apply -f -
```

For all params see the list in the `../jenkins-node-generic-template.yaml` or run `oc process --parameters -f ../jenkins-node-generic-template.yaml`.

## Jenkins

Add a new Kubernetes Container template called `jenkins-node-npm` (if you've build and pushed the container image locally) and specify this as the node when running builds. If you're using the template attached; the `role: jenkins-node` is attached and Jenkins should automatically discover the node for you. Further instructions can be found [here](https://docs.openshift.com/container-platform/3.11/using_images/other_images/jenkins.html#using-the-jenkins-kubernetes-plug-in).

Add this new Kubernetes Container template and specify this as the node when running builds.

```
npm install
npm run build
```
