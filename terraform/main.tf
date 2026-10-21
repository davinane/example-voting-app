data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "zone_a" {
  id = "subnet-03654063e7150d47f"
}

data "aws_subnet" "zone_b" {
  id = "subnet-078c587704037e2f4"
}

resource "aws_iam_role" "eks_cluster" {
  name = "ts-academy-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "capstone" {
  name     = "ts-academy-capstone-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.zone_a.id,
      data.aws_subnet.zone_b.id
    ]

    endpoint_public_access  = true
    public_access_cidrs     = local.allowed_api_cidrs
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]

  tags = {
    Name = "ts-academy-capstone-eks"
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "ts-academy-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_eks_node_group" "capstone" {
  cluster_name    = aws_eks_cluster.capstone.name
  node_group_name = "capstone-workers"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    data.aws_subnet.zone_a.id,
    data.aws_subnet.zone_b.id
  ]

  instance_types = ["c7i-flex.large"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr
  ]

  tags = {
    Name = "ts-academy-capstone-workers"
  }
}
