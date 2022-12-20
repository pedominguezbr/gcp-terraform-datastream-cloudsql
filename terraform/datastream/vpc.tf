data "google_compute_network" "vpc" {
  name = "${var.gcloud_project_id}-vpc"
}

resource "google_compute_subnetwork" "vpc_subnet_vm" {
  name          = "${var.gcloud_project_id}-vpc-subnet-vm"
  ip_cidr_range = var.vpc_subnet_vm_cidr_range
  network       = data.google_compute_network.vpc.id
  # secondary_ip_range {
  #   ip_cidr_range = var.vpc_subnet_pods_cidr_range
  #   range_name    = "pods"
  # }
  # secondary_ip_range {
  #   ip_cidr_range = var.vpc_subnet_services_cidr_range
  #   range_name    = "services"
  # }  
}

# resource "google_compute_firewall" "allow_ssh" {
#   name        = "allow-ssh"
#   network     = data.google_compute_network.vpc.name
#   direction   = "INGRESS"
#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#   target_tags = ["ssh-enabled"]
# }

resource "google_compute_firewall" "postgresql" {
  name      = "${data.google_compute_network.vpc.name}-firewall-postgresql"
  network   = data.google_compute_network.vpc.self_link
  project   = var.gcloud_project_id
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  # target_tags = ["firewall-postgresql"]
  # source_ranges = ["${var.vpc_subnet_datastream_ip_cidr_range}","10.228.0.0/24"]  #10.228.0.0/24 rango 
  source_ranges = ["10.5.0.0/29"] # ["0.0.0.0/0"]
}


resource "google_compute_firewall" "ssh" {
  name          = "allow-ingress-tcp-22-shared-networking"
  network       = data.google_compute_network.vpc.self_link
  project       = var.gcloud_project_id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# resource "google_compute_firewall" "allow-db" {
#   name    = "allow-from-${var.cluster_name}-cluster-to-other-project-db"
#   network = "other-network"
#   allow {
#     protocol = "icmp"
#   }
#   allow {
#     protocol = "tcp"
#     ports    = ["5432"]
#   }
#   source_ranges = ["${var.subnet_cidr}", "${var.pod_range}"]
#   target_tags = ["network-tag-name"]
# }