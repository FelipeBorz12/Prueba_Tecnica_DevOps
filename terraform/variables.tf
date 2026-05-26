variable "aws_region" {
  description = "Región de AWS para desplegar los recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetar los recursos"
  type        = string
  default     = "payfast"
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Bloque CIDR para la subred pública (EC2 API)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "Bloque CIDR para la subred privada 1 (RDS)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Bloque CIDR para la subred privada 2 (RDS)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para la aplicación"
  type        = string
  default     = "t2.micro"
}

variable "db_password" {
  description = "Contraseña maestra para la base de datos PostgreSQL en RDS"
  type        = string
  sensitive   = true
  default     = "PayfastSecurePassword123!" # Usar variable de entorno TF_VAR_db_password en producción
}
