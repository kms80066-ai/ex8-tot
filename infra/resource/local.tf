locals {
  # =====================================================
  # 기본 설정
  # =====================================================
  owner    = "std09"
  region   = "ca-central-1"
  azs      = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
  vpc_cidr = "10.0.0.0/16"

  # 기존 실습과 AWS 리소스 이름 충돌 방지
  tag_header = "${local.owner}-ex8-"

  # EKS
  cluster_name = "${local.tag_header}k8s"

  # =====================================================
  # Subnet 9개
  # 기존 압축파일의 subnet_map 로직 유지
  # =====================================================
  subnet_map = merge([
    for idx, kind in ["public", "private", "cluster"] : {
      for i, az in local.azs : "${kind}${split("-", az)[2]}" => {
        type = kind
        az   = az
        cidr = cidrsubnet(local.vpc_cidr, 8, i + idx * 10 + 1)
      }
    }
  ]...)

  non_public_cidrs = [
    for subnet in local.subnet_map : subnet.cidr
    if subnet.type != "public"
  ]

  # =====================================================
  # EKS Node Group
  # =====================================================
  eks_node_instance_type = "t3.small"

  eks_node_min_size     = 1
  eks_node_desired_size = 2
  eks_node_max_size     = 3

  # =====================================================
  # ECR - Board 서비스만 사용
  # =====================================================
  ecr_repository_names = toset([
    "${local.tag_header}nginx",
    "${local.tag_header}fastapi"
  ])

  # AWS 계정 정보
  account_id = data.aws_caller_identity.current.account_id

  ecr_registry = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}