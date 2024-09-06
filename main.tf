# main.tf
# Configure the Google provider
provider "google" {
  region = "us-central1"
}

# Configure remote state
terraform {
  backend "gcs" {
    bucket = "tf-state-network-3-way-vpn-sandbox"
  }
}
