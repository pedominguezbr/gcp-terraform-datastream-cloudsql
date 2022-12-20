locals {
  ssh_keys = [
    {
      username   = "user"
      public_key = "~/.ssh/id_rsa.pub"
    },
  ]
}

resource "random_id" "id_name" {
  byte_length = 8
}

resource "google_datastream_private_connection" "vpc_" {
  project               = var.gcloud_project_id
  display_name          = "${var.gcloud_project_id}-pc-vpc-"
  location              = var.gcloud_region
  private_connection_id = "vpc--${random_id.id_name.id}"

  labels = {
    key = "vpc_"
  }

  vpc_peering_config {
    vpc    = data.google_compute_network.vpc.id #"projects/${var.gcloud_project_id}/global/networks/${data.google_compute_network.vpc.name}" 
    subnet = var.vpc_subnet_datastream_ip_cidr_range
  }

  depends_on = [
    random_id.id_name,
  ]
}

resource "google_datastream_connection_profile" "bd_site" {
  project               = var.gcloud_project_id
  display_name          = "${var.gcloud_project_id}-connection_profile-${var.gcloud_sql_database}"
  location              = var.gcloud_region
  connection_profile_id = "${var.gcloud_sql_database}-${random_id.id_name.id}"

  postgresql_profile {

    hostname = var.gcloud_sql_database_private_ip_address
    username = var.gcloud_sql_user_name
    password = var.gcloud_sql_user_password
    database = var.gcloud_sql_database
    # port = "5432"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.vpc_.id
  }

  depends_on = [
    google_datastream_private_connection.vpc_,
    google_compute_firewall.postgresql,
  ]
}

resource "google_compute_instance" "vm" {
  project      = var.gcloud_project_id
  name         = "${var.name_instance}-vm"
  machine_type = "e2-micro" #"e2-micro" "f1-micro"
  zone         = var.gcloud_zone

  boot_disk {
    initialize_params {
      # image = "busybox"
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network            = data.google_compute_network.vpc.self_link #module.vpc-module.network_self_link  data.google_compute_network.default_network.self_link
    subnetwork_project = var.gcloud_project_id                     #var.subnetwork_project
    subnetwork         = "${var.gcloud_project_id}-vpc-subnet-vm"  #"subnet-redis" #var.subnetwork
    access_config {}
  }

  metadata = {
    ssh-keys = join("\n", [for key in local.ssh_keys : "${key.username}:${file(key.public_key)}"])
  }

  tags = ["allow-web", "allow-ssh", "firewall-postgresql"]

  # metadata = {
  #   gce-container-declaration = module.gce-advanced-container.metadata_value
  # }

  # labels = {
  #   container-vm = module.gce-advanced-container.vm_container_label
  # }

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  provisioner "file" {
    source      = var.path_local_file_sa_pk
    destination = "/home/user/iam-acount-cloudsqlproxy1.json"

    connection {
      host        = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "user"
      private_key = file("~/.ssh/id_rsa")
      agent       = "false"
    }
  }

  depends_on = [
    google_compute_subnetwork.vpc_subnet_vm,
  ]
}


## https://cloud.google.com/datastream/docs/private-connectivity
########install config para proxy
# sudo apt install wget
# wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
# chmod +x cloud_sql_proxy
### copy key.json to vm path

# ./cloud_sql_proxy -instances=-staging:southamerica-west1:-staging-0ada6cc6=tcp:0.0.0.0:5432 -credential_file=./iam-acount-cloudsqlproxy.json -ip_address_types=PRIVATE &

