

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.eks.id
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.node_group.id
}

output "load_balancer_dns_name" {
  description = "The DNS name of the external load balancer"
  value       = aws_lb.external.dns_name
}

ouptut "load_balancer_arn" {
  description = "The ARN of the external load balancer"
  value       = aws_lb.external.arn
}
output "load_balancer_arn" {
  value = aws_lb.eks_lb.arn
}