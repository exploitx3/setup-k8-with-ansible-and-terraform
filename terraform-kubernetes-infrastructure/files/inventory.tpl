---

all:
  hosts:
    kube-master:
      ansible_host: ${kube_master_public_ip}
      ansible_connection: ssh
      ansible_user: ${instance_user}
      ansible_ssh_private_key_file: ./data/Exp-US2.pem
      internal_ip: ${kube_master_private_ip}


    kube-node1: 
      ansible_host: ${kube_node01_public_ip}
      ansible_connection: ssh 
      ansible_user: ${instance_user}
      ansible_ssh_private_key_file: ./data/Exp-US2.pem
      internal_ip: ${kube_node01_private_ip}

    kube-node2: 
      ansible_host: ${kube_node02_public_ip}
      ansible_connection: ssh
      ansible_user: ${instance_user}
      ansible_ssh_private_key_file: ./data/Exp-US2.pem
      internal_ip: ${kube_node02_private_ip}

