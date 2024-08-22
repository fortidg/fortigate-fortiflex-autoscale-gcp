resource "google_cloudfunctions_function" "flex_function" {
  #If name is updated the Trigger URL will need to be updated too.
  name                  = "autoscaleflex-${random_string.random_name_post.result}"
  description           = "FortiFlex AutoScaling Function"
  runtime               = var.python_version
  available_memory_mb   = 1024
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.flex_archive.name
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.log_topic.name
  }
  timeout               = var.SCRIPT_TIMEOUT
  entry_point           = "ascale_pubsub"
  timeouts {
    create = "20m"
  }

  environment_variables = {
    BUCKET_NAME              = "${google_storage_bucket.bucket.name}",
    WORKSHOP_SERVICE_ACCOUNT = "${google_storage_bucket_object.servie_account.name}",
    REGION                   = "${var.region}",
    FLEXUSER                 = "${var.flexuser}",
    FLEXPASS                 = "${var.flexpass}",
    FUNCTION_NAME            = "autoscaleflex-${random_string.random_name_post.result}",
    COLLECTION_NAME          = "autoscaleflex-${random_string.random_name_post.result}",
    VM_API_KEY               = "${random_string.api_key.result}",
    FLEX_PROG_SERIAL         = "${var.flex_prog_serial}",
    FLEX_CONFIG_NAME         = "${var.flex_conf_name}",
  }
}