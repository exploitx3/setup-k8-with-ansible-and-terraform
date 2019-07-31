# setup-k8-with-ansible-and-terraform
Setup Kubernetes with Ansible and Terraform 

![alt text](https://raw.githubusercontent.com/exploitx3/setup-k8-with-ansible-and-terraform/master/terraform-kubernetes-infrastructure/docs/infrastructure-diagram.png)


Prerequisites:
    - Generate a public and private key-pairs using the command below the guide

    - Change `terraform-kubernetes-infrastructure/files/Exp-US2.pub` to your public key which you want to use as EC2 Key-Pair

    - In `terraform-kubernetes-infrastructure/variables.tf` change public_key_path default attribute to your public key path which you have added in the first step

    - Add your EC2 Key-Pair in `ansible-setup-kubernetes/data` folder

    - In `terraform-kubernetes-infrastructure/inventory.tf` change ansible_ssh_private_key_file for each host to the location of your private EC2 Key-Pair inside ansible's configuration folder(`ansible-setup-kubernetes`):
    For Example ./data/Private.pem


Setup Kubernetes Master and Nodes with Terraform:
    - Execute `terraform apply`
    - Copy the generated inventory `terraform-inventory-output.yml` into 
        `setup-kubernetes/inventory` folder
    
Setup Kubernetes Master and Nodes with Ansible:
    - Run setup_kubernetes.yml playbook against the "/inventory" machines to setup initial docker and kubernetes configurations: 
        `ansible-playbook -i ./inventory setup_kubernetes.yml`
    - Run setup_kube_master.yml to setup the kube-master machine: 
        `ansible-playbook -i ./inventory setup_kube_master.yml`
    - Run setup_kube_nodes.yml to setup the kube-node machines:
        `ansible-playbook -i ./inventory setup_kube_nodes.yml`
    - Login in to kube-master with: `ssh -i Private.pem centos@<kube_master_private_ip>`
        and execute `kubectl get nodes` to see all nodes in the cluster

Experianced problems after "setup_kubernetes.yml" sometimes EC2 machine receives kernel panic and does not want to boot after the playbook finishes. Know should be gone.

P.S: For testing ansible with docker - you have to expose the docker host 

// Import a EC2 Key-Pair
aws ec2 import-key-pair --key-name Exp-US2 --public-key-material file://./Exp-US2.pub

// Generate Public and Private Key-Pair
ssh-keygen -f ./key-pair -t ecdsa -b 521

// Generate Public Key from your Private Key
ssh-keygen -y -f ./Exp-US2.pem > ./Exp-US2.pub

// Remove the directory path from the shell terminal
export PS1="\u > "

// Ansible Ad-Hoc - Restart all machines in list
ansible -i hosts all -m command -a "reboot" -u centos --become

// Restart a specific instances
ansible -i hosts "kube-master, kube-node1, kube-node2" -m command -a "reboot" -u centos --become