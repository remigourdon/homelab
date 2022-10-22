.PHONY: lint
lint:
	ansible-lint

.PHONY: stand-up
stand-up:
	ansible-playbook stand-up-k3s.yml

.PHONY: reset
reset:
	ansible-playbook reset.yml