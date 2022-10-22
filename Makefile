.PHONY: all
all: homelab

###
### Boostrap homelab
###

.PHONY: deps
deps:
	pip install --upgrade pip
	pip install -r requirements.txt

.PHONY: infrastructure
infrastructure:
	$(MAKE) -C iac/terraform init
	$(MAKE) -C iac/terraform apply

.PHONY: cluster
cluster:
	$(MAKE) -C iac/ansible stand-up

.PHONY: homelab
homelab: deps infrastructure cluster

###
### Teardown homelab
###

.PHONY: teardown-cluster
teardown-cluster:
	$(MAKE) -C iac/ansible reset

.PHONY: teardown-infrastructure
teardown-infrastructure:
	$(MAKE) -C iac/terraform destroy

.PHONY: teardown-homelab
teardown-homelab: teardown-cluster teardown-infrastructure

###
### Lint and format
###

.PHONY: lint-ansible
lint-ansible:
	$(MAKE) -C iac/ansible lint

.PHONY: lint
lint: lint-ansible

.PHONY: format-terraform
format-terraform:
	$(MAKE) -C iac/terraform format

.PHONY: format
format: format-terraform