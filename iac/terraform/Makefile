.PHONY: init
init:
	terraform init

.PHONY: format
format:
	terraform fmt -recursive

.PHONY: apply
apply:
	terraform apply -auto-approve -parallelism=3
	sleep 15

.PHONY: destroy
destroy:
	terraform apply -destroy -auto-approve -parallelism=3