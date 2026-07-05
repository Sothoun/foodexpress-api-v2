# ------------------------------------------------------------------
# Look up latest Amazon Linux 2023 AMI (keeps the pipeline future-proof)
# ------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------
# Security group: SSH (22), App port, and HTTP (80) if you front it later
# ------------------------------------------------------------------
resource "aws_security_group" "foodexpress_sg" {
  name        = "foodexpress-sg-${var.environment}"
  description = "Allow SSH and app traffic for FoodExpress"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "App port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "foodexpress-sg"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------
# EC2 instance - bootstrapped with Docker via user_data
# ------------------------------------------------------------------
resource "aws_instance" "foodexpress_app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.foodexpress_sg.id]

  # Installs Docker so Jenkins can SSH in and run containers on this host
  user_data = <<-EOF
              #!/bin/bash
              set -e
              dnf update -y
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name        = "foodexpress-app-server"
    Environment = var.environment
  }
}
