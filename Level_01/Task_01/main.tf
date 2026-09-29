
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "tls_private_key" "test-key-2" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.test-key-2.private_key_pem
  filename        = "/home/bob/xfusion-kp.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "my-test-key" {
  key_name   = "xfusion-kp"
  public_key = tls_private_key.test-key-2.public_key_openssh
}

