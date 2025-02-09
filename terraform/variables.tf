data "aws_availability_zones" "available" {
  state = "available"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "cluster_name" {
  type    = string
  default = "url-shortener"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
} 