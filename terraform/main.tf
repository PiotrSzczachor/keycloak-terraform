terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.0.0"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.keycloak_admin_username
  password  = var.keycloak_admin_password
  url       = "http://keycloak:8080"
  realm     = "master"
}

# Realm
resource "keycloak_realm" "pmpk" {
  realm                     = var.realm_name
  enabled                   = true
  registration_allowed      = true
  login_with_email_allowed  = true
  reset_password_allowed    = true
}

# Grupy
resource "keycloak_group" "app_admin" {
  realm_id = keycloak_realm.pmpk.id
  name     = "app-admin"
}

resource "keycloak_group" "app_user" {
  realm_id = keycloak_realm.pmpk.id
  name     = "app-user"
}

# Role
resource "keycloak_role" "app_access" {
  realm_id    = keycloak_realm.pmpk.id
  name        = "app-access"
  description = "Access to PMP app"
}

resource "keycloak_group_roles" "app_admin_roles" {
  realm_id = keycloak_realm.pmpk.id
  group_id = keycloak_group.app_admin.id
  role_ids = [keycloak_role.app_access.id]
}

resource "keycloak_group_roles" "app_user_roles" {
  realm_id = keycloak_realm.pmpk.id
  group_id = keycloak_group.app_user.id
  role_ids = [keycloak_role.app_access.id]
}

# Użytkownicy
locals {
  users = [
    "piotr@pmpk.pl",
    "patryk@pmpk.pl",
    "mikolaj@pmpk.pl",
    "kuba@pmpk.pl"
  ]
}

resource "keycloak_user" "users" {
  for_each       = toset(local.users)
  realm_id       = keycloak_realm.pmpk.id
  username       = each.value
  enabled        = true
  email          = each.value
  email_verified = true

  initial_password {
    value     = var.default_password
    temporary = false
  }
}

resource "keycloak_group_memberships" "users_to_admin" {
  realm_id = keycloak_realm.pmpk.id
  group_id = keycloak_group.app_admin.id
  members  = [for u in keycloak_user.users : u.username]
}

# Klient
resource "keycloak_openid_client" "pmpk_app" {
  realm_id                     = keycloak_realm.pmpk.id
  client_id                    = "pmpk-app"
  name                         = "PMPK Application"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  client_secret = "cc581549c765443fb35831c4283f61c5"

  valid_redirect_uris = ["*"]
}

# Client Scope
resource "keycloak_openid_client_scope" "pmpk_scope" {
  realm_id = keycloak_realm.pmpk.id
  name     = "pmpk.OpenIdConnect"
}

resource "keycloak_openid_client_default_scopes" "client_scopes" {
  realm_id  = keycloak_realm.pmpk.id
  client_id = keycloak_openid_client.pmpk_app.id
  default_scopes = [
    "pmpk.OpenIdConnect",
    "profile",
    "email"
  ]
}

# Mapp’ery
resource "keycloak_openid_group_membership_protocol_mapper" "groups_as_roles" {
  realm_id   = keycloak_realm.pmpk.id
  client_id  = keycloak_openid_client.pmpk_app.id
  name       = "groups-as-roles"
  claim_name = "roles"
  full_path  = false
}

resource "keycloak_openid_user_realm_role_protocol_mapper" "roles_claims" {
  realm_id    = keycloak_realm.pmpk.id
  client_id   = keycloak_openid_client.pmpk_app.id
  name        = "roles-to-claims"
  claim_name  = "claims"
  multivalued = true
}
