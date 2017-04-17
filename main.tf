variable "do_token" {
  description = "Digital Ocean API key"
}

variable "do_user" {
  description = "Droplet default user"
}

variable "do_ssh_key" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "private-vpn" {
  name   = "private-vpn"
  image  = "ubuntu-16-04-x64"
  region = "fra1"
  size   = "512mb"
  ssh_keys = ["${var.do_ssh_key}"]

  user_data = <<EOF
    users:
      - name: ${var.do_user}
        ssh-authorized-keys:
          ${file("~/.ssh/id_rsa.pub")}
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        groups: sudo
        shell: /bin/bash
  EOF

  provisioner "local-exec" {
    command = <<CMD
      echo '[server]\n${digitalocean_droplet.private-vpn.ipv4_address} ipsec={"local_ip":"${digitalocean_droplet.private-vpn.ipv4_address}"}' > ./provisioning/inventory
    CMD
  }

//  provisioner "local-exec" {
//    command = <<CMD
//      ansible-playbook --inventory-file=provisioning/inventory provisioning/playbook.yml --limit server
//    CMD
//  }

}
