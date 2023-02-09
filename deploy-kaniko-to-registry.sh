#!/bin/bash
#eval $(cat cluster.config)
#eval $(cat registry.config)
#export KUBECONFIG=$PWD/k3s.yaml

#IP=$(multipass info ${node1_name} | grep IPv4 | awk '{print $2}')

image_name_to_pull="gcr.io/kaniko-project/executor:debug"
image_name_new="root/kaniko-project/executor:debug"
registry_domain="reg.gitlab.server.lan"


docker pull ${image_name_to_pull}
docker tag ${image_name_to_pull} ${registry_domain}/${image_name_new}
docker push ${registry_domain}/${image_name_new}

# curl https://${registry_domain}/v2/_catalog
#curl http://${registry_domain}:5000/v2/node/tags/list
#curl http://registry.dev.test:5000/v2/gcr.io/kaniko-project/executor/tags/list

# registry.dev.test:5000/gcr.io/kaniko-project/executor:debug