# Salida de la IP Pública de la Instancia
output "instance_public_ip" {
  #Entre app_server y public_ip poner * para que abarque todas las instancias si hay varias
  value = aws_instance.draftbook_app_server.public_ip
}