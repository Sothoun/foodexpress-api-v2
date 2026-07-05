output "public_ip" {
  description = "Public IP address of the FoodExpress EC2 instance"
  value       = aws_instance.foodexpress_app.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.foodexpress_app.id
}

output "app_url" {
  description = "URL to access the deployed API"
  value       = "http://${aws_instance.foodexpress_app.public_ip}:${var.app_port}"
}
