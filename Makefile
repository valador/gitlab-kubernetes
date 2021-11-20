THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# base gitlab installation
.PHONY: gitlab-up gitlab-down
gitlab-up:
	# GITLAB
	sudo mkdir -p /mnt/data_store/gitlab/gitlab_data/
	sudo kubectl apply -f ./gitlab/pvc.yml
	sudo kubectl apply -f ./gitlab/pv.yml
	sudo kubectl apply -f ./gitlab/omnibus-conf.yml
	sudo kubectl apply -f ./gitlab/svc.yml
	sudo kubectl apply -f ./gitlab/ingress.yml
	sudo kubectl apply -f ./gitlab/deployment.yml
	# Database
	sudo mkdir -p /mnt/data_store/gitlab/postgres_data
	sudo kubectl apply -f ./postgres/pv.yml
	sudo kubectl apply -f ./postgres/pvc.yml
	sudo kubectl apply -f ./postgres/svc.yml
	sudo kubectl apply -f ./postgres/deployment.yaml
	# Redis
	sudo mkdir -p /mnt/data_store/gitlab/redis_data
	sudo kubectl apply -f ./redis/pv.yml
	sudo kubectl apply -f ./redis/pvc.yml
	sudo kubectl apply -f ./redis/svc.yml
	sudo kubectl apply -f ./redis/deployment.yml
	# Registry
	sudo mkdir -p /mnt/data_store/gitlab/registry_data
	sudo kubectl apply -f ./registry/pv.yml
	sudo kubectl apply -f ./registry/pvc.yml
	sudo kubectl apply -f ./registry/svc.yml
	sudo kubectl apply -f ./registry/deployment.yaml
gitlab-down:
	sudo kubectl delete -f ./gitlab/deployment.yml
	sudo kubectl delete -f ./gitlab/pvc.yml
	sudo kubectl delete -f ./gitlab/pv.yml
	sudo kubectl delete -f ./gitlab/omnibus-conf.yml
	sudo kubectl delete -f ./gitlab/svc.yml
	sudo kubectl delete -f ./gitlab/ingress.yml
	# Database
	sudo kubectl delete -f ./postgres/deployment.yaml
	sudo kubectl delete -f ./postgres/pvc.yml
	sudo kubectl delete -f ./postgres/svc.yml
	sudo kubectl delete -f ./postgres/pv.yml
	# Redis
	sudo kubectl delete -f ./redis/deployment.yml
	sudo kubectl delete -f ./redis/pvc.yml
	sudo kubectl delete -f ./redis/pv.yml
	sudo kubectl delete -f ./redis/svc.yml
	# Registry
	sudo kubectl delete -f ./registry/deployment.yaml
	sudo kubectl delete -f ./registry/pvc.yml
	sudo kubectl delete -f ./registry/svc.yml
	sudo kubectl delete -f ./registry/pv.yml
gitlab-purge:
	sudo rm -rf /mnt/data_store/gitlab
.PHONY: gitlab-runner-up gitlab-runner-down
gitlab-runner-up:
	sudo kubectl apply -f ./runner/deployment.yml
gitlab-runner-down:
	sudo kubectl delete -f ./runner/deployment.yml