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
