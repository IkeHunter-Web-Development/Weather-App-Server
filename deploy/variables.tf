variable "prefix" {
  default = "wwa" # Weather Wise App
}

variable "project" {
  default = "weather-app"
}

variable "contact" {
  default = "web@ikehunter.dev"
}

variable "bastion_key_name" {
  default = "weather-app-bastion"
}
variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "Database password"
}

variable "ecr_image_server" {
  description = "ECR image for the server"
  default     = "178537739852.dkr.ecr.us-east-1.amazonaws.com/weather-app-server:latest"
}

variable "ecr_image_proxy" {
  description = "ECR image for the proxy"
  default     = "178537739852.dkr.ecr.us-east-1.amazonaws.com/weather-app-proxy:latest"
}

variable "ecr_image_frontend" {
  description = "ECR image for the frontend"
  default     = "178537739852.dkr.ecr.us-east-1.amazonaws.com/weather-app-frontend"
}
# variable "ecr_image_frontend_tagged" {
#   default = {
#     dev = var.ecr_image_frontend + ":dev"
#     staging = var.ecr_image_frontend + ":staging"
#     production = var.ecr_image_frontend + ":latest"
#   }
# }

variable "weather_api_key" {
  description = "Open Weather Maps API Key."
}

variable "google_maps_key" {
  description = "Google Maps API Key."
}

variable "django_cors_allowed_origins" {
  default = "https://weatherwise.cloud"
}

variable "django_secret_key" {
  description = "Secret key for django config."
}

variable "dns_zone_name" {
  description = "Custom domain name."
  default     = "weatherwise.cloud"
}

variable "server_subdomain" {
  description = "Subdomain per environment."
  type        = map(string)

  default = {
    production = "api."
    staging    = "staging.api."
    dev        = "dev.api."
  }
}

variable "frontend_subdomain" {
  description = "Subdomain per environment."
  type        = map(string)

  default = {
    production = ""
    staging    = "staging."
    dev        = "dev."
  }
}
