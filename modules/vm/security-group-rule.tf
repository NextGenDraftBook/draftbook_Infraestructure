# Agregar regla SSH al Security Group existente para permitir acceso desde GitHub Actions
resource "aws_security_group_rule" "allow_ssh_from_anywhere" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Permitir desde cualquier IP (necesario para GitHub Actions)
  description       = "SSH access for GitHub Actions provisioning"
  security_group_id = data.aws_security_group.draftbook_sg.id
}
