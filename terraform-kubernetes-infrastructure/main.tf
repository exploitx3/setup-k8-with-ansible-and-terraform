# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "k8_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "k8_internet_gateway" {
  vpc_id = "${aws_vpc.k8_vpc.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.k8_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.k8_internet_gateway.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "subnet_a" {
  vpc_id                  = "${aws_vpc.k8_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AZs["A"]}"
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = "${aws_vpc.k8_vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AZs["B"]}"
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = "${aws_vpc.k8_vpc.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AZs["C"]}"
}


# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "kube_access" {
  name        = "kube-access"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.k8_vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kube Dashboard
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // ingress {
  //   from_port   = 10248
  //   to_port     = 10256
  //   protocol    = "tcp"
  //   cidr_blocks = ["10.0.1.0/24"]
  //   description = "Kubelet API, kube-scheduler, kube-controller-manager"
  // }

  // ingress {
  //   from_port   = 6443
  //   to_port     = 6443
  //   protocol    = "tcp"
  //   cidr_blocks = ["10.0.1.0/24"]
  //   description = "Kubernetes API server"
  // }

  // ingress {
  //   from_port   = 2379
  //   to_port     = 2380
  //   protocol    = "tcp"
  //   cidr_blocks = ["10.0.1.0/24"]
  //   description = "etcd server client API"
  // }

  // ingress {
  //   from_port   = 30000
  //   to_port     = 32767
  //   protocol    = "tcp"
  //   cidr_blocks = ["10.0.1.0/24"]
  //   description = "NodePort Services"
  // }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    description = "Open all ports for the Kubernetes Cluster"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "kube_master" {
  instance_type = "t2.medium"
  availability_zone = "${var.AZs["A"]}"
  root_block_device {
    volume_size = 8
    delete_on_termination = true
    volume_type = "standard"
  }

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.kube_access.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.subnet_a.id}"
  tags = {
    Name = "kube-master"
  }
}


resource "aws_instance" "kube_node01" {
  instance_type = "t2.micro"
  availability_zone = "${var.AZs["B"]}"
  root_block_device {
    volume_size = 8
    delete_on_termination = true
    volume_type = "standard"
  }
  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.kube_access.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.subnet_b.id}"
  tags = {
    Name = "kube-node01"
  }
}


resource "aws_instance" "kube_node02" {
  instance_type = "t2.micro"
  availability_zone = "${var.AZs["C"]}"
  root_block_device {
    volume_size = 8
    delete_on_termination = true
    volume_type = "standard"
  }

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.kube_access.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.subnet_c.id}"
  tags = {
    Name = "kube-node02"
  }
}
