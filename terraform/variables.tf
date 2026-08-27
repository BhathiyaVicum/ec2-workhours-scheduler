variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "us-east-1"
}

variable "instance_type" {
    description = "Instance type"
    type = string
    default = "t3.micro"
}

variable "instance_count" {
    description = "Instance count"
    type = number
    default = 2
}

variable "environment" {
    description = "Working environment"
    type = string
    default = "dev"
}

variable "schedule_tag" {
    description = "Tag for scheduler"
    type = string
    default = "WorkHours"
}

variable "ssh_ip" {
  description = "ssh ip"
  type = string
}

variable "key_name" {
  description = ""
  type = string
}