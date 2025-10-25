# Usar key pair existente
data "aws_key_pair" "draftbook_app_keys" {
    key_name = var.aws_key_pair_name
}

# Usar security group existente
data "aws_security_group" "draftbook_sg" {
    id = var.aws_draftbook_sg
}

# Obtener el VPC del security group
data "aws_vpc" "selected" {
  id = data.aws_security_group.draftbook_sg.vpc_id
}

# Obtener subnets disponibles en el VPC
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# Obtener el AMI más reciente de Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instancia EC2
resource "aws_instance" "draftbook_app_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  key_name = data.aws_key_pair.draftbook_app_keys.key_name
  user_data_base64 = filebase64("${path.module}/scripts/apps-install.sh")
  
  # Asegurar que la instancia tenga IP pública
  associate_public_ip_address = true
  
  # Usar una subnet del VPC
  subnet_id = length(data.aws_subnets.available.ids) > 0 ? data.aws_subnets.available.ids[0] : null
  
  vpc_security_group_ids = [
    data.aws_security_group.draftbook_sg.id
  ]

  tags = {
    Name = "${var.aws_server_name} - ${var.aws_environment}"
  }
}

# NOTA: Los provisioners SSH han sido deshabilitados temporalmente debido a problemas de conectividad
# desde GitHub Actions. Todo el setup se hace ahora vía user_data (apps-install.sh)

# Esperar 5 minutos para que user_data complete la instalación
resource "time_sleep" "wait_for_setup" {
  create_duration = "300s"  # 5 minutos
  depends_on = [ aws_instance.draftbook_app_server ]
}

# TODO: Descomentar estos provisioners una vez que se resuelva el acceso SSH desde GitHub Actions
# O implementar un método alternativo (AWS Systems Manager Session Manager, etc.)

/*
# Null resource para copiar docker-compose y ejecutar aplicación
resource "null_resource" "deploy_app" {
  depends_on = [ time_sleep.wait_for_setup ]

  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("${path.root}/keys/draftbook_KEYPAR.pem")
      host = aws_instance.draftbook_app_server.public_ip
      timeout = "10m"
    }
    source = "./containers/docker-compose.yml"
    destination = "/containers/docker-compose.yml"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("${path.root}/keys/draftbook_KEYPAR.pem")
      host = aws_instance.draftbook_app_server.public_ip
      timeout = "10m"
    }
    inline = [ 
      "cloud-init status --wait",
      "cd /containers",
      "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 970547369328.dkr.ecr.us-east-2.amazonaws.com",
      "docker compose up -d"
    ]
  }
}
*/

