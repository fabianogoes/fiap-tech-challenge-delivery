# Variáveis
AWS_REGION=us-east-1
EKS_CLUSTER_NAME="tech_challenge_eks_cluster"
EKS_NODEGROUP_NAME="tech-challenge-ng"

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: postgres
postgres: ## Provisiona um banco de dados PostgreSQL na AWS
	@echo "Provisionando banco de dados PostgreSQL"
	cd modules/postgres && terraform init && terraform apply -auto-approve
	cd ../../

.PHONY: eks
eks: ## Provisiona um cluster EKS na AWS
	@echo "Provisionando cluster EKS"
	cd modules/eks && terraform init && terraform apply -auto-approve
	aws sts get-caller-identity
	aws eks --region $AWS_REGION update-kubeconfig --name tech_challenge_eks_cluster
	kubectl cluster-info
	cd ../../
	
.PHONY: del-ng
del-ng: ## Deleta o nodegroup do cluster EKS
	@echo "Deletando nodegroup do cluster EKS"
	aws eks delete-nodegroup --nodegroup-name tech-challenge-ng --cluster-name tech_challenge_eks_cluster

.PHONY: delete-eks
del-eks: ## Deleta o cluster EKS
	@echo "Deletando cluster EKS"
	aws eks delete-cluster --name tech_challenge_eks_cluster

.PHONY: delete-postgres
del-postgres: ## Deleta o banco de dados PostgreSQL
	@echo "Deletando banco de dados PostgreSQL"
	cd modules/postgres && terraform destroy -auto-approve
	cd ../../
	
.PHONY: eks-config
eks-config: ## Testa o cluster EKS
	@echo "Testando cluster EKS"
	@aws sts get-caller-identity
	@aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}
	@echo "run 'kubectl cluster-info' to check the cluster info"
	@echo "run 'kubectl apply -f ./modules/eks/nginx.yml' to deploy a nginx pod"
	@echo "run 'kubectl get svc' to check the service and get the external IP to access the nginx service"