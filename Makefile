THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# base gitlab installation
.PHONY: gitlab-up gitlab-down
gitlab-up:
	sudo kubectl apply -f ./gitlab/deployment.yml
	sudo kubectl apply -f ./gitlab/ingress.yml
	sudo kubectl apply -f ./postgres/deployment.yaml
	sudo kubectl apply -f ./redis/deployment.yml
	sudo kubectl apply -f ./registry/deployment.yaml
gitlab-down:
	sudo kubectl delete -f ./gitlab/deployment.yml
	sudo kubectl delete -f ./gitlab/ingress.yml
	sudo kubectl delete -f ./postgres/deployment.yaml
	sudo kubectl delete -f ./redis/deployment.yml
	sudo kubectl delete -f ./registry/deployment.yaml