master:
	cd terraform/master && terraform init -backend-config=backend.tfvars
	cd terraform/master && terraform apply
