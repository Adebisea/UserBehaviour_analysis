#set up infrastructure
tf-init:
	terraform -chdir=./terraform init

infra-plan:
	terraform -chdir=./terraform plan

infra-up:
	terraform -chdir=./terraform apply