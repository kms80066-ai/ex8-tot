# =====================================================
# 1. Network
# =====================================================
module "network" {
  source = "./modules/network"

  azs          = local.azs
  vpc_cidr     = local.vpc_cidr
  tag_header   = local.tag_header
  subnet_map   = local.subnet_map
  cluster_name = local.cluster_name
}

# =====================================================
# 2. Security
# =====================================================
module "security" {
  source = "./modules/security"

  vpc_id           = module.network.vpc_id
  tag_header       = local.tag_header
  non_public_cidrs = local.non_public_cidrs
}

# =====================================================
# 3. VPC Endpoints
# =====================================================
module "endpoints" {
  source = "./modules/endpoints"

  region                     = local.region
  vpc_id                     = module.network.vpc_id
  tag_header                 = local.tag_header
  private_subnet_ids         = module.network.private_subnet_ids
  non_public_route_table_ids = module.network.non_public_route_table_ids
  endpoint_sg_id             = module.security.endpoint_sg_id
}

# =====================================================
# 4. EKS
# =====================================================
module "eks" {
  source = "./modules/eks"

  cluster_name = local.cluster_name
  tag_header   = local.tag_header

  cluster_subnet_ids = module.network.cluster_subnet_ids
  node_subnet_ids    = module.network.cluster_subnet_ids

  node_instance_type = local.eks_node_instance_type

  min_size     = local.eks_node_min_size
  desired_size = local.eks_node_desired_size
  max_size     = local.eks_node_max_size

  depends_on = [
    module.network,
    module.endpoints
  ]
}

# =====================================================
# 5. ECR
# =====================================================
module "ecr" {
  source = "./modules/ecr"

  repository_names = local.ecr_repository_names
}