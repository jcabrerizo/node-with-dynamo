
output "server_main_uri" {
  value = "http://${aws_eip.node_server.public_ip}:${var.port}"
}

output "data_table_arn" {
  value = aws_dynamodb_table.data_table.arn
}
output "data_table_name" {
  value = aws_dynamodb_table.data_table.name
}

