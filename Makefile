all: homelab

###
### Boostrap homelab
###

deps:
	pip install --upgrade pip
	pip install -r requirements.txt

infrastructure:
	$(MAKE) -C iac/terraform init
	$(MAKE) -C iac/terraform apply

cluster:
	$(MAKE) -C iac/ansible stand-up

homelab: deps infrastructure cluster

###
### Teardown homelab
###

teardown-cluster:
	$(MAKE) -C iac/ansible reset

teardown-infrastructure:
	$(MAKE) -C iac/terraform destroy

teardown-homelab: teardown-cluster teardown-infrastructure

###
### Lint and format
###

lint-ansible:
	$(MAKE) -C iac/ansible lint

lint: lint-ansible

format-terraform:
	$(MAKE) -C iac/terraform format

format: format-terraform