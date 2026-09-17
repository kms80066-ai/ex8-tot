output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "cluster_subnet_ids" {
  value = module.network.cluster_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_node_group_name" {
  value = module.eks.node_group_name
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ecr_registry" {
  value = local.ecr_registry
}