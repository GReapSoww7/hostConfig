control_ip        = "10.0.0.10"         # IP address of the control plane node
num_worker_nodes  = 2                   # Number of worker nodes
ip_network        = "10.0.0."           # Base network for IP allocation
ip_start          = 20                  # Starting IP for workers (incremental)
control_cpu       = 2                   # Number of CPUs for the control plane node
control_memory    = 4096                # Memory for the control plane node (in MB)
worker_cpu        = 1                   # Number of CPUs for worker nodes
worker_memory     = 2048                # Memory for worker nodes (in MB)
vm_image          = "bento/ubuntu-22.04" # Pre-imported VirtualBox image for VMs
dashboard_version = "2.7.0"             # Kubernetes Dashboard version

