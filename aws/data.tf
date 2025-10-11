data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# AWS 기존 VPC 참조
data "aws_vpc" "default" {
    default = true
    id = "vpc-08289defd1ea10e6f"
}

# AWS 기존 Subnet 참조
data "aws_subnet" "default" {
  
    id = "subnet-075de9772da50ef19"
}

