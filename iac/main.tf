provider "google" {
  project = var.project_id
  region  = var.region
}

# 0. Enable APIs
resource "google_project_service" "artifactregistry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# 1. Artifact Registry (Stores your custom OpenClaw images)
resource "google_artifact_registry_repository" "openclaw_repo" {
  location      = var.region
  repository_id = "openclaw-repo"
  description   = "Docker repository for OpenClaw custom images"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifactregistry]
}

# 1. Persistent Disk (Stores Signal sessions and Agent memory)
resource "google_compute_disk" "openclaw_data" {
  name = "openclaw-data-disk"
  type = "pd-standard"
  zone = var.zone
  size = 10
}

# 2. Static IP (Required for consistent communication)
resource "google_compute_address" "static_ip" {
  name   = "openclaw-static-ip"
  region = var.region
}

# 3. The Spot VM
resource "google_compute_instance" "openclaw_server" {
  name         = "openclaw-agent"
  machine_type = var.machine_type
  zone         = var.zone
  depends_on   = [google_project_service.compute, google_compute_disk.openclaw_data]

  # Spot Instance Configuration (Keeping costs under $10)
  scheduling {
    preemptible                 = true
    automatic_restart           = false
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  # Attaching the Persistent Data Disk
  attached_disk {
    source      = google_compute_disk.openclaw_data.id
    device_name = "openclaw_data"
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    project_id          = var.project_id
    region              = var.region
    signal_phone_number = var.signal_phone_number
    image_tag           = var.image_tag
  })

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["openclaw-server"]
}

# 4. Firewall Rule (SSH and Web UI)
resource "google_compute_firewall" "allow_ssh_and_ui" {
  name    = "allow-ssh-and-ui"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "3000"]
  }

  source_ranges = ["0.0.0.0/0"] # In production, restrict this to your IP
  target_tags   = ["openclaw-server"]
}
