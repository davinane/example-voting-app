resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.capstone.name
  addon_name   = "aws-ebs-csi-driver"

  addon_version = "v1.67.1-eksbuild.1"

  service_account_role_arn = "arn:aws:iam::358230849784:role/ts-academy-ebs-csi-role"

  depends_on = [
    aws_eks_node_group.capstone,
    aws_iam_openid_connect_provider.eks
  ]

  tags = {
    Name = "ts-academy-ebs-csi-driver"
  }
}
