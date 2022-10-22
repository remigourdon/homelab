deps:
	pip install --upgrade pip
	pip install -r requirements.txt

init-terraform:
	$(MAKE) -C iac/terraform init

init: init-terraform

lint-ansible:
	$(MAKE) -C iac/ansible lint

lint: lint-ansible

format-terraform:
	$(MAKE) -C iac/terraform format

format: format-terraform