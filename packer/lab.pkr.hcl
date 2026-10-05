packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

source "amazon-ebs" "lab" {
  region        = "us-east-1"
  instance_type = "t3.micro"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["099720109477"]
    most_recent = true
  }

  ssh_username = "ubuntu"

  ami_name = "lab-api-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.lab"]

  provisioner "shell" {
    script = "install.sh"
  }
}