THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
.PHONY: gitlab-mkdir
gitlab-mkdir:
# Gitlab
# sudo mkdir -p /mnt/nfs-store/gitlab
# sudo chown nobody.nobody /mnt/nfs-store/gitlab
# sudo mkdir -p /mnt/nfs-store/gitlab
	sudo mkdir -p /mnt/gitlab/{gitlab_etc,gitlab_git_data,gitlab_uploads_data,gitlab_shared_data,gitlab_builds_data}
# sudo mkdir -p /mnt/nfs-store/gitlab/gitlab_etc
# sudo mkdir -p /mnt/nfs-store/gitlab/gitlab_git_data
# sudo mkdir -p /mnt/nfs-store/gitlab/gitlab_uploads_data
# sudo mkdir -p /mnt/nfs-store/gitlab/gitlab_shared_data
# sudo mkdir -p /mnt/nfs-store/gitlab/gitlab_builds_data
# sudo chown slayer:slayer -R /mnt/nfs-store/gitlab/gitlab_etc
# 777 ближе но все равно не то
# sudo chmod -R 777 /mnt/nfs-store/gitlab/gitlab_etc
# Postgres
	sudo mkdir -p /mnt/gitlab/postgres_data
# sudo chown 70:70 /mnt/nfs-store/gitlab/postgres_data
# Redis
	sudo mkdir -p /mnt/gitlab/redis_data
# Registry
	sudo mkdir -p /mnt/gitlab/registry_data
# base gitlab installation
.PHONY: gitlab-up gitlab-down gitlab-purge
gitlab-up:
# GITLAB
	sudo kubectl apply -f ./gitlab/pvc-local-path.yml
	sudo kubectl apply -f ./gitlab/pv-local-path.yml
	sudo kubectl apply -f ./gitlab/omnibus-conf.yml
	sudo kubectl apply -f ./gitlab/svc.yml
	sudo kubectl apply -f ./gitlab/deployment.yml
	sudo kubectl apply -f ./gitlab/ingress.yml
# Database
	sudo kubectl apply -f ./postgres/pv-local-path.yml
	sudo kubectl apply -f ./postgres/pvc-local-path.yml
	sudo kubectl apply -f ./postgres/svc.yml
	sudo kubectl apply -f ./postgres/deployment.yaml
# Redis
	sudo kubectl apply -f ./redis/pv-local-path.yml
	sudo kubectl apply -f ./redis/pvc-local-path.yml
	sudo kubectl apply -f ./redis/deployment.yml
	sudo kubectl apply -f ./redis/svc.yml
# Registry
	sudo kubectl apply -f ./registry/pv-local-path.yml
	sudo kubectl apply -f ./registry/pvc-local-path.yml
	sudo kubectl apply -f ./registry/svc.yml
#sudo kubectl apply -f ./registry/notifications-conf.yml
	sudo kubectl apply -f ./registry/deployment.yaml
gitlab-down:
	sudo kubectl delete -f ./gitlab/deployment.yml
	sudo kubectl delete -f ./gitlab/pvc-local-path.yml
	sudo kubectl delete -f ./gitlab/pv-local-path.yml
	sudo kubectl delete -f ./gitlab/omnibus-conf.yml
	sudo kubectl delete -f ./gitlab/svc.yml
	sudo kubectl delete -f ./gitlab/ingress.yml
# Database
	sudo kubectl delete -f ./postgres/deployment.yaml
	sudo kubectl delete -f ./postgres/pvc-local-path.yml
	sudo kubectl delete -f ./postgres/svc.yml
	sudo kubectl delete -f ./postgres/pv-local-path.yml
# Redis
	sudo kubectl delete -f ./redis/svc.yml
	sudo kubectl delete -f ./redis/deployment.yml
	sudo kubectl delete -f ./redis/pvc-local-path.yml
	sudo kubectl delete -f ./redis/pv-local-path.yml
# Registry
	sudo kubectl delete -f ./registry/deployment.yaml
#sudo kubectl delete -f ./registry/notifications-conf.yml
	sudo kubectl delete -f ./registry/pvc-local-path.yml
	sudo kubectl delete -f ./registry/svc.yml
	sudo kubectl delete -f ./registry/pv-local-path.yml
gitlab-purge:
	sudo rm -rf /mnt/gitlab/*
.PHONY: registry-up registry-down
registry-up:
	sudo kubectl apply -f ./registry/pv-local-path.yml
	sudo kubectl apply -f ./registry/pvc-local-path.yml
	sudo kubectl apply -f ./registry/svc.yml
	sudo kubectl apply -f ./registry/notifications-conf.yml
	sudo kubectl apply -f ./registry/deployment.yaml
registry-down:
	sudo kubectl delete -f ./registry/deployment.yaml
	sudo kubectl delete -f ./registry/notifications-conf.yml
	sudo kubectl delete -f ./registry/pvc-local-path.yml
	sudo kubectl delete -f ./registry/svc.yml
	sudo kubectl delete -f ./registry/pv-local-path.yml
.PHONY: gitlab-runner-up gitlab-runner-down
gitlab-runner-up:
	sudo kubectl apply -f ./runner/configmap.yaml
	sudo kubectl apply -f ./runner/gitlab-runner-admin.yml
	sudo kubectl apply -f ./runner/deployment.yml
gitlab-runner-down:
	sudo kubectl delete -f ./runner/deployment.yml
	sudo kubectl delete -f ./runner/gitlab-runner-admin.yml
	sudo kubectl delete -f ./runner/configmap.yaml
.PHONY: get-all
get-all:
	sudo kubectl get all --all-namespaces
# .PHONY: gitlab-test-up gitlab-test-down
# gitlab-test-up: gitlab-nfs-mkdir
# 	sudo kubectl apply -f ./gitlab/pvc.yml
# 	sudo kubectl apply -f ./gitlab/pv.yml
# 	sudo kubectl apply -f ./gitlab/omnibus-conf.yml
# 	sudo kubectl apply -f ./gitlab/deployment.yml
# gitlab-test-down: gitlab-purge
# 	sudo kubectl delete -f ./gitlab/deployment.yml
# 	sudo kubectl delete -f ./gitlab/pvc.yml
# 	sudo kubectl delete -f ./gitlab/pv.yml
# 	sudo kubectl delete -f ./gitlab/omnibus-conf.yml