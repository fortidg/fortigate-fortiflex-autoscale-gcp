# No Capital Letters allowed in the bucket name
resource "google_storage_bucket" "bucket" {

  name     = "fortigate-autoscale-${random_string.random_name_post.result}"
  location = var.region
}

resource "google_storage_bucket_object" "archive" {
  name   = var.source_code_name
  bucket = google_storage_bucket.bucket.name
  source = var.source_code_location
}




# Use rendered template file and upload as 'baseconfig'
resource "google_storage_bucket_object" "baseconfig" {
  name       = "baseconfig"
  bucket     = google_storage_bucket.bucket.name
  source     = "./assets/configset/baseconfig.rendered"
  depends_on = [local_file.setup_secondary_ip_render]
}
data "google_iam_policy" "editor" {
  binding {
    role = "roles/editor"
    members = [
      "serviceAccount:${var.service_account}",

    ]
  }
}

####FortiFlex Resources####
resource "google_storage_bucket_object" "flex_archive" {
  name   = var.flex_code_name
  bucket = google_storage_bucket.bucket.name
  source = var.flex_code_location
}

resource "google_storage_bucket_object" "servie_account" {
  name   = var.account_json_name
  bucket = google_storage_bucket.bucket.name
  source = var.account_json_location
}