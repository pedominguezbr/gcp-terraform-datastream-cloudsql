variable "gcloud_project_id" {
  default = "staging"
}
variable "gcloud_region" {
  default = "west1"
}
variable "gcloud_zone" {
  default = "west1-c"
}

# Network.
variable "vpc_subnet_datastream_ip_cidr_range" {
  default = "10.1.0.0/29"
}

variable "vpc_subnet_vm_cidr_range" {
  default = "10.2.0.0/16"
}

# Database.
variable "gcloud_sql_database_private_ip_address" {
  default = "10.2.0.2" #ipo de la vm proxy db
}

variable "gcloud_sql_database" {
}
variable "gcloud_sql_user_name" { 
}
variable "gcloud_sql_user_password" {  
}


variable "name_instance" {
  type    = string
  default = "vm-cloud-proxy"
}

variable "client_email" {
  default = "deploy@staging.iam.gserviceaccount.com"
}
variable "path_local_file_sa_pk" {
  default = "../keys/iam-acount-cloudsqlproxy.json"
}