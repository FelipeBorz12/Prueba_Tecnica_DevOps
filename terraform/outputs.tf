output "app_server_public_ip" {
  description = "Dirección IP pública del servidor de aplicaciones (EC2)"
  value       = aws_instance.app_server.public_ip
}

output "database_endpoint" {
  description = "Endpoint de conexión de la base de datos RDS PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}

output "ssh_connection_command" {
  description = "Comando rápido de SSH para conectarse al servidor"
  value       = "ssh -i payfast-key.pem ubuntu@${aws_instance.app_server.public_ip}"
}
