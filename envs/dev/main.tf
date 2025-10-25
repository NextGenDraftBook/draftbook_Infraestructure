terraform {
  backend "s3" {
    bucket  = "draftbook-terraform-state"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vm-linux-server" {
  source = "../../modules/vm"
  region            = var.aws_region
  aws_key_pair_name = var.aws_key_pair_name
  aws_draftbook_sg  = var.aws_draftbook_sg
  aws_instance_type = var.aws_instance_type
  aws_server_name   = var.aws_server_name
  aws_environment   = var.aws_environment
}

output "vm-linux-server-ip" {
  value = module.vm-linux-server.instance_public_ip 
}





