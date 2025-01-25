module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets

  eks_managed_node_groups = {
    main = {
      min_size       = 2
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
    }
  }

  # Enable OIDC provider for service accounts
  enable_irsa = true
}

# Install AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  depends_on = [module.eks]
} 