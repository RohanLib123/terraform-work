provider "aws"{
    region      = "ap-south-1"
    access_key  = "var.aws_access_key"
    secret_key  = "var.aws_secret_key"
}

resource "aws_instance" "test-instance" {
  ami                       = "ami-0f918f7e67a3323f0"
  instance_type             = "t2.micro"
  key_name                  = "login-key"
  vpc_security_group_ids    = [ aws_security_group.allow_tls.id ]

  tags = {
    Name    = "test-instance"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name       = "login-key"
  public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc42PEZq5ITaXWSDbq3Tv+LYXK6Js6MrS0eItOgcWXC ubuntu@ip-172-31-9-189"
}

resource "aws_default_vpc" "default" {
  tags = {
   Name  = "Default VPC"
  }
}

resource "aws_eip" "elastic-ip" {
  instance  = aws_instance.test-instance.id
  domain    = "vpc"
}

resource "aws_security_group" "allow_tls" {
    name            = "rohan-sg"
    description     = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id = aws_default_vpc.default.id

    tags = {
     Name   = "rohan-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4     = aws_default_vpc.default.cidr_block
  from_port     = 443
  ip_protocol   = "tcp"
  to_port       = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_traffic_ipv4" {
    security_group_id   = aws_security_group.allow_tls.id
    cidr_ipv4       = "0.0.0.0/0"
    ip_protocol     = "-1"

}
