#Define Outputs

output "eip" {
  value = aws_eip.static_eip.public_ip
}

output "webapp_ecr_url" {
  value = aws_ecr_repository.webapp.repository_url
}

output "mysql_ecr_url" {
  value = aws_ecr_repository.mysql.repository_url
}