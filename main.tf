provider "aws" {
  region = us-east-1
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-instance-role"
  }
}

# IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" 
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instances"
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # NOTE: In production, restrict to your IP
  }
  
  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "ec2-security-group"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = ami-0f9de6e2d2f067fca
  instance_type          = t2.micro
  key_name               = terra ppk
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from user data script"
              sudo yum update -y
              EOF
  
  tags = {
    Name = "AppServer"
  }
}

# EBS Volume
resource "aws_ebs_volume" "app_data" {
  availability_zone = aws_instance.app_server.us-east-1a
  size              = 10
  type              = "gp3"
  
  tags = {
    Name = "AppData"
  }
}

# EBS Volume Attachment
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.app_data.id
  instance_id = aws_instance.app_server.id
}
