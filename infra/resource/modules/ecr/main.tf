resource "aws_ecr_repository" "this" {
  for_each = local.repository_names

  name = each.value

  image_tag_mutability = "MUTABLE"

  # 실습 종료 시 이미지가 남아 있어도 삭제 가능
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}