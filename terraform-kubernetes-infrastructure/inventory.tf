
data "template_file" "inventory" {
    template = "${file("./files/inventory.tpl")}"

    vars = {
       instance_user           = "${var.instance_user}"
       kube_master_public_ip   = "${aws_instance.kube_master.public_ip}"
       kube_node01_public_ip   = "${aws_instance.kube_node01.public_ip}"
       kube_node02_public_ip   = "${aws_instance.kube_node02.public_ip}"
       kube_master_private_ip  = "${aws_instance.kube_master.private_ip}"
       kube_node01_private_ip  = "${aws_instance.kube_node01.private_ip}"
       kube_node02_private_ip  = "${aws_instance.kube_node02.private_ip}"
    }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "./terraform-inventory-output.yml"
}
