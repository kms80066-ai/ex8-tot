# ALB Controller용 설정
locals {
  alb_role_name = "${local.tag_header}alb-controller-role"

  alb_policy_arn = "arn:aws:iam::${local.account_id}:policy/${local.tag_header}ALBControllerPolicy"

  alb_oidc_issuer = module.eks.oidc_issuer_url

  alb_oidc_hostpath = replace(
    local.alb_oidc_issuer,
    "https://",
    ""
  )

  alb_trust_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.alb.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.alb_oidc_hostpath}:aud" = "sts.amazonaws.com"

            "${local.alb_oidc_hostpath}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# 1. OIDC Provider
resource "aws_iam_openid_connect_provider" "alb" {
  url = local.alb_oidc_issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# 2. IAM Role
resource "aws_iam_role" "alb_controller" {
  name = local.alb_role_name

  assume_role_policy = local.alb_trust_policy
}

# 3. 기존 IAM Policy 연결
resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = local.alb_policy_arn
}