resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.capstone.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "06b25927c42a721631c1efd9431e648fa62e1e39"
  ]

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}
