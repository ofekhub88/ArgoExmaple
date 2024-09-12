# Description: This script will install argoCD on the EKS cluster
################################
#
#  Usage: ./installArgoCD.sh
#
################################
#!/bin/bash

#  assign the region and cluster name to the variables
REGION=$(grep region ../terraform/terraform.tfvars | cut -d'=' -f2 | tr -d '"')
CULSTER_NAME=$(grep cluster_name ../terraform/terraform.tfvars | cut -d'=' -f2 | tr -d '"')


# install argoCD
aws eks update-kubeconfig --region $REGION --name $CULSTER_NAME
kubectl create namespace argocd
kubectl create namespace app
kubectl create serviceaccount argocd-admin -n argocd 
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
#kubectl apply rback.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd argocd-server -w
# get the argo cd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# get the argo cd server url
kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
# deploy the application for application deployment
kubectl apply -n argocd -f ../argo-cd/applications.yaml