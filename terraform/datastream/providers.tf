terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.38.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.38.0"
    }
  }
  backend "gcs" {
    bucket = "_terraform"
    prefix = "staging-datastream"
  }
}

provider "google" {
  project = var.gcloud_project_id
  region  = var.gcloud_region
  zone    = var.gcloud_zone
}
provider "google-beta" {
  project = var.gcloud_project_id
  region  = var.gcloud_region
  zone    = var.gcloud_zone
}