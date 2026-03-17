terraform {
  backend "gcs" {
    bucket = "lab-k8s-bootstrap-tfstate"
    prefix = "environments/develop/state"

  }
}