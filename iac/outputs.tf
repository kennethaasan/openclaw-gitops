output "server_public_ip" {
  value       = google_compute_address.static_ip.address
  description = "The public IP of the OpenClaw server"
}
