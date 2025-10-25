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

  #PROVISIONERS para ejecutar comandos después de crear la instancia
    provisioner "remote-exec" {
        connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file("${path.root}/keys/draftbook_KEYPAR.pem")
          host = self.public_ip
          timeout = "5m"
        }
        inline = [ 
            "sudo mkdir /containers",
            "sudo mkdir /home/ubuntu/.aws",
            "touch /containers/.env",
            "sudo chmod 777 /containers",
            "sudo chmod 777 /containers/.env",

            # TODO: Configurar instance profile en lugar de credenciales estáticas
            # "sudo echo \"[default]\naws_access_key_id=xxx\naws_secret_access_key=xxx\" | sudo tee /home/ubuntu/.aws/credentials >/dev/null",
            "sudo echo \"[default]\nregion=${var.region}\noutput=json\" | sudo tee /home/ubuntu/.aws/config >/dev/null",
            "sudo chown -R ubuntu:ubuntu /home/ubuntu/.aws",
            "sudo chmod 700 /home/ubuntu/.aws",
            "sudo chmod 600 /home/ubuntu/.aws/config",
         ]
    }

  #Copiando contenido del docker compose a EC2
    provisioner "file" {
        connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file("${path.root}/keys/draftbook_KEYPAR.pem")
          host = self.public_ip
          timeout = "5m"
        }
        source = "./containers/docker-compose.yml"
        destination = "/containers/docker-compose.yml"
        
    }

  #Para hacer muchas iguales -> count = 3
}

resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"
  depends_on = [ aws_instance.draftbook_app_server ]
}

resource "null_resource" "setup_app" {
    depends_on = [ time_sleep.wait_120_seconds ]
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("${path.root}/keys/draftbook_KEYPAR.pem")
        host = aws_instance.draftbook_app_server.public_ip
        timeout = "5m"
      }
      inline = [ 
        "cd /containers",
        #Cambiar linea por info del ECR nuestro 
        "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 970547369328.dkr.ecr.us-east-2.amazonaws.com",
        "docker compose up -d"

       ]
    }
}

