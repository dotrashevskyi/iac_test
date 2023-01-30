terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.46.0"
    }
  }
}

provider "google" {
  credentials = file("terraform-service-account-key.json")

  project = "internship-166-375809"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.test_network.name

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
  source_ranges = ["0.0.0.0/0"]
  priority = 65534
}

resource "google_compute_network" "test_network" {
  name = "test-network"
}

resource "google_compute_instance" "terraform_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  service_account {
    email  = "terraform-service-account@internship-166-375809.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}