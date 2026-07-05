variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # scalable: change to t3.small/medium as load grows
}

variable "key_name" {
  description = "Name of an existing EC2 key pair (for SSH access)"
  type        = string
}

variable "app_port" {
  description = "Port the containerized app listens on"
  type        = number
  default     = 3000
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH into the instance (lock this down to your IP in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "environment" {
  description = "Deployment environment tag"
  type        = string
  default     = "production"
}
