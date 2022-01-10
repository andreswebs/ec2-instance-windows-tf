data "aws_ami" "windows" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"]
}

locals {
  ssh_key_name   = var.ssh_key_name != "" ? var.ssh_key_name : "${var.name}-ssh"
  ami_id         = var.ami_id == "" || var.ami_id == null ? data.aws_ami.windows.id : var.ami_id
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.cidr_whitelist
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }

  name = "${var.name}-sg"

}

module "ec2_keypair" {
  source             = "andreswebs/insecure-ec2-key-pair/aws"
  version            = "1.0.0"
  key_name           = local.ssh_key_name
  ssm_parameter_name = "/${var.name}/ssh-key"
}

module "ec2_role" {
  source       = "andreswebs/ec2-role/aws"
  version      = "1.0.0"
  role_name    = var.name
  profile_name = var.name
  policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  ]
}

module "s3_requisites_for_ssm" {
  source  = "andreswebs/s3-requisites-for-ssm-policy-document/aws"
  version = "1.0.0"
}

resource "aws_iam_role_policy" "s3_requisites_for_ssm" {
  name   = "s3-requisites-for-ssm"
  role   = module.ec2_role.role.name
  policy = module.s3_requisites_for_ssm.json
}

resource "aws_instance" "this" {
  ami                     = local.ami_id
  disable_api_termination = var.instance_termination_disable
  key_name                = local.ssh_key_name
  vpc_security_group_ids  = [aws_security_group.this.id]
  subnet_id               = var.subnet_id
  iam_instance_profile    = module.ec2_role.instance_profile.name
  instance_type           = var.instance_type

  root_block_device {
    delete_on_termination = var.volume_delete
    encrypted             = var.volume_encrypted
    volume_size           = var.volume_size
  }

  enclave_options {
    enabled = var.enclave_enabled
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    ignore_changes = [ ami, tags ]
  }

}

data "aws_instance" "this" {
  instance_id = aws_instance.this.id
}