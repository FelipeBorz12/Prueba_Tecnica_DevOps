output "vpc_id" {
  description = "El ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "public_ip" {
  description = "La dirección IP pública de la instancia EC2"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "El nombre DNS público de la instancia EC2"
  value       = aws_instance.web.public_dns
}
