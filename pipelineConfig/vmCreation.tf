provider "virtualbox" {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = ">= 0.5.0"
    }
  }
}

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
  default     = "bento/ubuntu-22.04"  # Import this image into VirtualBox
}

variable "dashboard_version" {
  description = "Kubernetes Dashboard version"
  type        = string
  default     = "2.7.0"
}

resource "virtualbox_vm" "control_plane" {
  name     = "controlplane"
  image    = var.vm_image
  cpus     = var.control_cpu
  memory   = var.control_memory
  network_adapter {
    type            = "hostonly"
    host_interface  = "vboxnet0"
    ipv4_address    = var.control_ip
  }

  provisioner "file" {
    source      = "./scripts/consolidatedPlaybook.yaml"
    destination = "/tmp/consolidatedPlaybook.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y ansible",
      "ansible-playbook /tmp/consolidatedPlaybook.yaml --extra-vars 'inventory_hostname=controlplane'",
    ]
  }
}

resource "virtualbox_vm" "worker_nodes" {
  count    = var.num_worker_nodes
  name     = "node${count.index + 1}"
  image    = var.vm_image
  cpus     = var.worker_cpu
  memory   = var.worker_memory
  network_adapter {
    type            = "hostonly"
    host_interface  = "vboxnet0"
    ipv4_address    = "${var.ip_network}${var.ip_start + count.index + 1}"
  }

  provisioner "file" {
    source      = "./scripts/consolidatedPlaybook.yaml"
    destination = "/tmp/consolidatedPlaybook.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y ansible",
      "ansible-playbook /tmp/consolidatedPlaybook.yaml --extra-vars 'inventory_hostname=node${count.index + 1}'",
    ]
  }
}

