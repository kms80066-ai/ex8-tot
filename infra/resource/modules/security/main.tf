resource "aws_security_group" "endpoint" {
  name   = "${local.tag_header}endpoint-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.non_public_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tag_header}endpoint-sg"
  }
}