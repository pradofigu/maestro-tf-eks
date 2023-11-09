module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "maestro"
  cluster_version = "1.28"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = "vpc-07a6c37f7f8bb7f1c"
  subnet_ids               = ["subnet-08cd513a3b04cb940", "subnet-09df73c741c1f2f4a", "subnet-0fa3916d926297273", "subnet-09bf03d614c8905a3"]
  control_plane_subnet_ids = ["subnet-idsubnet-09bf03d614c8905a3", "subnet-09df73c741c1f2f4a"]

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "t2.micro"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::867818665421:role/maestro-role-eks-node-group"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "maestro-node-group"
      max_size     = 2
      desired_size = 1

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t2.micro"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.micro"
            weighted_capacity = "2"
          },
        ]
      }
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "On Demand"
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true  

  tags = {
    bu = "maestro"    
  }
}