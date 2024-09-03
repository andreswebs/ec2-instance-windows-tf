data "aws_subnet" "this" {
  id = var.subnet_id
}

# module "ec2_keypair" {
#   source             = "andreswebs/insecure-ec2-key-pair/aws"
#   version            = "1.1.0"
#   key_name           = "${var.name}-ssh"
#   ssm_parameter_name = "/${var.name}/ssh-key"
# }

module "ec2_base" {
  source  = "andreswebs/ec2-base/aws"
  version = "0.5.0"
  vpc_id  = data.aws_subnet.this.vpc_id
  name    = var.name
}

module "ec2_instance" {
  source           = "andreswebs/ec2-instance-windows/aws"
  version          = "0.0.1"
  name             = var.name
  iam_profile_name = module.ec2_base.instance_profile.name
  subnet_id        = data.aws_subnet.this.id
}
