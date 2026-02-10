variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-north2"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "europe-north2-a"
}

variable "machine_type" {
  description = "The instance type"
  type        = string
  default     = "e2-medium"
}

variable "image_tag" {
  description = "The docker image tag to deploy (Git SHA)"
  type        = string
  default     = "latest"
}

variable "telegram_bot_token" {
  description = "The Telegram bot token (BotFather)"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for aasan.dev"
  type        = string
}
