#Par de claves 
resource "aws_key_pair" "draftbook_app_keys" {
    public_key = file("./keys/draftbook_app_key.pub")
    key_name   = var.aws_key_pair_name
}

# Usar security group existente
data "aws_security_group" "draftbook_sg" {
    id = var.aws_draftbook_sg
}

# Instancia EC2
resource "aws_instance" "draftbook_app_server" {
  ami = "ami-0cfde0ea8edd312d4" #Amazon Linux 2 AMI (HVM), SSD Volume Type - us-east-2
  instance_type = var.aws_instance_type
  key_name = aws_key_pair.draftbook_app_keys.key_name
  user_data = filebase64("${path.module}/scripts/apps-install.sh")
  vpc_security_group_ids = [
    aws_security_group.draftbook_sg.id
  ]

  tags = {
    Name = "${var.aws_server_name} - ${var.aws_environment}"
  }

  #PROVISIONERS para ejecutar comandos después de crear la instancia
    provisioner "remote-exec" {
        connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file("./keys/draftbook_app_key")
          host = self.public_ip
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
          private_key = file("./keys/draftbook_app_key")
          host = self.public_ip
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
        private_key = file("./keys/draftbook_app_key")
        host = aws_instance.draftbook_app_server.public_ip
      }
      inline = [ 
        "cd /containers",
        #Cambiar linea por info del ECR nuestro 
        "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 970547369328.dkr.ecr.us-east-2.amazonaws.com",
        "docker compose up -d"

       ]
    }
}

