# Project Overview

This project is designed to deploy a Kubernetes application using Terraform, Argo CD, and AWS EKS. It automates the infrastructure setup, application deployment, and continuous delivery pipeline. The structure is organized into different directories for clarity and separation of concerns.

## Directory Structure

- `app/`: Contains Kubernetes service and deployment configurations for the application.
  - `deployment.yaml`: Kubernetes deployment configuration for the application.
  - `svc.yaml`: Kubernetes service configuration, exposing the application.
- `argo-cd/`: Holds the Argo CD application definition for continuous deployment.
  - `application.yaml`: Argo CD application definition for managing the deployment lifecycle.
- `argoCDinstall/`: ** (This is Option )Scripts and configurations for installing Argo CD on the Kubernetes cluster.
  - `installArgoCD.sh`: Shell script to install Argo CD on the EKS cluster.
  - `rbac.yaml`: RBAC configurations for Argo CD.
- `terraform/`: Terraform configurations for provisioning AWS resources and the EKS cluster.
  - `argocd.tf`: Terraform configuration for Argo CD settings.
  - `config.tf`: General Terraform configurations and provider settings.
  - `deploy.yaml`: Kubernetes deployment configuration managed by Terraform.
  - `main.tf`: Main Terraform configuration file for AWS resources.
  - `outputs.tf`: Terraform outputs for the provisioned resources.
  - `role_policy.tf`: IAM role policies for the EKS cluster.
  - `terraform.tfvars`: Terraform variables definition file.
  - `variables.tf`: Terraform variables declaration file.
- `README.md`: This file, providing an overview and instructions for the project.

## How to Use This Project

1. **Prepare Your Environment**: Ensure you have AWS CLI, kubectl, Terraform, and Argo CD CLI installed on your machine.
2. **Configure AWS Credentials**: Set up your AWS credentials using AWS CLI or environment variables.
   for example:
   ```bash
     export AWS_ACCESS_KEY_ID="your_access_key_id"
     export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
     export AWS_DEFAULT_REGION="your_region"
     export AWS_PROFILE=your_profile_name
  ```
3. **Initialize Terraform**: Navigate to the `terraform/` directory and run `terraform init` to initialize the Terraform workspace.
4. **Apply Terraform Configuration**: Execute `terraform apply` to create the AWS resources, including the EKS cluster.
5. **Install Argo CD**: Run the `installArgoCD.sh` script located in the `argoCDinstall/` directory to install Argo CD on your EKS cluster.
6. **Deploy Your Application**: Update the `argo-cd/application.yaml` with your application's repository details and apply it using `kubectl` to deploy your application through Argo CD.

## Understanding the Files

- **Terraform Configurations (`terraform/`)**: Define the infrastructure as code, including the EKS cluster, VPC, subnets, and other AWS resources.
##Optionally configure the Argo CD installation with bash script
- **Argo CD Installation (`argoCDinstall/`)**: Scripts and configurations for setting up Argo CD on the EKS cluster for continuous deployment.
- **Application Deployment (`app/`)**: Kubernetes configurations for deploying the application, including a LoadBalancer service for exposing the application.
- **Argo CD Application (`argo-cd/`)**: Defines the Argo CD application for continuous deployment of the Kubernetes application.

## Get the enpoints url of the Argo CD and the application and argocd password
   ```bash
      terraform output argocd_server_url
      kubectl get service hello-world -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
      terraform output argocd_password
   ```

This project simplifies the process of deploying and managing Kubernetes applications on AWS EKS using Terraform and Argo CD, providing a robust foundation for continuous delivery and infrastructure management.