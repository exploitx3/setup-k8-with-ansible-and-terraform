variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
  default = "./files/Exp-US2.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "Exp-US2"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-02eac2c0129f6376b"
    us-west-1 = "ami-65e0e305"
    us-east-2 = "ami-e1496384"
  }
}

variable "AZs" {
    type    = "map"
    default = {
      "A" = "us-east-1a"
      "B" = "us-east-1b"
      "C" = "us-east-1c"
    }
}

variable "instance_user" {
  description = "The name of the username for all aws instances"
  default = "centos"
}
