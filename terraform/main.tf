provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "eks-private-subnet"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)
  vpc   = true
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidr_blocks)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name = "eks-nat-gateway-${count.index + 1}"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# Security Group for EKS Nodes
resource "aws_security_group" "eks_node_group_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     =var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy,
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private.*.id

  scaling_config {
    desired_size = var.autscale_params.desired_size
    max_size     = var.autscale_params.max_size
    min_size     = var.autscale_params.min_size
  }

  instance_types = var.instance_type

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKS_CNI_Policy,
  ]
}

# Load Balancer
resource "aws_lb" "eks_lb" {
  name                      = "eks-load-balancer"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = [aws_security_group.eks_node_group_sg.id]
  subnets                   = aws_subnet.public.*.id
  enable_deletion_protection = false

  tags = {
    Name = "eks-load-balancer"
  }
}

resource "aws_acm_certificate" "example" {
  domain_name       = "migdal.co.il"
  validation_method = "DNS"

  tags = {
    Name = "example-cert"
  }
}

resource "aws_lb_listener" "lb_list" {
  load_balancer_arn = aws_lb.eks_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.example.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_lb.arn
  }

  tags = {
    Name = "elb-listener"
  }
}
