data "aws_subnet" "this" {
  id = var.subnet_id
}

module "ec2_base" {
  source  = "andreswebs/ec2-base/aws"
  version = "0.6.0"
  name    = var.name
  vpc_id  = data.aws_subnet.this.vpc_id
}

module "ec2_instance" {
  source                 = "andreswebs/ec2-instance-windows/aws"
  version                = "0.0.3"
  name                   = var.name
  iam_profile_name       = module.ec2_base.instance_profile.name
  subnet_id              = data.aws_subnet.this.id
  vpc_security_group_ids = [module.ec2_base.security_group.id]
  ad_domain_id           = var.ad_domain_id
}
