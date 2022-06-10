module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups_launch_template = [
    {
      name                          = "worker-group-1"
      instance_type                 = ["t2.medium", "t3.medium"]
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      spot_allocation_strategy      = "lowest-price"
      asg_max_size                  = 3
      asg_desired_capacity          = 2
      kubelet_extra_args            = "--node-labels=node.kubernetes.io/lifecycle=spot"
    },
  ]

  worker_groups = [
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_max_size                  = 3
      asg_desired_capacity          = 1
      kubelet_extra_args            = "--node-labels=node.kubernetes.io/lifecycle=ondemand"
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
