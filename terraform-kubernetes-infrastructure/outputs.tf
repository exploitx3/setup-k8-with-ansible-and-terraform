// Private IPs of Kube Master and Kube Nodes
output "kube_master_private_ip" {
  value = "${aws_instance.kube_master.private_ip}"
}

output "kube_node01_private_ip" {
  value = "${aws_instance.kube_node01.private_ip}"
}

output "kube_kube_node02_private_ip" {
  value = "${aws_instance.kube_node02.private_ip}"
}

// Public IPs of Kube Master and Kube Nodes
output "kube_master_public_ip" {
  value = "${aws_instance.kube_master.public_ip}"
}

output "kube_node01_public_ip" {
  value = "${aws_instance.kube_node01.public_ip}"
}

output "kube_kube_node02_public_ip" {
  value = "${aws_instance.kube_node02.public_ip}"
}

output "instance_user" {
  value = "${var.instance_user}"
}