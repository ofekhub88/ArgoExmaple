region                     = "us-west-2"
cluster_name               = "eks-cluster"
node_group_name            = "eks-node-group"
desired_capacity           = 2
max_capacity               = 3
min_capacity               = 1
instance_type              = "t3.medium"
cidr_block                 = "10.0.0.0/16"
private_subnet_cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
availability_zones         = ["us-west-2a", "us-west-2b", "us-west-2c"]

