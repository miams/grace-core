default: master

bootstrap:
	cd terraform/bootstrap && terraform init
	cd terraform/bootstrap && terraform apply -var-file=../master/backend.tfvars

master:
	cd terraform/master && terraform init -backend-config=backend.tfvars
	cd terraform/master && terraform apply -var-file=backend.tfvars
