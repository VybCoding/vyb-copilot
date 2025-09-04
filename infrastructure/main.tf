terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.51.0"
    }
  }
}

variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for resources."
  type        = string
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Enable necessary Google Cloud APIs
resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore_api" {
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firebase_api" {
  service            = "firebase.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# Provision a Firebase project
resource "google_firebase_project" "default" {
  project = var.gcp_project_id
  depends_on = [
    google_project_service.firebase_api,
  ]
}

# Provision a Firestore Native database
resource "google_firestore_database" "database" {
  project     = var.gcp_project_id
  name        = "(default)"
  location_id = var.gcp_region
  type        = "FIRESTORE_NATIVE"
  depends_on = [
    google_project_service.firestore_api,
  ]
}

# Provision the api-gateway Cloud Run service
resource "google_cloud_run_v2_service" "api_gateway" {
  name     = "api-gateway"
  location = var.gcp_region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [
    google_project_service.run_api,
  ]
}

# Allow unauthenticated access to the api-gateway service
resource "google_cloud_run_v2_service_iam_binding" "api_gateway_public_access" {
  project  = google_cloud_run_v2_service.api_gateway.project
  location = google_cloud_run_v2_service.api_gateway.location
  name     = google_cloud_run_v2_service.api_gateway.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Provision the orchestrator Cloud Run service
resource "google_cloud_run_v2_service" "orchestrator" {
  name     = "orchestrator"
  location = var.gcp_region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [
    google_project_service.run_api,
  ]
}

# Allow unauthenticated access to the orchestrator service
resource "google_cloud_run_v2_service_iam_binding" "orchestrator_public_access" {
  project  = google_cloud_run_v2_service.orchestrator.project
  location = google_cloud_run_v2_service.orchestrator.location
  name     = google_cloud_run_v2_service.orchestrator.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
