variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Rango de direcciones IP para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Rango de direcciones IP para la subred pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el servidor"
  type        = string
  default     = "t2.micro" # Capa gratuita en la mayoría de regiones (t3.micro en algunas)
}

variable "key_name" {
  description = "Nombre del Key Pair existente en AWS para acceder por SSH"
  type        = string
  default     = "mi-key-pair" # Cambiar por el nombre de tu key pair en AWS
}
