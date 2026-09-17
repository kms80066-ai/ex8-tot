# 1. 테라폼 실행 환경 설정 블록
terraform {
  backend "s3" {
    bucket         = "std09-terraform-state-bucket-0917"        # 테라폼 상태파일을 저장할 버킷 이름
    key            = "ex8-tot/infra/resource/terraform.tfstate" # 버킷에서 테라폼 상태 파일 저장 경로
    region         = "ca-central-1"
    dynamodb_table = "std09-terraform-lock-table" # 락온 상태를 저장할 DynamoDB table 이름
    encrypt        = true
  }
}
