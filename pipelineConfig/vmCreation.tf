provider "virtualbox" {
  required_providers = ">= 0.5.0"
}

resource "virtualbox_vm" "control_plane" {
  name     = "controlplane"
  image    = var.vm_image  # bento/ubuntu-22.04 after importing into VirtualBox
  cpus     = var.control_cpu
  memory   = var.control_memory
  network_adapter {
    type = "hostonly"
    host_interface = "vboxnet0"
    ipv4_address = var.control_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "echo '${var.ip_network}${var.ip_start} controlplane' | sudo tee -a /etc/hosts",
      "for i in $(seq 1 ${var.num_worker_nodes}); do echo '${var.ip_network}$((var.ip_start + i)) node0${i}' | sudo tee -a /etc/hosts; done"
    ]
  }

  provisioner "file" {
    source      = "./scripts/common.sh"
    destination = "/tmp/common.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/common.sh", "bash /tmp/common.sh"]
  }

  provisioner "file" {
    source      = "./scripts/master.sh"
    destination = "/tmp/master.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/master.sh", "bash /tmp/master.sh"]
  }
}

resource "virtualbox_vm" "worker_nodes" {
  count = var.num_worker_nodes

  name     = "node${count.index + 1}"
  image    = var.vm_image  # bento/ubuntu-22.04 after importing into VirtualBox
  cpus     = var.worker_cpu
  memory   = var.worker_memory
  network_adapter {
    type = "hostonly"
    host_interface = "vboxnet0"
    ipv4_address = "${var.ip_network}${var.ip_start + count.index + 1}"
  }

  provisioner "file" {
    source      = "./scripts/common.sh"
    destination = "/tmp/common.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/common.sh", "bash /tmp/common.sh"]
  }

  provisioner "file" {
    source      = "./scripts/node.sh"
    destination = "/tmp/node.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/node.sh", "bash /tmp/node.sh"]
  }

  provisioner "file" {
    source      = "./scripts/dashboard.sh"
    destination = "/tmp/dashboard.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ${count.index + 1} == ${var.num_worker_nodes} ] && [ ! -z '${var.dashboard_version}' ]; then bash /tmp/dashboard.sh; fi"
    ]
  }
}

# Variables
variable "control_ip" {
  description = "IP address for the control plane node"
  type        = string
  default     = "10.0.0.10"
}

variable "num_worker_nodes" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "ip_network" {
  description = "Network for IP allocation"
  type        = string
  default     = "10.0.0."
}

variable "ip_start" {
  description = "Starting IP segment"
  type        = number
  default     = 10
}

variable "control_cpu" {
  description = "CPU allocation for control plane"
  type        = number
  default     = 2
}

variable "control_memory" {
  description = "Memory allocation for control plane"
  type        = number
  default     = 4096
}

variable "worker_cpu" {
  description = "CPU allocation for worker nodes"
  type        = number
  default     = 1
}

variable "worker_memory" {
  description = "Memory allocation for worker nodes"
  type        = number
  default     = 2048
}

variable "vm_image" {
  description = "VM image to use for the nodes"
  type        = string
  default     = "ubuntu-22.04"  # Image imported into VirtualBox
}

variable "dashboard_version" {
  description = "Kubernetes Dashboard version"
  type        = string
  default     = "2.7.0"
}
