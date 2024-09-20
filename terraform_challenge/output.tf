output "db_instance_endpoint" {
  value       = aws_db_instance.mysql.endpoint
}

output "web_server_public_ip" {
  value = aws_instance.web.public_ip
}