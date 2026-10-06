resource "aws_eks_cluster" "main" {
    name = "main-cluster"
}

resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main
}