variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0f9de6e2d2f067fca" # Amazon Linux 2023 in us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 instance"
  type        = string
  default     = "terra ppk" # Replace with your key pair name
}

variable "ebs_volume_size" {
  description = "Size of additional EBS volume in GB"
  type        = number
  default     = 20
}
