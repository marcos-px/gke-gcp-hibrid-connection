terraform {
  backend "gcs" {
    bucket = "lab-k8s-bootstrap-tfstate"
    
    prefix = "bootstrap/state"
  }
}