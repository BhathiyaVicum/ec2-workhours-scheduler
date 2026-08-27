data "aws_subnets" "default" {
    filter {
      name = "vpc-id"
      values = [ data.aws_vpc.default.id ]
    }
}

data "aws_vpc" "default" {
    default = true
}

resource "aws_instance" "controling_app" {
    count = var.instance_count
    ami = "ami-0332d564d76dbd8d6"
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = data.aws_subnets.default.ids[0]
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    tags = {
      Name = "${var.environment}-controlled-instance"
      Environment = var.environment
      Schedule = "enabled"
    }
}

resource "aws_security_group" "ec2_sg" {
    name = "ec2-sg"
    description = "Security group for EC2 instances"
    vpc_id = data.aws_vpc.default.id

    # SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_ip]
    }

    # HTTP
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
        Name = "${var.environment}-sg"
    }
}