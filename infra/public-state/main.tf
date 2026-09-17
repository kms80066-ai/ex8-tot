# 1. 테라폼 실행 환경 설정 블록
terraform {
  required_providers {
    aws = {
      # 프로바이터 라이브러리 다운로드 경로
      source = "hashicorp/aws"
      # 사용할 버전 정의
      version = "~> 6.0" # 6.0 ~ 7.0 (6.0 이상 7.0 미만의 최신 버전)
    }
  }
}


provider "aws" {
  region = "ca-central-1"
}

# ================================================================
# 2. 상태 파일 저장(공유)를 위한 버킷 생성 및 버전 활성화
# S3 bucket 생성
resource "aws_s3_bucket" "std09_terraform_state_bucket" {
  bucket = "std09-terraform-state-bucket-0917"

  lifecycle {
    prevent_destroy = true # 실수로 삭제되는 것을 방지  
  }
}

# Bucket 버전 관리
resource "aws_s3_bucket_versioning" "std09_state_versioning" {
  bucket = aws_s3_bucket.std09_terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled" # Enabled
  }
}

# =====================================================================
# 3. 배포중 락온 설정을 위한 DynamoDB Table 생성
resource "aws_dynamodb_table" "terraform_lock" {
  name = "std09-terraform-lock-table" # 리전내에 유일한 이름
  # 테이블의 비용 지불 방식 및 처리 성능 관리 모드
  billing_mode   = "PROVISIONED"
  read_capacity  = 20       # RCU(초당 4KB 데이터 1개 읽기) --> 1RCU
  write_capacity = 20       # WCU(초당 1KB 데이터 1개 읽기) --> 1WCU
  hash_key       = "LockID" # Partition Key: RDS의 Primary Key역할 수행

  attribute {
    name = "LockID"
    type = "S"
  }
}
