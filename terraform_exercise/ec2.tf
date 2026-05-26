# 1. Obtener de forma dinámica el último ID de AMI para Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (dueños oficiales de Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Crear el Security Group
resource "aws_security_group" "web_sg" {
  name        = "sg_web_devops_practice"
  description = "Permite acceso HTTP, HTTPS y SSH"
  vpc_id      = aws_vpc.main.id

  # Regla de Entrada: HTTP
  ingress {
    description = "HTTP desde cualquier parte"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de Entrada: HTTPS
  ingress {
    description = "HTTPS desde cualquier parte"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de Entrada: SSH
  ingress {
    description = "SSH desde cualquier parte (puedes restringir a tu IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Recomendado en producción restringir a tu IP (ej. "X.X.X.X/32")
  }

  # Regla de Salida: Permitir todo el tráfico saliente
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "sg-web-devops-practice"
    Environment = "practice"
  }
}

# 3. Crear la Instancia EC2
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  # Script de inicialización (User Data) para instalar Nginx básico como prueba
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Desplegado con Terraform por Felipe Botero</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "server-web-devops-practice"
    Environment = "practice"
  }
}
