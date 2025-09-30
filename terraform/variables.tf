variable "realm_name" {
  description = "Nazwa realma"
  type        = string
  default     = "PMPK"
}

variable "default_password" {
  description = "Domyślne hasło dla użytkowników"
  type        = string
  default     = "admin"
}

variable "keycloak_admin_username" {
  description = "Admin Keycloak username"
  type        = string
  default     = "admin"
}

variable "keycloak_admin_password" {
  description = "Admin Keycloak password"
  type        = string
  default     = "admin"
}
