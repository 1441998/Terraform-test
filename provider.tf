terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.59.0"
    }
  }
}

provider "ibm" {
  # CHANGE THIS: If you want to deploy to a different region than Tokyo
  region = "us-south" 
}
