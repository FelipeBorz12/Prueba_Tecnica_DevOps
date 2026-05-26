# 1. Crear la VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-devops-practice"
    Environment = "practice"
  }
}

# 2. Crear la Subred Pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true # Permite que las instancias en esta subred obtengan IP pública automáticamente

  tags = {
    Name        = "subnet-public-devops-practice"
    Environment = "practice"
  }
}

# 3. Crear el Internet Gateway (IGW) para dar salida a Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "igw-devops-practice"
    Environment = "practice"
  }
}

# 4. Crear la Tabla de Ruteo Pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  # Ruta por defecto para mandar todo el tráfico de salida a Internet a través del IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "rt-public-devops-practice"
    Environment = "practice"
  }
}

# 5. Asociar la Subred con la Tabla de Ruteo Pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
