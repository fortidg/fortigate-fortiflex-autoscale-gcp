resource "google_pubsub_topic" "log_topic" {
    name = "ascaler-log-topic"
}

resource "google_logging_project_sink" "ascale-sink" {
    name        = "autoscale-log-sink"
    destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.log_topic.name}"
    filter = <<EOF
    protoPayload.methodName="v1.compute.instances.insert" OR "v1.compute.instances.delete"
    protoPayload.requestMetadata.callerSuppliedUserAgent="GCE Managed Instance Group"
    protoPayload.response.@type="type.googleapis.com/operation"
    SEARCH("fortigateautoscale-instance-${random_string.random_name_post.result}")
    EOF
}