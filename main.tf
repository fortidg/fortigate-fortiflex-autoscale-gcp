
provider "google" {
  credentials = file(var.auth_key)
  project     = var.project
  region      = var.region
  zone        = var.zone
}
provider "google-beta" {
  credentials = file(var.auth_key)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "random_string" "psk" {
  length           = 16
  special          = true
  override_special = "![]{}"
}
#Random 5 char string appended to the end of each name to avoid conflicts
resource "random_string" "random_name_post" {
  length           = 5
  special          = true
  override_special = ""
  min_lower        = 5
}

resource "random_string" "api_key" {
  length  = 30
  special = false
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [google_cloudfunctions2_function.flex_function]

  create_duration = "60s"
}