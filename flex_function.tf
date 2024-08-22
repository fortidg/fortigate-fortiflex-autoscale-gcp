resource "google_cloudfunctions2_function" "flex_function" {
  name = "autoscaleflex-${random_string.random_name_post.result}"
  location = "${var.region}"
  description = "FortiFlex AutoScaling Function"

  build_config {
    runtime = var.python_version
    entry_point = "ascale_pubsub"  # Set the entry point to the function
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.flex_archive.name
      }
    }
  }

  service_config {
    max_instance_count  = 100
    available_memory    = "1Gi"
    timeout_seconds     = 60
    max_instance_request_concurrency = 1
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
      FLEX_CONFIG_NAME         = "${var.flex_conf_name}"
    }
    ingress_settings = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    service_account_email = var.service_account
  }

  event_trigger {
    trigger_region = "us-central1"
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.log_topic.name
    retry_policy = "RETRY_POLICY_DO_NOT_RETRY"
  }
}

# This is the old code that is being replaced by the new code above

# resource "google_cloudfunctions_function" "flex_function" {
#   #If name is updated the Trigger URL will need to be updated too.
#   name                  = "autoscaleflex-${random_string.random_name_post.result}"
#   description           = "FortiFlex AutoScaling Function"
#   runtime               = var.python_version
#   available_memory_mb   = 1024
#   source_archive_bucket = google_storage_bucket.bucket.name
#   source_archive_object = google_storage_bucket_object.flex_archive.name
#   event_trigger {
#     event_type = "google.pubsub.topic.publish"
#     resource   = google_pubsub_topic.log_topic.name
#   }
#   timeout               = var.SCRIPT_TIMEOUT
#   entry_point           = "ascale_pubsub"
#   timeouts {
#     create = "20m"
#   }

  # environment_variables = {
  #   BUCKET_NAME              = "${google_storage_bucket.bucket.name}",
  #   WORKSHOP_SERVICE_ACCOUNT = "${google_storage_bucket_object.servie_account.name}",
  #   REGION                   = "${var.region}",
  #   FLEXUSER                 = "${var.flexuser}",
  #   FLEXPASS                 = "${var.flexpass}",
  #   FUNCTION_NAME            = "autoscaleflex-${random_string.random_name_post.result}",
  #   COLLECTION_NAME          = "autoscaleflex-${random_string.random_name_post.result}",
  #   VM_API_KEY               = "${random_string.api_key.result}",
  #   FLEX_PROG_SERIAL         = "${var.flex_prog_serial}",
  #   FLEX_CONFIG_NAME         = "${var.flex_conf_name}",
  # }
# }