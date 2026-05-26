# 1. Generar una clave privada RSA
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Crear el recurso Key Pair en AWS con la clave pública generada
resource "aws_key_pair" "generated_key" {
  key_name   = "devops-practice-key"
  public_key = tls_private_key.pk.public_key_openssh
}

# 3. Guardar la clave privada en un archivo local .pem para usar con SSH
resource "local_file" "private_key" {
  content         = tls_private_key.pk.private_key_pem
  filename        = "${path.module}/devops-practice-key.pem"
  file_permission = "0400" # Restringir permisos para que SSH no falle por permisos inseguros
}
