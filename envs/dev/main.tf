provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key

}

module "vm-linux-server" {
  source = "../../modules/vm"
  access_key        = var.aws_access_key
  secret_key        = var.aws_secret_key
  region            = var.aws_region
  aws_key_pair_name = var.aws_key_pair_name
  aws_draftbook_sg  = var.aws_draftbook_sg
  aws_instance_type = var.aws_instance_type
  aws_server_name   = var.aws_server_name
  aws_environment   = var.aws_environment
}

output "vm-linux-server-ip" {
  value = module.vm-linux-server.aws_instance_ip 
}





